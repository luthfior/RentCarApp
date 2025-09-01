import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/models/orders.dart';

class BookedCar {
  final Orders order;
  final Car car;
  BookedCar({required this.order, required this.car});
}
