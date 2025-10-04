import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/favorite_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/notification_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/order_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/seller_view_model.dart';

class DiscoverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiscoverViewModel>(() => DiscoverViewModel());
    Get.lazyPut<BrowseViewModel>(() => BrowseViewModel());
    Get.lazyPut<OrderViewModel>(() => OrderViewModel());
    Get.lazyPut<FavoriteViewModel>(() => FavoriteViewModel());
    Get.lazyPut<SellerViewModel>(() => SellerViewModel());
    Get.lazyPut<NotificationViewModel>(() => NotificationViewModel());
  }
}
