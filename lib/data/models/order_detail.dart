import 'package:rent_car_app/data/models/car.dart';

class OrderDetail {
  final Car car;
  final bool withDriver;
  final num driverCostPerDay;
  final String startDate;
  final String endDate;
  final num duration;
  final num subTotal;
  final String agency;
  final String insurance;
  final num totalInsuranceCost;
  final num additionalCost;
  final num totalPrice;
  OrderDetail({
    required this.car,
    required this.withDriver,
    required this.driverCostPerDay,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.subTotal,
    required this.agency,
    required this.insurance,
    required this.totalInsuranceCost,
    required this.additionalCost,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'carDetail': car.toJson(),
      'withDriver': withDriver,
      'driverCost': driverCostPerDay,
      'startDate': startDate,
      'endDate': endDate,
      'duration': duration,
      'subTotal': subTotal,
      'agency': agency,
      'insurance': insurance,
      'totalInsuranceCost': totalInsuranceCost,
      'additionalCost': additionalCost,
      'totalPrice': totalPrice,
    };
  }

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      car: json['carDetail'] != null
          ? Car.fromJson(json['carDetail'] as Map<String, dynamic>)
          : Car.empty,
      withDriver: json['withDriver'] as bool? ?? false,
      driverCostPerDay: json['driverCost'] as num? ?? 0,
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      duration: json['duration'] as num? ?? 0,
      subTotal: json['subTotal'] as num? ?? 0,
      agency: json['agency'] as String? ?? '',
      insurance: json['insurance'] as String? ?? '',
      totalInsuranceCost: json['totalInsuranceCost'] as num? ?? 0,
      additionalCost: json['additionalCost'] as num? ?? 0,
      totalPrice: json['totalPrice'] as num? ?? 0,
    );
  }

  static OrderDetail get empty => OrderDetail(
    car: Car.empty,
    withDriver: false,
    driverCostPerDay: 0,
    startDate: '',
    endDate: '',
    duration: 0,
    subTotal: 0,
    agency: '',
    insurance: '',
    totalInsuranceCost: 0,
    additionalCost: 0,
    totalPrice: 0,
  );
}
