import 'package:get/get.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/fragments/browse_fragment.dart';
import 'package:rent_car_app/presentation/fragments/favorite_fragment.dart';
import 'package:rent_car_app/presentation/fragments/order_fragment.dart';
import 'package:rent_car_app/presentation/fragments/setting_fragment.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';

class DiscoverViewModel extends GetxController {
  final fragmentIndex = 0.obs;
  final AuthViewModel authVM = Get.find<AuthViewModel>();
  final BrowseViewModel browseVM = Get.find<BrowseViewModel>();

  final fragments = [
    BrowseFragment(),
    const OrderFragment(),
    FavoriteFragment(),
    SettingFragment(),
  ];

  @override
  void onInit() {
    super.onInit();
    authVM.loadUser();
    browseVM.fetchAllCars();
    final arguments = Get.arguments;
    if (arguments != null) {
      final int? newIndex = arguments['fragmentIndex'];
      final Car? bookedCar = arguments['bookedCar'];

      if (newIndex != null) {
        setFragmentIndex(newIndex);
      }
      if (bookedCar != null) {
        browseVM.car.value = bookedCar;
      }
    }
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
