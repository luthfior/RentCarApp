import 'package:get/get.dart';
import 'package:rent_car_app/data/services/serp_api_service.dart';
import 'package:rent_car_app/data/sources/car_source.dart';
import 'package:rent_car_app/data/models/car.dart';

class BrowseViewModel extends GetxController {
  final _featuredList = <Car>[].obs;
  List<Car> get featuredList => _featuredList;
  set featuredList(List<Car> n) => _featuredList.value = n;

  final _newestList = <Car>[].obs;
  List<Car> get newestList => _newestList;
  set newestList(List<Car> n) => _newestList.value = n;

  final _loadingStatus = ''.obs;
  String get loadingStatus => _loadingStatus.value;
  set loadingStatus(String n) => _loadingStatus.value = n;

  var categories = <String>[].obs;

  Future<void> fetchCategories() async {
    final result = await CarSource.fetchCategories();
    categories.assignAll(result);
  }

  Future<void> fetchAllCars() async {
    loadingStatus = 'loading';

    final featuredCars = await CarSource.fetchFeatureCars();
    if (featuredCars != null) {
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
      loadingStatus = 'Failed to fetch featured cars';
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
      loadingStatus = 'Failed to fetch newest cars';
      return;
    }

    loadingStatus = 'success';
  }

  // final _featuredStatus = ''.obs;
  // String get featuredStatus => _featuredStatus.value;
  // set featuredStatus(String n) => _featuredStatus.value = n;

  // final _newestStatus = ''.obs;
  // String get newestStatus => _newestStatus.value;
  // set newestStatus(String n) => _newestStatus.value = n;

  // fetchFeatured() async {
  //   featuredStatus = 'loading';
  //   final cars = await CarSource.fetchFeatureCars();
  //   if (cars != null) {
  //     for (var car in cars) {
  //       if (car.imageProduct.isEmpty) {
  //         final imageUrl = await SerpApiService.fetchImageForCar(
  //           car.nameProduct,
  //           car.releaseProduct.toString(),
  //         );
  //         if (imageUrl != null) {
  //           await CarSource.updateImageProduct(car.id, imageUrl);
  //           car.imageProduct = imageUrl;
  //         }
  //       }
  //     }
  //     featuredStatus = 'success';
  //     featuredList = cars;
  //   } else {
  //     featuredStatus = 'something wrong';
  //     return;
  //   }
  // }

  // fetchNewest() async {
  //   newestStatus = 'loading';
  //   final cars = await CarSource.fetchNewestCars();
  //   if (cars != null) {
  //     bool isImageFetchFailed = false;
  //     for (var car in cars) {
  //       if (car.imageProduct.isEmpty) {
  //         final imageUrl = await SerpApiService.fetchImageForCar(
  //           car.nameProduct,
  //           car.releaseProduct.toString(),
  //         );
  //         if (imageUrl != null) {
  //           await CarSource.updateImageProduct(car.id, imageUrl);
  //           car.imageProduct = imageUrl;
  //         } else {
  //           isImageFetchFailed = true;
  //         }
  //       }
  //     }

  //     if (isImageFetchFailed) {
  //       newestStatus = 'Image not found';
  //     } else {
  //       newestStatus = 'success';
  //       newestList = cars;
  //     }
  //   } else {
  //     newestStatus = 'Failed to fetch data from database';
  //   }
  // }
}
