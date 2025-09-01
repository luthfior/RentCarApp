import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:rent_car_app/data/sources/chat_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:uuid/uuid.dart';

class ChatViewModel extends GetxController {
  final authVM = Get.find<AuthViewModel>();

  final Rx<String?> _roomId = Rx<String?>(null);
  String? get roomId => _roomId.value;
  set roomId(String? value) => _roomId.value = value;

  final Rx<String?> _uid = Rx<String?>(null);
  String? get uid => _uid.value;
  set uid(String? value) => _uid.value = value;

  final Rx<String?> _ownerType = Rx<String?>(null);
  String? get ownerType => _ownerType.value;
  set ownerType(String? value) => _ownerType.value = value;

  final Rx<String?> _ownerId = Rx<String?>(null);
  String? get ownerId => _ownerId.value;
  set ownerId(String? value) => _ownerId.value = value;

  final Rx<Account?> _partner = Rx<Account?>(null);
  Account? get partner => _partner.value;
  set partner(Account? value) => _partner.value = value;

  final edtInput = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final Rx<Stream<QuerySnapshot<Map<String, dynamic>>>?> _streamChat =
      Rx<Stream<QuerySnapshot<Map<String, dynamic>>>?>(null);
  Stream<QuerySnapshot<Map<String, dynamic>>>? get streamChat =>
      _streamChat.value;

  final Set<String> skippedIds = {};

  @override
  void onInit() {
    super.onInit();
    resetForm();
  }

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      roomId = args['roomId'] as String?;
      uid = args['uid'] as String?;
      ownerId = args['ownerId'] as String?;
      ownerType = args['ownerType'] as String?;

      if (args['partner'] != null) {
        final partnerInfo = args['partner'] as Map<String, dynamic>;
        partner = Account(
          uid: partnerInfo['id'],
          name: partnerInfo['name'],
          email: partnerInfo['email'],
          photoUrl: partnerInfo['photoUrl'],
          role: partnerInfo['type'],
        );
      } else {
        final currentUser = authVM.account.value;
        if (currentUser != null) {
          if (currentUser.uid == uid && ownerId != null && ownerType != null) {
            fetchPartner(ownerId!, ownerType!);
          } else if (currentUser.uid == ownerId && uid != null) {
            fetchPartner(uid!, "user");
          }
        }
      }

      if (uid != null && ownerId != null) {
        _streamChat.value = _firestore
            .collection('Services')
            .doc("${uid}_$ownerId")
            .collection('chats')
            .orderBy('timeStamp', descending: true)
            .snapshots();
      }
    }
  }

  @override
  void onClose() {
    edtInput.dispose();
    super.onClose();
  }

  void resetForm() {
    edtInput.clear();
  }

  Future<void> sendMessage() async {
    final message = edtInput.text.trim();
    if (message.isEmpty) return;

    final currentUser = authVM.account.value;
    if (currentUser == null || ownerId == null) return;

    try {
      Chat chat = Chat(
        chatId: const Uuid().v4(),
        message: message,
        productDetail: null,
        receiverId: ownerId!,
        senderId: currentUser.uid,
        timeStamp: Timestamp.now(),
      );

      await ChatSource.send(chat, uid!, ownerId!);
      edtInput.clear();
    } catch (e) {
      Message.error('Gagal mengirim Pesan. Coba lagi');
      log('Error sending message: $e');
    }
  }

  Future<void> fetchPartner(String id, String type) async {
    final collection = (type == 'admin') ? 'Admin' : 'Users';
    final doc = await _firestore.collection(collection).doc(id).get();

    if (doc.exists) {
      partner = Account.fromJson(doc.data()!);
    }
  }

  Chat? getFirstProductChat(List<Chat> chats) {
    return chats.firstWhereOrNull((c) => c.productDetail != null);
  }

  List<Chat> filterChats(List<QueryDocumentSnapshot> docs) {
    skippedIds.clear();
    final chats = docs
        .map((d) => Chat.fromJson(d.data() as Map<String, dynamic>))
        .toList();

    for (int i = 0; i < chats.length; i++) {
      final chat = chats[i];
      if (chat.productDetail != null && i + 1 < chats.length) {
        final nextChat = chats[i + 1];
        if (nextChat.senderId == ownerId && nextChat.message.isNotEmpty) {
          skippedIds.add(nextChat.chatId);
        }
      }
    }

    return chats;
  }
}
