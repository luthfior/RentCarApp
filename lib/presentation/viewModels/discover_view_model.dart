import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';

class DiscoverViewModel extends GetxController {
  final fragmentIndex = 0.obs;
  final AuthViewModel authVM = Get.find<AuthViewModel>();
  final BrowseViewModel browseVM = Get.find<BrowseViewModel>();

  @override
  void onInit() {
    super.onInit();
    authVM.loadUser();
    browseVM.fetchAllCars();
  }

  void setFragmentIndex(int index) {
    fragmentIndex.value = index;

    switch (index) {
      case 0:
        browseVM.fetchAllCars();
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        authVM.loadUser();
        break;
    }
  }
}
