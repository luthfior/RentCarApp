import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/constants/message.dart';
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
  final hasShownTutorial = false.obs;
  final box = GetStorage();
  final status = 'loading'.obs;
  final isLoadingDelete = false.obs;

  @override
  void onInit() {
    super.onInit();
    hasShownTutorial.value = box.read('hasShownSwipeTutorial') ?? false;
    if (authVM.account.value != null) {
      fetchMyProducts();
    } else {
      status.value = 'empty';
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
                car.brandProduct.toLowerCase().contains(query),
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
      status.value = 'empty';
      return;
    }

    status.value = 'loading';

    _productsSubscription?.cancel();
    _productsSubscription = sellerSource
        .fetchMyProductsStream(userAccount.uid, userAccount.role)
        .listen(
          (updatedProducts) {
            _myProducts.value = updatedProducts;
            if (updatedProducts.isEmpty) {
              status.value = 'empty';
            } else {
              status.value = 'success';
            }
            _checkAndShowTutorial();
          },
          onError: (e) {
            log('Error fetching products: $e');
            status.value = 'error';
          },
        );
  }

  Future<void> goToAddProductPage() async {
    final acc = authVM.account.value;
    if (acc == null) return;

    final isProfileComplete =
        (acc.phoneNumber?.isNotEmpty ?? false) &&
        (acc.street?.isNotEmpty ?? false) &&
        (acc.province?.isNotEmpty ?? false) &&
        (acc.city?.isNotEmpty ?? false) &&
        (acc.district?.isNotEmpty ?? false) &&
        (acc.village?.isNotEmpty ?? false) &&
        acc.latLocation != null &&
        acc.longLocation != null;

    if (isProfileComplete) {
      Get.toNamed('/add-product', arguments: {'isEdit': false});
    } else {
      Message.neutral(
        'Data Profil Anda belum lengkap. Silahkan lengkapi terlebih dahulu untuk melanjutkan',
        fontSize: 12,
      );
      Get.toNamed('/edit-profile', arguments: {'from': 'add-product'});
    }
  }

  Future<void> deleteProduct(String productId) async {
    bool? confirm = await showConfirmationDialog(
      context: Get.context!,
      title: 'Hapus Produk?',
      content:
          'Apakah Anda yakin ingin menghapus produk ini secara permanen? Tindakan ini tidak dapat diurungkan.',
      confirmText: 'Ya, Hapus',
    );
    if (confirm != true) {
      return;
    }
    isLoadingDelete.value = true;
    try {
      await sellerSource.deleteProduct(productId);
      fetchMyProducts();
    } catch (e) {
      log("Gagal menghapus produk dari ViewModel: $e");
      Message.error('Terjadi kesalahan saat menghapus produk.');
    } finally {
      isLoadingDelete.value = false;
    }
  }

  void _checkAndShowTutorial() {
    final bool shouldShow =
        status.value == 'success' &&
        _myProducts.isNotEmpty &&
        !(box.read('hasShownSwipeTutorial') ?? false);
    hasShownTutorial.value = shouldShow;
  }

  void dismissTutorial() {
    box.write('hasShownSwipeTutorial', true);
    hasShownTutorial.value = false;
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
}
