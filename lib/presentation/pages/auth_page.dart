import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/presentation/fragments/login_fragment.dart';
import 'package:rent_car_app/presentation/fragments/register_fragment.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? initialView = Get.arguments;

    return Scaffold(
      body: initialView == 'login'
          ? LoginFragment(
              onSwitchToRegister: () =>
                  Get.offAllNamed('/auth', arguments: 'register'),
            )
          : RegisterFragment(
              onSwitchToLogin: () =>
                  Get.offAllNamed('/auth', arguments: 'login'),
            ),
    );
  }
}
