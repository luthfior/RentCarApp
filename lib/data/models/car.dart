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
  final String transmissionProduct;
  final String ownerId;
  final String ownerType;
  final String ownerStoreName;
  final String ownerFullName;
  final String ownerUsername;
  final String ownerEmail;
  final String ownerPhotoUrl;
  final String ownerPhoneNumber;
  final String fullAddress;
  final String street;
  final String province;
  final String city;
  final String district;
  final String village;
  final num latLocation;
  final num longLocation;
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
    required this.transmissionProduct,
    required this.ownerId,
    required this.ownerType,
    required this.ownerStoreName,
    required this.ownerUsername,
    required this.ownerFullName,
    required this.ownerEmail,
    required this.ownerPhotoUrl,
    required this.ownerPhoneNumber,
    this.createdAt,
    this.updatedAt,
    required this.fullAddress,
    required this.street,
    required this.province,
    required this.city,
    required this.district,
    required this.village,
    required this.latLocation,
    required this.longLocation,
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
      'transmissionProduct': transmissionProduct,
      'ownerId': ownerId,
      'ownerType': ownerType,
      'ownerStoreName': ownerStoreName,
      'ownerUsername': ownerUsername,
      'ownerFullName': ownerFullName,
      'ownerEmail': ownerEmail,
      'ownerPhotoUrl': ownerPhotoUrl,
      'ownerPhoneNumber': ownerPhoneNumber,
      'fullAddress': fullAddress,
      'street': street,
      'province': province,
      'city': city,
      'district': district,
      'village': village,
      'latLocation': latLocation,
      'longLocation': longLocation,
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
      transmissionProduct: json['transmissionProduct'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      ownerType: json['ownerType'] as String? ?? '',
      ownerStoreName: json['ownerStoreName'] as String? ?? '',
      ownerUsername: json['ownerUsername'] as String? ?? '',
      ownerFullName: json['ownerFullName'] as String? ?? '',
      ownerEmail: json['ownerEmail'] as String? ?? '',
      ownerPhotoUrl: json['ownerPhotoUrl'] as String? ?? '',
      ownerPhoneNumber: json['ownerPhoneNumber'] as String? ?? '',
      fullAddress: json['fullAddress'] as String? ?? '',
      street: json['street'] as String? ?? '',
      province: json['province'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      village: json['village'] as String? ?? '',
      latLocation: json['latLocation'] as num? ?? 0,
      longLocation: json['longLocation'] as num? ?? 0,
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
    transmissionProduct: '',
    ownerId: '',
    ownerType: '',
    ownerStoreName: '',
    ownerEmail: '',
    ownerUsername: '',
    ownerFullName: '',
    ownerPhotoUrl: '',
    ownerPhoneNumber: '',
    fullAddress: '',
    street: '',
    province: '',
    city: '',
    district: '',
    village: '',
    latLocation: -6.200000,
    longLocation: 106.816666,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  );
}
