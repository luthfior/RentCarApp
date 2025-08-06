import 'package:get/get.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/car_source.dart';

class DetailsViewModel extends GetxController {
  final _car = Car.empty.obs;
  Car get car => _car.value;
  set car(Car n) => _car.value = n;

  final _status = ''.obs;
  String get status => _status.value;
  set status(String n) => _status.value = n;

  Future<void> getDetail(String id) async {
    status = 'loading';

    final cars = await CarSource.fetchCar(id);
    if (cars != null) {
      car = cars;
      status = 'success';
    } else {
      status = 'Failed to fetch cars';
      return;
    }
  }
}
