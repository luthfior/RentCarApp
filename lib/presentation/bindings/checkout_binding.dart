import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/checkout_view_model.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutViewModel>(() => CheckoutViewModel());
  }
}
