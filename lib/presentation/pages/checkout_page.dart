import 'package:flutter/material.dart';
import 'package:rent_car_app/data/models/car.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({
    super.key,
    required this.car,
    required this.startDate,
    required this.endDate,
  });
  final Car car;
  final String startDate;
  final String endDate;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
