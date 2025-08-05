import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/register_view_model.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterViewmodel>(() => RegisterViewmodel());
  }
}
