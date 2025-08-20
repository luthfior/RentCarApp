import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/favorite_view_model.dart';

class DiscoverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiscoverViewModel>(() => DiscoverViewModel(), fenix: true);
    Get.lazyPut<BrowseViewModel>(() => BrowseViewModel(), fenix: true);
    Get.lazyPut<FavoriteViewModel>(() => FavoriteViewModel());
  }
}
