import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class SplashScreen extends GetView<AuthViewModel> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset('assets/logo_text_1.png')));
  }
}
