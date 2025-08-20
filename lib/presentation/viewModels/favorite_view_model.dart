import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class FavoriteViewModel extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _authVM = Get.find<AuthViewModel>();
  final favoriteProducts = <Car>[].obs;
  final status = ''.obs;

  final isFavorited = false.obs;
  final _userSource = UserSource();

  @override
  void onInit() {
    super.onInit();
    if (_authVM.account.value != null) {
      fetchFavorites();
    }
  }

  void fetchFavorites() {
    status.value = 'loading';
    final userId = _authVM.account.value!.uid;
    _firestore
        .collection('Users')
        .doc(userId)
        .collection('favProducts')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.docs.isEmpty) {
              favoriteProducts.clear();
              status.value = 'empty';
              return;
            }

            favoriteProducts.value = snapshot.docs
                .map((doc) => Car.fromJson(doc.data()))
                .toList();
            status.value = 'success';
          },
          onError: (error) {
            log('Gagal fetch favorit: $error');
            status.value = 'error';
          },
        );
  }

  void deleteFavorite(Car car) async {
    final userId = _authVM.account.value!.uid;
    try {
      await _userSource.toggleFavoriteProduct(userId, car);
      isFavorited.value = !isFavorited.value;
      if (isFavorited.value) {
        Message.success('Produk ditambahkan ke Favorit');
      } else {
        Message.success('Produk dihapus dari Favorit');
      }
    } catch (e) {
      log('Failed to toggle favorite status: $e');
      Message.error('Gagal menambahkan Produk ke Favorit');
    }
  }
}
