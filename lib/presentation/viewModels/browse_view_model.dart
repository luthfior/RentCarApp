import 'package:get/get.dart';
import 'package:rent_car_app/data/services/serp_api_service.dart';
import 'package:rent_car_app/data/sources/car_source.dart';
import 'package:rent_car_app/data/models/car.dart';

class BrowseViewModel extends GetxController {
  final Rx<Car?> car = Rx<Car?>(null);
  final _featuredList = <Car>[].obs;
  List<Car> get featuredList => _featuredList;
  set featuredList(List<Car> value) => _featuredList.value = value;

  final _newestList = <Car>[].obs;
  List<Car> get newestList => _newestList;
  set newestList(List<Car> value) => _newestList.value = value;

  final _status = ''.obs;
  String get status => _status.value;
  set status(String value) => _status.value = value;

  var categories = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllCars();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final result = await CarSource.fetchCategories();
    categories.assignAll(result);
  }

  Future<void> fetchAllCars() async {
    status = 'loading';

    final featuredCars = await CarSource.fetchFeatureCars();
    if (featuredCars != null) {
      featuredCars.sort((a, b) {
        int comparePurchased = b.purchasedProduct.compareTo(a.purchasedProduct);
        if (comparePurchased != 0) {
          return comparePurchased;
        }
        return b.ratingProduct.compareTo(a.ratingProduct);
      });

      for (var car in featuredCars) {
        if (car.imageProduct.isEmpty) {
          final imageUrl = await SerpApiService.fetchImageForCar(
            car.nameProduct,
            car.releaseProduct.toString(),
          );
          if (imageUrl != null) {
            await CarSource.updateImageProduct(car.id, imageUrl);
            car.imageProduct = imageUrl;
          }
        }
      }
      featuredList = featuredCars;
    } else {
      status = 'Failed to fetch featured cars';
      return;
    }

    final newestCars = await CarSource.fetchNewestCars();
    if (newestCars != null) {
      for (var car in newestCars) {
        if (car.imageProduct.isEmpty) {
          final imageUrl = await SerpApiService.fetchImageForCar(
            car.nameProduct,
            car.releaseProduct.toString(),
          );
          if (imageUrl != null) {
            await CarSource.updateImageProduct(car.id, imageUrl);
            car.imageProduct = imageUrl;
          }
        }
      }
      newestList = newestCars;
    } else {
      status = 'Failed to fetch newest cars';
      return;
    }

    status = 'success';
  }
}
