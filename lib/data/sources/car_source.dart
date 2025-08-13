import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_car_app/data/models/car.dart';

class CarSource {
  static Future<List<Car>?> fetchFeatureCars() async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('Cars')
          .where('ratingProduct', isGreaterThan: 4.5)
          .orderBy('purchasedProduct', descending: true);
      final queryDocs = await ref.get();
      final getCars = queryDocs.docs
          .map((doc) => Car.fromJson(doc.data()))
          .toList();
      return getCars;
    } catch (e) {
      log('Gagal fetching Feature Cars: $e');
      return null;
    }
  }

  static Future<List<Car>?> fetchNewestCars() async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('Cars')
          .orderBy('releaseProduct', descending: true);
      final queryDocs = await ref.get();

      final getCars = queryDocs.docs.map((doc) {
        log('Processing document ID: ${doc.id}');
        try {
          return Car.fromJson(doc.data());
        } catch (e) {
          log('Error dalam memparsing dokumen dengan ID ${doc.id}: $e');
          throw Exception('Gagal memparsing data mobil');
        }
      }).toList();

      return getCars;
    } catch (e) {
      log('Gagal fetching Newest Cars: $e');
      return null;
    }
  }

  static Future<Car?> fetchCar(String id) async {
    try {
      final ref = FirebaseFirestore.instance.collection('Cars').doc(id);
      final doc = await ref.get();
      if (doc.exists) {
        final getCar = Car.fromJson(doc.data()!);
        return getCar;
      } else {
        return null;
      }
    } catch (e) {
      log('Gagal fetching Car: $e');
      return null;
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
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  static Future<void> updateImageProduct(String id, String url) async {
    try {
      await FirebaseFirestore.instance.collection('Cars').doc(id).update({
        'imageProduct': url,
      });
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
    } catch (e) {
      log('Gagal memperbarui purchasedProduct: $e');
      rethrow;
    }
  }
}
