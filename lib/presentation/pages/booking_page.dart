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
    final BookingViewModel bookingVM = Get.find<BookingViewModel>();
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Gap(20 + MediaQuery.of(context).padding.top),
              CustomHeader(title: 'Pemesanan'),
              const Gap(20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _snippetCar(bookingVM),
                      const Gap(10),
                      _buildInput(context, bookingVM),
                      const Gap(20),
                      _buildAgency(bookingVM),
                      const Gap(20),
                      _buildInsurance(bookingVM),
                      const Gap(20),
                      _buildDriverOption(bookingVM),
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
                  bookingVM.goToCheckout();
                } else {
                  null;
                }
              },
              text: 'Lanjutkan ke Pembayaran',
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _snippetCar(BookingViewModel bookingVM) {
    final String productName = bookingVM.car.nameProduct.length > 16
        ? '${bookingVM.car.nameProduct.substring(0, 14)}...'
        : bookingVM.car.nameProduct;

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
            bookingVM.car.imageProduct,
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
                  bookingVM.car.transmissionProduct,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
                ),
                Text(
                  bookingVM.car.categoryProduct,
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
                ).format(bookingVM.car.priceProduct),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
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

  Widget _buildInput(BuildContext context, BookingViewModel bookingVM) {
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
            enable: connectivity.isOnline.value,
            icon: 'assets/ic_profile.png',
            hint: bookingVM.nameController.text.isNotEmpty
                ? bookingVM.nameController.text
                : 'Nama Lengkap',
            customHintFontSize: 14,
            editingController: bookingVM.nameController,
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
                      icon: 'assets/ic_calendar.png',
                      hint: 'Pilih Tanggal',
                      customHintFontSize: 14,
                      editingController: bookingVM.startDateController,
                      enable: false,
                      onTapBox: () => bookingVM.pickDate(
                        context,
                        bookingVM.startDateController,
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
                      icon: 'assets/ic_calendar.png',
                      hint: 'Pilih Tanggal',
                      customHintFontSize: 14,
                      editingController: bookingVM.endDateController,
                      enable: false,
                      onTapBox: () => bookingVM.pickDate(
                        context,
                        bookingVM.endDateController,
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

  Widget _buildAgency(BookingViewModel bookingVM) {
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
            itemCount: bookingVM.listAgency.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final agency = bookingVM.listAgency[index];
              return Obx(() {
                return GestureDetector(
                  onTap: () {
                    if (connectivity.isOnline.value) {
                      bookingVM.agencyPicked = agency;
                    } else {
                      null;
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
                      right: index == bookingVM.listAgency.length - 1 ? 24 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: bookingVM.agencyPicked == agency
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
                            'assets/agency.png',
                            width: 38,
                            height: 38,
                          ),
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

  Widget _buildInsurance(BookingViewModel bookingVM) {
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
                value: bookingVM.insurancePicked,
                items: bookingVM.listInsurance.map((e) {
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
                  prefixIcon: UnconstrainedBox(
                    alignment: const Alignment(0.4, 0),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color(0xffFF5722),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/ic_insurance.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
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
                  bookingVM.insurancePicked = value;
                  log('Asuransi yang dipilih: $bookingVM.insurancePicked');
                },
                icon: Image.asset(
                  'assets/ic_arrow_down.png',
                  width: 18,
                  height: 18,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDriverOption(BookingViewModel bookingVM) {
    return Obx(() {
      final isWithDriver = bookingVM.withDriver;
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
                        bookingVM.withDriver = true;
                      } else {
                        null;
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
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (connectivity.isOnline.value) {
                        bookingVM.withDriver = false;
                      } else {
                        null;
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
              ],
            ),
          ],
        ),
      );
    });
  }
}
