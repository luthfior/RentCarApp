import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/models/booked_car.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:rent_car_app/data/models/orders.dart';
import 'package:rent_car_app/data/services/notification_service.dart';
import 'package:rent_car_app/data/services/push_notification_service.dart';
import 'package:rent_car_app/data/sources/car_source.dart';
import 'package:rent_car_app/data/sources/chat_source.dart';
import 'package:rent_car_app/data/sources/seller_source.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:uuid/uuid.dart';

class DetailOrderViewModel extends GetxController {
  DetailOrderViewModel(this.bookedCar);

  final BookedCar? bookedCar;
  final isSeller = false.obs;
  final authVM = Get.find<AuthViewModel>();
  final firestore = FirebaseFirestore.instance;

  final Rx<Account?> _partner = Rx<Account?>(null);
  Account? get partner => _partner.value;
  set partner(Account? value) => _partner.value = value;

  final Rx<Orders> _order = Orders.empty.obs;
  Orders get order => _order.value;
  set order(Orders value) => _order.value = value;

  final _status = ''.obs;
  String get status => _status.value;
  set status(String value) => _status.value = value;

  StreamSubscription<Orders>? _orderSubscription;
  final userSource = UserSource();
  final Rx<Car> _car = Car.empty.obs;
  Car get car => _car.value;
  set car(Car value) => _car.value = value;

  @override
  void onInit() {
    super.onInit();
    if (authVM.account.value != null) {
      isSeller.value =
          authVM.account.value!.role == 'seller' ||
          authVM.account.value!.role == 'admin';
      if (bookedCar != null) {
        _order.value = bookedCar!.order;
        _car.value = bookedCar!.car;
        status = 'success';
        listenToOrderUpdates(bookedCar!.order.id);
      } else {
        Message.error('Gagal Membuka Detail Order');
        log('Error: DetailOrderViewModel tidak ada BookedCar.');
        status = 'error';
      }
    } else {
      status = 'empty';
    }
  }

  @override
  void onClose() {
    _orderSubscription?.cancel();
    super.onClose();
  }

  void listenToOrderUpdates(String orderId) {
    status = 'loading';
    _orderSubscription = userSource
        .fetchMyOrderStream(orderId)
        .listen(
          (updatedOrder) {
            _order.value = updatedOrder;
            if (updatedOrder.id.isEmpty) {
              status = 'error';
              log('Dokumen order dengan ID $orderId tidak ditemukan.');
            } else {
              status = 'success';
            }
          },
          onError: (error) {
            status = 'error';
            log('Error mendengarkan update order: $error');
          },
        );
  }

  Future<void> refreshOrder() async {
    if (bookedCar != null) {
      log('Refreshing order data...');
      await _orderSubscription?.cancel();
      listenToOrderUpdates(bookedCar!.order.id);
    }
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
    final isCurrentUserSeller = isSeller.value;

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
          'from': 'detail-order',
          'productDetail': bookedCar.car.toJson(),
        },
      );
    } catch (e) {
      Get.back();
      log('Gagal membuka chat: $e');
      Message.error('Gagal membuka chat. Coba lagi.');
    }
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

  String formatCurrency(double amount) {
    final currencyFormatter = NumberFormat.currency(
      decimalDigits: 0,
      locale: 'id_ID',
      symbol: 'Rp.',
    );
    return currencyFormatter.format(amount);
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final DateTime date = timestamp.toDate();
      return DateFormat('dd MMMM yyyy HH:mm:ss', 'id_ID').format(date);
    }
    return timestamp.toString();
  }

  String formatOrderStatus(String orderStatus) {
    String orderStatusFormatted;
    final isSeller =
        authVM.account.value!.role == 'admin' ||
        authVM.account.value!.role == 'seller';
    if (orderStatus.toLowerCase().contains('pending')) {
      orderStatusFormatted = (isSeller)
          ? 'Menunggu untuk Kamu proses.'
          : 'Menunggu diproses oleh Penyedia.';
    } else if (orderStatus.toLowerCase().contains('success')) {
      orderStatusFormatted = (isSeller)
          ? 'Telah Kamu proses'
          : 'Dikonfirmasi oleh Penyedia.';
    } else if (orderStatus.toLowerCase().contains('cancelled')) {
      orderStatusFormatted = (isSeller)
          ? 'Telah Kamu batalkan'
          : 'Dibatalkan oleh Penyedia.';
    } else {
      orderStatusFormatted = 'Tidak diketahui.';
    }
    return orderStatusFormatted;
  }

  Future<void> confirmOrder(
    String orderId,
    String customerId,
    String sellerId,
    num orderPrice,
  ) async {
    try {
      if (orderId.isEmpty) {
        log('Gagal mengkonfirmasi pesanan: Order ID kosong');
        Message.error('Gagal mengkonfirmasi pesanan. ID pesanan tidak valid.');
        return;
      }
      await SellerSource().updateOrderStatus(orderId, 'success');
      await userSource.updateUserBalance(customerId, orderPrice.toDouble());
      log('Saldo berhasil dipotong');
      await CarSource.updateProductAfterPurchase(car.id);
      log('Jumlah produk yang disewa berhasil diupdate');
      await SellerSource().markOrderAsSuccess(
        orderId,
        authVM.account.value!.uid,
        authVM.account.value!.role,
        orderPrice.round(),
      );
      Message.success('Silahkan Cek Saldo Anda di Pengaturan');
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
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            content: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
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
                      ? const Color(0xff75A47F)
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
