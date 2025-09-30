import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class SplashScreen extends GetView<AuthViewModel> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: Image.asset(
          isDarkMode
              ? 'assets/logo_text_1_dark_mode.png'
              : 'assets/logo_text_1.png',
        ),
      ),
    );
  }
}
