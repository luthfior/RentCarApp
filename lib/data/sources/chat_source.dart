import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_car_app/data/models/chat.dart';

class ChatSource {
  static Future<void> openChat(String uid, String username) async {
    final doc = await FirebaseFirestore.instance
        .collection('CS')
        .doc(uid)
        .get();
    if (doc.exists) {
      await FirebaseFirestore.instance.collection('CS').doc(uid).update({
        'newFromCS': false,
      });
      return;
    }

    await FirebaseFirestore.instance.collection('CS').doc(uid).set({
      'roomId': uid,
      'name': username,
      'lastMessage': 'Helo user',
      'newFromUser': false,
      'newFromCS': true,
    });

    await FirebaseFirestore.instance
        .collection('CS')
        .doc(uid)
        .collection('chats')
        .add({
          'chatId': uid,
          'message': 'Halo user',
          'productDetail': null,
          'receiverId': uid,
          'senderId': 'cs',
          'timeStamp': FieldValue.serverTimestamp(),
        });
  }

  static Future<void> send(Chat chat, String uid) async {
    await FirebaseFirestore.instance.collection('CS').doc(uid).update({
      'lastMessage': chat.message,
      'newFromUser': true,
      'newFromCS': false,
    });
    await FirebaseFirestore.instance
        .collection('CS')
        .doc(uid)
        .collection('chats')
        .add({
          'chatId': chat.chatId,
          'message': chat.message,
          'productDetail': chat.productDetail,
          'receiverId': chat.receiverId,
          'senderId': chat.senderId,
          'timeStamp': FieldValue.serverTimestamp(),
        });
  }
}
