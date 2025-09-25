import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/pin_view_model.dart';

class PinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PinViewModel>(() => PinViewModel());
  }
}
