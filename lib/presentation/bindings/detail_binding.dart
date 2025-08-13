import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/detail_view_model.dart';

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    final idProduct = Get.arguments as String;
    Get.lazyPut<DetailViewModel>(() => DetailViewModel(idProduct));
  }
}
