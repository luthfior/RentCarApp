import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:rent_car_app/data/services/notification_service.dart';
import 'package:rent_car_app/data/services/push_notification_service.dart';
import 'package:rent_car_app/data/sources/car_source.dart';
import 'package:rent_car_app/data/sources/chat_source.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:uuid/uuid.dart';

class DetailViewModel extends GetxController {
  DetailViewModel(this.idProduct);
  final String? idProduct;
  final isFavorited = false.obs;
  final userSource = UserSource();
  final authVM = Get.find<AuthViewModel>();
  final firestore = FirebaseFirestore.instance;

  final Rx<Car> _car = Car.empty.obs;
  Car get car => _car.value;
  set car(Car value) => _car.value = value;

  final Rx<Account?> _partner = Rx<Account?>(null);
  Account? get partner => _partner.value;
  set partner(Account? value) => _partner.value = value;

  final _status = ''.obs;
  String get status => _status.value;
  set status(String value) => _status.value = value;

  @override
  void onInit() {
    super.onInit();
    if (idProduct != null && idProduct!.isNotEmpty) {
      getDetail(idProduct!);
    } else {
      log('Error: DetailViewModel tidak ada product ID.');
      status = 'error';
    }
  }

  Future<void> getDetail(String idProduct) async {
    status = 'loading';
    try {
      final data = await CarSource.fetchDetailCar(idProduct);
      if (data == null) {
        status = 'empty';
        car = Car.empty;
        return;
      }
      car = data;
      await fetchPartner(data.ownerId, data.ownerType);
      await checkFavoriteStatus();
      status = 'success';
    } catch (e) {
      status = 'error';
      log('Error fetching detail: $e');
    }
  }

  void toggleFavorite() async {
    final userId = authVM.account.value!.uid;
    try {
      await userSource.toggleFavoriteProduct(userId, car);
      isFavorited.value = !isFavorited.value;
      if (isFavorited.value) {
        Message.success('Produk ditambahkan ke Favorit');
      } else {
        Message.success('Produk dihapus dari Favorit');
      }
    } catch (e) {
      log('Failed to toggle favorite status: $e');
      Message.error('Gagal menambahkan Produk ke Favorit. Coba lagi');
    }
  }

  Future<void> checkFavoriteStatus() async {
    if (authVM.account.value != null) {
      final userId = authVM.account.value!.uid;
      final isFav = await userSource.isProductFavorited(userId, car.id);
      isFavorited.value = isFav;
    }
  }

  Future<void> fetchPartner(String id, String role) async {
    try {
      final collection = (role == 'admin') ? 'Admin' : 'Users';
      final doc = await firestore.collection(collection).doc(id).get();

      if (doc.exists) {
        partner = Account.fromJson(doc.data()!);
      }
    } catch (e) {
      log("Gagal fetch partner/owner: $e");
    }
  }

  Future<void> openChat() async {
    final currentUser = authVM.account.value!;
    final String roomId = '${currentUser.uid}_${car.ownerId}';

    final String partnerId = car.ownerId;
    final String partnerRole = car.ownerType;

    await fetchPartner(partnerId, partnerRole);
    if (partner == null) {
      Message.error('Tidak dapat memulai chat, coba lagi nanti.', fontSize: 12);
      return;
    }

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
        ),
      ),
      barrierDismissible: false,
    );

    if (authVM.account.value != null && _partner.value != null) {
      try {
        Chat chat = Chat(
          chatId: const Uuid().v4(),
          message:
              'Halo, saya tertarik dengan mobil ${car.nameProduct} ${car.releaseProduct}.',
          receiverId: partner!.uid,
          senderId: currentUser.uid,
          productDetail: car.toJson(),
          timeStamp: Timestamp.now(),
        );
        await ChatSource.send(
          chat,
          roomId,
          buyerId: authVM.account.value!.uid,
          ownerId: car.ownerId,
          ownerType: car.ownerType,
          currentUser: currentUser,
          partner: partner!,
        );

        Get.back();
        Get.toNamed(
          '/chatting',
          arguments: {
            'roomId': roomId,
            'customerId': authVM.account.value!.uid,
            'ownerId': car.ownerId,
            'ownerType': car.ownerType,
            'from': 'detail',
          },
        );

        final tokens = partner?.fcmTokens ?? [];
        if (tokens.isNotEmpty) {
          await PushNotificationService.sendToMany(
            tokens,
            "Chat Baru",
            "Kamu mendapat Chat baru dari ${currentUser.fullName.capitalizeFirst}",
            data: {'type': 'chat', 'referenceId': roomId},
          );
        }

        await NotificationService.addNotification(
          userId: partner!.uid,
          title: "Chat Baru",
          body: "Kamu mendapatkan Chat baru dari ${currentUser.fullName}",
          type: "chat",
          referenceId: roomId,
        );
      } catch (e) {
        Get.back();
        log('Gagal membuka chat: $e');
        Message.error('Gagal membuka chat. Coba lagi.');
      }
    } else {
      Get.back();
      log('Data Akun yang login & Data Partner tidak ada');
      Message.error('Gagal membuka chat. Coba lagi.');
    }
  }

  Future<void> refreshCarDetail() async {
    if (idProduct != null && idProduct!.isNotEmpty) {
      log('Refreshing car detail for ID: $idProduct');
      await getDetail(idProduct!);
    }
  }

  Future<void> handleBooked() async {
    final pending = await hasPendingOrder(authVM.account.value!.uid, car.id);
    if (pending) {
      Message.error(
        'Anda sudah memesan produk ini dengan status pending. Periksa pada halaman Pesanan Anda.',
        fontSize: 12,
      );
      return;
    }
    Get.toNamed('/booking', arguments: car);
  }

  Future<bool> hasPendingOrder(String customerId, String productId) async {
    final query = await firestore
        .collection('Orders')
        .where('customerId', isEqualTo: customerId)
        .where('productId', isEqualTo: productId)
        .where('orderStatus', isEqualTo: 'pending')
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }
}
