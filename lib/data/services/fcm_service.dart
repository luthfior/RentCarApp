import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';

class FCMService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> setupFCMHandlers() async {
    await _fcm.requestPermission();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          _handleMessageClick({"route": response.payload!});
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _showLocalNotification(notification, message.data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageClick(message.data);
    });

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageClick(initialMessage.data);
    }
  }

  static void _showLocalNotification(
    RemoteNotification notif,
    Map<String, dynamic> data,
  ) {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.max,
      priority: Priority.high,
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    _flutterLocalNotificationsPlugin.show(
      notif.hashCode,
      notif.title,
      notif.body,
      platformDetails,
      payload: data['route'] ?? '',
    );
  }

  static void _handleMessageClick(Map<String, dynamic> data) {
    log("User klik notifikasi dengan data: $data");
    if (data['type'] == 'chat') {
      final discoverVM = Get.find<DiscoverViewModel>();
      if (Get.find<AuthViewModel>().account.value?.role == 'admin') {
        Get.until((route) => route.settings.name == '/discover');
        discoverVM.setFragmentIndex(3);
      } else {
        Get.until((route) => route.settings.name == '/discover');
        discoverVM.setFragmentIndex(2);
      }
    } else if (data['type'] == 'order') {
      final discoverVM = Get.find<DiscoverViewModel>();
      if (Get.find<AuthViewModel>().account.value?.role == 'admin') {
        Get.until((route) => route.settings.name == '/discover');
        discoverVM.setFragmentIndex(2);
      } else {
        Get.until((route) => route.settings.name == '/discover');
        discoverVM.setFragmentIndex(1);
      }
    }
  }
}
