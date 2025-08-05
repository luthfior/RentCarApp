import 'dart:async';
import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    var user = await DSession.getUser();

    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('is_first_time') ?? true;

    if (user != null) {
      Get.offAllNamed('/discover');
    } else if (isFirstTime == true) {
      await prefs.setBool("is_first_time", false);
      Get.offAllNamed('/onboarding');
    } else {
      Get.offAllNamed('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset('assets/logo_text_1.png')));
  }
}
