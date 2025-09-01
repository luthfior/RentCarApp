import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_car_app/data/models/car.dart';

class CarSource {
  static Stream<List<Car>> fetchFeaturedCarsStream() {
    try {
      final fetchFeaturedCars = FirebaseFirestore.instance
          .collection('Cars')
          .where('ratingProduct', isGreaterThan: 4.5)
          .orderBy('purchasedProduct', descending: true)
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
          .orderBy('releaseProduct', descending: true)
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

  static Future<List<String>> fetchCategories() async {
    try {
      final ref = FirebaseFirestore.instance.collection('Cars');
      final queryDocs = await ref.get();
      final categories = queryDocs.docs
          .map((doc) => doc['categoryProduct'] as String?)
          .where((e) => e != null)
          .toSet()
          .toList();
      return categories.cast<String>();
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal ambil kategori mobil $e');
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

  static Future<void> updateImageProduct(String id, String url) async {
    try {
      await FirebaseFirestore.instance.collection('Cars').doc(id).update({
        'imageProduct': url,
      });
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memperbarui imageProduct: $e');
      rethrow;
    }
  }

  static Future<void> updatePurchasedProduct(String id) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('Cars').doc(id);
      await docRef.update({'purchasedProduct': FieldValue.increment(1)});
      log('Berhasil memperbarui purchasedProduct untuk mobil dengan ID: $id');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal memperbarui purchasedProduct: $e');
      rethrow;
    }
  }
}
