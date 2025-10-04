import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';

class PermissionViewModel extends GetxController {
  final connectivity = Get.find<ConnectivityService>();
  var hasPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    final isOnline = connectivity.isOnline.value;
    final notifStatus = await Permission.notification.request();

    if (notifStatus.isGranted && isOnline) {
      hasPermission.value = true;
    } else {
      hasPermission.value = false;
      await showPermissionDialog();
    }
  }

  Future<void> showPermissionDialog() async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Izin Diperlukan",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(Get.context!).colorScheme.onSurface,
          ),
        ),
        content: Text(
          "Aplikasi memerlukan akses internet aktif dan izin notifikasi agar bisa digunakan.",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(Get.context!).colorScheme.onSurface,
          ),
        ),
        actionsOverflowDirection: VerticalDirection.up,
        actions: <Widget>[
          TextButton(
            child: Text(
              'Keluar',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            onPressed: () {
              Get.back();
              SystemNavigator.pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffFF5722),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Coba Lagi',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Get.back();
              requestPermissions();
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
