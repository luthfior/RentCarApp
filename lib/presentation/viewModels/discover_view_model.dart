import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class DiscoverViewModel extends GetxController {
  final fragmentIndex = 0.obs;
  final AuthViewModel authVM = Get.find<AuthViewModel>();

  @override
  void onInit() {
    super.onInit();
    authVM.loadUser();
  }

  void setFragmentIndex(int index) {
    fragmentIndex.value = index;
  }
}
