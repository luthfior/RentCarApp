import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/presentation/viewModels/order_view_model.dart';
import 'package:rent_car_app/presentation/widgets/item_order_car.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class OrderFragment extends GetView<OrderViewModel> {
  const OrderFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(30 + MediaQuery.of(context).padding.top),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const OfflineBanner(),
        const Gap(20),
        Expanded(
          child: Obx(() {
            if (controller.status.value == 'loading') {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
                ),
              );
            }
            if (controller.status.value == 'empty') {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Anda belum melakukan Booking sebelumnya. Silahkan lakukan Boking terlebih dahulu',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (controller.status.value == 'error') {
              return Center(
                child: Text(
                  'Gagal memuat daftar Pesanan. Coba lagi nanti.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              itemCount: controller.bookedProducts.length,
              itemBuilder: (context, index) {
                final bookedCar = controller.bookedProducts[index];
                return itemOrderCar(bookedCar, EdgeInsets.zero);
              },
            );
          }),
        ),
      ],
    );
  }
}
