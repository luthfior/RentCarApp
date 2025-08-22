import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/checkout_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class CheckoutPage extends GetView<CheckoutViewModel> {
  CheckoutPage({super.key});

  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Gap(20 + MediaQuery.of(context).padding.top),
              CustomHeader(title: 'Pembayaran'),
              const Gap(20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _snippetCar(),
                      const Gap(20),
                      _buildReceipt(),
                      const Gap(20),
                      _buildPaymentMethod(),
                      const Gap(20),
                      _buildWallet(),
                      const Gap(20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const OfflineBanner(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonPrimary(
              onTap: () {
                if (connectivity.isOnline.value) {
                  controller.goToPin();
                } else {
                  null;
                }
              },
              text: 'Bayar Sekarang',
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _snippetCar() {
    final String productName = controller.car.nameProduct.length > 16
        ? '${controller.car.nameProduct.substring(0, 14)}...'
        : controller.car.nameProduct;

    return Container(
      height: 85,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ExtendedImage.network(
            controller.car.imageProduct,
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
          const Gap(5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
                Text(
                  controller.car.transmissionProduct,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
                ),
                Text(
                  controller.car.categoryProduct,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const Gap(21),
          Row(
            children: [
              RatingBar.builder(
                initialRating: controller.car.ratingProduct.toDouble(),
                itemPadding: const EdgeInsets.all(0),
                itemSize: 14,
                unratedColor: Colors.grey[300],
                itemBuilder: (context, index) =>
                    const Icon(Icons.star, color: Color(0xffFFBC1C)),
                ignoreGestures: true,
                allowHalfRating: true,
                onRatingUpdate: (value) {},
              ),
              const Gap(4),
              Text(
                '(${controller.car.ratingProduct})',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceipt() {
    Widget buildReceiptRow(
      String title,
      String value, {
      bool isBold = false,
      bool isBlue = false,
      bool isInsurance = false,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            const Gap(50),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: isInsurance ? TextOverflow.ellipsis : null,
                style: GoogleFonts.poppins(
                  fontSize: isBold ? 14 : 12,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                  color: isBlue
                      ? const Color(0xffFF5722)
                      : Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            buildReceiptRow(
              'Nama Order',
              isBold: true,
              controller.nameOrder ?? 'Tidak Ada',
            ),
            const Divider(color: Color(0xffEFEEF7), height: 24),
            buildReceiptRow(
              'Harga',
              isBold: true,
              '${controller.formatCurrency(controller.car.priceProduct.toDouble())}/hari',
            ),
            if (controller.withDriver)
              buildReceiptRow(
                'Biaya Driver',
                isBold: true,
                '${controller.formatCurrency(controller.driverCostPerDay)}/hari',
              ),
            buildReceiptRow(
              'Tanggal Mulai',
              isBold: true,
              controller.formatDate(controller.startDate),
            ),
            buildReceiptRow(
              'Tanggal Berakhir',
              isBold: true,
              controller.formatDate(controller.endDate),
            ),
            buildReceiptRow(
              'Durasi',
              isBold: true,
              '${controller.rentDurationInDays} hari',
            ),
            buildReceiptRow(
              'Sub Total',
              isBold: true,
              controller.formatCurrency(controller.subTotal),
            ),
            const Divider(color: Color(0xffEFEEF7), height: 24),

            buildReceiptRow(
              'Penyedia',
              isBold: true,
              controller.agency ?? 'Tidak Dipilih',
            ),
            buildReceiptRow(
              'Asuransi',
              isBold: true,
              isInsurance: true,
              controller.insurance ?? 'Tidak Ada',
            ),
            const Divider(color: Color(0xffEFEEF7), height: 24),
            buildReceiptRow(
              'Biaya Asuransi (20%)',
              isBold: true,
              controller.formatCurrency(controller.totalInsuranceCost),
            ),
            buildReceiptRow(
              'Biaya Tambahan',
              isBold: true,
              controller.formatCurrency(controller.additionalCost),
            ),
            const Divider(color: Color(0xffEFEFF0), height: 24),
            buildReceiptRow(
              'Total Harga',
              isBold: true,
              isBlue: true,
              controller.formatCurrency(controller.finalTotal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Metode Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(Get.context!).colorScheme.onSurface,
            ),
          ),
        ),
        const Gap(10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.listPayment.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final paymentMethod = controller.listPayment[index];
              return Obx(
                () => GestureDetector(
                  onTap: () {
                    if (connectivity.isOnline.value) {
                      controller.setPaymentMethod(paymentMethod['name']!);
                    } else {
                      null;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    width: 120,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 24 : 8,
                      right: index == controller.listPayment.length - 1
                          ? 24
                          : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          controller.paymentMethodPicked.value ==
                              paymentMethod['name']
                          ? Border.all(color: const Color(0xffFF5722))
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Color(0xffFF5722),
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            paymentMethod['icon']!,
                            width: 38,
                            height: 38,
                          ),
                        ),
                        const Gap(5),
                        Text(
                          paymentMethod['name']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(Get.context!).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWallet() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          Image.asset(
            'assets/bg_wallet.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.nameOrder}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xffFFFFFF),
                  ),
                ),
                Text(
                  '09/11',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xffFFFFFF),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Saldo',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xffFFFFFF),
                  ),
                ),
                Obx(() {
                  final balance = controller.userBalance.value;
                  return Text(
                    balance != null
                        ? controller.formatCurrency(balance.toDouble())
                        : 'Memuat...',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffFFFFFF),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
