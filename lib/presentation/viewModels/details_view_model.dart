import 'package:get/get.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/car_source.dart';

class DetailsViewModel extends GetxController {
  final _car = Car.empty.obs;
  Car get car => _car.value;
  set car(Car n) => _car.value = n;

  final _loading = ''.obs;
  String get loading => _loading.value;
  set loading(String n) => _loading.value = n;

  Future<void> getDetail(String id) async {
    loading = 'loading';

    final cars = await CarSource.fetchCar(id);
    if (cars != null) {
      car = cars;
      loading = 'success';
    } else {
      loading = 'Failed to fetch cars';
      return;
    }
  }
}
