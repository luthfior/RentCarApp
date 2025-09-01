import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class OnBoardingPage extends StatelessWidget {
  OnBoardingPage({super.key});

  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Gap(20 + MediaQuery.of(context).padding.top),
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            'assets/logo_text_16_9.png',
                            height: 90,
                          ),
                        ),
                        const Gap(10),
                        Text(
                          ' ',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(Get.context!).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(20),
                        Transform.translate(
                          offset: Offset(
                            -0.25 * MediaQuery.of(context).size.width,
                            0,
                          ),
                          child: Image.asset(
                            'assets/splash_screen.png',
                            width: MediaQuery.of(context).size.width * 2,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Gap(10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Nikmati kemudahan menyewa mobil langsung dari genggamanmu, kapan saja dan di mana saja.',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                Get.context!,
                              ).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Gap(50),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ButtonPrimary(
                            onTap: () {
                              if (connectivity.isOnline.value) {
                                Get.offAllNamed('/auth');
                              }
                            },
                            text: 'Jelajahi Sekarang',
                          ),
                        ),
                        Gap(70 + MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const OfflineBanner(),
          ],
        ),
      ),
    );
  }
}
