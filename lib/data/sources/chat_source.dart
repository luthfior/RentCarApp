import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_car_app/data/models/chat.dart';

class ChatSource {
  static Future<void> openChat(String uid, String username) async {
    final doc = await FirebaseFirestore.instance
        .collection('Services')
        .doc(uid)
        .get();
    if (doc.exists) {
      await FirebaseFirestore.instance.collection('Services').doc(uid).update({
        'newFromServices': false,
      });
      return;
    }

    await FirebaseFirestore.instance.collection('Services').doc(uid).set({
      'roomId': uid,
      'name': username,
      'lastMessage': 'Helo user',
      'newFromUser': false,
      'newFromCS': true,
    });

    await FirebaseFirestore.instance
        .collection('Services')
        .doc(uid)
        .collection('chats')
        .add({
          'chatId': uid,
          'message':
              'Halo Selamat Datang! ini adalah pesan otomatis, silahkan tunggu penjual merespon pesan ini ya.',
          'productDetail': null,
          'receiverId': uid,
          'senderId': 'cs',
          'timeStamp': FieldValue.serverTimestamp(),
        });
  }

  static Future<void> send(Chat chat, String uid) async {
    await FirebaseFirestore.instance.collection('Services').doc(uid).update({
      'lastMessage': chat.message,
      'newFromUser': true,
      'newFromCS': false,
    });
    await FirebaseFirestore.instance
        .collection('Services')
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
