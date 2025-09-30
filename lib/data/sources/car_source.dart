import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_car_app/data/models/car.dart';

class CarSource {
  static Stream<List<Car>> fetchFeaturedCarsStream() {
    try {
      final fetchFeaturedCars = FirebaseFirestore.instance
          .collection('Cars')
          .where('ratingAverage', isGreaterThan: 4.5)
          .orderBy('purchasedProduct', descending: true)
          .orderBy('nameProduct')
          .snapshots()
          .map((querySnapshot) {
            return querySnapshot.docs
                .map((doc) => Car.fromJson(doc.data()))
                .toList();
          });
      return fetchFeaturedCars;
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal ambil mobil terbaru $e');
      rethrow;
    }
  }

  static Stream<List<Car>> fetchNewestCarsStream() {
    try {
      final fetchNewCars = FirebaseFirestore.instance
          .collection('Cars')
          .orderBy('createdAt', descending: true)
          .orderBy('nameProduct')
          .snapshots()
          .map((querySnapshot) {
            return querySnapshot.docs
                .map((doc) => Car.fromJson(doc.data()))
                .toList();
          });
      return fetchNewCars;
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal ambil mobil terbaru $e');
      rethrow;
    }
  }

  static Future<List<String>> fetchBrands() async {
    try {
      final ref = FirebaseFirestore.instance.collection('Cars');
      final queryDocs = await ref.get();
      final categories = queryDocs.docs
          .map((doc) => doc['brandProduct'] as String?)
          .where((e) => e != null)
          .toSet()
          .toList();
      return categories.cast<String>();
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal ambil brand produk $e');
      return [];
    }
  }

  static Future<List<String>> fetchUniqueCategories() async {
    try {
      final ref = FirebaseFirestore.instance.collection('Cars');
      final queryDocs = await ref.get();
      final categories = queryDocs.docs
          .map((doc) => doc['categoryProduct'] as String?)
          .where((e) => e != null && e.isNotEmpty)
          .toSet()
          .toList();
      return categories.cast<String>();
    } on FirebaseException catch (e) {
      log('Firebase Error saat fetch kategori unik: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal ambil kategori unik produk: $e');
      return [];
    }
  }

  static Future<Car?> fetchDetailCar(String id) async {
    try {
      final ref = FirebaseFirestore.instance.collection('Cars').doc(id);
      final doc = await ref.get();
      if (doc.exists) {
        final getCar = Car.fromJson(doc.data()!);
        return getCar;
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal fetching Car: $e');
      return null;
    }
  }

  static Future<void> updateProductAfterPurchase(String id) async {
    final docRef = FirebaseFirestore.instance.collection('Cars').doc(id);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception("Produk tidak ditemukan!");
        }

        final oldRatingAverage = snapshot.data()?['ratingAverage'] as num? ?? 0;
        final oldReviewCount = snapshot.data()?['reviewCount'] as num? ?? 0;

        const newRatingFromPurchase = 5;
        final newReviewCount = oldReviewCount + 1;
        final newRatingAverage =
            ((oldRatingAverage * oldReviewCount) + newRatingFromPurchase) /
            newReviewCount;

        transaction.update(docRef, {
          'purchasedProduct': FieldValue.increment(1),
          'reviewCount': FieldValue.increment(1),
          'ratingAverage': newRatingAverage,
        });
      });

      log('Berhasil memperbarui data produk setelah pembelian untuk ID: $id');
    } on FirebaseException catch (e) {
      log('Firebase Error saat update produk: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memperbarui data produk setelah pembelian: $e');
      rethrow;
    }
  }
}
