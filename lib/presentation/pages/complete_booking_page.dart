import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';

class CompleteBookingPage extends StatelessWidget {
  const CompleteBookingPage({super.key, required this.car});
  final Car car;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const Gap(120),
          Text(
            'Pemesanan Berhasil\nSelamat Menikmati Perjalanan Anda!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: const Color(0xff070623),
            ),
          ),
          const Gap(50),
          ExtendedImage.network(
            car.imageProduct,
            width: 240,
            height: 220,
            fit: BoxFit.cover,
            loadStateChanged: (state) {
              if (state.extendedImageLoadState == LoadState.failed) {
                return Image.asset(
                  'assets/splash_screen.png',
                  width: 220,
                  height: 170,
                );
              }
              return null;
            },
          ),
          const Gap(50),
          Text(
            car.nameProduct,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: const Color(0xff070623),
            ),
          ),
          Text(
            car.categoryProduct,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              color: const Color(0xff838384),
            ),
          ),
          const Gap(50),
          ButtonPrimary(
            text: 'Cari Produk Lainnya',
            onTap: () {
              Get.offAllNamed(
                '/discover',
                arguments: {'fragmentIndex': 0, 'bookedCar': car},
              );
            },
          ),
          const Gap(12),
          ButtonPrimary(
            text: 'Lihat Pesanan Saya',
            customBackgroundColor: Colors.white,
            onTap: () {
              Get.offAllNamed(
                '/discover',
                arguments: {'fragmentIndex': 1, 'bookedCar': car},
              );
            },
          ),
        ],
      ),
    );
  }
}
