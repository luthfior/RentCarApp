import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/data/models/app_notification.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class NotificationViewModel extends GetxController {
  final authVM = Get.find<AuthViewModel>();
  final notifications = <AppNotification>[].obs;

  final _firestore = FirebaseFirestore.instance;

  @override
  void onReady() {
    super.onReady();
    if (authVM.account.value != null) {
      listenNotifications(authVM.account.value!.uid);
    }
  }

  void listenNotifications(String userId) {
    _firestore
        .collection('Notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.docs.isEmpty) {
              notifications.clear();
            } else {
              notifications.value = snapshot.docs.map((doc) {
                final data = doc.data();
                return AppNotification.fromJson({...data, 'id': doc.id});
              }).toList();
            }
          },
          onError: (e) {
            log("Error listening to notifications: $e");
          },
        );
  }

  Future<void> markAsRead(String id) async {
    await _firestore.collection('Notifications').doc(id).update({
      'isRead': true,
    });
  }

  Future<void> clearAll() async {
    for (final notif in notifications) {
      await _firestore.collection('Notifications').doc(notif.id).delete();
    }
    notifications.clear();
  }

  bool get hasUnread => notifications.any((n) => !n.isRead);
}
