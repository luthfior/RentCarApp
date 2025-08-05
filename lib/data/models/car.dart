class Car {
  final String categoryProduct;
  final String descriptionProduct;
  final String id;
  String imageProduct;
  final String nameProduct;
  final num priceProduct;
  final num ratingProduct;
  final num releaseProduct;
  final String transmissionProduct;
  Car({
    required this.categoryProduct,
    required this.descriptionProduct,
    required this.id,
    required this.imageProduct,
    required this.nameProduct,
    required this.priceProduct,
    required this.ratingProduct,
    required this.releaseProduct,
    required this.transmissionProduct,
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
      'transmissionProduct': transmissionProduct,
    };
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      categoryProduct: json['categoryProduct'] as String,
      descriptionProduct: json['descriptionProduct'] as String,
      id: json['id'] as String,
      imageProduct: json['imageProduct'] as String,
      nameProduct: json['nameProduct'] as String,
      priceProduct: json['priceProduct'] as num,
      ratingProduct: json['ratingProduct'] as num,
      releaseProduct: json['releaseProduct'] as num,
      transmissionProduct: json['transmissionProduct'] as String,
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
    transmissionProduct: '',
  );
}
