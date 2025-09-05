import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/sources/auth_source.dart';

class RegisterViewModel extends GetxController {
  final AuthSource _authSource = AuthSource();

  final fullNameController = TextEditingController();
  final storeNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameFocus = FocusNode();
  final storeNameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final fullNameError = RxnString();
  final storeNameError = RxnString();
  final emailError = RxnString();
  final passwordError = RxnString();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isFullNameTouched = false.obs;
  final isStoreNameTouched = false.obs;
  final isEmailTouched = false.obs;
  final isPasswordTouched = false.obs;
  final selectedRole = 'customer'.obs;
  final storeNameSuggestion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    resetForm();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    storeNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    fullNameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void validateInputs() {
    if (isFullNameTouched.value) {
      fullNameError.value = fullNameController.text.isEmpty
          ? 'Nama lengkap tidak boleh kosong'
          : null;
    }

    if (isStoreNameTouched.value) {
      storeNameError.value = storeNameController.text.isEmpty
          ? 'Nama Toko tidak boleh kosong'
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

  void handleRegister(
    BuildContext context, {
    required VoidCallback onRegisterSuccess,
  }) {
    isFullNameTouched.value = true;
    isStoreNameTouched.value = true;
    isEmailTouched.value = true;
    isPasswordTouched.value = true;

    validateInputs();

    if (fullNameError.value != null ||
        storeNameError.value != null ||
        emailError.value != null ||
        passwordError.value != null) {
      Message.error('Semua field harus diisi');
      if (fullNameError.value != null) {
        FocusScope.of(context).requestFocus(fullNameFocus);
      } else if (storeNameError.value != null) {
        FocusScope.of(context).requestFocus(storeNameFocus);
      } else if (emailError.value != null) {
        FocusScope.of(context).requestFocus(emailFocus);
      } else if (passwordError.value != null) {
        FocusScope.of(context).requestFocus(passwordFocus);
      }
      return;
    }

    createNewAccount(onRegisterSuccess);
  }

  Future<void> createNewAccount(VoidCallback onRegisterSuccess) async {
    validateInputs();
    if (fullNameError.value != null ||
        storeNameError.value != null ||
        emailError.value != null ||
        passwordError.value != null) {
      return;
    }
    if (fullNameController.text.isEmpty ||
        storeNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Message.error('Semua field harus diisi');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authSource.register(
        fullName: fullNameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: selectedRole.value,
        storeName: selectedRole.value == 'seller'
            ? storeNameController.text
            : null,
      );

      if (response.isSuccess) {
        Message.success('Berhasil membuat Akun');
        resetForm();
        onRegisterSuccess();
      } else {
        if (selectedRole.value == 'seller' &&
            response.error?.contains('Nama Toko sudah digunakan') == true) {
          final suggestion = [
            '${storeNameController.text} Store',
            '${storeNameController.text} Official',
            '${storeNameController.text} ${Random().nextInt(999)}',
          ];
          storeNameSuggestion.value =
              "Nama Toko telah digunakan. Coba: ${suggestion.join(", ")}";
        }
        Message.error(
          response.error ?? 'Gagal melakukan proses Daftar. Silahkan coba lagi',
        );
      }
    } catch (e) {
      Message.error('Gagal melakukan proses Daftar. Silahkan coba lagi');
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    fullNameController.clear();
    storeNameController.clear();
    emailController.clear();
    passwordController.clear();
    isFullNameTouched.value = false;
    isStoreNameTouched.value = false;
    isEmailTouched.value = false;
    isPasswordTouched.value = false;
    isPasswordVisible.value = false;
    isLoading.value = false;
    fullNameError.value = null;
    storeNameError.value = null;
    emailError.value = null;
    passwordError.value = null;
    selectedRole.value = 'customer';
  }
}
