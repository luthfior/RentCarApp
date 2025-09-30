import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/presentation/viewModels/midtrans_web_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebView extends GetView<MidtransWebViewModel> {
  const MidtransWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (controller.status == 'loading') {
          Message.neutral(
            'Mohon Tunggu, Proses sedang berlangsung...',
            fontSize: 12,
          );
        } else {
          Get.back(result: 'cancel');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Pilih Pembayaran',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(Get.context!).colorScheme.onSurface,
            ),
          ),
          leading: Obx(
            () => IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: controller.status == 'loading'
                  ? () {
                      Message.neutral(
                        'Mohon Tunggu. Proses sedang berlangsung...',
                        fontSize: 13,
                      );
                      return;
                    }
                  : () {
                      Get.back(result: 'cancel');
                    },
            ),
          ),
        ),
        body: Obx(() {
          if (controller.status == 'error') {
            return _buildErrorView(context);
          }
          if (controller.status == 'loading' ||
              controller.webViewController == null) {
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
                    'Sedang memproses Midtrans, mohon tunggu...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            );
          }
          return WebViewWidget(controller: controller.webViewController!);
        }),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: Theme.of(Get.context!).colorScheme.secondary,
            ),
            const Gap(20),
            Text(
              'Gagal Memuat Halaman',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const Gap(8),
            Text(
              'Periksa kembali koneksi internet Anda atau coba lagi dalam beberapa saat.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(Get.context!).colorScheme.secondary,
              ),
            ),
            const Gap(30),
            ElevatedButton(
              onPressed: () => controller.retryLoad(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF5722),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
            const Gap(10),
            TextButton(
              onPressed: () => Get.back(result: 'cancel'),
              child: Text(
                'Kembali',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
