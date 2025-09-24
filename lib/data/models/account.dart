class Account {
  final String uid;
  final String fullName;
  final String email;
  final String username;
  final String storeName;
  final String? fullAddress;
  final String? street;
  final String? province;
  final String? city;
  final String? district;
  final String? village;
  final num? latLocation;
  final num? longLocation;
  final String? photoUrl;
  final String? phoneNumber;
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
    this.fullAddress = '',
    this.street = '',
    this.province = '',
    this.city = '',
    this.district = '',
    this.village = '',
    this.latLocation = -6.200000,
    this.longLocation = 106.816666,
    this.photoUrl =
        'https://res.cloudinary.com/dodjmyloc/image/upload/v1756392698/profile_blirky.png',
    this.phoneNumber = '',
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
      'fullAddress': fullAddress,
      'street': street,
      'province': province,
      'city': city,
      'district': district,
      'village': village,
      'latLocation': latLocation,
      'longLocation': longLocation,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
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
      fullAddress: json['fullAddress'] as String?,
      street: json['street'] as String?,
      province: json['province'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      village: json['village'] as String?,
      latLocation: json['latLocation'] as num? ?? 0,
      longLocation: json['longLocation'] as num? ?? 0,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
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
