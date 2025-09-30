import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/checkout_view_model.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';

class PinViewModel extends GetxController {
  final authVM = Get.find<AuthViewModel>();
  final discoverVM = Get.find<DiscoverViewModel>();
  CheckoutViewModel? get checkoutVm => Get.isRegistered<CheckoutViewModel>()
      ? Get.find<CheckoutViewModel>()
      : null;
  Car? car;
  final pin1 = TextEditingController();
  final pin2 = TextEditingController();
  final pin3 = TextEditingController();
  final pin4 = TextEditingController();

  final isForVerification = false.obs;
  final isPinComplete = false.obs;
  final RxInt _failedAttempts = 0.obs;

  final UserSource userSource = UserSource();
  final isChangingPin = false.obs;
  final RxString _newPin = ''.obs;

  bool _disposed = false;

  @override
  void onInit() {
    final args = Get.arguments;
    if (args != null) {
      isForVerification.value = args['isForVerification'] ?? false;
      isChangingPin.value = args['isChangingPin'] ?? false;
    }
    super.onInit();
  }

  @override
  void onClose() {
    _disposed = true;

    pin1.dispose();
    pin2.dispose();
    pin3.dispose();
    pin4.dispose();

    super.onClose();
  }

  void handlePinInput(dynamic input) {
    if (input is int) {
      if (pin1.text.isEmpty) {
        pin1.text = input.toString();
      } else if (pin2.text.isEmpty) {
        pin2.text = input.toString();
      } else if (pin3.text.isEmpty) {
        pin3.text = input.toString();
      } else if (pin4.text.isEmpty) {
        pin4.text = input.toString();
        isPinComplete.value = true;
      }
    } else if (input is IconData) {
      if (pin4.text.isNotEmpty) {
        pin4.clear();
        isPinComplete.value = false;
      } else if (pin3.text.isNotEmpty) {
        pin3.clear();
      } else if (pin2.text.isNotEmpty) {
        pin2.clear();
      } else if (pin1.text.isNotEmpty) {
        pin1.clear();
      }
    }
  }

  String get getPin {
    return pin1.text + pin2.text + pin3.text + pin4.text;
  }

  void clearPin() {
    if (_disposed) return;

    for (final ctrl in [pin1, pin2, pin3, pin4]) {
      if (ctrl.text.isNotEmpty) {
        ctrl.clear();
      }
    }
  }

  Future<void> setPin(String pin) async {
    try {
      final userId = authVM.account.value?.uid;
      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }

      if (_newPin.value.isEmpty) {
        _newPin.value = pin;
        clearPin();
        Message.success('Masukkan PIN sekali lagi untuk konfirmasi.');
        return;
      } else if (_newPin.value != pin) {
        clearPin();
        _newPin.value = '';
        Message.error('Konfirmasi PIN tidak cocok. Coba lagi');
        return;
      }

      if (isChangingPin.value) {
        await userSource.updatePin(userId, pin);
        Message.success('Pin berhasil diubah');
        Get.until((route) => route.settings.name == '/discover');
        discoverVM.setFragmentIndex(3);
      } else {
        await userSource.createPin(userId, pin);
        if (checkoutVm != null) {
          checkoutVm!.hasPin.value = true;
          Get.back();
        } else {
          Message.success('PIN berhasil dibuat');
          Get.until((route) => route.settings.name == '/discover');
          discoverVM.setFragmentIndex(4);
        }
      }
    } catch (e) {
      log('Gagal memproses PIN: $e');
      Message.error('Gagal memproses PIN: ${e.toString()}');
      clearPin();
      _newPin.value = '';
    }
  }

  Future<void> verifyOldPin() async {
    try {
      final enteredPin = getPin;
      final isPinValid = await userSource.verifyPin(
        authVM.account.value!.uid,
        enteredPin,
      );

      if (isPinValid) {
        Message.success(
          'PIN lama berhasil diverifikasi. Masukkan PIN baru Anda.',
        );
        clearPin();
        Get.toNamed('/pin-setup', arguments: {'isChangingPin': true});
      } else {
        _failedAttempts.value++;
        clearPin();
        if (_failedAttempts.value >= 3) {
          Message.error(
            'Anda telah 3 kali salah memasukkan PIN. Silakan coba lagi nanti.',
          );
          await Future.delayed(const Duration(seconds: 2));
          Get.until((route) => route.settings.name == '/discover');
          discoverVM.setFragmentIndex(3);
        } else {
          Message.error(
            'PIN yang Anda masukkan salah. Anda masih memiliki ${3 - _failedAttempts.value} kali percobaan lagi.',
          );
        }
      }
    } catch (e) {
      log('Gagal memverifikasi PIN lama: $e');
      Message.error('Terjadi kesalahan');
      clearPin();
    }
  }

  Future<void> finishedPayment() async {
    try {
      final enteredPin = getPin;
      final isPinValid = await userSource.verifyPin(
        authVM.account.value!.uid,
        enteredPin,
      );
      if (!isPinValid) {
        throw Exception('PIN yang Anda masukkan salah');
      }
      final safeUid = authVM.account.value!.uid.substring(0, 5);
      final resi = "ORDER-$safeUid-${DateTime.now().millisecondsSinceEpoch}";
      await checkoutVm?.processPayment(resi, 'DompetKu', 'Sudah Dibayar');
    } catch (e) {
      log('Error dari PinViewModel: $e');
      clearPin();
      if (e.toString().contains('PIN yang Anda masukkan salah')) {
        _failedAttempts.value++;

        if (_failedAttempts.value >= 3) {
          Message.error(
            'Anda telah 3 kali salah memasukkan PIN. Silakan coba lagi nanti.',
          );
          await Future.delayed(const Duration(seconds: 2));
          Get.until((route) => route.settings.name == '/discover');
          discoverVM.setFragmentIndex(0);
        } else {
          Message.error(
            'PIN yang Anda masukkan salah. Anda masih memiliki ${3 - _failedAttempts.value} kali percobaan lagi.',
          );
        }
      } else {
        Message.error('Pembayaran gagal: ${e.toString()}');
      }
    }
  }
}
