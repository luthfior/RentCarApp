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
    String? referenceId,
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
