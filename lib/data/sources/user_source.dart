import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/models/booked_car.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/models/orders.dart';

class UserSource {
  final firestore = FirebaseFirestore.instance;
  final cloudinary = CloudinaryPublic(
    'dodjmyloc',
    'user_profiles',
    cache: true,
  );

  String hasPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> createPin(String userId, String pin) async {
    final userRef = firestore.collection('Users').doc(userId);
    final hashedPin = hasPin(pin);

    try {
      await userRef.update({'pin': hashedPin});
      log('PIN berhasil dibuat dan disimpan.');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal membuat PIN: $e');
      rethrow;
    }
  }

  Future<bool> verifyPin(String userId, String enteredPin) async {
    try {
      final userRef = firestore.collection('Users').doc(userId);
      final userSnapshot = await userRef.get();

      if (!userSnapshot.exists || userSnapshot.data()?['pin'] == null) {
        log('Error: PIN belum dibuat atau pengguna tidak ditemukan.');
        return false;
      }

      final storedHashedPin = userSnapshot.data()?['pin'];
      final enteredHashedPin = hasPin(enteredPin);
      return storedHashedPin == enteredHashedPin;
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      log('Gagal memverifikasi PIN: $e');
      return false;
    }
  }

  Future<void> updatePin(String userId, String newPin) async {
    final userRef = firestore.collection('Users').doc(userId);
    final hashedPin = hasPin(newPin);

    try {
      await userRef.update({'pin': hashedPin});
      log('PIN berhasil diperbarui');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memperbarui PIN: $e');
      rethrow;
    }
  }

  Future<void> updateUserBalance(String userId, double amount) async {
    try {
      final userRef = firestore.collection('Users').doc(userId);
      await firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw Exception('User tidak ditemukan');
        }
        final currentBalance = (userSnapshot.data()?['balance'] as num)
            .toDouble();
        final newBalance = currentBalance - amount;
        if (newBalance < 0) {
          throw Exception('Saldo tidak mencukupi');
        }
        transaction.update(userRef, {'balance': newBalance});
      });
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memperbarui saldo: $e');
      rethrow;
    }
  }

  Future<void> updateProfilePicture(
    String userId,
    String userRole,
    XFile file,
  ) async {
    final String userCollection = userRole == 'admin' ? 'Admin' : 'Users';
    final userRef = firestore.collection(userCollection).doc(userId);
    String? imageUrl;
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      imageUrl = response.secureUrl;
      // ignore: unnecessary_null_comparison
      if (imageUrl == null) {
        log('Gagal mengunggah gambar ke Cloudinary.');
        throw Exception('Gagal mengunggah gambar');
      }
      await userRef.update({'photoUrl': imageUrl});
      log('Gambar profil berhasil diperbarui: $imageUrl');
    } on CloudinaryException catch (e) {
      log('Cloudinary Error: ${e.message}');
      throw Exception('Gagal mengunggah gambar');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal mengunggah gambar.');
      rethrow;
    }
  }

  Future<void> updateUserName(
    String userId,
    String userRole,
    String newName,
  ) async {
    try {
      final String userCollection = userRole == 'admin' ? 'Admin' : 'Users';
      final userRef = firestore.collection(userCollection).doc(userId);
      await userRef.update({'name': newName});
      log('Nama berhasil diperbarui menjadi: $newName');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memperbarui nama: $e');
      rethrow;
    }
  }

  Future<void> updateUserAddress(
    String userId,
    String userRole,
    String newAddress,
  ) async {
    try {
      final String userCollection = userRole == 'admin' ? 'Admin' : 'Users';
      final userRef = firestore.collection(userCollection).doc(userId);
      await userRef.update({'address': newAddress});
      log('Alamat berhasil diperbarui menjadi: $newAddress');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memperbarui Alamat: $e');
      rethrow;
    }
  }

  Future<void> toggleFavoriteProduct(String userId, Car car) async {
    try {
      final favProductRef = firestore
          .collection('Users')
          .doc(userId)
          .collection('favProducts')
          .doc(car.id);

      final docSnapshot = await favProductRef.get();

      if (docSnapshot.exists) {
        await favProductRef.delete();
        log('Produk dengan ID ${car.id} berhasil dihapus dari favorit');
      } else {
        await favProductRef.set({
          ...car.toJson(),
          'timeStamp': FieldValue.serverTimestamp(),
        });
        log('Produk dengan ID ${car.id} berhasil ditambahkan ke favorit');
      }
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal toggle produk favorit: $e');
      rethrow;
    }
  }

  Future<void> deleteFavoriteProduct(String userId, String productId) async {
    try {
      final favProductRef = firestore
          .collection('Users')
          .doc(userId)
          .collection('favProducts')
          .doc(productId);

      await favProductRef.delete();
      log('Produk dengan ID $productId berhasil dihapus dari Favorit');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal menghapus produk dari Favorit: $e');
      rethrow;
    }
  }

  Future<bool> isProductFavorited(String userId, String productId) async {
    try {
      final favProductRef = firestore
          .collection('Users')
          .doc(userId)
          .collection('favProducts')
          .doc(productId);

      final docSnapshot = await favProductRef.get();
      return docSnapshot.exists;
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      log('Gagal memeriksa status favorit: $e');
      return false;
    }
  }

  Future<void> createOrder(Account account, Car car) async {
    try {
      final orderDocRef = await firestore.collection('Orders').add({
        'customerId': account.uid,
        'sellerId': car.ownerId,
        'productId': car.id,
        'productName': car.nameProduct,
        'productPrice': car.priceProduct,
        'orderDate': FieldValue.serverTimestamp(),
        'orderStatus': 'pending',
        'customerAddress': account.address,
        'sellerAddress': car.address,
      });
      log(
        'Pesanan berhasil dibuat di koleksi Orders dengan ID: ${orderDocRef.id}',
      );

      final String ownerCollection = car.ownerType == 'admin'
          ? 'Admin'
          : 'Users';
      await firestore
          .collection(ownerCollection)
          .doc(car.ownerId)
          .collection('myOrders')
          .doc(orderDocRef.id)
          .set({
            'orderId': orderDocRef.id,
            'orderDate': FieldValue.serverTimestamp(),
          });
      log('Referensi pesanan berhasil ditambahkan ke riwayat pesanan penyedia');

      final bookedProductUserRef = firestore
          .collection('Users')
          .doc(account.uid)
          .collection('myOrders')
          .doc(orderDocRef.id);

      final docSnapshot = await bookedProductUserRef.get();
      if (!docSnapshot.exists) {
        await bookedProductUserRef.set({
          'orderId': orderDocRef.id,
          'orderDate': FieldValue.serverTimestamp(),
        });
        log(
          'Produk dengan ID ${car.id} berhasil di booking oleh pengguna ${account.uid}',
        );
      } else {
        log(
          'Produk dengan ID ${orderDocRef.id} sudah ada dalam daftar pesanan.',
        );
      }
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memproses pemesanan: $e');
      rethrow;
    }
  }

  Future<void> addBalance(String userId, double amount) async {
    try {
      final userRef = firestore.collection('Users').doc(userId);
      await firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw Exception('User tidak ditemukan');
        }
        final currentBalance = (userSnapshot.data()?['balance'] as num)
            .toDouble();
        final newBalance = currentBalance + amount;
        transaction.update(userRef, {'balance': newBalance});
      });
      log('Saldo User ID $userId berhasil ditambahkan: $amount');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal menambahkan saldo: $e');
      rethrow;
    }
  }

  Stream<List<BookedCar>> fetchBookedCarStream(String userId, bool isSeller) {
    Query<Map<String, dynamic>> ordersQuery = firestore.collection('Orders');

    if (isSeller) {
      ordersQuery = ordersQuery.where('sellerId', isEqualTo: userId);
    } else {
      ordersQuery = ordersQuery.where('customerId', isEqualTo: userId);
    }

    ordersQuery = ordersQuery.orderBy('orderDate', descending: true);

    return ordersQuery.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return [];
      }

      final List<BookedCar> updateMyOrders = [];
      final carFutures = snapshot.docs.map((doc) async {
        try {
          final orderData = Orders.fromJson(doc.data(), doc.id);
          final carDoc = await firestore
              .collection('Cars')
              .doc(orderData.productId)
              .get();

          if (carDoc.exists) {
            final carData = Car.fromJson(carDoc.data()!);
            updateMyOrders.add(BookedCar(order: orderData, car: carData));
          }
        } catch (e) {
          log('Gagal memproses pesanan dengan ID ${doc.id}: $e');
        }
      });

      await Future.wait(carFutures);
      return updateMyOrders;
    });
  }
}
