import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Message {
  static void error(String message) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withAlpha(200),
      duration: const Duration(seconds: 3),
    );
  }

  static void success(String message) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withAlpha(200),
      duration: const Duration(seconds: 3),
    );
  }

  static void neutral(String message) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.grey.withAlpha(200),
      duration: const Duration(seconds: 3),
    );
  }
}
