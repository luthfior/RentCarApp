import 'dart:developer';

import 'package:get/get.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/car_source.dart';

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

  getDetail(String idProduct) async {
    status = 'loading';

    try {
      final data = await CarSource.fetchCar(idProduct);
      if (data == null) {
        status = '';
        return;
      }
      status = 'success';
      car = data;
    } catch (e) {
      status = 'error';
      log('Error fetching detail: $e');
    }
  }
}
