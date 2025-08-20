import 'dart:developer';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';

class ProfileViewModel extends GetxController {
  final userSource = UserSource();
  final authVM = Get.find<AuthViewModel>();

  final name = ''.obs;
  final isChanged = false.obs;
  final selectedPhotoFile = Rx<XFile?>(null);

  final _status = ''.obs;
  String get status => _status.value;
  set status(String value) => _status.value = value;

  void checkChanges() {
    isChanged.value =
        (name.value != authVM.account.value?.name) ||
        (selectedPhotoFile.value != null);
  }

  @override
  void onInit() {
    super.onInit();
    if (authVM.account.value?.name != null) {
      name.value = authVM.account.value!.name;
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
    if (uid == null) {
      status = 'failed';
      log('Error: User ID tidak ditemukan');
      return;
    }
    if (name.value.trim().isEmpty) {
      status = 'failed';
      Message.error('Nama Lengkap tidak boleh kosong');
      return;
    }
    try {
      if (selectedPhotoFile.value != null) {
        await userSource.updateProfilePicture(uid, selectedPhotoFile.value!);
      }
      if (name.value != authVM.account.value?.name) {
        await userSource.updateUserName(uid, name.value);
      }
      await authVM.loadUser();
      status = 'success';
      isChanged.value = false;
      selectedPhotoFile.value = null;
      Message.success('Profil berhasil diperbarui');
      Get.until((route) => route.settings.name == '/discover');
      Get.find<DiscoverViewModel>().setFragmentIndex(3);
    } catch (e) {
      status = 'failed';
      Message.error('Gagal memperbarui profil');
      log('Gagal memperbarui profil:');
    }
  }
}
