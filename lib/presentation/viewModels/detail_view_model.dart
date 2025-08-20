import 'dart:developer';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/car_source.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class DetailViewModel extends GetxController {
  final String? idProduct;
  DetailViewModel(this.idProduct) {
    if (idProduct != null) {
      getDetail(idProduct!);
    } else {
      log('Error: DetailViewModel initialized with a null product ID.');
      status = 'error';
    }
  }

  final Rx<Car> _car = Car.empty.obs;
  Car get car => _car.value;
  set car(Car value) => _car.value = value;

  final _status = ''.obs;
  String get status => _status.value;
  set status(String value) => _status.value = value;

  final isFavorited = false.obs;
  final _userSource = UserSource();
  final _authVM = Get.find<AuthViewModel>();

  Future<void> getDetail(String idProduct) async {
    status = 'loading';

    try {
      final data = await CarSource.fetchCar(idProduct);
      if (data == null) {
        status = '';
        return;
      }
      status = 'success';
      car = data;
      await checkFavoriteStatus();
    } catch (e) {
      status = 'error';
      log('Error fetching detail: $e');
    }
  }

  void toggleFavorite() async {
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
      Message.error('Gagal menambahkan Produk ke Favorit. Coba lagi');
    }
  }

  Future<void> checkFavoriteStatus() async {
    if (_authVM.account.value != null) {
      final userId = _authVM.account.value!.uid;
      final isFav = await _userSource.isProductFavorited(userId, car.id);
      isFavorited.value = isFav;
    }
  }
}
