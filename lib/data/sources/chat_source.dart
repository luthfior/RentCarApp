import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_car_app/data/models/chat.dart';

class ChatSource {
  static Future<void> openChat({
    required String buyerId,
    required String ownerId,
    required String buyerFullName,
    required String buyerUsername,
    required String buyerEmail,
    required String buyerPhotoUrl,
    required String ownerStoreName,
    required String ownerUsername,
    required String ownerEmail,
    required String ownerPhotoUrl,
    required String ownerType,
  }) async {
    try {
      String roomId = "${buyerId}_$ownerId";
      final roomRef = FirebaseFirestore.instance
          .collection('Services')
          .doc(roomId);

      final doc = await roomRef.get();

      if (doc.exists) {
        await roomRef.update({'newFromServices': false});
      } else {
        await roomRef.set({
          'roomId': roomId,
          'lastMessage': 'Halo user',
          'newFromCustomer': false,
          'newFromOwner': true,
          'customerId': buyerId,
          'customerFullName': buyerFullName,
          'customerUsername': buyerUsername,
          'customerEmail': buyerEmail,
          'customerPhotoUrl': buyerPhotoUrl,
          'ownerId': ownerId,
          'ownerStoreName': ownerStoreName,
          'ownerUsername': ownerUsername,
          'ownerEmail': ownerEmail,
          'ownerType': ownerType,
          'ownerPhotoUrl': ownerPhotoUrl,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCountCustomer': 0,
          'unreadCountOwner': 1,
        });

        final chatsRef = roomRef.collection('chats');
        final firstChat = await chatsRef.orderBy('timeStamp').limit(1).get();

        if (firstChat.docs.isEmpty) {
          await chatsRef.add({
            'chatId': roomId,
            'message':
                'Halo, selamat datang! Ini adalah pesan otomatis, silakan tunggu penyedia merespons pesan ini, ya. Terima kasih.',
            'productDetail': null,
            'receiverId': buyerId,
            'senderId': ownerId,
            'timeStamp': FieldValue.serverTimestamp(),
          });
        }
      }
    } on FirebaseException catch (e) {
      log('Terjadi kesalahan pada Firebase: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Terjadi kesalahan: $e');
      rethrow;
    }
  }

  static Future<void> send(Chat chat, String uid, String ownerId) async {
    try {
      String roomId = "${uid}_$ownerId";
      final roomRef = FirebaseFirestore.instance
          .collection('Services')
          .doc(roomId);

      bool fromCustomer = chat.senderId == uid;
      bool fromSeller = chat.senderId == ownerId;

      await roomRef.update({
        'lastMessage': chat.message,
        'newFromCustomer': fromCustomer,
        'newFromOwner': fromSeller,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCountCustomer': fromSeller ? FieldValue.increment(1) : 0,
        'unreadCountOwner': fromCustomer ? FieldValue.increment(1) : 0,
      });

      await roomRef.collection('chats').add({
        'chatId': chat.chatId,
        'message': chat.message,
        'productDetail': chat.productDetail,
        'receiverId': chat.receiverId,
        'senderId': chat.senderId,
        'timeStamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      log('Terjadi kesalahan pada Firebase: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Terjadi kesalahan $e');
      rethrow;
    }
  }
}
