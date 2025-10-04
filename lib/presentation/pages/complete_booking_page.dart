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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Get.offAllNamed('/discover', arguments: {'fragmentIndex': 0});
      },
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const Gap(50),
            Text(
              'Pemesanan Berhasil\nSelamat Menikmati Produk Sewa Anda!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            const Gap(24),
            ExtendedImage.network(
              car.imageProduct,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadStateChanged: (state) {
                switch (state.extendedImageLoadState) {
                  case LoadState.loading:
                    return const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xffFF5722),
                          ),
                        ),
                      ),
                    );
                  case LoadState.completed:
                    return ExtendedImage(
                      image: state.imageProvider,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    );
                  case LoadState.failed:
                    return Image.asset(
                      'assets/splash_screen.png',
                      width: 200,
                      height: 200,
                    );
                }
              },
            ),
            const Gap(24),
            Text(
              "${car.nameProduct} (${car.releaseProduct})",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            const Gap(8),
            Text(
              car.categoryProduct,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: const Color(0xff838384),
              ),
            ),
            Text(
              car.brandProduct,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: const Color(0xff838384),
              ),
            ),
            const Gap(24),
            ButtonPrimary(
              customBackgroundColor: const Color(0xffFF5722),
              text: 'Cari Produk Lainnya',
              onTap: () {
                Get.offAllNamed('/discover', arguments: {'fragmentIndex': 0});
              },
            ),
            const Gap(12),
            ButtonPrimary(
              text: 'Lihat Pesanan Saya',
              customTextColor: Theme.of(context).colorScheme.onSurface,
              customBackgroundColor: Theme.of(context).colorScheme.surface,
              customBorderColor: Get.isDarkMode
                  ? const Color(0xffEFEFF0)
                  : const Color(0xff070623),
              onTap: () {
                Get.offAllNamed('/discover', arguments: {'fragmentIndex': 1});
              },
            ),
            const Gap(50),
          ],
        ),
      ),
    );
  }
}
