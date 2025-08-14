import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/checkout_view_model.dart';
import 'package:rent_car_app/data/sources/user_source.dart';

class PinViewModel extends GetxController {
  final checkoutVm = Get.find<CheckoutViewModel>();
  final browseVm = Get.find<BrowseViewModel>();
  final AuthViewModel authVM = Get.find<AuthViewModel>();

  late final Car car = Get.arguments as Car;

  final pin1 = TextEditingController();
  final pin2 = TextEditingController();
  final pin3 = TextEditingController();
  final pin4 = TextEditingController();

  final isPinComplete = false.obs;
  final RxInt _failedAttempts = 0.obs;

  final UserSource userSource = UserSource();

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
    pin1.clear();
    pin2.clear();
    pin3.clear();
    pin4.clear();
    isPinComplete.value = false;
  }

  Future<void> setPin(String pin) async {
    try {
      final userId = authVM.account.value?.uid;
      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }
      await userSource.createPin(userId, pin);
      checkoutVm.hasPin.value = true;
      Message.success('PIN berhasil dibuat');
      await Future.delayed(const Duration(seconds: 2));
      Get.offNamed(
        '/checkout',
        arguments: {
          'car': checkoutVm.car,
          'nameOrder': checkoutVm.nameOrder,
          'startDate': checkoutVm.startDate,
          'endDate': checkoutVm.endDate,
          'agency': checkoutVm.agency,
          'insurance': checkoutVm.insurance,
          'withDriver': checkoutVm.withDriver,
        },
      );
    } catch (e) {
      log('Gagal membuat PIN: $e');
      Message.error('Gagal membuat PIN: ${e.toString()}');
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

      await checkoutVm.processPayment(enteredPin);
      await authVM.loadUser();
      Message.success('Pembayaran berhasil!');
      Get.offAllNamed('/complete', arguments: car);
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
          Get.offAllNamed('/discover');
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

  @override
  void onClose() {
    pin1.dispose();
    pin2.dispose();
    pin3.dispose();
    pin4.dispose();
    super.onClose();
  }
}
