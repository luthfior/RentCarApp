import 'dart:developer';
import 'dart:math' show Random;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/models/order_detail.dart';
import 'package:rent_car_app/data/services/midtrans_service.dart';
import 'package:rent_car_app/data/services/notification_service.dart';
import 'package:rent_car_app/data/services/push_notification_service.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class CheckoutViewModel extends GetxController {
  late final Car car;
  late final String? nameOrder;
  late final DateTime startDate;
  late final DateTime endDate;
  late final String? agency;
  late final String? insurance;
  late final bool withDriver;

  final Rx<num?> userBalance = Rx<num?>(null);
  final Rx<bool> hasPin = Rx<bool>(false);
  final RxString paymentMethodPicked = 'DompetKu'.obs;

  late final int rentDurationInDays;
  late final double totalDriverCost;
  late final double subTotal;
  late final double totalInsuranceCost;
  late final double finalTotal;

  final double driverCostPerDay = 300000;
  final double additionalCost = 2500;

  final AuthViewModel authVM = Get.find<AuthViewModel>();
  final UserSource userSource = UserSource();

  String userFirstName = "Guest";
  String userLastName = "User";
  String userEmail = "guest@gmail.com";
  String userPhoneNumber = "08123456789";
  String userCity = "Jakarta";
  String userFullAddress = "Jl. Default No.1";

  final Rx<Account?> _partner = Rx<Account?>(null);
  Account? get partner => _partner.value;
  set partner(Account? value) => _partner.value = value;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    car = arguments['car'] as Car;
    nameOrder = arguments['nameOrder'] as String?;
    startDate = arguments['startDate'] as DateTime;
    endDate = arguments['endDate'] as DateTime;
    agency = arguments['agency'] as String;
    insurance = arguments['insurance'] as String?;
    withDriver = arguments['withDriver'] as bool;
    _calculateCosts();

    populateFieldsFromAccount(authVM.account.value);
    ever(authVM.account, (account) => populateFieldsFromAccount(account));
    fetchPartner(car.ownerId, car.ownerType);
  }

  void populateFieldsFromAccount(Account? acc) {
    if (acc != null) {
      if (acc.fullName.contains(' ')) {
        final parts = acc.fullName.split(' ');
        userFirstName = parts.first;
        userLastName = parts.sublist(1).join(' ');
      } else {
        userFirstName = acc.fullName;
      }
      userEmail = acc.email;
      userPhoneNumber = acc.phoneNumber ?? userPhoneNumber;
      userCity = acc.city ?? userCity;
      userFullAddress = acc.fullAddress ?? userFullAddress;
      userBalance.value = acc.balance;
      hasPin.value = acc.pin != null && acc.pin!.isNotEmpty;
    } else {
      userBalance.value = null;
      hasPin.value = false;
    }
  }

  Future<void> refreshCheckoutData() async {
    try {
      await authVM.loadUser();
      log('Checkout data (balance) refreshed successfully.');
    } catch (e) {
      log('Failed to refresh checkout data: $e');
      Message.error('Gagal mengambil data saldo terbaru.');
    }
  }

  void _calculateCosts() {
    rentDurationInDays = endDate.difference(startDate).inDays + 1;
    double pricePerDay = car.priceProduct.toDouble();
    totalDriverCost = withDriver ? driverCostPerDay * rentDurationInDays : 0;
    subTotal = pricePerDay * rentDurationInDays + totalDriverCost;

    totalInsuranceCost = subTotal * 0.20;

    finalTotal = subTotal + totalInsuranceCost + additionalCost;
  }

  final List<Map<String, dynamic>> listPayment = [
    {'name': 'DompetKu', 'icon': Icons.wallet},
    {'name': 'Midtrans', 'icon': Icons.payments_rounded},
    {'name': 'Tunai', 'icon': Icons.account_balance_wallet_rounded},
  ];

  String formatCurrency(double amount) {
    final currencyFormatter = NumberFormat.currency(
      decimalDigits: 0,
      locale: 'id_ID',
      symbol: 'Rp.',
    );
    return currencyFormatter.format(amount);
  }

  String formatDate(DateTime date) {
    final checkoutDateFormatter = DateFormat("dd MMMM yyyy", "id_ID");
    return checkoutDateFormatter.format(date);
  }

  void goToPin() {
    final balance = userBalance.value;
    if (balance == null) {
      Message.error('Saldo tidak ditemukan. Mohon coba kembali.');
      return;
    }
    if (balance < finalTotal) {
      Message.error(
        'Gagal melakukan Pembayaran. Saldo Anda tidak mencukupi untuk melakukan pembayaran ini. Silahkan lakukan Top Up untuk isi ulang',
        fontSize: 12,
      );
      return;
    }
    if (!hasPin.value) {
      Get.toNamed('/pin-setup');
    } else {
      Get.toNamed('/pin', arguments: {'isForVerification': false, 'car': car});
    }
  }

  Future<void> handlePayment() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      if (paymentMethodPicked.value == 'Midtrans') {
        await handleMidtransPayment();
      } else if (paymentMethodPicked.value == 'DompetKu') {
        goToPin();
      } else {
        await cashPayment();
      }
    } catch (e, s) {
      log('ERROR handlePayment: $e\n$s');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processPayment(
    String resi,
    String paymentMethod,
    String paymentStatus,
  ) async {
    try {
      final userId = authVM.account.value?.uid;
      final sellerOrAdmin = car.ownerId;
      if (userId != null && sellerOrAdmin.isNotEmpty) {
        if (paymentMethod == 'DompetKu') {
          await postPaymentSuccessActions(resi, paymentMethod, paymentStatus);
        } else if (paymentMethod == 'Tunai') {
          await postPaymentSuccessActions(resi, paymentMethod, paymentStatus);
        } else {
          log("WebView Midtrans selesai. Navigasi ke halaman complete...");
          await sendNotification();
          Message.success('Pembayaran berhasil. Pesanan telah dibuat!');
          await navigateWithLoading(
            '/complete',
            arguments: {'fragmentIndex': 0, 'bookedCar': car},
          );
        }
      } else {
        Message.error(
          'Gagal melakukan pembayaran. Silakan pilih metode pembayaran lain atau coba beberapa saat lagi.',
          fontSize: 12,
        );
        log('User atau pemilik mobil tidak terautentikasi');
      }
    } catch (e, s) {
      log('Gagal memproses pembayaran: $e\n$s');
    }
  }

  Future<void> fetchPartner(String id, String role) async {
    final collection = (role == 'admin') ? 'Admin' : 'Users';
    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(id)
        .get();

    if (doc.exists) {
      partner = Account.fromJson(doc.data()!);
    }
  }

  Future<void> sendNotification() async {
    if (partner == null) {
      log('Partner belum dimuat, tidak bisa kirim notifikasi');
      return;
    }
    final tokens = partner!.fcmTokens ?? [];
    String message =
        "Pesanan baru untuk mobil ${car.nameProduct} ${car.releaseProduct}"
            .trim();
    if (message.isEmpty || message == "Pesanan baru untuk mobil") {
      message = "Pesanan baru di toko Anda";
    }
    if (tokens.isNotEmpty) {
      await PushNotificationService.sendToMany(
        tokens,
        "Info Order",
        message,
        data: {'type': 'order', 'referenceId': car.id},
      );
    } else {
      log('Gagal kirim push notification: token kosong');
    }
    await NotificationService.addNotification(
      userId: car.ownerId,
      title: "Info Order",
      body: message,
      type: "order",
      referenceId: "${authVM.account.value!.uid}_${car.ownerId}",
    );
  }

  Future<void> cashPayment() async {
    try {
      final safeUid = authVM.account.value!.uid.substring(0, 5);
      final resi = "ORDER-$safeUid-${DateTime.now().millisecondsSinceEpoch}";
      await processPayment(resi, 'Tunai', 'Bayar di Tempat');
    } catch (e) {
      log('Gagal memproses pembayaran: $e');
      Message.error(
        'Pembayaran gagal. Silakan pilih metode pembayaran lain atau coba beberapa saat lagi.',
        fontSize: 12,
      );
    }
  }

  Future<void> handleMidtransPayment() async {
    final paymentData = await MidtransService.processPaymentWithMidtrans(
      authVM.account.value?.uid ?? Random().nextInt(99999).toString(),
      userFirstName,
      userLastName,
      userEmail,
      userPhoneNumber,
      userFullAddress,
      car.id,
      car.nameProduct,
      car.priceProduct.round(),
      rentDurationInDays.toInt(),
      (withDriver ? driverCostPerDay : 0).round(),
      totalInsuranceCost.round(),
      additionalCost.round(),
      finalTotal.round(),
      car.brandProduct,
      car.categoryProduct,
    );

    if (paymentData != null && paymentData.isNotEmpty) {
      final redirectUrl = paymentData['redirect_url']!;
      final resi = paymentData['order_id']!;
      final newOrderId = await createInitialOrder(
        resi,
        'Midtrans',
        'Menunggu Pembayaran',
      );
      if (newOrderId == null) {
        log(
          "Gagal membuat order awal di Firebase. Membatalkan transaksi Midtrans...",
        );
        await MidtransService.cancelMidtransTransaction(resi);
        Message.error('Gagal memproses pesanan. Silakan coba lagi.');
        return;
      }

      final result = await Get.toNamed(
        '/midtrans-web-view',
        arguments: {'url': redirectUrl, 'resi': resi},
      );

      if (result == 'cancel') {
        Message.neutral('Pembayaran dibatalkan.');
        log("User membatalkan pembayaran Midtrans");
        await MidtransService.cancelMidtransTransaction(resi);
        await deleteCancelledOrder(newOrderId);
        return;
      }
    } else {
      log("terjadi kesalahan pada MidtransService()");
      Message.error(
        'Gagal melakukan pembayaran. Silakan pilih metode pembayaran lain atau coba beberapa saat lagi.',
        fontSize: 12,
      );
    }
  }

  Future<void> postPaymentSuccessActions(
    String resi,
    String paymentMethod,
    String paymentStatus,
  ) async {
    try {
      if (partner == null) {
        await fetchPartner(car.ownerId, car.ownerType);
      }
      final userId = authVM.account.value?.uid;
      final sellerOrAdmin = car.ownerId;
      if (userId != null && sellerOrAdmin.isNotEmpty) {
        final orderId = await UserSource().createOrder(
          resi,
          authVM.account.value!.uid,
          partner!.uid,
          partner!.role,
          paymentMethod,
          paymentStatus,
          OrderDetail(
            car: car,
            withDriver: withDriver,
            driverCostPerDay: withDriver ? driverCostPerDay.round() : 0,
            startDate: formatDate(startDate),
            endDate: formatDate(endDate),
            duration: rentDurationInDays,
            subTotal: subTotal.round(),
            agency: agency!,
            insurance: insurance!,
            totalInsuranceCost: totalInsuranceCost.round(),
            additionalCost: additionalCost.round(),
            totalPrice: finalTotal.round(),
          ),
        );
        if (orderId == null) {
          log('Order gagal dibuat, tidak lanjut ke success.');
          return;
        } else {
          log(
            'Produk berhasil ditambahkan ke riwayat pesanan customer: $userId dan seller: $sellerOrAdmin',
          );
        }
        await sendNotification();
        Message.success('Pembayaran berhasil. Pesanan telah dibuat!');
        await navigateWithLoading(
          '/complete',
          arguments: {'fragmentIndex': 0, 'bookedCar': car},
        );
      } else {
        throw Exception('User atau pemilik mobil tidak terautentikasi');
      }
    } catch (e, s) {
      log('ERROR postPaymentSuccessActions: $e\n$s');
      Message.error(
        'Gagal melakukan pembayaran. Silakan pilih metode pembayaran lain atau coba beberapa saat lagi.',
        fontSize: 12,
      );
    }
  }

  Future<void> navigateWithLoading(
    String route, {
    Map<String, dynamic>? arguments,
  }) async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    Get.offAllNamed(route, arguments: arguments);
  }

  Future<String?> createInitialOrder(
    String resi,
    String paymentMethod,
    String paymentStatus,
  ) async {
    if (partner == null) {
      await fetchPartner(car.ownerId, car.ownerType);
    }
    final userId = authVM.account.value?.uid;
    if (userId != null && partner != null) {
      return await UserSource().createOrder(
        resi,
        userId,
        partner!.uid,
        partner!.role,
        paymentMethod,
        paymentStatus,
        OrderDetail(
          car: car,
          withDriver: withDriver,
          driverCostPerDay: withDriver ? driverCostPerDay.round() : 0,
          startDate: formatDate(startDate),
          endDate: formatDate(endDate),
          duration: rentDurationInDays,
          subTotal: subTotal.round(),
          agency: agency!,
          insurance: insurance!,
          totalInsuranceCost: totalInsuranceCost.round(),
          additionalCost: additionalCost.round(),
          totalPrice: finalTotal.round(),
        ),
      );
    }
    return null;
  }

  Future<void> deleteCancelledOrder(String orderId) async {
    try {
      final db = FirebaseFirestore.instance;
      final customerId = authVM.account.value!.uid;

      if (partner == null) {
        log("Partner null, tidak bisa menghapus order dari sisi seller.");
        return;
      }

      final batch = db.batch();

      final orderDocRef = db.collection('Orders').doc(orderId);

      final customerOrderRef = db
          .collection('Users')
          .doc(customerId)
          .collection('myOrders')
          .doc(orderId);

      final ownerCollection = partner!.role == 'admin' ? 'Admin' : 'Users';
      final sellerOrderRef = db
          .collection(ownerCollection)
          .doc(partner!.uid)
          .collection('myOrders')
          .doc(orderId);

      batch.delete(orderDocRef);
      batch.delete(customerOrderRef);
      batch.delete(sellerOrderRef);

      await batch.commit();

      log(
        "Order $orderId yang dibatalkan berhasil dihapus bersih dari database.",
      );
    } catch (e) {
      log("Gagal menghapus order $orderId yang dibatalkan: $e");
      Message.error(
        'Pembayaran berhasil dibatalkan, tetapi gagal membersihkan pesanan dari riwayat Anda. Anda bisa mengabaikan atau menghapusnya.',
        fontSize: 12,
      );
    }
  }
}
