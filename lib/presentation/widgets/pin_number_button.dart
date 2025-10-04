import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/presentation/viewModels/pin_view_model.dart';

Widget pinNumberButton(PinViewModel pinVm, dynamic input) {
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
        color: Theme.of(Get.context!).colorScheme.onSurface,
      ),
    );
    onPressed = () => pinVm.handlePinInput(input);
  } else {
    content = Icon(
      input as IconData,
      color: Theme.of(Get.context!).colorScheme.onSurface,
      size: 24,
    );
    onPressed = () => pinVm.handlePinInput(input);
  }

  return Center(
    child: IconButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(Get.context!).colorScheme.surface,
        ),
        shape: WidgetStateProperty.all(const CircleBorder()),
      ),
      constraints: const BoxConstraints(
        minHeight: 60,
        minWidth: 60,
        maxHeight: 70,
        maxWidth: 70,
      ),
      icon: content,
    ),
  );
}
