import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/profile_view_model.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileViewModel>(() => ProfileViewModel());
  }
}
