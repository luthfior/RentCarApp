import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/sources/auth_source.dart';

class LoginViewModel extends GetxController {
  final AuthSource _authSource = AuthSource();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final emailError = RxnString();
  final passwordError = RxnString();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isEmailTouched = false.obs;
  final isPasswordTouched = false.obs;

  @override
  void onInit() {
    super.onInit();
    resetForm();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void validateInputs() {
    if (isEmailTouched.value) {
      emailError.value = emailController.text.isEmpty
          ? 'Alamat email tidak boleh kosong'
          : null;
    }
    if (isPasswordTouched.value) {
      passwordError.value = passwordController.text.isEmpty
          ? 'Kata sandi tidak boleh kosong'
          : null;
    }
  }

  void handleLogin(BuildContext context) {
    isEmailTouched.value = true;
    isPasswordTouched.value = true;
    validateInputs();

    if (emailError.value != null || passwordError.value != null) {
      Message.neutral('Semua field harus diisi');
      if (emailError.value != null) {
        FocusScope.of(context).requestFocus(emailFocus);
      } else if (passwordError.value != null) {
        FocusScope.of(context).requestFocus(passwordFocus);
      }
      return;
    }

    login();
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Message.neutral('Semua field harus diisi');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authSource.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.isSuccess) {
        resetForm();
        Get.offAllNamed('/discover', arguments: {'fragmentIndex': 0});
      } else {
        Message.error(response.error.toString());
      }
    } catch (e) {
      Message.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    emailController.clear();
    passwordController.clear();
    emailError.value = null;
    passwordError.value = null;
    isPasswordVisible.value = false;
    isLoading.value = false;
    isEmailTouched.value = false;
    isPasswordTouched.value = false;
  }
}
