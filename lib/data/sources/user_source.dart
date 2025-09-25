import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/booked_car.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/models/order_detail.dart';
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
        Message.error('Gagal menggugah Gambar');
      }
      await userRef.update({'photoUrl': imageUrl});
      if (userRole == 'admin' || userRole == 'seller') {
        await _syncCarsOwnerFields(userId, {'ownerPhotoUrl': imageUrl});
      }
      log('Gambar profil berhasil diperbarui: $imageUrl');
    } on CloudinaryException catch (e) {
      log('Cloudinary Error: ${e.message}');
      Message.error('Gagal menggugah Gambar');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal mengunggah gambar.');
      rethrow;
    }
  }

  Future<void> updateFullName(
    String userId,
    String userRole,
    String newName,
  ) async {
    try {
      final String userCollection = userRole == 'admin' ? 'Admin' : 'Users';
      final userRef = firestore.collection(userCollection).doc(userId);
      await userRef.update({'name': newName});
      if (userRole == 'admin' || userRole == 'seller') {
        await _syncCarsOwnerFields(userId, {'ownerFullName': newName});
      }
      log('Nama berhasil diperbarui menjadi: $newName');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memperbarui nama: $e');
      rethrow;
    }
  }

  Future<void> updatePhoneNumber(
    String userId,
    String userRole,
    String phoneNumber,
  ) async {
    try {
      final String userCollection = userRole == 'admin' ? 'Admin' : 'Users';
      final userRef = firestore.collection(userCollection).doc(userId);
      await userRef.update({'phoneNumber': phoneNumber});
      if (userRole == 'admin' || userRole == 'seller') {
        await _syncCarsOwnerFields(userId, {'ownerPhoneNumber': phoneNumber});
      }
      log('No.Telp berhasil diperbarui menjadi: $phoneNumber');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memperbarui No.telp: $e');
      rethrow;
    }
  }

  Future<void> updateUserAddress(
    String userId,
    String userRole,
    String fullAddress,
    String street,
    String village,
    String district,
    String city,
    String province,
    double latLocation,
    double longLocation,
  ) async {
    try {
      final String userCollection = userRole == 'admin' ? 'Admin' : 'Users';
      final userRef = firestore.collection(userCollection).doc(userId);
      await userRef.update({
        'fullAddress': fullAddress,
        'street': street,
        'village': village,
        'district': district,
        'city': city,
        'province': province,
        'latLocation': latLocation,
        'longLocation': longLocation,
      });
      if (userRole == 'admin' || userRole == 'seller') {
        await _syncCarsOwnerFields(userId, {
          'fullAddress': fullAddress,
          'street': street,
          'village': village,
          'district': district,
          'city': city,
          'province': province,
          'latLocation': latLocation,
          'longLocation': longLocation,
        });
      }
      log(
        'Alamat berhasil diperbarui menjadi, alamat lengkap: $fullAddress, jalan: $street, kelurahan: $village, kecamatan: $district, kota: $city, provinsi: $province, latLocation: $latLocation, longLocation: $longLocation',
      );
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
          'productId': car.id,
          'timeStamp': Timestamp.now(),
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

  Future<void> createOrder(
    String resi,
    String customerId,
    String sellerId,
    String customerFullname,
    String sellerStoreName,
    String? customerAddress,
    String? sellerAddress,
    String sellerRole,
    String paymentMethod,
    String paymentStatus,
    OrderDetail orderDetail,
  ) async {
    try {
      final productId = orderDetail.car.id;
      // ignore: unnecessary_null_comparison
      if (productId == null || productId.isEmpty) {
        throw Exception("Detail pesanan tidak memiliki 'productId'.");
      }
      final existingOrderQuery = await firestore
          .collection('Orders')
          .where('customerId', isEqualTo: customerId)
          .where('resi', isEqualTo: resi)
          .where('orderStatus', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingOrderQuery.docs.isNotEmpty) {
        log(
          'GAGAL: Pelanggan $customerId sudah pernah memesan produk $productId.',
        );
        throw Exception(
          'Anda sudah memesan produk ini. Periksa pada halaman Pesanan Anda',
        );
      }

      log('Pengecekan berhasil. Membuat pesanan baru...');

      const String initialOrderStatus = 'pending';
      final orderDocRef = await firestore.collection('Orders').add({
        'resi': resi,
        'customerId': customerId,
        'sellerId': sellerId,
        'customerFullname': customerFullname.isNotEmpty ? customerFullname : '',
        'sellerStoreName': sellerStoreName.isNotEmpty ? sellerStoreName : '',
        'customerAddress': customerAddress ?? '',
        'sellerAddress': sellerAddress ?? '',
        'orderDetail': orderDetail.toJson(),
        'orderDate': Timestamp.now(),
        'orderStatus': initialOrderStatus,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
      });
      log(
        'Pesanan berhasil dibuat di koleksi Orders dengan ID: ${orderDocRef.id}',
      );

      final String ownerCollection = sellerRole == 'admin' ? 'Admin' : 'Users';
      await firestore
          .collection(ownerCollection)
          .doc(sellerId)
          .collection('myOrders')
          .doc(orderDocRef.id)
          .set({
            'orderId': orderDocRef.id,
            'orderStatus': initialOrderStatus,
            'orderDate': Timestamp.now(),
          });
      log('Referensi pesanan berhasil ditambahkan ke riwayat pesanan penjual.');

      await firestore
          .collection('Users')
          .doc(customerId)
          .collection('myOrders')
          .doc(orderDocRef.id)
          .set({
            'orderId': orderDocRef.id,
            'orderStatus': initialOrderStatus,
            'orderDate': Timestamp.now(),
          });
      log('Referensi pesanan berhasil ditambahkan ke riwayat pesanan pembeli.');
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

    return ordersQuery.snapshots().asyncMap((orderSnapshot) async {
      if (orderSnapshot.docs.isEmpty) {
        return [];
      }

      final carFutures = orderSnapshot.docs.map<Future<BookedCar?>>((
        orderDoc,
      ) async {
        try {
          final orderData = Orders.fromJson(orderDoc.data(), orderDoc.id);

          final productId = orderData.orderDetail.car.id;

          // ignore: unnecessary_null_comparison
          if (productId == null || productId.toString().isEmpty) {
            log(
              'Warning: Pesanan dengan ID ${orderDoc.id} tidak memiliki productId.',
            );
            return null;
          }

          final carDoc = await firestore
              .collection('Cars')
              .doc(productId)
              .get();

          if (carDoc.exists) {
            final carData = Car.fromJson(carDoc.data()!);
            return BookedCar(order: orderData, car: carData);
          } else {
            log(
              'Warning: Mobil dengan ID $productId untuk pesanan ${orderDoc.id} tidak ditemukan.',
            );
            return null;
          }
        } catch (e) {
          log('Gagal memproses pesanan dengan ID ${orderDoc.id}: $e');
          return null;
        }
      }).toList();

      final List<BookedCar?> bookedCarResults = await Future.wait(carFutures);

      return bookedCarResults.whereType<BookedCar>().toList();
    });
  }

  Stream<Orders> fetchMyOrderStream(String orderId) {
    return firestore.collection('Orders').doc(orderId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return Orders.fromJson(snapshot.data()!, snapshot.id);
      } else {
        return Orders.empty;
      }
    });
  }

  Future<void> _syncCarsOwnerFields(
    String ownerId,
    Map<String, dynamic> updatedFields,
  ) async {
    final carsQuery = await firestore
        .collection('Cars')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    for (var doc in carsQuery.docs) {
      await doc.reference.update(updatedFields);
    }
    log("Berhasil update field owner ke Cars untuk ownerId=$ownerId");
  }
}
