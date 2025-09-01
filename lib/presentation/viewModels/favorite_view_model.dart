import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class FavoriteViewModel extends GetxController {
  final firestore = FirebaseFirestore.instance;
  final authVM = Get.find<AuthViewModel>();
  final favoriteProducts = <Car>[].obs;
  final userSource = UserSource();

  final Rx<Car> _car = Car.empty.obs;
  Car get car => _car.value;
  set car(Car value) => _car.value = value;

  final status = ''.obs;
  final hasShownTutorial = false.obs;
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    hasShownTutorial.value = box.read('hasShownSwipeTutorial') ?? false;
    if (authVM.account.value != null) {
      fetchFavorites();
    } else {
      favoriteProducts.clear();
    }
  }

  @override
  void onClose() {
    _favoritesSubscription?.cancel();
    super.onClose();
  }

  void showTutorial() {
    box.write('hasShownSwipeTutorial', true);
    hasShownTutorial.value = true;
  }

  void dismissTutorial() {
    box.write('hasShownSwipeTutorial', true);
    hasShownTutorial.value = true;
  }

  Future<void> fetchFavorites() async {
    status.value = 'loading';
    final userId = authVM.account.value!.uid;

    await _favoritesSubscription?.cancel();
    _favoritesSubscription = firestore
        .collection('Users')
        .doc(userId)
        .collection('favProducts')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) async {
            if (snapshot.docs.isEmpty) {
              favoriteProducts.clear();
              status.value = 'empty';
              if (box.read('hasShownSwipeTutorial') != false) {
                box.write('hasShownSwipeTutorial', false);
                hasShownTutorial.value = false;
              }
              return;
            }

            final List<String> carIds = snapshot.docs
                .map((doc) => doc.id)
                .toList();

            if (carIds.isNotEmpty) {
              try {
                final carsSnapshot = await firestore
                    .collection('Cars')
                    .where(FieldPath.documentId, whereIn: carIds)
                    .get();

                final List<Car> updatedCars = carsSnapshot.docs
                    .map((doc) => Car.fromJson(doc.data()))
                    .toList();

                final Map<String, Car> carMap = {
                  for (var car in updatedCars) car.id: car,
                };
                final List<Car> sortedCars = snapshot.docs.map((doc) {
                  return carMap[doc.id]!;
                }).toList();

                favoriteProducts.value = sortedCars;
                status.value = 'success';
              } catch (e) {
                log('Gagal fetch data mobil: $e');
                status.value = 'error';
                if (box.read('hasShownSwipeTutorial') != false) {
                  box.write('hasShownSwipeTutorial', false);
                  hasShownTutorial.value = false;
                }
              }
            } else {
              favoriteProducts.clear();
              status.value = 'empty';
              if (box.read('hasShownSwipeTutorial') != false) {
                box.write('hasShownSwipeTutorial', false);
                hasShownTutorial.value = false;
              }
            }
          },
          onError: (error) {
            log('Gagal fetch favorit: $error');
            status.value = 'error';
            if (box.read('hasShownSwipeTutorial') != false) {
              box.write('hasShownSwipeTutorial', false);
              hasShownTutorial.value = false;
            }
          },
        );
    await Future.microtask(() => null);
  }

  Future<void> deleteFavorite(Car car) async {
    status.value = 'loading';
    final userId = authVM.account.value!.uid;
    try {
      await userSource.deleteFavoriteProduct(userId, car.id);
      Message.success('Produk berhasil dihapus dari Favorit');
    } catch (e) {
      log('Failed to toggle favorite status: $e');
      Message.error('Gagal menambahkan Produk ke Favorit');
    }
  }
}
