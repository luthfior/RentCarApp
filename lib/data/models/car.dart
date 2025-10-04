import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String categoryProduct;
  final String descriptionProduct;
  final String id;
  final String imageProduct;
  final String nameProduct;
  final num priceProduct;
  final num ratingAverage;
  final num reviewCount;
  final num releaseProduct;
  final num purchasedProduct;
  final String brandProduct;
  final String? transmissionProduct;
  final String? energySourceProduct;
  final String ownerId;
  final String ownerType;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  Car({
    required this.categoryProduct,
    required this.descriptionProduct,
    required this.id,
    required this.imageProduct,
    required this.nameProduct,
    required this.priceProduct,
    required this.ratingAverage,
    required this.reviewCount,
    required this.releaseProduct,
    required this.purchasedProduct,
    required this.brandProduct,
    this.transmissionProduct,
    this.energySourceProduct,
    required this.ownerId,
    required this.ownerType,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'categoryProduct': categoryProduct,
      'descriptionProduct': descriptionProduct,
      'id': id,
      'imageProduct': imageProduct,
      'nameProduct': nameProduct,
      'priceProduct': priceProduct,
      'ratingAverage': ratingAverage,
      'reviewCount': reviewCount,
      'releaseProduct': releaseProduct,
      'purchasedProduct': purchasedProduct,
      'brandProduct': brandProduct,
      'transmissionProduct': transmissionProduct,
      'energySourceProduct': energySourceProduct,
      'ownerId': ownerId,
      'ownerType': ownerType,
      'createdAt': createdAt,
      'updateAt': updatedAt,
    };
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      categoryProduct: json['categoryProduct'] as String? ?? '',
      descriptionProduct: json['descriptionProduct'] as String? ?? '',
      id: json['id'] as String? ?? '',
      imageProduct: json['imageProduct'] as String? ?? '',
      nameProduct: json['nameProduct'] as String? ?? '',
      priceProduct: json['priceProduct'] as num? ?? 0,
      ratingAverage: json['ratingAverage'] as num? ?? 0,
      reviewCount: json['reviewCount'] as num? ?? 0,
      releaseProduct: json['releaseProduct'] as num? ?? 0,
      purchasedProduct: json['purchasedProduct'] as num? ?? 0,
      brandProduct: json['brandProduct'] as String? ?? '',
      transmissionProduct: json['transmissionProduct'] as String? ?? '',
      energySourceProduct: json['energySourceProduct'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      ownerType: json['ownerType'] as String? ?? '',
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: json['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  static Car get empty => Car(
    categoryProduct: '',
    descriptionProduct: '',
    id: '',
    imageProduct: '',
    nameProduct: '',
    priceProduct: 0,
    ratingAverage: 0,
    reviewCount: 0,
    releaseProduct: 0,
    purchasedProduct: 0,
    brandProduct: '',
    transmissionProduct: '',
    energySourceProduct: '',
    ownerId: '',
    ownerType: '',
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  );
}
