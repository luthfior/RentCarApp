import 'dart:developer';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebViewModel extends GetxController {
  final RxString _status = 'loading'.obs;
  String get status => _status.value;
  set status(String value) => _status.value = value;

  WebViewController? webViewController;
  final String url;
  String detectedPaymentMethod = 'Midtrans';

  MidtransWebViewModel(this.url);

  @override
  void onInit() {
    super.onInit();
    if (url.isNotEmpty) {
      init(url);
      ever(_status, (value) {
        if (value == 'error') {
          if (Get.isDialogOpen ?? false) Get.back();
          Get.back(result: 'error');
        }
      });
    } else {
      log('Error: MidtransWebViewModel tidak ada URL.');
      status = 'error';
    }
  }

  @override
  void onClose() {
    webViewController?.clearCache();
    super.onClose();
  }

  String _extractPaymentMethod(String url) {
    if (url.contains('gopay')) return 'GoPay';
    if (url.contains('shopeepay')) return 'ShopeePay';
    if (url.contains('dana')) return 'DANA';
    if (url.contains('/va/')) return 'Virtual Account';
    if (url.contains('qris')) return 'QRIS';
    if (url.contains('credit_card')) return 'Kartu Kredit/Debit';
    if (url.contains('cstore/alfamart')) return 'Alfamart';
    if (url.contains('cstore/indomaret')) return 'Indomaret';
    return 'Midtrans';
  }

  void init(String url) {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => status = 'loading',
          onPageFinished: (_) => status = 'done',
          onWebResourceError: (error) {
            log("WebResourceError: ${error.description} (${error.errorCode})");
            if (error.errorCode == -2 || error.errorCode == -6) {
              status = 'error';
            }
          },
          onNavigationRequest: (request) {
            log("Navigating to: ${request.url}");
            final currentMethod = _extractPaymentMethod(request.url);
            log("Metode Pembayaran terdeteksi: $currentMethod");
            if (currentMethod != 'Midtrans') {
              detectedPaymentMethod = currentMethod;
              log(
                "Metode pembayaran ter-update menjadi: $detectedPaymentMethod",
              );
            }
            if (request.url.contains('example.com')) {
              final uri = Uri.parse(request.url);
              final transactionStatus =
                  uri.queryParameters['transaction_status'] ?? 'pending';
              log('Transaction Status from URL: $transactionStatus');
              Get.back(
                result: {
                  'status': transactionStatus,
                  'payment_method': detectedPaymentMethod,
                },
              );
              return NavigationDecision.prevent;
            }

            if (request.url.contains('/v2/deeplink/payment') ||
                request.url.contains('v2/deeplink/index')) {
              log('GoPay deeplink detected, considering payment as pending.');
              Get.back(
                result: {'status': 'settlement', 'payment_method': 'GoPay'},
              );
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }
}
