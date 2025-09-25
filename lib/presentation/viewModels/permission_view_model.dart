import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
      showPermissionDialog();
    }
  }

  void showPermissionDialog() {
    Get.defaultDialog(
      title: "Izin Diperlukan",
      middleText:
          "Aplikasi memerlukan akses internet aktif dan izin notifikasi agar bisa digunakan.",
      textCancel: "Keluar",
      textConfirm: "Coba Lagi",
      confirmTextColor: const Color(0xffFF5722),
      onCancel: () {
        SystemNavigator.pop();
      },
      onConfirm: () {
        Get.back();
        requestPermissions();
      },
    );
  }
}
