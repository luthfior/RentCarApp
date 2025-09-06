class Account {
  final String uid;
  final String fullName;
  final String email;
  final String? username;
  final String? storeName;
  final String? address;
  final String? photoUrl;
  final String role;
  final num balance;
  final num income;
  final String? pin;
  final Map? favProducts;
  final Map? myOrders;
  final List<String>? fcmTokens;
  Account({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.storeName,
    required this.email,
    this.address = '',
    this.photoUrl =
        'https://res.cloudinary.com/dodjmyloc/image/upload/v1756392698/profile_blirky.png',
    required this.role,
    this.balance = 9786500,
    this.income = 0,
    this.pin,
    this.favProducts,
    this.myOrders,
    this.fcmTokens,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'fullName': fullName,
      'username': username,
      'storeName': storeName,
      'email': email,
      'address': address,
      'photoUrl': photoUrl,
      'role': role,
      'balance': balance,
      'income': income,
      'pin': pin,
      'favProducts': favProducts,
      'myOrders': myOrders,
      'fcmTokens': fcmTokens,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      uid: json['uid'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      storeName: json['storeName'] as String,
      email: json['email'] as String,
      address: json['address'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: json['role'] as String,
      balance: json['balance'] as num? ?? 0,
      income: json['income'] as num? ?? 0,
      pin: json['pin'] as String?,
      favProducts: json['favProducts'] != null
          ? Map.from(json['favProducts'] as Map<String, dynamic>)
          : null,
      myOrders: json['myOrders'] != null
          ? Map.from(json['myOrders'] as Map<String, dynamic>)
          : null,
      fcmTokens: json['fcmTokens'] != null
          ? List<String>.from(json['fcmTokens'])
          : null,
    );
  }
}
