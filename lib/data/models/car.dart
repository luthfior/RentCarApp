class Car {
  final String categoryProduct;
  final String descriptionProduct;
  final String id;
  final String imageProduct;
  final String nameProduct;
  final num priceProduct;
  final num ratingProduct;
  final num releaseProduct;
  final num purchasedProduct;
  final String transmissionProduct;
  final String ownerId;
  final String ownerType;
  final String ownerName;
  final String ownerEmail;
  final String ownerPhotoUrl;
  final String? address;
  final String? province;
  final String? city;
  final String? district;
  final String? village;
  Car({
    required this.categoryProduct,
    required this.descriptionProduct,
    required this.id,
    required this.imageProduct,
    required this.nameProduct,
    required this.priceProduct,
    required this.ratingProduct,
    required this.releaseProduct,
    required this.purchasedProduct,
    required this.transmissionProduct,
    required this.ownerId,
    required this.ownerType,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerPhotoUrl,
    this.address,
    this.province,
    this.city,
    this.district,
    this.village,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'categoryProduct': categoryProduct,
      'descriptionProduct': descriptionProduct,
      'id': id,
      'imageProduct': imageProduct,
      'nameProduct': nameProduct,
      'priceProduct': priceProduct,
      'ratingProduct': ratingProduct,
      'releaseProduct': releaseProduct,
      'purchasedProduct': purchasedProduct,
      'transmissionProduct': transmissionProduct,
      'ownerId': ownerId,
      'ownerType': ownerType,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'ownerPhotoUrl': ownerPhotoUrl,
      'address': address,
      'province': province,
      'city': city,
      'district': district,
      'village': village,
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
      ratingProduct: json['ratingProduct'] as num? ?? 0,
      releaseProduct: json['releaseProduct'] as num? ?? 0,
      purchasedProduct: json['purchasedProduct'] as num? ?? 0,
      transmissionProduct: json['transmissionProduct'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      ownerType: json['ownerType'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      ownerEmail: json['ownerEmail'] as String? ?? '',
      ownerPhotoUrl: json['ownerPhotoUrl'] as String? ?? '',
      address: json['address'] as String? ?? '',
      province: json['province'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      village: json['village'] as String? ?? '',
    );
  }

  static Car get empty => Car(
    categoryProduct: '',
    descriptionProduct: '',
    id: '',
    imageProduct: '',
    nameProduct: '',
    priceProduct: 0,
    ratingProduct: 0,
    releaseProduct: 0,
    purchasedProduct: 0,
    transmissionProduct: '',
    ownerId: '',
    ownerType: '',
    ownerName: '',
    ownerEmail: '',
    ownerPhotoUrl: '',
    address: '',
    province: '',
    city: '',
    district: '',
    village: '',
  );
}
