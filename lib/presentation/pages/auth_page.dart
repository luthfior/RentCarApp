import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/presentation/fragments/login_fragment.dart';
import 'package:rent_car_app/presentation/fragments/register_fragment.dart';
import 'package:rent_car_app/presentation/viewModels/login_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/register_view_model.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  final String? initialView = Get.arguments;
  late final currentView = (initialView == 'login' ? 'login' : 'register').obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (currentView.value == 'register') {
          Get.find<LoginViewModel>().resetForm();
          return RegisterFragment(
            onSwitchToLogin: () => currentView.value = 'login',
          );
        } else {
          Get.find<RegisterViewmodel>().resetForm();
          return LoginFragment(
            onSwitchToRegister: () => currentView.value = 'register',
          );
        }
      }),
    );
  }
}
