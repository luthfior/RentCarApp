class Account {
  final String uid;
  final String name;
  final String email;
  final String? address;
  final String? photoUrl;
  final String role;
  final num balance;
  final String? pin;
  final Map? favProducts;
  final Map? myOrders;
  Account({
    required this.uid,
    required this.name,
    required this.email,
    this.address = '',
    this.photoUrl =
        'https://res.cloudinary.com/dodjmyloc/image/upload/v1756392698/profile_blirky.png',
    required this.role,
    this.balance = 9786500,
    this.pin,
    this.favProducts,
    this.myOrders,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'address': address,
      'photoUrl': photoUrl,
      'role': role,
      'balance': balance,
      'pin': pin,
      'favProducts': favProducts,
      'myOrders': myOrders,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      address: json['address'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: json['role'] as String,
      balance: json['balance'] as num? ?? 0,
      pin: json['pin'] as String?,
      favProducts: json['favProducts'] != null
          ? Map.from(json['favProducts'] as Map<String, dynamic>)
          : null,
      myOrders: json['myOrders'] != null
          ? Map.from(json['myOrders'] as Map<String, dynamic>)
          : null,
    );
  }
}
