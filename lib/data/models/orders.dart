import 'package:cloud_firestore/cloud_firestore.dart';

class Orders {
  final String id;
  final String resi;
  final String customerId;
  final String sellerId;
  final String productId;
  final String productName;
  final num productPrice;
  final String orderStatus;
  final Timestamp orderDate;
  final String customerAddress;
  final String sellerAddress;
  Orders({
    required this.id,
    required this.resi,
    required this.customerId,
    required this.sellerId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.orderStatus,
    required this.orderDate,
    required this.customerAddress,
    required this.sellerAddress,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'resi': resi,
      'customerId': customerId,
      'sellerId': sellerId,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'orderStatus': orderStatus,
      'orderDate': orderDate,
      'customerAddress': customerAddress,
      'sellerAddress': sellerAddress,
    };
  }

  factory Orders.fromJson(Map<String, dynamic> json, String docId) {
    return Orders(
      id: docId,
      resi: json['resi'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      productPrice: json['productPrice'] as num? ?? 0,
      orderStatus: json['orderStatus'] as String? ?? '',
      orderDate: json['orderDate'] as Timestamp? ?? Timestamp.now(),
      customerAddress: json['customerAddress'] as String? ?? '',
      sellerAddress: json['sellerAddress'] as String? ?? '',
    );
  }
}
