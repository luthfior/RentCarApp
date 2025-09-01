import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/add_product_view_model.dart';

class AddProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProductViewModel>(() => AddProductViewModel());
  }
}
