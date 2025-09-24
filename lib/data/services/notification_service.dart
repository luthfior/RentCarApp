import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_car_app/data/models/app_notification.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    required String? referenceId,
  }) async {
    try {
      final notifId = const Uuid().v4();
      final notif = AppNotification(
        id: notifId,
        userId: userId,
        title: title,
        body: body,
        type: type,
        referenceId: referenceId,
        isRead: false,
        createdAt: Timestamp.now(),
      );

      await _firestore
          .collection('Notifications')
          .doc(notifId)
          .set(notif.toJson());
    } on FirebaseException catch (e) {
      log('Gagal menambahkan notifikasi: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal menambahkan notifikasi: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> addNotificationForRole({
    required String role,
    required String title,
    required String body,
    required String type,
    String? referenceId,
  }) async {
    final collectionName = role == "admin" ? "Admin" : "Users";
    final snap = await _firestore
        .collection(collectionName)
        .where("role", isEqualTo: role)
        .get();

    for (var doc in snap.docs) {
      final notifId = const Uuid().v4();
      final notif = AppNotification(
        id: notifId,
        userId: doc.id,
        title: title,
        body: body,
        type: type,
        referenceId: referenceId,
        isRead: false,
        createdAt: Timestamp.now(),
      );
      try {
        await _firestore
            .collection('Notifications')
            .doc(notifId)
            .set(notif.toJson());
      } catch (e) {
        log('Gagal menambahkan notifikasi: ${e.toString()}');
        rethrow;
      }
    }
  }

  static Future<void> deleteNotification(String notifId) async {
    try {
      await _firestore.collection('Notifications').doc(notifId).delete();
    } on FirebaseException catch (e) {
      log('Gagal menambahkan notifikasi: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal menambahkan notifikasi: ${e.toString()}');
      rethrow;
    }
  }
}
