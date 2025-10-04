import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:uuid/uuid.dart';

class ChatSource {
  static Future<void> send(
    Chat chat,
    String roomId, {
    required String buyerId,
    required String ownerId,
    required String ownerType,
    required Account currentUser,
    required Account partner,
  }) async {
    try {
      final roomRef = FirebaseFirestore.instance
          .collection('Services')
          .doc(roomId);
      var roomDoc = await roomRef.get();
      if (!roomDoc.exists) {
        try {
          final roomRef = FirebaseFirestore.instance
              .collection('Services')
              .doc(roomId);
          final doc = await roomRef.get();

          if (!doc.exists) {
            await roomRef.set({
              'roomId': roomId,
              'customerId': buyerId,
              'ownerId': ownerId,
              'ownerType': ownerType,
              'participants': [buyerId, ownerId],
              'lastMessage': '',
              'lastMessageTime': Timestamp.now(),
              'unreadCountCustomer': 0,
              'unreadCountOwner': 0,
              'autoMessageSent': false,
              'productDetail': chat.productDetail,
            });

            roomDoc = await roomRef.get();
          }
        } catch (e) {
          log('Error di openChat: $e');
          rethrow;
        }
      }

      final customerId = roomDoc.data()?['customerId'];
      bool sentByCustomer = chat.senderId == customerId;

      await roomRef.update({
        'lastMessage': chat.message,
        'lastMessageTime': Timestamp.now(),
        'unreadCountOwner': sentByCustomer ? FieldValue.increment(1) : 0,
        'unreadCountCustomer': !sentByCustomer ? FieldValue.increment(1) : 0,
        if (chat.productDetail != null) 'productDetail': chat.productDetail,
      });

      await roomRef.collection('chats').doc(chat.chatId).set(chat.toJson());

      if (sentByCustomer) {
        final data = roomDoc.data()!;
        final autoSent = data['autoMessageSent'] ?? false;
        final Timestamp? lastMsgTs = data['lastMessageTime'];

        bool shouldSendAuto = false;

        if (!autoSent) {
          shouldSendAuto = true;
        } else if (lastMsgTs != null) {
          final lastDate = lastMsgTs.toDate();
          final now = DateTime.now();
          if (now.difference(lastDate).inDays >= 1) {
            shouldSendAuto = true;
          }
        }

        if (shouldSendAuto) {
          const autoMessage =
              'Halo, selamat datang! Ini adalah pesan otomatis, silakan tunggu penyedia merespons pesan ini, ya. Terima kasih.';

          Chat autoChat = Chat(
            chatId: const Uuid().v4(),
            message: autoMessage,
            receiverId: customerId,
            senderId: roomDoc.data()?['ownerId'],
            timeStamp: Timestamp.now(),
            productDetail: null,
          );

          await roomRef
              .collection('chats')
              .doc(autoChat.chatId)
              .set(autoChat.toJson());
          await roomRef.update({
            'lastMessage': autoMessage,
            'lastMessageTime': Timestamp.now(),
            'autoMessageSent': true,
          });
        }
      }
    } catch (e) {
      log('Error di ChatSource.send: $e');
      rethrow;
    }
  }
}
