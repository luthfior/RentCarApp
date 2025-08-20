import 'package:flutter/material.dart';
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

  List<Car> _allFeaturedList = [];
  List<Car> _allNewestList = [];

  final _status = ''.obs;
  String get status => _status.value;
  set status(String value) => _status.value = value;

  final categories = <String>[].obs;
  final selectedCategory = ''.obs;

  final TextEditingController searchController = TextEditingController();
  final _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;
  final _searchResults = <Car>[].obs;
  List<Car> get searchResults => _searchResults;

  final _currentView = 'home'.obs;
  RxString get currentView => _currentView;

  @override
  void onInit() {
    super.onInit();
    fetchAllCars();
    fetchCategories();

    searchController.addListener(() {
      _searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void clearSearch() {
    searchController.clear();
    _currentView.value = 'home';
    _searchResults.clear();
  }

  Future<void> fetchCategories() async {
    final result = await CarSource.fetchCategories();
    categories.assignAll(result);
  }

  Future<void> fetchAllCars() async {
    status = 'loading';
    try {
      final featuredCars = await CarSource.fetchFeatureCars();
      final newestCars = await CarSource.fetchNewestCars();
      if (featuredCars != null) {
        _allFeaturedList = featuredCars;
        _allFeaturedList.sort((a, b) {
          int comparePurchased = b.purchasedProduct.compareTo(
            a.purchasedProduct,
          );
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
        featuredList = _allFeaturedList;
      } else {
        status = 'Failed to fetch featured cars';
        return;
      }

      if (newestCars != null) {
        _allNewestList = newestCars;
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
        newestList = _allNewestList;
      } else {
        status = 'Failed to fetch newest cars';
        return;
      }

      status = 'success';
    } catch (e) {
      status = 'error';
    }
  }

  void filterCars(String category) {
    if (selectedCategory.value == category) {
      selectedCategory.value = '';
      featuredList = _allFeaturedList;
      newestList = _allNewestList;
      _currentView.value = 'home';
    } else {
      selectedCategory.value = category;
      featuredList = _allFeaturedList
          .where(
            (car) =>
                car.categoryProduct.toLowerCase() == category.toLowerCase(),
          )
          .toList();
      newestList = _allNewestList
          .where(
            (car) =>
                car.categoryProduct.toLowerCase() == category.toLowerCase(),
          )
          .toList();
      _currentView.value = 'home';
    }
  }

  void handleSearchSubmit() {
    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      _currentView.value = 'search';
      final Map<String, Car> uniqueCarsMap = {};
      for (var car in _allFeaturedList) {
        uniqueCarsMap[car.id] = car;
      }
      for (var car in _allNewestList) {
        uniqueCarsMap[car.id] = car;
      }
      final uniqueList = uniqueCarsMap.values.toList();
      final filteredResults = uniqueList
          .where(
            (car) =>
                car.nameProduct.toLowerCase().contains(query) ||
                car.categoryProduct.toLowerCase().contains(query) ||
                car.transmissionProduct.toLowerCase().contains(query),
          )
          .toList();
      _searchResults.value = filteredResults;
    } else {
      _currentView.value = 'home';
      _searchResults.clear();
    }
  }
}
