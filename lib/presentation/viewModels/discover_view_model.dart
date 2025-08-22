import 'package:get/get.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/favorite_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/order_view_model.dart';

class DiscoverViewModel extends GetxController {
  final fragmentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments != null) {
      final int? newIndex = arguments['fragmentIndex'];
      final Car? bookedCar = arguments['bookedCar'];

      if (newIndex != null) {
        setFragmentIndex(newIndex);
      }
      if (bookedCar != null) {
        final browseVM = Get.find<BrowseViewModel>();
        browseVM.car.value = bookedCar;
      }
    }
  }

  void setFragmentIndex(int index) {
    fragmentIndex.value = index;
    switch (index) {
      case 0:
        Get.find<BrowseViewModel>().fetchAllCars();
        break;
      case 1:
        Get.find<OrderViewModel>().fetchBookedCars();
        break;
      case 2:
        Get.find<FavoriteViewModel>().fetchFavorites();
        break;
      case 3:
        Get.find<AuthViewModel>().loadUser();
        break;
    }
  }
}
