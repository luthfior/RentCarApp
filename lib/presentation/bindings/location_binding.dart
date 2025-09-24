import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/location_view_model.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationViewModel>(() => LocationViewModel());
  }
}
