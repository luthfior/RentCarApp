import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:d_session/d_session.dart';
import 'package:rent_car_app/data/sources/auth_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends GetxController {
  Rx<Account?> account = Rx<Account?>(null);
  final authSource = AuthSource();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> checkSession() async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      var user = await DSession.getUser();
      final prefs = await SharedPreferences.getInstance();
      bool isFirstTime = prefs.getBool('is_first_time') ?? true;

      if (user != null) {
        final success = await loadUser();
        if (success) {
          Get.offAllNamed('/discover', arguments: {'fragmentIndex': 0});
        } else {
          await DSession.removeUser();
          Get.offAllNamed('/auth');
        }
      } else if (isFirstTime) {
        await prefs.setBool("is_first_time", false);
        Get.offAllNamed('/onboarding');
      } else {
        Get.offAllNamed('/auth');
      }
    } catch (e) {
      Message.error('Gagal memeriksa sesi: $e');
      Get.offAllNamed('/auth');
    }
  }

  Future<bool> loadUser() async {
    final user = await DSession.getUser();
    if (user != null) {
      final userId = user['uid'] as String;
      try {
        final userDocSnapshot = await firestore
            .collection('Users')
            .doc(userId)
            .get();
        if (userDocSnapshot.exists) {
          final updatedAccount = Account.fromJson(userDocSnapshot.data()!);
          account.value = updatedAccount;
          await DSession.setUser(updatedAccount.toMapForSession());
          log('Data pengguna dari koleksi Users berhasil dimuat');
          return true;
        }

        final adminDocSnapshot = await firestore
            .collection('Admin')
            .doc(userId)
            .get();
        if (adminDocSnapshot.exists) {
          final updatedAccount = Account.fromJson(adminDocSnapshot.data()!);
          account.value = updatedAccount;
          await DSession.setUser(updatedAccount.toMapForSession());
          log('Data pengguna dari koleksi Admin berhasil dimuat');
          return true;
        }

        account.value = null;
        log('Data pengguna tidak ditemukan di Users maupun Admin');
        return false;
      } catch (e) {
        log('Gagal memuat data pengguna dari Firebase: $e');
        account.value = null;
        return false;
      }
    } else {
      account.value = null;
      return false;
    }
  }

  Future<void> logout() async {
    final user = await DSession.getUser();
    if (user != null) {
      final userRole = user['role'];
      if (userRole != 'admin') {
        authSource.removeFcmToken(user['uid'], isAdmin: false);
      } else {
        authSource.removeFcmToken(user['uid'], isAdmin: true);
      }
      await DSession.removeUser().then((removed) {
        if (removed) {
          Get.offAllNamed('/auth', arguments: 'login');
        }
      });
    }
  }
}
