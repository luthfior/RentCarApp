import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class BookingViewModel extends GetxController {
  final authVM = Get.find<AuthViewModel>();
  final Rx<Car> _car = (Get.arguments as Car).obs;
  Car get car => _car.value;

  final Rx<String?> _name = ''.obs;
  String? get name => _name.value;
  set name(String? value) => _name.value = value;

  final Rx<String?> _email = ''.obs;
  String? get email => _email.value;
  set email(String? value) => _email.value = value;

  final Rx<String?> _phoneNumber = ''.obs;
  String? get phoneNumber => _phoneNumber.value;
  set phoneNumber(String? value) => _phoneNumber.value = value;

  final Rx<String?> _city = ''.obs;
  String? get city => _city.value;
  set city(String? value) => _city.value = value;

  final Rx<String?> _fullAddress = ''.obs;
  String? get fullAddress => _fullAddress.value;
  set fullAddress(String? value) => _fullAddress.value = value;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  final Rx<String?> _agencyPicked = 'Jakarta Rental'.obs;
  String? get agencyPicked => _agencyPicked.value;
  set agencyPicked(String? value) => _agencyPicked.value = value;

  final Rx<String?> _insurancePicked = Rx<String?>(null);
  String? get insurancePicked => _insurancePicked.value;
  set insurancePicked(String? value) => _insurancePicked.value = value;

  final Rx<DateTime?> _selectedStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> _selectedEndDate = Rx<DateTime?>(null);

  final RxBool _withDriver = false.obs;
  bool get withDriver => _withDriver.value;
  set withDriver(bool value) => _withDriver.value = value;

  final List<String> listAgency = [
    'Jakarta Rental',
    'DrivePlus',
    'Mitra Rental',
    'Bandung Rental',
    'Jaya Abadi Rental',
    'Surabaya Rental',
  ];

  final List<String> listInsurance = [
    'Asuransi Tanggung Jawab Pihak Ke-3',
    'Asuransi Kecelakaan Diri',
    'Asuransi Perlindungan Pencurian',
    'Asuransi Perlindungan Kerusakan',
  ];

  @override
  void onInit() {
    super.onInit();
    ever(authVM.account, (_) => _refreshAccountData());
    _refreshAccountData();
  }

  void _refreshAccountData() {
    if (authVM.account.value != null) {
      final acc = authVM.account.value!;
      _name.value = acc.fullName;
      fullNameController.text = name ?? '';
      _email.value = acc.email;
      _phoneNumber.value = acc.phoneNumber ?? '';
      _city.value = acc.city ?? '';
      _fullAddress.value = acc.fullAddress ?? '';
    }
  }

  Future<void> pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();

    if (controller == endDateController && _selectedStartDate.value != null) {
      firstDate = _selectedStartDate.value!.add(const Duration(days: 1));
      initialDate = firstDate;
    }

    final datePicked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: initialDate,
    );

    if (datePicked == null) return;

    if (controller == startDateController) {
      _selectedStartDate.value = datePicked;
      _selectedEndDate.value = null;
      endDateController.clear();
    } else {
      _selectedEndDate.value = datePicked;
    }
    controller.text = DateFormat("dd MMM yyyy", "id_ID").format(datePicked);
  }

  Future<void> goToCheckout() async {
    if (fullNameController.text.isEmpty) {
      Message.error('Mohon lengkapi Nama Lengkap Anda.');
      return;
    }
    if (startDateController.text.isEmpty || endDateController.text.isEmpty) {
      Message.error('Mohon lengkapi Tanggal Mulai dan Berakhir.');
      return;
    }
    if (insurancePicked == null) {
      Message.error('Anda wajib memilih asuransi terlebih dahulu.');
      return;
    }
    if (_selectedStartDate.value == null || _selectedEndDate.value == null) {
      Message.error(
        'Terjadi kesalahan pada tanggal. Mohon pilih ulang tanggal.',
      );
      return;
    }
    if ((phoneNumber ?? '').isEmpty ||
        (city ?? '').isEmpty ||
        (fullAddress ?? '').isEmpty) {
      Message.neutral(
        'Data Profil Anda belum lengkap. Silahkan lengkapi terlebih dahulu untuk melanjutkan',
      );
      Get.toNamed(
        '/edit-profile',
        arguments: {'car': _car.value, 'from': 'booking'},
      );
    } else {
      final pending = await hasPendingOrder(authVM.account.value!.uid, car.id);
      if (pending) {
        Message.error(
          'Anda sudah memesan produk ini dengan status pending. Periksa pada halaman Pesanan Anda.',
          fontSize: 12,
        );
        return;
      }
      Get.toNamed(
        '/checkout',
        arguments: {
          'car': _car.value,
          'nameOrder': fullNameController.text,
          'startDate': _selectedStartDate.value,
          'endDate': _selectedEndDate.value,
          'agency': agencyPicked,
          'insurance': insurancePicked,
          'withDriver': withDriver,
        },
      );
    }
  }

  Future<bool> hasPendingOrder(String customerId, String productId) async {
    final query = await FirebaseFirestore.instance
        .collection('Orders')
        .where('customerId', isEqualTo: customerId)
        .where('productId', isEqualTo: productId)
        .where('orderStatus', isEqualTo: 'pending')
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }
}
