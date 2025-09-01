import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxController {
  final connectivity = Connectivity();
  final isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    connectivity.onConnectivityChanged.listen((results) {
      isOnline.value =
          results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);
    });
    initConnectivity();
  }

  Future<void> initConnectivity() async {
    final results = await connectivity.checkConnectivity();
    isOnline.value =
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);
  }
}
