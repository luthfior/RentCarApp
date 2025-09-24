import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final String message;
  final Map? productDetail;
  final String receiverId;
  final String senderId;
  final Timestamp timeStamp;
  Chat({
    required this.chatId,
    required this.message,
    this.productDetail,
    required this.receiverId,
    required this.senderId,
    required this.timeStamp,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'chatId': chatId,
      'message': message,
      'productDetail': productDetail,
      'receiverId': receiverId,
      'senderId': senderId,
      'timeStamp': timeStamp,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chatId'] as String,
      message: json['message'] as String,
      productDetail: json['productDetail'] != null
          ? Map.from(json['productDetail'] as Map<String, dynamic>)
          : null,
      receiverId: json['receiverId'] as String,
      senderId: json['senderId'] as String,
      timeStamp: json['timeStamp'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
