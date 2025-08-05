import 'package:get/get.dart';

class BookingViewModel extends GetxController {
  final RxMap _car = {}.obs;
  Map get car => _car;
  set car(Map n) => _car.value = n;

  void setDummyBook() {
    _car.value = {
      'name': 'Hyundai Ioniq 5',
      'image':
          'https://dealermobilhyundai.com/wp-content/uploads/2022/11/Hyundai-Ioniq-5.png',
    };
  }

  void clearBooking() {
    _car.clear();
  }
}
