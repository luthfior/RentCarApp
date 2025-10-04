import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/pin_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';
import 'package:rent_car_app/presentation/widgets/pin_layout.dart';
import 'package:rent_car_app/presentation/widgets/pin_number_input.dart';

class PinPage extends GetView<PinViewModel> {
  PinPage({super.key});

  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final titleHeader = controller.isForVerification.value
          ? 'Verifikasi PIN Lama'
          : 'Masukkan PIN';
      final buttonText = controller.isForVerification.value
          ? 'Verifikasi PIN'
          : 'Konfirmasi Pembayaran';

      return PopScope(
        canPop: !isLoading,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && isLoading) {
            Message.neutral('Sedang memproses, mohon tunggu...', fontSize: 12);
          }
        },
        child: Scaffold(
          body: isLoading
              ? SafeArea(
                  child: Column(
                    children: [
                      CustomHeader(
                        title: 'Pembayaran',
                        onBackTap: () {
                          if (isLoading) {
                            Message.neutral(
                              'Sedang memproses, mohon tunggu...',
                              fontSize: 12,
                            );
                            return;
                          }
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xffFF5722),
                                ),
                              ),
                              const Gap(16),
                              Text(
                                'Sedang memproses, mohon tunggu...',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : buildPinContent(context, titleHeader, buttonText),
        ),
      );
    });
  }

  Widget buildPinContent(
    BuildContext context,
    String titleHeader,
    String buttonText,
  ) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              CustomHeader(title: titleHeader),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 52),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          pinNumberInput(controller.pin1),
                          const Gap(30),
                          pinNumberInput(controller.pin2),
                          const Gap(30),
                          pinNumberInput(controller.pin3),
                          const Gap(30),
                          pinNumberInput(controller.pin4),
                        ],
                      ),
                    ),
                    const Gap(30),
                    pinLayout(controller),
                    const Gap(50),
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            color: Get.isDarkMode
                ? const Color(0xff070623)
                : const Color(0xffEFEFF0),
            child: SafeArea(
              top: false,
              child: Obx(
                () => ButtonPrimary(
                  onTap:
                      (controller.isPinComplete.value &&
                          connectivity.isOnline.value &&
                          !controller.isLoading.value)
                      ? () async {
                          controller.isLoading.value = true;
                          try {
                            if (controller.isForVerification.value) {
                              await controller.verifyOldPin();
                            } else {
                              await controller.finishedPayment();
                            }
                          } finally {
                            controller.isLoading.value = false;
                          }
                        }
                      : null,
                  text: buttonText,
                ),
              ),
            ),
          ),
        ),
        const OfflineBanner(),
      ],
    );
  }
}
