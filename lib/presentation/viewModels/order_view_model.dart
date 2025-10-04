import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/models/booked_car.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:rent_car_app/data/services/notification_service.dart';
import 'package:rent_car_app/data/services/push_notification_service.dart';
import 'package:rent_car_app/data/sources/car_source.dart';
import 'package:rent_car_app/data/sources/chat_source.dart';
import 'package:rent_car_app/data/sources/seller_source.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:uuid/uuid.dart';

class OrderViewModel extends GetxController {
  final firestore = FirebaseFirestore.instance;
  final authVM = Get.find<AuthViewModel>();
  final userSource = UserSource();
  final sellerSource = SellerSource();

  final status = ''.obs;
  final myOrders = <BookedCar>[].obs;
  StreamSubscription<List<BookedCar>>? _ordersSubscription;
  final hasShownTutorial = false.obs;
  final box = GetStorage();

  final Rx<Account?> _partner = Rx<Account?>(null);
  Account? get partner => _partner.value;
  set partner(Account? value) => _partner.value = value;

  @override
  void onInit() {
    super.onInit();
    if (authVM.account.value != null) {
      startOrdersListener();
    } else {
      myOrders.clear();
      status.value = 'empty';
    }
  }

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    super.onClose();
  }

  void _checkAndShowTutorial() {
    final bool shouldShow =
        myOrders.isNotEmpty && !(box.read('hasShownSwipeTutorial') ?? false);
    hasShownTutorial.value = shouldShow;
  }

  void dismissTutorial() {
    box.write('hasShownSwipeTutorial', true);
    hasShownTutorial.value = false;
  }

  Future<void> startOrdersListener() async {
    status.value = 'loading';
    final userId = authVM.account.value!.uid;
    final userRole = authVM.account.value!.role;

    if (authVM.account.value?.uid == null) {
      status.value = 'empty';
      myOrders.clear();
      return;
    }

    _ordersSubscription?.cancel();
    _ordersSubscription = userSource
        .fetchBookedCarStream(userId, userRole)
        .listen(
          (updatedOrders) {
            if (updatedOrders.isEmpty) {
              myOrders.clear();
              status.value = 'empty';
            } else {
              myOrders.value = updatedOrders;
              status.value = 'success';
            }
            _checkAndShowTutorial();
          },
          onError: (error) {
            myOrders.clear();
            status.value = 'error';
            log('Gagal Mengambil Data Order');
            _checkAndShowTutorial();
          },
        );
  }

  String formatDate(DateTime date) {
    final orderDateFormatter = DateFormat("dd MMMM yyyy", "id_ID");
    return orderDateFormatter.format(date);
  }

  Future<void> sendNotification(
    String customerId,
    String sellerId,
    String title,
    String body,
    String type,
    String referenceId,
  ) async {
    if (partner == null) {
      log("Partner belum dimuat, notifikasi dibatalkan");
      return;
    }
    final tokens = partner?.fcmTokens ?? [];

    if (tokens.isNotEmpty) {
      await PushNotificationService.sendToMany(
        tokens,
        title,
        body,
        data: {'type': type, 'referenceId': referenceId},
      );
    } else {
      log('Gagal kirim push notification: token kosong');
    }

    await NotificationService.addNotification(
      userId: customerId,
      title: title,
      body: body,
      type: type,
      referenceId: referenceId,
    );
  }

  Future<void> fetchPartner(String id, String role) async {
    final collection = (role == 'admin') ? 'Admin' : 'Users';
    final doc = await firestore.collection(collection).doc(id).get();

    if (doc.exists) {
      partner = Account.fromJson(doc.data()!);
    }
  }

  Future<void> openChatWithPartner(
    BookedCar bookedCar, {
    String? message,
  }) async {
    final currentUser = authVM.account.value!;
    final isCurrentUserSeller =
        currentUser.role == 'admin' || currentUser.role == 'seller';

    final String buyerId = isCurrentUserSeller
        ? bookedCar.order.customerId
        : currentUser.uid;
    final String ownerId = isCurrentUserSeller
        ? currentUser.uid
        : bookedCar.order.sellerId;
    final String roomId = '${buyerId}_$ownerId';

    final String partnerId = isCurrentUserSeller ? buyerId : ownerId;
    final String partnerRole = isCurrentUserSeller
        ? 'customer'
        : bookedCar.car.ownerType;

    await fetchPartner(partnerId, partnerRole);
    if (partner == null) {
      Message.error('Gagal memulai chat.');
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

    try {
      final Car carInfo = bookedCar.car;

      if (message != null && message.isNotEmpty) {
        // final chatsRef = firestore
        //     .collection('Services')
        //     .doc(roomId)
        //     .collection('chats');
        // final chatsSnapshot = await chatsRef.get();

        // bool hasChattedAboutProduct = chatsSnapshot.docs.any((doc) {
        //   final chatData = doc.data();
        //   return chatData['senderId'] == currentUser.uid &&
        //       chatData['productDetail'] != null &&
        //       chatData['productDetail']['id'] == bookedCar.car.id;
        // });

        Chat chat = Chat(
          chatId: const Uuid().v4(),
          message: message,
          receiverId: partner!.uid,
          senderId: currentUser.uid,
          productDetail: isCurrentUserSeller ? null : bookedCar.car.toJson(),
          timeStamp: Timestamp.now(),
        );
        await ChatSource.send(
          chat,
          roomId,
          buyerId: buyerId,
          ownerId: ownerId,
          ownerType: carInfo.ownerType,
          currentUser: currentUser,
          partner: partner!,
        );

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
          await sendNotification(
            buyerId,
            ownerId,
            "Chat Baru",
            "Kamu mendapatkan Chat baru dari ${displayName.capitalizeFirst}",
            "order",
            chat.chatId,
          );
        }
      }

      Get.back();
      Get.toNamed(
        '/chatting',
        arguments: {
          'roomId': roomId,
          'customerId': buyerId,
          'ownerId': ownerId,
          'ownerType': carInfo.ownerType,
          'from': 'order',
          'productDetail': bookedCar.car.toJson(),
        },
      );
    } catch (e) {
      Get.back();
      log('Gagal membuka chat: $e');
      Message.error('Gagal membuka chat. Coba lagi.');
    }
  }

  Future<void> confirmOrder(
    String orderId,
    String customerId,
    String sellerId,
    String carId,
    String paymentMethod,
    num orderPrice,
  ) async {
    try {
      if (orderId.isEmpty) {
        log('Gagal mengkonfirmasi pesanan: Order ID kosong');
        Message.error('Gagal mengkonfirmasi pesanan. ID pesanan tidak valid.');
        return;
      }
      await SellerSource().updateOrderStatus(orderId, 'success');
      await CarSource.updateProductAfterPurchase(carId);
      log('Jumlah produk yang disewa berhasil diupdate');
      await SellerSource().markOrderAsSuccess(
        orderId,
        authVM.account.value!.uid,
        authVM.account.value!.role,
        orderPrice.round(),
      );
      if (paymentMethod == 'DompetKu') {
        await userSource.updateUserBalance(customerId, orderPrice.toDouble());
        log('Saldo berhasil dipotong');
      }
      Message.success(
        'Pesanan berhasil dikonfirmasi. Silahkan Cek Saldo Anda di Pengaturan',
        fontSize: 12,
      );
      log('Pesanan dengan ID $orderId berhasil dikonfirmasi');
      await sendNotification(
        customerId,
        sellerId,
        "Info Order",
        "Pesanan Anda telah dikonfirmasi ${authVM.account.value!.storeName}",
        "order",
        orderId,
      );
    } catch (e) {
      log('Gagal mengkonfirmasi pesanan: $e');
      Message.error('Gagal mengkonfirmasi pesanan.');
    }
  }

  Future<void> cancelOrder(
    String orderId,
    String customerId,
    String sellerId,
  ) async {
    try {
      if (orderId.isEmpty) {
        log('Gagal membatalkan pesanan: Order ID kosong');
        Message.error('Gagal membatalkan pesanan. ID pesanan tidak valid.');
        return;
      }
      await SellerSource().updateOrderStatus(orderId, 'cancelled');
      log('Pesanan dengan ID $orderId berhasil dibatalkan');
      await sendNotification(
        customerId,
        sellerId,
        "Info Order",
        "Pesanan Anda dibatalkan oleh ${authVM.account.value!.storeName}",
        "order",
        orderId,
      );
    } catch (e) {
      log('Gagal membatalkan pesanan: $e');
      Message.error('Gagal membatalkan pesanan.');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    if (orderId.isEmpty) {
      Message.error('Gagal menghapus pesanan: ID tidak valid.');
      return;
    }

    Get.dialog(
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
            ),
            const Gap(16),
            Text(
              'Sedang menghapus Proddduk, mohon tunggu...',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Theme.of(Get.context!).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final currentUser = authVM.account.value!;
      final userIsCustomer = currentUser.role == 'customer';
      await firestore.collection('Orders').doc(orderId).update({
        if (userIsCustomer) 'deletedByCustomer': true,
        if (!userIsCustomer) 'deletedBySeller': true,
      });

      final collectionName = currentUser.role == 'admin' ? 'Admin' : 'Users';
      await firestore
          .collection(collectionName)
          .doc(currentUser.uid)
          .collection('myOrders')
          .doc(orderId)
          .delete();

      Get.back();
      Message.success('Riwayat pesanan berhasil dihapus.');
      log(
        'Referensi order $orderId berhasil dihapus dari myOrders milik ${currentUser.uid}.',
      );
    } catch (e) {
      Get.back();
      Message.error('Terjadi kesalahan saat menghapus pesanan.');
      log('Gagal menghapus referensi order $orderId: $e');
    }
  }

  Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
  }) async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            content: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            actionsOverflowDirection: VerticalDirection.up,
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
                onPressed: () {
                  Get.back(result: false);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: title.contains('Konfirmasi')
                      ? const Color(0xffFF5722)
                      : const Color(0xffFF2056),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Get.back(result: true);
                },
              ),
            ],
          ),
        ) ??
        false;
  }
}
