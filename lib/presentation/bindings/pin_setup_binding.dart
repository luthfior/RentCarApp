import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/pin_view_model.dart';

class PinSetupBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    final isChangingPin = args?['isChangingPin'] ?? false;
    Get.lazyPut<PinViewModel>(() => PinViewModel(isChangingPin: isChangingPin));
  }
}
