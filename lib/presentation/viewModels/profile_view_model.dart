import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';

class ProfileViewModel extends GetxController {
  final userSource = UserSource();
  final authVM = Get.find<AuthViewModel>();
  final discoverVM = Get.find<DiscoverViewModel>();

  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final locationController = TextEditingController();

  final fullName = ''.obs;
  final phoneNumber = ''.obs;
  final selectedPhotoFile = Rx<XFile?>(null);

  final _locationChanged = false.obs;
  bool get locationChanged => _locationChanged.value;
  set locationChanged(bool value) => _locationChanged.value = value;

  final Rx<String?> selectedStreet = Rx<String?>(null);
  final Rx<String?> selectedProvinceName = Rx<String?>(null);
  final Rx<String?> selectedCityName = Rx<String?>(null);
  final Rx<String?> selectedSubDistrictName = Rx<String?>(null);
  final Rx<String?> selectedVillageName = Rx<String?>(null);
  final Rx<double?> selectedLatLocation = Rx<double?>(null);
  final Rx<double?> selectedLongLocation = Rx<double?>(null);

  final _status = ''.obs;
  String get status => _status.value;
  set status(String value) => _status.value = value;

  Car? car;
  late final String fromPage;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    car = args['car'] as Car?;
    fromPage = args['from'] as String;
    populateFieldsFromAccount();
  }

  @override
  void onClose() {
    fullNameController.clear();
    phoneNumberController.clear();
    locationController.clear();
    fullName.value = '';
    phoneNumber.value = '';
    selectedPhotoFile.value = null;
    selectedStreet.value = null;
    selectedProvinceName.value = null;
    selectedCityName.value = null;
    selectedSubDistrictName.value = null;
    selectedVillageName.value = null;
    super.onClose();
  }

  void populateFieldsFromAccount() {
    if (authVM.account.value != null) {
      final acc = authVM.account.value!;
      fullName.value = acc.fullName;
      fullNameController.text = acc.fullName;
      phoneNumber.value = acc.phoneNumber ?? '';
      phoneNumberController.text = acc.phoneNumber ?? '';
      locationController.text = acc.fullAddress ?? '';
      selectedStreet.value = acc.street ?? '';
      selectedProvinceName.value = acc.province ?? '';
      selectedCityName.value = acc.city ?? '';
      selectedSubDistrictName.value = acc.district ?? '';
      selectedVillageName.value = acc.village ?? '';
      selectedLatLocation.value = acc.latLocation?.toDouble() ?? -6.200000;
      selectedLongLocation.value = acc.longLocation?.toDouble() ?? 106.816666;
    } else {
      selectedLatLocation.value = -6.200000;
      selectedLongLocation.value = 106.816666;
    }
  }

  Future<void> selectProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (selectedPhotoFile.value != null) {
          selectedPhotoFile.value = image;
        }
      }
    } catch (e) {
      log('Gagal memilih foto');
    }
  }

  Future<void> updateProfile() async {
    status = 'loading';
    final uid = authVM.account.value?.uid;
    final userRole = authVM.account.value?.role;
    if (uid == null) {
      status = 'failed';
      log('Error: User ID tidak ditemukan');
      return;
    }
    if (fullNameController.text.trim().isEmpty) {
      status = 'failed';
      Message.error('Nama Lengkap tidak boleh kosong');
      return;
    }
    if (phoneNumberController.text.trim().isEmpty) {
      status = 'failed';
      Message.error('No.Telp/WA tidak boleh kosong');
      return;
    }
    if (locationController.text.trim().isEmpty) {
      status = 'failed';
      Message.error('Alamat Lengkap tidak boleh kosong');
      return;
    }
    if (int.tryParse(phoneNumberController.text.trim()) == null) {
      status = 'failed';
      Message.error('Nomor Telepon harus berupa angka.');
      return;
    }
    try {
      if (selectedPhotoFile.value != null) {
        await userSource.updateProfilePicture(
          uid,
          userRole!,
          selectedPhotoFile.value!,
        );
        selectedPhotoFile.value = null;
      }
      if (fullNameController.text != authVM.account.value?.fullName) {
        await userSource.updateFullName(
          uid,
          userRole!,
          fullNameController.text,
        );
      }
      if (phoneNumberController.text != authVM.account.value?.phoneNumber) {
        await userSource.updatePhoneNumber(
          uid,
          userRole!,
          phoneNumberController.text,
        );
      }
      if (_locationChanged.value) {
        await userSource.updateUserAddress(
          uid,
          userRole!,
          locationController.text,
          selectedStreet.value ?? '',
          selectedVillageName.value ?? '',
          selectedSubDistrictName.value ?? '',
          selectedCityName.value ?? '',
          selectedProvinceName.value ?? '',
          selectedLatLocation.value ?? -6.200000,
          selectedLongLocation.value ?? 106.816666,
        );
      }

      if (selectedPhotoFile.value == null &&
          fullNameController.text == authVM.account.value?.fullName &&
          phoneNumberController.text == authVM.account.value?.phoneNumber &&
          !_locationChanged.value) {
        status = 'failed';
        Message.error('Tidak ada perubahan yang dilakukan');
        log('Tidak ada perubahan, batalkan pembaruan.');
        return;
      }

      status = 'success';
      await authVM.loadUser();
      Message.success('Profil berhasil diperbarui');

      if (fromPage == 'setting') {
        if (authVM.account.value?.role == 'seller') {
          Get.until((route) => route.settings.name == '/discover');
          discoverVM.setFragmentIndex(3);
        } else {
          Get.until((route) => route.settings.name == '/discover');
          discoverVM.setFragmentIndex(4);
        }
      } else if (fromPage == 'booking') {
        Get.offAllNamed('/booking', arguments: car);
      } else {
        Get.back();
      }
    } catch (e) {
      status = 'failed';
      log('Gagal memperbarui profil: $e');
      Message.error('Gagal memperbarui profil');
    }
  }

  void markLocationChanged(String oldFullAddress, Map result) {
    locationChanged =
        oldFullAddress != result["fullAddress"] ||
        selectedLatLocation.value != result["latLocation"] ||
        selectedLongLocation.value != result["longLocation"];
  }

  Future<void> refreshProfile() async {
    try {
      await authVM.loadUser();
      populateFieldsFromAccount();
      log('Profile data refreshed successfully.');
    } catch (e) {
      log('Failed to refresh profile: $e');
      Message.error('Gagal mengambil data terbaru.');
    }
  }
}
