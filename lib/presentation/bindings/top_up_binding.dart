import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/top_up_view_model.dart';

class TopUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TopUpViewModel>(() => TopUpViewModel());
  }
}
