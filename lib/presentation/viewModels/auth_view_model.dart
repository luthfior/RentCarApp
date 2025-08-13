import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:d_session/d_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends GetxController {
  Rx<Account?> account = Rx<Account?>(null);

  @override
  void onInit() {
    super.onInit();
    checkSession();
  }

  Future<void> checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      var user = await DSession.getUser();
      final prefs = await SharedPreferences.getInstance();
      bool isFirstTime = prefs.getBool('is_first_time') ?? true;

      if (user != null) {
        await loadUser();
        Get.offAllNamed('/discover');
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

  Future<void> loadUser() async {
    final user = await DSession.getUser();
    if (user != null) {
      account.value = Account.fromJson(Map.from(user));
    } else {
      account.value = null;
    }
  }

  Future<void> logout() async {
    await DSession.removeUser().then((removed) {
      if (!removed) {
        return;
      } else {
        Get.offAllNamed('/auth', arguments: 'login');
      }
    });
  }
}
