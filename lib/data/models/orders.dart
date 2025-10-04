import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_car_app/data/models/order_detail.dart';

class Orders {
  final String id;
  final String resi;
  final String productId;
  final String customerId;
  final String sellerId;
  final String sellerRole;
  final OrderDetail orderDetail;
  final String orderStatus;
  final Timestamp orderDate;
  final String paymentMethod;
  final String paymentStatus;
  final bool hasBeenReviewed;
  final bool deletedByCustomer;
  final bool deletedBySeller;
  Orders({
    required this.id,
    required this.resi,
    required this.productId,
    required this.customerId,
    required this.sellerId,
    required this.sellerRole,
    required this.orderDetail,
    required this.orderStatus,
    required this.orderDate,
    required this.paymentMethod,
    required this.paymentStatus,
    this.hasBeenReviewed = false,
    this.deletedByCustomer = false,
    this.deletedBySeller = false,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'resi': resi,
      'productId': productId,
      'customerId': customerId,
      'sellerId': sellerId,
      'sellerRole': sellerRole,
      'orderDetail': orderDetail.toJson(),
      'orderStatus': orderStatus,
      'orderDate': orderDate,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'hasBeenReviewed': hasBeenReviewed,
      'deletedByCustomer': deletedByCustomer,
      'deletedBySeller': deletedBySeller,
    };
  }

  factory Orders.fromJson(Map<String, dynamic> json, String docId) {
    return Orders(
      id: docId,
      resi: json['resi'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      sellerRole: json['sellerRole'] as String? ?? '',
      orderDetail: json['orderDetail'] != null
          ? OrderDetail.fromJson(json['orderDetail'] as Map<String, dynamic>)
          : OrderDetail.empty,
      orderStatus: json['orderStatus'] as String? ?? '',
      orderDate: json['orderDate'] as Timestamp? ?? Timestamp.now(),
      paymentMethod: json['paymentMethod'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? '',
      hasBeenReviewed: json['hasBeenReviewed'] as bool? ?? false,
      deletedByCustomer: json['deletedByCustomer'] as bool? ?? false,
      deletedBySeller: json['deletedBySeller'] as bool? ?? false,
    );
  }

  static Orders get empty => Orders(
    id: '',
    resi: '',
    productId: '',
    customerId: '',
    sellerId: '',
    sellerRole: '',
    orderDetail: OrderDetail.empty,
    orderStatus: '',
    orderDate: Timestamp.now(),
    paymentMethod: '',
    paymentStatus: '',
    hasBeenReviewed: false,
    deletedByCustomer: false,
    deletedBySeller: false,
  );
}
