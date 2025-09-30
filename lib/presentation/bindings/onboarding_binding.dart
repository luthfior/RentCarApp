import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/permission_view_model.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PermissionViewModel>(() => PermissionViewModel());
  }
}
