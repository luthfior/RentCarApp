class Account {
  final String uid;
  final String name;
  final String email;
  final num balance;
  final String? pin;
  Account({
    required this.uid,
    required this.name,
    required this.email,
    this.balance = 8740900,
    this.pin,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'balance': balance,
      'pin': pin,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      balance: json['balance'] as num? ?? 0,
      pin: json['pin'] as String?,
    );
  }
}
