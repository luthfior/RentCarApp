import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';

class TopUpViewModel extends GetxController {
  final authVM = Get.find<AuthViewModel>();
  final discoverVM = Get.find<DiscoverViewModel>();
  final userSource = UserSource();

  final amountEdt = TextEditingController();
  final currentBalance = Rxn<num>();
  final isChanged = false.obs;
  final status = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (authVM.account.value != null) {
      currentBalance.value = authVM.account.value!.balance;
    }
    amountEdt.addListener(checkChanges);
  }

  @override
  void onClose() {
    amountEdt.removeListener(checkChanges);
    amountEdt.dispose();
    super.onClose();
  }

  void checkChanges() {
    isChanged.value = amountEdt.text.trim().isNotEmpty;
  }

  Future<void> topUpBalance() async {
    final amountToString = amountEdt.text.trim();
    final amount = int.tryParse(amountToString.replaceAll('.', ''));

    if (amountToString.isEmpty) {
      Message.error('Jumlah top up tidak boleh kosong.');
      return;
    }

    if (amount == null || amount <= 0) {
      Message.error('Jumlah top up tidak boleh kosong.');
      return;
    }

    status.value = 'loading';

    try {
      await userSource.addBalance(authVM.account.value!.uid, amount.toDouble());
      Message.success('Saldo berhasil ditambahkan!');
      amountEdt.clear();
      isChanged.value = false;
      status.value = 'success';
      Get.until((route) => route.settings.name == '/discover');
      discoverVM.setFragmentIndex(3);
    } catch (e) {
      status.value = 'failed';
      Message.error('Gagal top up: ${e.toString()}');
    }
  }
}
