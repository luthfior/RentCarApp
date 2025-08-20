import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/pin_view_model.dart';

class PinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PinViewModel>(
      () => PinViewModel(
        isForVerification: Get.arguments?['isForVerification'] ?? false,
        isChangingPin: Get.arguments?['isChangingPin'] ?? false,
        car: Get.arguments?['car'],
      ),
    );
  }
}
