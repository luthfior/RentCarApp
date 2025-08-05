import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/login_view_model.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginViewModel>(() => LoginViewModel());
  }
}
