import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/login_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/register_view_model.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginViewModel>(() => LoginViewModel());
    Get.lazyPut<RegisterViewmodel>(() => RegisterViewmodel());
  }
}
