import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Message {
  static void error(String message, {double fontSize = 14.0}) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      barBlur: 20,
      overlayBlur: 0,
      overlayColor: Colors.transparent,
      backgroundColor: Colors.red.withAlpha(175),
    );
  }

  static void success(String message, {double fontSize = 14.0}) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      barBlur: 20,
      overlayBlur: 0,
      overlayColor: Colors.transparent,
      backgroundColor: Colors.green.withAlpha(175),
    );
  }

  static void neutral(String message, {double fontSize = 14.0}) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      barBlur: 20,
      overlayBlur: 0,
      overlayColor: Colors.transparent,
      backgroundColor: Colors.grey.withAlpha(175),
    );
  }
}
