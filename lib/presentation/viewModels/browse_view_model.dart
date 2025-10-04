import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/models/booked_car.dart';
import 'package:rent_car_app/data/sources/car_source.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/seller_source.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class BrowseViewModel extends GetxController {
  final Rx<BookedCar?> bookedCar = Rx<BookedCar?>(null);
  final authVM = Get.find<AuthViewModel>();

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
  final isLoadingDelete = false.obs;

  final chipItems = <String>[].obs;

  final RxString chipMode = 'brands'.obs;
  final List<String> standardCategories = [
    'Truk',
    'Mobil',
    'Motor',
    'Sepeda',
    'Lainnya',
  ];
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

  final _ownersMap = <String, Account>{}.obs;
  Map<String, Account> get ownersMap => _ownersMap;

  @override
  void onInit() {
    super.onInit();
    if (authVM.account.value != null) {
      checkForPendingOrder();
      loadChipData();
      startCarListeners();
    }
    searchController.addListener(() {
      _searchQuery.value = searchController.text;
    });

    debounce(
      _searchQuery,
      (_) => handleSearchSubmit(),
      time: const Duration(milliseconds: 500),
    );
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

  Future<void> loadChipData() async {
    try {
      final uniqueCategories = await CarSource.fetchUniqueCategories();

      if (uniqueCategories.length > 4) {
        chipMode.value = 'categories';
        chipItems.assignAll(standardCategories);
        log(
          'Mode chip diubah ke KATEGORI karena ada ${uniqueCategories.length} kategori unik.',
        );
      } else {
        chipMode.value = 'brands';
        final fetchedBrands = await CarSource.fetchBrands();
        chipItems.assignAll(fetchedBrands);
        log('Mode chip tetap BRAND.');
      }
    } catch (e) {
      log("Gagal memuat data chip: $e");
      chipMode.value = 'categories';
      chipItems.assignAll(standardCategories);
    }
  }

  Future<void> _fetchAndAssignOwners(List<Car> cars) async {
    final newOwnerIds = cars
        .map((car) => car.ownerId)
        .where((id) => !_ownersMap.containsKey(id))
        .toSet()
        .toList();

    if (newOwnerIds.isEmpty) return;

    final fetchedOwners = await UserSource.fetchAccountsByIds(newOwnerIds);
    _ownersMap.addAll(fetchedOwners);
    log('${fetchedOwners.length} data owner baru berhasil diambil.');
  }

  Future<void> startCarListeners() async {
    if (_allFeaturedList.isEmpty && _allNewestList.isEmpty) {
      status = 'loading';
    }
    _featuredSubscription?.cancel();
    _newestSubscription?.cancel();

    try {
      final results = await Future.wait([
        CarSource.fetchFeaturedCarsStream().first,
        CarSource.fetchNewestCarsStream().first,
      ]);

      final featuredCars = results[0];
      final newestCars = results[1];

      final allCars = [...featuredCars, ...newestCars];
      await _fetchAndAssignOwners(allCars);

      _allFeaturedList.assignAll(featuredCars);
      _featuredList.assignAll(featuredCars);
      _allNewestList.assignAll(newestCars);
      _newestList.assignAll(newestCars);

      status = 'success';
      log('Initial load selesai. Semua data siap.');

      _featuredSubscription = CarSource.fetchFeaturedCarsStream().listen((
        cars,
      ) {
        _allFeaturedList.assignAll(cars);
        _featuredList.assignAll(cars);
        _fetchAndAssignOwners(cars);
      });

      _newestSubscription = CarSource.fetchNewestCarsStream().listen((cars) {
        _allNewestList.assignAll(cars);
        _newestList.assignAll(cars);
        _fetchAndAssignOwners(cars);
      });
    } catch (e) {
      log('Gagal fetch mobil terbaru secara real-time.');
      status = 'error';
    }

    try {
      _newestSubscription = CarSource.fetchNewestCarsStream().listen((cars) {
        _allNewestList.clear();
        _allNewestList.addAll(cars);
        _newestList.assignAll(cars);
        _fetchAndAssignOwners(cars);
        log('Fetch mobil terbaru secara real-time.');
        status = 'success';
      });
    } catch (e) {
      log('Gagal fetch mobil terbaru secara real-time.');
      status = 'error';
    }
  }

  void filterCars(String filterValue) {
    if (selectedCategory.value.toLowerCase() == filterValue.toLowerCase()) {
      selectedCategory.value = '';
      featuredList.assignAll(_allFeaturedList);
      newestList.assignAll(_allNewestList);
    } else {
      selectedCategory.value = filterValue;
      if (chipMode.value == 'brands') {
        featuredList.assignAll(
          _allFeaturedList
              .where(
                (car) =>
                    car.brandProduct.toLowerCase() == filterValue.toLowerCase(),
              )
              .toList(),
        );
        newestList.assignAll(
          _allNewestList
              .where(
                (car) =>
                    car.brandProduct.toLowerCase() == filterValue.toLowerCase(),
              )
              .toList(),
        );
      } else {
        if (filterValue == 'Lainnya') {
          featuredList.assignAll(
            _allFeaturedList
                .where(
                  (car) => !standardCategories.contains(car.categoryProduct),
                )
                .toList(),
          );
          newestList.assignAll(
            _allNewestList
                .where(
                  (car) => !standardCategories.contains(car.categoryProduct),
                )
                .toList(),
          );
        } else {
          featuredList.assignAll(
            _allFeaturedList
                .where(
                  (car) =>
                      car.categoryProduct.toLowerCase() ==
                      filterValue.toLowerCase(),
                )
                .toList(),
          );
          newestList.assignAll(
            _allNewestList
                .where(
                  (car) =>
                      car.categoryProduct.toLowerCase() ==
                      filterValue.toLowerCase(),
                )
                .toList(),
          );
        }
      }
    }
  }

  void handleSearchSubmit() {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      _currentView.value = 'home';
      _searchResults.clear();
      return;
    }
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
              car.brandProduct.toLowerCase().contains(query),
        )
        .toList();
    _searchResults.value = filteredResults;
  }

  Future<void> deleteProduct(String productId) async {
    bool? confirm = await showConfirmationDialog(
      context: Get.context!,
      title: 'Hapus Produk?',
      content: 'Apakah Anda yakin ingin menghapus produk ini secara permanen?',
      confirmText: 'Ya, Hapus',
    );
    if (confirm != true) {
      return;
    }
    isLoadingDelete.value = true;
    try {
      await SellerSource().deleteProduct(productId);
      startCarListeners();
    } catch (e) {
      log("Gagal menghapus produk dari ViewModel: $e");
      Message.error('Terjadi kesalahan saat menghapus produk.');
    } finally {
      isLoadingDelete.value = false;
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
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            content: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            actionsOverflowDirection: VerticalDirection.up,
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
                  backgroundColor: const Color(0xffFF5722),
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

  Future<void> checkForPendingOrder() async {
    final user = authVM.account.value;
    if (user == null) return;

    final userSource = UserSource();
    final allOrders = await userSource
        .fetchBookedCarStream(user.uid, user.role)
        .first;

    final pendingOrder = allOrders.firstWhereOrNull(
      (bookedCar) => bookedCar.order.orderStatus == 'pending',
    );

    bookedCar.value = pendingOrder;
  }
}
