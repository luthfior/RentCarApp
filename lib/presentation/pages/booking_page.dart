import 'dart:developer';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/booking_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/custom_input.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class BookingPage extends GetView<BookingViewModel> {
  BookingPage({super.key});
  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                CustomHeader(title: 'Pemesanan'),
                const Gap(20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        snippetCar(),
                        const Gap(10),
                        buildInput(context),
                        const Gap(20),
                        buildAgency(),
                        const Gap(20),
                        buildInsurance(),
                        const Gap(20),
                        if (controller.car.categoryProduct == 'Mobil' ||
                            controller.car.categoryProduct == 'Truk')
                          buildDriverOption(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const OfflineBanner(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonPrimary(
              onTap: () async {
                if (connectivity.isOnline.value) {
                  await controller.goToCheckout();
                } else {
                  const OfflineBanner();
                  return;
                }
              },
              text: 'Lanjutkan ke Pembayaran',
            ),
          ],
        ),
      ),
    );
  }

  Widget snippetCar() {
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
                  controller.car.brandProduct,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                NumberFormat.currency(
                  decimalDigits: 0,
                  locale: 'id',
                  symbol: 'Rp.',
                ).format(controller.car.priceProduct),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xffFF5722),
                ),
              ),
              Text(
                '/hari',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nama Lengkap',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(Get.context!).colorScheme.onSurface,
            ),
          ),
          const Gap(10),
          CustomInput(
            icon: Icons.perm_contact_calendar_outlined,
            hint: (controller.name ?? '').isNotEmpty
                ? controller.name!
                : 'Nama Lengkap',
            customHintFontSize: 14,
            editingController: controller.fullNameController,
            isTextCapital: true,
          ),
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Mulai Sewa',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(Get.context!).colorScheme.onSurface,
                      ),
                    ),
                    const Gap(10),
                    CustomInput(
                      icon: Icons.calendar_month_outlined,
                      hint: 'Pilih Tanggal',
                      customHintFontSize: 14,
                      editingController: controller.startDateController,
                      onTapBox: () => controller.pickDate(
                        context,
                        controller.startDateController,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Berakhir',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(Get.context!).colorScheme.onSurface,
                      ),
                    ),
                    const Gap(10),
                    CustomInput(
                      icon: Icons.calendar_month_outlined,
                      hint: 'Pilih Tanggal',
                      customHintFontSize: 14,
                      editingController: controller.endDateController,
                      onTapBox: () => controller.pickDate(
                        context,
                        controller.endDateController,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildAgency() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Penyedia',
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
            itemCount: controller.listAgency.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final agency = controller.listAgency[index];
              return Obx(() {
                return GestureDetector(
                  onTap: () {
                    if (connectivity.isOnline.value) {
                      controller.agencyPicked = agency;
                    } else {
                      const OfflineBanner();
                      return;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    width: 125,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 24 : 8,
                      right: index == controller.listAgency.length - 1 ? 24 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: controller.agencyPicked == agency
                          ? Border.all(color: const Color(0xffFF5722), width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.business_rounded,
                          size: 38,
                          color: Color(0xffFF5722),
                        ),
                        const Gap(5),
                        Text(
                          agency,
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
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildInsurance() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asuransi',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            const Gap(10),
            SizedBox(
              height: 45,
              child: DropdownButtonFormField(
                isExpanded: true,
                value: controller.insurancePicked,
                items: controller.listInsurance.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(Get.context!).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  enabled: connectivity.isOnline.value,
                  hint: Text(
                    'Pilih Asuransi yang tersedia',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(Get.context!).colorScheme.onSurface,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(Get.context!).colorScheme.surface,
                  contentPadding: const EdgeInsets.fromLTRB(16, 18, 18, 10),
                  prefixIcon: const Icon(
                    Icons.health_and_safety_outlined,
                    size: 24,
                    color: Color(0xffFF5722),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(
                      width: 2,
                      color: Color(0xffFF5722),
                    ),
                  ),
                ),
                onChanged: (value) {
                  controller.insurancePicked = value;
                  log('Asuransi yang dipilih: $controller.insurancePicked');
                },
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget buildDriverOption() {
    return Obx(() {
      final isWithDriver = controller.withDriver;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilihan Driver',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            const Gap(10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (connectivity.isOnline.value) {
                        controller.withDriver = false;
                      } else {
                        const OfflineBanner();
                        return;
                      }
                    },
                    child: Container(
                      height: 65,
                      decoration: BoxDecoration(
                        color: Theme.of(Get.context!).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isWithDriver
                              ? Colors.transparent
                              : const Color(0xffFF5722),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_off,
                            size: 24,
                            color: Color(0xffFF5722),
                          ),
                          const Gap(5),
                          Text(
                            'Tanpa Driver',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                Get.context!,
                              ).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (connectivity.isOnline.value) {
                        controller.withDriver = true;
                      } else {
                        const OfflineBanner();
                        return;
                      }
                    },
                    child: Container(
                      height: 65,
                      decoration: BoxDecoration(
                        color: Theme.of(Get.context!).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isWithDriver
                              ? const Color(0xffFF5722)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person,
                            size: 24,
                            color: Color(0xffFF5722),
                          ),
                          const Gap(5),
                          Text(
                            'Dengan Driver',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                Get.context!,
                              ).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
