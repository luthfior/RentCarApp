import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();

    return Obx(() {
      if (connectivity.isOnline.value) {
        return const SizedBox.shrink();
      }

      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 32),
          padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff000000).withAlpha(70),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Aplikasi ini memerlukan koneksi internet",
                style: GoogleFonts.poppins(
                  color: const Color(0xffFFFFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    color: Color(0xffFFFFFF),
                    size: 20,
                  ),
                  const Gap(5),
                  Text(
                    "Tidak ada koneksi internet",
                    style: GoogleFonts.poppins(
                      color: const Color(0xB3FFFFFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
