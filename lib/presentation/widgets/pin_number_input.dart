import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Widget pinNumberInput(TextEditingController editingController) {
  InputBorder inputBorder = UnderlineInputBorder(
    borderSide: BorderSide(
      color: Theme.of(Get.context!).colorScheme.onSurface,
      width: 3,
    ),
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
        color: Theme.of(Get.context!).colorScheme.onSurface,
      ),
    ),
  );
}
