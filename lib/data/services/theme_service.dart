import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/utils/app_colors.dart';

class ThemeService extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    final storedValue = _box.read(_key) ?? false;
    isDarkMode.value = storedValue;
  }

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(themeMode);
    _box.write(_key, isDarkMode.value);
  }

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.lightPrimary,
    colorScheme: const ColorScheme.light(
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: GoogleFonts.poppins(color: AppColors.lightOnSurface),
      bodyMedium: GoogleFonts.poppins(color: AppColors.lightOnSurface),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.darkPrimary,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: GoogleFonts.poppins(color: AppColors.darkOnSurface),
      bodyMedium: GoogleFonts.poppins(color: AppColors.darkOnSurface),
    ),
  );
}
