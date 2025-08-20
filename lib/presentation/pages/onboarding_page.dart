import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';

class OnBoardingPage extends StatelessWidget {
  OnBoardingPage({super.key});

  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap(50 + MediaQuery.of(context).padding.top),
          Image.asset('assets/logo_text_16_9.png', height: 90),
          const Gap(10),
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
              child: Image.asset(
                'assets/splash_screen.png',
                width: 400,
                height: 400,
              ),
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
          const Gap(50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ButtonPrimary(
              onTap: () {
                if (!connectivity.isOnline.value) {
                  null;
                }
                Get.offAllNamed('/auth');
              },
              text: 'Jelajahi Sekarang',
            ),
          ),
          Gap(70 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
