import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/address_view_model.dart';

class AddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressViewModel>(() => AddressViewModel());
  }
}
