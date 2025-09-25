import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_car_app/data/models/order_detail.dart';

class Orders {
  final String id;
  final String resi;
  final String customerId;
  final String sellerId;
  final String customerFullname;
  final String sellerStoreName;
  final String customerAddress;
  final String sellerAddress;
  final OrderDetail orderDetail;
  final String orderStatus;
  final Timestamp orderDate;
  final String paymentMethod;
  final String paymentStatus;
  final bool hasBeenReviewed;
  Orders({
    required this.id,
    required this.resi,
    required this.customerId,
    required this.sellerId,
    required this.customerFullname,
    required this.sellerStoreName,
    required this.customerAddress,
    required this.sellerAddress,
    required this.orderDetail,
    required this.orderStatus,
    required this.orderDate,
    required this.paymentMethod,
    required this.paymentStatus,
    this.hasBeenReviewed = false,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'resi': resi,
      'customerId': customerId,
      'sellerId': sellerId,
      'customerFullname': customerFullname,
      'sellerStoreName': sellerStoreName,
      'customerAddress': customerAddress,
      'sellerAddress': sellerAddress,
      'orderDetail': orderDetail.toJson(),
      'orderStatus': orderStatus,
      'orderDate': orderDate,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'hasBeenReviewed': hasBeenReviewed,
    };
  }

  factory Orders.fromJson(Map<String, dynamic> json, String docId) {
    return Orders(
      id: docId,
      resi: json['resi'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      customerFullname: json['customerFullname'] as String? ?? '',
      sellerStoreName: json['sellerStoreName'] as String? ?? '',
      customerAddress: json['customerAddress'] as String? ?? '',
      sellerAddress: json['sellerAddress'] as String? ?? '',
      orderDetail: json['orderDetail'] != null
          ? OrderDetail.fromJson(json['orderDetail'] as Map<String, dynamic>)
          : OrderDetail.empty,
      orderStatus: json['orderStatus'] as String? ?? '',
      orderDate: json['orderDate'] as Timestamp? ?? Timestamp.now(),
      paymentMethod: json['paymentMethod'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? '',
      hasBeenReviewed: json['hasBeenReviewed'] as bool? ?? false,
    );
  }

  static Orders get empty => Orders(
    id: '',
    resi: '',
    customerId: '',
    sellerId: '',
    customerFullname: '',
    sellerStoreName: '',
    customerAddress: '',
    sellerAddress: '',
    orderDetail: OrderDetail.empty,
    orderStatus: '',
    orderDate: Timestamp.now(),
    paymentMethod: '',
    paymentStatus: '',
    hasBeenReviewed: false,
  );
}
