import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_car_app/data/models/car.dart';

class CarSource {
  static Future<List<Car>?> fetchFeatureCars() async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('Cars')
          .where('ratingProduct', isGreaterThan: 4.5)
          .orderBy('ratingProduct', descending: true);
      final queryDocs = await ref.get();
      final getCars = queryDocs.docs
          .map((doc) => Car.fromJson(doc.data()))
          .toList();
      return getCars;
    } catch (e) {
      log(e.toString());
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
          log('Error parsing document with ID ${doc.id}: $e');
          throw Exception('Failed to parse car data');
        }
      }).toList();

      return getCars;
    } catch (e) {
      log('Error fetching newest cars: $e');
      return null;
    }
  }

  static Future<Car?> fetchCar(String productId) async {
    try {
      final ref = FirebaseFirestore.instance.collection('Cars').doc(productId);
      final doc = await ref.get();
      if (doc.exists) {
        final getCar = Car.fromJson(doc.data()!);
        return getCar;
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString());
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
      log('Failed to update imageProduct: $e');
    }
  }
}
