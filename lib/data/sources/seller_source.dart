import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';

class SellerSource {
  final firestore = FirebaseFirestore.instance;
  final cloudinary = CloudinaryPublic(
    'dodjmyloc',
    'user_profiles',
    cache: true,
  );

  Future<void> createProduct(Car car, String userId, String userRole) async {
    try {
      final docRef = firestore.collection('Cars').doc(car.id);
      await docRef.set(car.toJson());
      final String userCollection = userRole == 'admin' ? 'Admin' : 'Users';
      await firestore
          .collection(userCollection)
          .doc(userId)
          .collection('myProducts')
          .doc(car.id)
          .set({'productId': car.id, 'createdAt': Timestamp.now()});
      log('Produk dengan ID ${car.id} berhasil dibuat oleh $userRole');
      Message.success('Produk Berhasil di Upload');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal membuat produk: $e');
      rethrow;
    }
  }

  Stream<List<Car>> fetchMyProductsStream(String userId, String userRole) {
    try {
      final userCollection = userRole == 'admin' ? 'Admin' : 'Users';
      final fetchMyProduct = firestore
          .collection(userCollection)
          .doc(userId)
          .collection('myProducts')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
            final List<Car> myProducts = [];
            final productFeatures = snapshot.docs.map((doc) async {
              try {
                final productId = doc.data()['productId'];
                final carDoc = await firestore
                    .collection('Cars')
                    .doc(productId)
                    .get();
                if (carDoc.exists) {
                  final carData = Car.fromJson(carDoc.data()!);
                  myProducts.add(carData);
                }
              } catch (e) {
                log('Gagal memproses produk dengan ID ${doc.id}: $e');
              }
            });
            await Future.wait(productFeatures);
            return myProducts;
          });
      return fetchMyProduct;
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal fetch produk penyedia: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Car car) async {
    try {
      await firestore.collection('Cars').doc(car.id).update(car.toJson());
      log('Produk dengan ID ${car.id} berhasil di Perbarui');
      Message.success('Produk Berhasil diPerbarui');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memperbarui produk: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final productDocRef = firestore.collection('Cars').doc(productId);
      final productDoc = await productDocRef.get();

      if (!productDoc.exists) {
        log('Produk dengan ID $productId tidak ditemukan.');
        Message.error('Produk tidak ditemukan.');
        return;
      }

      final productData = productDoc.data()!;
      final String ownerId = productData['ownerId'];
      final String ownerRole = productData['ownerType'];
      final batch = firestore.batch();

      batch.delete(productDocRef);
      log('Menyiapkan penghapusan produk utama: /Cars/$productId');

      final String ownerCollection = (ownerRole == 'admin') ? 'Admin' : 'Users';
      final myProductRef = firestore
          .collection(ownerCollection)
          .doc(ownerId)
          .collection('myProducts')
          .doc(productId);
      batch.delete(myProductRef);
      log(
        'Menyiapkan penghapusan referensi produk dari: /$ownerCollection/$ownerId/myProducts/$productId',
      );

      final usersSnapshot = await firestore.collection('Users').get();
      for (var userDoc in usersSnapshot.docs) {
        final favProductRef = firestore
            .collection('Users')
            .doc(userDoc.id)
            .collection('favProducts')
            .doc(productId);

        batch.delete(favProductRef);
        log(
          'Menyiapkan penghapusan referensi favorit dari: /Users/${userDoc.id}/favProducts/$productId',
        );
      }

      await batch.commit();

      log(
        'Produk dengan ID $productId berhasil dihapus sepenuhnya dari collection Cars, myProducts, dan juga favProducts.',
      );
      Message.success('Produk Berhasil Dihapus');
    } on FirebaseException catch (e) {
      log('Firebase Error saat menghapus produk: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal menghapus produk: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final orderRef = firestore.collection('Orders').doc(orderId);
      await orderRef.update({'orderStatus': newStatus});
      log(
        'Status pesanan dengan ID $orderId berhasil diperbarui menjadi $newStatus',
      );
      Message.success('Status pesanan berhasil diperbarui.');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memperbarui status pesanan: $e');
      rethrow;
    }
  }

  Future<void> markOrderAsSuccess(
    String orderId,
    String userId,
    String userRole,
    num totalPrice,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final String userCollection = userRole == 'admin' ? 'Admin' : 'Users';

    await firestore.collection(userCollection).doc(userId).update({
      'income': FieldValue.increment(totalPrice),
    });
  }
}
