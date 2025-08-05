import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/sources/auth_source.dart';

class RegisterViewmodel extends GetxController {
  final AuthSource _authSource = AuthSource();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  final nameError = RxnString();
  final emailError = RxnString();
  final passwordError = RxnString();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isNameTouched = false.obs;
  final isEmailTouched = false.obs;
  final isPasswordTouched = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void validateInputs() {
    if (isNameTouched.value) {
      nameError.value = nameController.text.isEmpty
          ? 'Nama lengkap tidak boleh kosong'
          : null;
    }

    if (isEmailTouched.value) {
      emailError.value = emailController.text.isEmpty
          ? 'Alamat email tidak boleh kosong'
          : !emailController.text.contains('@')
          ? 'Alamat email tidak valid'
          : null;
    }

    if (isPasswordTouched.value) {
      passwordError.value = passwordController.text.isEmpty
          ? 'Kata sandi tidak boleh kosong'
          : passwordController.text.length < 8
          ? 'Kata sandi minimal 8 karakter'
          : null;
    }
  }

  void handleRegister(BuildContext context) {
    isNameTouched.value = true;
    isEmailTouched.value = true;
    isPasswordTouched.value = true;

    validateInputs();

    if (nameError.value != null ||
        emailError.value != null ||
        passwordError.value != null) {
      Message.neutral('Semua field harus diisi');
      if (nameError.value != null) {
        FocusScope.of(context).requestFocus(nameFocus);
      } else if (emailError.value != null) {
        FocusScope.of(context).requestFocus(emailFocus);
      } else if (passwordError.value != null) {
        FocusScope.of(context).requestFocus(passwordFocus);
      }
      return;
    }

    createNewAccount();
  }

  Future<void> createNewAccount() async {
    validateInputs();
    if (nameError.value != null ||
        emailError.value != null ||
        passwordError.value != null) {
      return;
    }
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Message.neutral('Semua field harus diisi');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authSource.register(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.isSuccess) {
        Get.snackbar('Berhasil', 'Akun Berhasil Dibuat');
        Get.toNamed('/login');
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
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    isNameTouched.value = false;
    isEmailTouched.value = false;
    isPasswordTouched.value = false;
    isPasswordVisible.value = false;
    isLoading.value = false;
    nameError.value = null;
    emailError.value = null;
    passwordError.value = null;
  }
}
