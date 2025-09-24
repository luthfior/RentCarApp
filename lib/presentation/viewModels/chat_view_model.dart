import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:rent_car_app/data/services/notification_service.dart';
import 'package:rent_car_app/data/services/push_notification_service.dart';
import 'package:rent_car_app/data/sources/chat_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';
import 'package:uuid/uuid.dart';

class ChatViewModel extends GetxController {
  final authVM = Get.find<AuthViewModel>();
  final discoverVM = Get.find<DiscoverViewModel>();

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

  final Rx<String?> _customerId = Rx<String?>(null);
  String? get customerId => _customerId.value;
  set customerId(String? value) => _customerId.value = value;

  final Rx<String?> _from = Rx<String?>(null);
  String? get from => _from.value;
  set from(String? value) => _from.value = value;

  final Rx<Map<dynamic, dynamic>?> _productDetail = Rx<Map<dynamic, dynamic>?>(
    null,
  );
  Map<dynamic, dynamic>? get productDetail => _productDetail.value;
  set productDetail(Map<dynamic, dynamic>? value) =>
      _productDetail.value = value;

  final RxString partnerStatus = 'loading'.obs;
  final Rx<Account?> _partner = Rx<Account?>(null);
  Account? get partner => _partner.value;
  set partner(Account? value) => _partner.value = value;

  final edtInput = TextEditingController();

  final _firestore = FirebaseFirestore.instance;

  final Rx<Stream<QuerySnapshot<Map<String, dynamic>>>?> _streamChat =
      Rx<Stream<QuerySnapshot<Map<String, dynamic>>>?>(null);
  Stream<QuerySnapshot<Map<String, dynamic>>>? get streamChat =>
      _streamChat.value;

  final RxBool _isSending = false.obs;
  bool get isSending => _isSending.value;

  @override
  void onInit() {
    super.onInit();
    edtInput.clear();
  }

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      from = args['from'] as String?;
      roomId = args['roomId'] as String?;
      if (args['productDetail'] is Map) {
        productDetail = args['productDetail'] as Map<dynamic, dynamic>?;
      }
      if (roomId != null) {
        _streamChat.value = _firestore
            .collection('Services')
            .doc(roomId)
            .collection('chats')
            .orderBy('timeStamp', descending: true)
            .snapshots();
      }

      if (productDetail == null) {
        _firestore.collection('Services').doc(roomId).get().then((doc) {
          if (doc.exists) {
            productDetail =
                doc.data()?['productDetail'] as Map<dynamic, dynamic>?;
          }
        });
      }

      if (args['customerId'] != null &&
          args['ownerId'] != null &&
          args['ownerType'] != null) {
        customerId = args['customerId'] as String?;
        ownerId = args['ownerId'] as String?;
        ownerType = args['ownerType'] as String?;
        final currentUser = authVM.account.value!;
        if (currentUser.uid == ownerId) {
          uid = ownerId;
          fetchPartner(customerId!, 'customer');
        } else {
          uid = customerId;
          fetchPartner(ownerId!, ownerType!);
        }
      }
    }
  }

  @override
  void onClose() {
    edtInput.dispose();
    super.onClose();
  }

  void handleBackNavigation() {
    if (from == 'detail' || from == 'detail-order') {
      Get.back();
    } else if (from == 'order') {
      Get.until((route) => route.settings.name == '/discover');
      if (authVM.account.value?.role == 'admin') {
        discoverVM.setFragmentIndex(2);
      } else {
        discoverVM.setFragmentIndex(1);
      }
    } else if (from == 'favorite') {
      Get.until((route) => route.settings.name == '/discover');
      discoverVM.setFragmentIndex(3);
    } else {
      Get.until((route) => route.settings.name == '/discover');
      if (authVM.account.value?.role == 'admin') {
        discoverVM.setFragmentIndex(3);
      } else {
        discoverVM.setFragmentIndex(2);
      }
    }
  }

  Future<void> refreshChat() async {
    if (partner != null) {
      log('Refreshing partner data...');
      try {
        final currentUser = authVM.account.value!;
        if (currentUser.uid == ownerId) {
          await fetchPartner(customerId!, 'customer');
        } else {
          await fetchPartner(ownerId!, ownerType!);
        }
      } catch (e) {
        log('Failed to refresh partner data: $e');
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> sendMessageWithNotification() async {
    if (_isSending.value) return;
    final message = edtInput.text.trim();
    if (message.isEmpty) return;

    final currentUser = authVM.account.value;
    if (currentUser == null || partner == null) return;

    _isSending.value = true;
    try {
      final snapshot = await _firestore
          .collection('Services')
          .doc(roomId)
          .collection('chats')
          .limit(1)
          .get();

      final includeProductDetail =
          snapshot.docs.isEmpty && productDetail != null;

      Chat chat = Chat(
        chatId: const Uuid().v4(),
        message: message,
        productDetail: includeProductDetail ? productDetail : null,
        receiverId: partner!.uid,
        senderId: currentUser.uid,
        timeStamp: Timestamp.now(),
      );

      await ChatSource.send(
        chat,
        roomId!,
        buyerId: customerId!,
        ownerId: ownerId!,
        ownerType: ownerType!,
        currentUser: currentUser,
        partner: partner!,
      );
      edtInput.clear();

      final partnerChat = partner;
      if (partnerChat != null) {
        final String? displayName;
        if (currentUser.role == 'customer') {
          if (currentUser.username.contains('#')) {
            final parts = currentUser.username.split('#');
            final rawName = parts[0].replaceAll('_', ' ');
            final suffix = parts[1];
            final capitalized = rawName
                .split(' ')
                .map(
                  (w) => w.isNotEmpty
                      ? "${w[0].toUpperCase()}${w.substring(1)}"
                      : w,
                )
                .join(' ');
            displayName = "$capitalized #$suffix";
          } else {
            displayName = currentUser.fullName;
          }
        } else {
          displayName = currentUser.storeName;
        }
        final tokens = partnerChat.fcmTokens ?? [];
        if (tokens.isNotEmpty) {
          await PushNotificationService.sendToMany(
            tokens,
            "Chat Baru",
            "Kamu mendapat Chat baru dari ${displayName.capitalizeFirst}",
            data: {'type': 'chat', 'referenceId': roomId!},
          );
        } else {
          log('gagal kirim push notification');
          log('token lawan chat: $tokens');
        }
        await NotificationService.addNotification(
          userId: partnerChat.uid,
          title: "Chat Baru",
          body:
              "Kamu mendapatkan Chat baru dari ${displayName.capitalizeFirst}",
          type: "chat",
          referenceId: roomId,
        );
      }
    } catch (e) {
      Message.error('Gagal mengirim Pesan. Coba lagi');
      log('Error sending message: $e');
    } finally {
      _isSending.value = false;
    }
  }

  Future<void> fetchPartner(String id, String role) async {
    try {
      partnerStatus.value = 'loading';
      final collection = (role == 'admin') ? 'Admin' : 'Users';
      final doc = await _firestore.collection(collection).doc(id).get();

      if (doc.exists) {
        partner = Account.fromJson(doc.data()!);
        partnerStatus.value = 'success';
      } else {
        partnerStatus.value = 'error';
      }
    } catch (e) {
      log("Gagal fetch partner: $e");
      partnerStatus.value = 'error';
    }
  }

  List<Chat> filterChats(List<QueryDocumentSnapshot> docs) {
    final chats = docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      return Chat.fromJson({...data, 'chatId': d.id});
    }).toList();

    return chats;
  }
}
