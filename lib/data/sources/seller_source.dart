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
          .set({
            'productId': car.id,
            'createdAt': FieldValue.serverTimestamp(),
          });
      log('Produk dengan ID ${car.id} berhasil dibuat oleh $userRole');
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
      log('Gagal fetch produk toko: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Car car) async {
    try {
      await firestore.collection('Cars').doc(car.id).update(car.toJson());
      log('Produk dengan ID ${car.id} berhasil diperbarui');
      Message.success('Produk Berhasil diPerbarui');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memperbarui produk: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(
    String productId,
    String userId,
    String userRole,
  ) async {
    try {
      await firestore.collection('Cars').doc(productId).delete();
      final String userCollection = userRole == 'admin' ? 'Admin' : 'Users';
      await firestore
          .collection(userCollection)
          .doc(userId)
          .collection('myProducts')
          .doc(productId)
          .delete();
      log('Produk dengan ID $productId berhasil dihapus');
      Message.success('Produk Berhasil Dihapus');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
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
    num productPrice,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final String userCollection = userRole == 'admin' ? 'Admin' : 'Users';

    await firestore.collection(userCollection).doc(userId).update({
      'income': FieldValue.increment(productPrice),
    });
  }
}
