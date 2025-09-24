import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/midtrans_web_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebView extends GetView<MidtransWebViewModel> {
  const MidtransWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Pembayaran")),
      body: Obx(() {
        if (controller.status == 'loading') {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
            ),
          );
        } else if (controller.status == 'error') {
          return const Center(child: Text("Gagal memuat halaman pembayaran"));
        }
        if (controller.webViewController == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
            ),
          );
        }
        return WebViewWidget(controller: controller.webViewController!);
      }),
    );
  }
}
