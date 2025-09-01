import 'dart:developer';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/car_source.dart';
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
  final RxString paymentMethodPicked = 'Dompet Ku'.obs;

  late final int rentDurationInDays;
  late final double totalDriverCost;
  late final double subTotal;
  late final double totalInsuranceCost;
  late final double finalTotal;

  final double driverCostPerDay = 250000;
  final double additionalCost = 2500;

  final AuthViewModel authVM = Get.find<AuthViewModel>();
  final UserSource userSource = UserSource();

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

    if (authVM.account.value != null) {
      userBalance.value = authVM.account.value!.balance;
      hasPin.value =
          authVM.account.value!.pin != null &&
          authVM.account.value!.pin!.isNotEmpty;
      log('User account updated. hasPin: ${hasPin.value}');
    } else {
      userBalance.value = null;
      hasPin.value = false;
      log('User account is null. hasPin: ${hasPin.value}');
    }
  }

  void _calculateCosts() {
    rentDurationInDays = endDate.difference(startDate).inDays + 1;
    double pricePerDay = car.priceProduct.toDouble();
    totalDriverCost = withDriver ? driverCostPerDay * rentDurationInDays : 0;
    subTotal = pricePerDay * rentDurationInDays + totalDriverCost;

    totalInsuranceCost = pricePerDay * 0.20;

    finalTotal = subTotal + totalInsuranceCost + additionalCost;
  }

  void setPaymentMethod(String method) {
    if (method != 'Dompet Saya') {
      Message.neutral('Fitur pembayaran $method belum tersedia', fontSize: 13);
    } else {
      paymentMethodPicked.value = method;
    }
    log('Jenis Pembayaran yang dipilih: ${paymentMethodPicked.value}');
  }

  final List<Map<String, String>> listPayment = [
    {'name': 'Dompet Ku', 'icon': 'assets/wallet.png'},
    {'name': 'Kartu Kredit', 'icon': 'assets/cards.png'},
    {'name': 'Tunai', 'icon': 'assets/cash.png'},
    {'name': 'Transfer Bank', 'icon': 'assets/transfer.png'},
    {'name': 'Minimarket', 'icon': 'assets/minimarket.png'},
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
    if (paymentMethodPicked.value == 'Dompet Ku') {
      final balance = userBalance.value;
      if (balance == null) {
        Message.error('Saldo tidak ditemukan. Mohon coba kembali.');
        return;
      }
      if (balance < finalTotal) {
        Message.error(
          'Gagal melakukan Pembayaran. Saldo Anda tidak mencukupi untuk melakukan pembayaran ini. Silahkan lakukan Top Up untuk isi ulang',
          fontSize: 13,
        );
        return;
      }
    }
    if (!hasPin.value) {
      Get.toNamed('/pin-setup');
    } else {
      Get.toNamed('/pin', arguments: {'isForVerification': false, 'car': car});
    }
  }

  Future<void> processPayment(String enteredPin) async {
    try {
      final userId = authVM.account.value?.uid;
      final sellerOrAdmin = car.ownerId;
      if (userId != null || sellerOrAdmin.isEmpty) {
        await userSource.updateUserBalance(userId!, finalTotal);
        log('Saldo berhasil dipotong');

        await CarSource.updatePurchasedProduct(car.id);
        log('Jumlah produk yang disewa berhasil diupdate');

        await UserSource().createOrder(authVM.account.value!, car);
        log(
          'Produk berhasil ditambahkan ke riwayat pesanan customer: $userId dan seller: $sellerOrAdmin',
        );
      } else {
        throw Exception('User atau pemilik mobil tidak terautentikasi');
      }
    } catch (e) {
      log('Gagal memproses pembayaran: $e');
      Message.error('Pembayaran gagal: ${e.toString()}');
      rethrow;
    }
  }
}
