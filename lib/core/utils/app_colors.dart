import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  static const Color lightBackground = Color(0xffEFEFF0);
  static const Color lightSurface = Color(0xffFFFFFF);
  static const Color lightOnSurface = Color(0xff070623);
  static const Color lightSecondaryText = Color(0xff838384);
  static const Color lightBorder = Color(0xffEFEEF7);
  static const Color lightPrimary = Color(0xff4A1DFF);
  static const Color lightTransparentWhite = Color(0xB3FFFFFF);
  static const Color lightBlack = Color(0xff000000);

  static const Color darkBackground = Color(0xff070623);
  static const Color darkSurface = Color(0xff292929);
  static const Color darkOnSurface = Color(0xffEFEFF0);
  static const Color darkSecondaryText = Color(0xffCECED5);
  static const Color darkBorder = Color(0xff393e52);
  static const Color darkPrimary = Color(0xff4A1DFF);
  static const Color darkTransparentWhite = Color(0xB3000000);
  static const Color darkBlack = Color(0xffFFFFFF);

  static Color get background =>
      Get.isDarkMode ? darkBackground : lightBackground;
  static Color get surface => Get.isDarkMode ? darkSurface : lightSurface;
  static Color get onSurface => Get.isDarkMode ? darkOnSurface : lightOnSurface;
  static Color get secondaryText =>
      Get.isDarkMode ? darkSecondaryText : lightSecondaryText;
  static Color get border => Get.isDarkMode ? darkBorder : lightBorder;
  static Color get primary => Get.isDarkMode ? darkPrimary : lightPrimary;
  static Color get transparentWhite =>
      Get.isDarkMode ? darkTransparentWhite : lightTransparentWhite;
  static Color get black => Get.isDarkMode ? darkBlack : lightBlack;
}
