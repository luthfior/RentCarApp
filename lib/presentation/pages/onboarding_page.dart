import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Gap(50),
          Image.asset('assets/logo_text_16_9.png', height: 90),
          const Gap(20),
          Text(
            'Bebas Berkendara, Tanpa Beli Mobil',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(Get.context!).colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(-99, 0),
              child: Image.asset('assets/splash_screen.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Nikmati kemudahan menyewa mobil langsung dari genggamanmu, kapan saja, di mana saja.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
          ),
          const Gap(30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ButtonPrimary(
              onTap: () {
                Get.offAllNamed('/auth');
              },
              text: 'Jelajahi Sekarang',
            ),
          ),
          const Gap(50),
        ],
      ),
    );
  }
}
