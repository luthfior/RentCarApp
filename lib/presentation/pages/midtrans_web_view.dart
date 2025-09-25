import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/presentation/viewModels/midtrans_web_view_model.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebView extends GetView<MidtransWebViewModel> {
  const MidtransWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: controller.status != 'loading',
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && controller.status != 'loading') {
            Get.back(result: 'cancel');
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Obx(
                      () => CustomHeader(
                        title: 'Pilih Pembayaran',
                        onBackTap: controller.status == 'loading'
                            ? () {
                                Message.neutral(
                                  'Tunggu, Proses sedang berlangsung...',
                                );
                                return;
                              }
                            : () {
                                Get.back(result: 'cancel');
                              },
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        if (controller.status == 'loading') {
                          return Center(
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
                                  'Sedang memproses pembayaran, mohon tunggu...',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (controller.webViewController == null) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xffFF5722),
                              ),
                            ),
                          );
                        }
                        return WebViewWidget(
                          controller: controller.webViewController!,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
