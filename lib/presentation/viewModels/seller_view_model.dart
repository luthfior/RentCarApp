import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/seller_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class SellerViewModel extends GetxController {
  final authVM = Get.find<AuthViewModel>();
  final sellerSource = SellerSource();

  final _myProducts = <Car>[].obs;
  List<Car> get myProducts => _myProducts;

  final _currentView = 'home'.obs;
  RxString get currentView => _currentView;

  final TextEditingController searchController = TextEditingController();
  final _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;
  final _searchResults = <Car>[].obs;
  List<Car> get searchResults => _searchResults;

  StreamSubscription<List<Car>>? _productsSubscription;

  @override
  void onInit() {
    super.onInit();
    if (authVM.account.value != null) {
      fetchMyProducts();
    }
    searchController.addListener(() {
      _searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    _productsSubscription?.cancel();
    super.onClose();
  }

  void clearSearch() {
    searchController.clear();
    _currentView.value = 'home';
    _searchResults.clear();
  }

  void handleSearchSubmit() {
    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      _currentView.value = 'search';
      final Map<String, Car> uniqueCarsMap = {};
      for (var car in _myProducts) {
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

  Future<void> fetchMyProducts() async {
    final userAccount = authVM.account.value;
    if (userAccount == null) {
      return;
    }

    _productsSubscription?.cancel();
    _productsSubscription = sellerSource
        .fetchMyProductsStream(userAccount.uid, userAccount.role)
        .listen((updatedProducts) {
          _myProducts.value = updatedProducts;
        });

    await Future.microtask(() => null);
  }
}
