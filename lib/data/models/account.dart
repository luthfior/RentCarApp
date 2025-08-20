class Account {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final num balance;
  final String? pin;
  final Map? favProducts;
  Account({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.balance = 8740900,
    this.pin,
    this.favProducts,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'balance': balance,
      'pin': pin,
      'favProducts': favProducts,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      balance: json['balance'] as num? ?? 0,
      pin: json['pin'] as String?,
      favProducts: json['favProducts'] != null
          ? Map.from(json['favProducts'] as Map<String, dynamic>)
          : null,
    );
  }
}
