import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/checkout_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';

class PinPage extends StatelessWidget {
  PinPage({super.key, required this.car});
  final Car car;

  final pin1 = TextEditingController();
  final pin2 = TextEditingController();
  final pin3 = TextEditingController();
  final pin4 = TextEditingController();

  final isPinComplete = false.obs;

  void isPinTap(dynamic input) {
    if (input is int) {
      if (pin1.text == '') {
        pin1.text = input.toString();
        return;
      }
      if (pin2.text == '') {
        pin2.text = input.toString();
        return;
      }
      if (pin3.text == '') {
        pin3.text = input.toString();
        return;
      }
      if (pin4.text == '') {
        pin4.text = input.toString();
        isPinComplete.value = true;
        return;
      }
    } else if (input is IconData) {
      if (pin4.text.isNotEmpty) {
        pin4.clear();
        isPinComplete.value = false;
        return;
      }
      if (pin3.text.isNotEmpty) {
        pin3.clear();
        return;
      }
      if (pin2.text.isNotEmpty) {
        pin2.clear();
        return;
      }
      if (pin1.text.isNotEmpty) {
        pin1.clear();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final browseVM = Get.find<BrowseViewModel>();
    final checkoutVM = Get.find<CheckoutViewModel>();

    void processPaymentWithPin() async {
      try {
        final enteredPin = pin1.text + pin2.text + pin3.text + pin4.text;
        await checkoutVM.processPayment(enteredPin);
        browseVM.car.value = car;
        Get.offAllNamed('/complete', arguments: car);
      } catch (e) {
        log('Error dari PinPage: $e');
        pin1.clear();
        pin2.clear();
        pin3.clear();
        pin4.clear();
        isPinComplete.value = false;
        Message.error(e.toString());
      }
    }

    return Scaffold(
      body: Column(
        children: [
          Gap(20 + MediaQuery.of(context).padding.top),
          CustomHeader(title: 'Booking'),
          const Gap(100),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _inputPin(pin1),
                  const Gap(30),
                  _inputPin(pin2),
                  const Gap(30),
                  _inputPin(pin3),
                  const Gap(30),
                  _inputPin(pin4),
                ],
              ),
              const Gap(30),
              _buildNumberInput(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              return ButtonPrimary(
                onTap: (!isPinComplete.value)
                    ? null
                    : () async {
                        processPaymentWithPin();
                      },
                text: 'Konfirmasi Pembayaran',
              );
            }),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _inputPin(TextEditingController editingController) {
    InputBorder inputBorder = const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xff070623), width: 3),
    );
    return SizedBox(
      width: 30,
      child: TextField(
        controller: editingController,
        obscureText: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          enabled: false,
          focusedBorder: inputBorder,
          enabledBorder: inputBorder,
          border: inputBorder,
          disabledBorder: inputBorder,
        ),
        style: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: const Color(0xff070623),
        ),
      ),
    );
  }

  Widget _buildNumberInput() {
    return SizedBox(
      width: 300,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.25,
        mainAxisSpacing: 25,
        crossAxisSpacing: 25,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          _buildNumberButton(1),
          _buildNumberButton(2),
          _buildNumberButton(3),
          _buildNumberButton(4),
          _buildNumberButton(5),
          _buildNumberButton(6),
          _buildNumberButton(7),
          _buildNumberButton(8),
          _buildNumberButton(9),
          _buildNumberButton(null),
          _buildNumberButton(0),
          _buildNumberButton(Icons.backspace),
        ],
      ),
    );
  }

  Widget _buildNumberButton(dynamic input) {
    if (input == null) {
      return Container();
    }

    Widget content;
    VoidCallback? onPressed;

    if (input is int) {
      content = Text(
        '$input',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xff070623),
        ),
      );
      onPressed = () => isPinTap(input);
    } else {
      content = Icon(
        input as IconData,
        color: const Color(0xff070623),
        size: 28,
      );
      onPressed = () => isPinTap(input);
    }

    return Center(
      child: IconButton(
        onPressed: onPressed,
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.white),
        ),
        constraints: const BoxConstraints(
          minHeight: 65,
          minWidth: 65,
          maxHeight: 65,
          maxWidth: 65,
        ),
        icon: content,
      ),
    );
  }
}
