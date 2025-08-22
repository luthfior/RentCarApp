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

  final name = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  final Rx<String?> _agencyPicked = 'Jakarta Rent Car'.obs;
  String? get agencyPicked => _agencyPicked.value;
  set agencyPicked(String? value) => _agencyPicked.value = value;

  final Rx<String?> _insurancePicked = Rx<String?>(null);
  String? get insurancePicked => _insurancePicked.value;
  set insurancePicked(String? value) => _insurancePicked.value = value;

  final Rx<DateTime?> _selectedStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> _selectedEndDate = Rx<DateTime?>(null);

  final RxBool _withDriver = true.obs;
  bool get withDriver => _withDriver.value;
  set withDriver(bool value) => _withDriver.value = value;

  final List<String> listAgency = [
    'Jakarta Rent Car',
    'DrivePlus',
    'Mitra Rental',
    'Surabaya Otomotif',
    'Jaya Abadi Rent',
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
    authVM.loadUser();
    if (authVM.account.value != null) {
      name.value = authVM.account.value!.name;
      nameController.text = name.value;
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

  void goToCheckout() {
    if (nameController.text.isEmpty) {
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
    Get.toNamed(
      '/checkout',
      arguments: {
        'car': _car.value,
        'nameOrder': nameController.text,
        'startDate': _selectedStartDate.value,
        'endDate': _selectedEndDate.value,
        'agency': agencyPicked,
        'insurance': insurancePicked,
        'withDriver': withDriver,
      },
    );
  }
}
