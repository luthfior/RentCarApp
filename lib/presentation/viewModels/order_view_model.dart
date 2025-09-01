import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/booked_car.dart';
import 'package:rent_car_app/data/sources/seller_source.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class OrderViewModel extends GetxController {
  final firestore = FirebaseFirestore.instance;
  final authVM = Get.find<AuthViewModel>();
  final userSource = UserSource();
  final sellerSource = SellerSource();

  final status = ''.obs;
  final isSeller = false.obs;
  final myOrders = <BookedCar>[].obs;
  StreamSubscription<List<BookedCar>>? _ordersSubscription;
  final hasShownTutorial = false.obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    hasShownTutorial.value = box.read('hasShownSwipeTutorial') ?? false;
    if (authVM.account.value != null) {
      isSeller.value =
          authVM.account.value!.role == 'seller' ||
          authVM.account.value!.role == 'admin';
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

  void showTutorial() {
    box.write('hasShownSwipeTutorial', true);
    hasShownTutorial.value = true;
  }

  void dismissTutorial() {
    box.write('hasShownSwipeTutorial', true);
    hasShownTutorial.value = true;
  }

  Future<void> startOrdersListener() async {
    status.value = 'loading';
    final userId = authVM.account.value!.uid;

    if (authVM.account.value?.uid == null) {
      status.value = 'empty';
      myOrders.clear();
      return;
    }

    _ordersSubscription?.cancel();
    _ordersSubscription = userSource
        .fetchBookedCarStream(userId, isSeller.value)
        .listen(
          (updatedOrders) {
            if (updatedOrders.isEmpty) {
              myOrders.clear();
              status.value = 'empty';
            } else {
              myOrders.value = updatedOrders;
              status.value = 'success';
            }
          },
          onError: (error) {
            myOrders.clear();
            status.value = 'error';
            log('Gagal Mengambil Data Order');
            if (box.read('hasShownSwipeTutorial') != false) {
              box.write('hasShownSwipeTutorial', false);
              hasShownTutorial.value = false;
            }
          },
        );
    await Future.microtask(() => null);
  }

  Future<void> confirmOrder(String orderId, num orderPrice) async {
    try {
      if (orderId.isEmpty) {
        log('Gagal mengkonfirmasi pesanan: Order ID kosong');
        Message.error('Gagal mengkonfirmasi pesanan. ID pesanan tidak valid.');
        return;
      }
      await sellerSource.updateOrderStatus(orderId, 'success');
      await sellerSource.markOrderAsSuccess(
        orderId,
        authVM.account.value!.uid,
        authVM.account.value!.role,
        orderPrice,
      );
      Message.success('Silahkan Cek Saldo Anda di Pengaturan');
      log('Pesanan dengan ID $orderId berhasil dikonfirmasi');
    } catch (e) {
      log('Gagal mengkonfirmasi pesanan: $e');
      Message.error('Gagal mengkonfirmasi pesanan.');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      if (orderId.isEmpty) {
        log('Gagal membatalkan pesanan: Order ID kosong');
        Message.error('Gagal membatalkan pesanan. ID pesanan tidak valid.');
        return;
      }
      await sellerSource.updateOrderStatus(orderId, 'failed');
      log('Pesanan dengan ID $orderId berhasil dibatalkan');
    } catch (e) {
      log('Gagal membatalkan pesanan: $e');
      Message.error('Gagal membatalkan pesanan.');
    }
  }

  String formatDate(DateTime date) {
    final orderDateFormatter = DateFormat("dd MMMM yyyy", "id_ID");
    return orderDateFormatter.format(date);
  }
}
