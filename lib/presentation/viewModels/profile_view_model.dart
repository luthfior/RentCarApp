import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';

class ProfileViewModel extends GetxController {
  final userSource = UserSource();
  final authVM = Get.find<AuthViewModel>();
  final discoverVM = Get.find<DiscoverViewModel>();

  final fullName = ''.obs;
  final address = ''.obs;
  final fullNameEdt = TextEditingController();
  final addressEdt = TextEditingController();
  final isChanged = false.obs;
  final selectedPhotoFile = Rx<XFile?>(null);

  final _status = ''.obs;
  String get status => _status.value;
  set status(String value) => _status.value = value;

  void checkChanges() {
    isChanged.value =
        (fullName.value != authVM.account.value?.fullName) ||
        address.value != authVM.account.value?.address ||
        (selectedPhotoFile.value != null);
  }

  @override
  void onInit() {
    super.onInit();
    if (authVM.account.value != null) {
      fullName.value = authVM.account.value!.fullName;
      fullNameEdt.text = authVM.account.value!.fullName;
      address.value = authVM.account.value!.address ?? '';
      addressEdt.text = authVM.account.value!.address ?? '';
    }
  }

  Future<void> selectProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedPhotoFile.value = image;
        checkChanges();
      }
    } catch (e) {
      log('Gagal memilih foto');
    }
  }

  Future<void> updateProfile() async {
    if (!isChanged.value) {
      log('Tidak ada perubahan, batalkan pembaruan.');
      return;
    }
    status = 'loading';
    final uid = authVM.account.value?.uid;
    final userRole = authVM.account.value?.role;
    if (uid == null) {
      status = 'failed';
      log('Error: User ID tidak ditemukan');
      return;
    }
    if (fullName.value.trim().isEmpty) {
      status = 'failed';
      Message.error('Nama Lengkap tidak boleh kosong');
      return;
    }
    if (address.value.trim().isEmpty) {
      status = 'failed';
      Message.error('Alamat Lengkap tidak boleh kosong');
      return;
    }
    try {
      if (selectedPhotoFile.value != null) {
        await userSource.updateProfilePicture(
          uid,
          userRole!,
          selectedPhotoFile.value!,
        );
      }
      if (fullName.value != authVM.account.value?.fullName) {
        await userSource.updateFullName(uid, userRole!, fullName.value);
      }
      if (address.value != authVM.account.value?.address) {
        await userSource.updateUserAddress(uid, userRole!, address.value);
      }
      status = 'success';
      isChanged.value = false;
      selectedPhotoFile.value = null;
      Message.success('Profil berhasil diperbarui');
      Get.until((route) => route.settings.name == '/discover');
      discoverVM.setFragmentIndex(3);
    } catch (e) {
      status = 'failed';
      Message.error('Gagal memperbarui profil');
      log('Gagal memperbarui profil:');
    }
  }
}
