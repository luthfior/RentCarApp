import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/sources/car_source.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/seller_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class BrowseViewModel extends GetxController {
  final Rx<Car?> car = Rx<Car?>(null);
  final authVM = Get.find<AuthViewModel>();
  final sellerSource = SellerSource();

  final _featuredList = <Car>[].obs;
  List<Car> get featuredList => _featuredList;
  set featuredList(List<Car> value) => _featuredList.value = value;

  final _newestList = <Car>[].obs;
  List<Car> get newestList => _newestList;
  set newestList(List<Car> value) => _newestList.value = value;

  final List<Car> _allFeaturedList = [];
  final List<Car> _allNewestList = [];

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

  StreamSubscription<List<Car>>? _featuredSubscription;
  StreamSubscription<List<Car>>? _newestSubscription;

  @override
  void onInit() {
    super.onInit();
    if (authVM.account.value != null) {
      startCarListeners();
      fetchCategories();
    }
    searchController.addListener(() {
      _searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    _featuredSubscription?.cancel();
    _newestSubscription?.cancel();
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

  Future<void> startCarListeners() async {
    status = 'loading';
    _featuredSubscription?.cancel();
    _newestSubscription?.cancel();

    try {
      _featuredSubscription = CarSource.fetchFeaturedCarsStream().listen((
        cars,
      ) {
        _allFeaturedList.clear();
        _allFeaturedList.addAll(cars);
        cars.sort((a, b) {
          int comparedPurchased = b.purchasedProduct.compareTo(
            a.purchasedProduct,
          );
          if (comparedPurchased != 0) {
            return comparedPurchased;
          }
          int compareRating = b.ratingAverage.compareTo(a.ratingAverage);
          if (compareRating != 0) {
            return compareRating;
          }
          return a.nameProduct.compareTo(b.nameProduct);
        });
        _featuredList.assignAll(cars);
        log('Fetch mobil populer secara real-time.');
        status = 'success';
      });
    } catch (e) {
      log('Gagal fetch mobil terbaru secara real-time.');
      status = 'error';
    }

    try {
      _newestSubscription = CarSource.fetchNewestCarsStream().listen((cars) {
        _allNewestList.clear();
        _allNewestList.addAll(cars);
        cars.sort((a, b) {
          int compareReleased = b.releaseProduct.compareTo(a.releaseProduct);
          if (compareReleased != 0) {
            return compareReleased;
          }
          return a.nameProduct.compareTo(b.nameProduct);
        });
        _newestList.assignAll(cars);
        log('Fetch mobil terbaru secara real-time.');
        status = 'success';
      });
    } catch (e) {
      log('Gagal fetch mobil terbaru secara real-time.');
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

  Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
  }) async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            content: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
                onPressed: () {
                  Get.back(result: false);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: title.contains('Konfirmasi')
                      ? const Color(0xff75A47F)
                      : const Color(0xffFF2056),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Get.back(result: true);
                },
              ),
            ],
          ),
        ) ??
        false;
  }
}
