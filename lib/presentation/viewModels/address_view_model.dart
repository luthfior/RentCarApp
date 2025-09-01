import 'dart:developer';
import 'package:get/get.dart';
import 'package:rent_car_app/data/services/kirimin_service.dart';

class AddressViewModel extends GetxController {
  final KiriminService kiriminService = KiriminService();

  final provinces = <Map<String, dynamic>>[].obs;
  final cities = <Map<String, dynamic>>[].obs;
  final subDistricts = <Map<String, dynamic>>[].obs;
  final villages = <Map<String, dynamic>>[].obs;

  final selectedProvince = Rxn<Map<String, dynamic>>();
  final selectedCity = Rxn<Map<String, dynamic>>();
  final selectedSubDistrict = Rxn<Map<String, dynamic>>();
  final selectedVillage = Rxn<Map<String, dynamic>>();

  final Rx<String?> selectedProvinceName = Rx<String?>(null);
  final Rx<String?> selectedCityName = Rx<String?>(null);
  final Rx<String?> selectedSubDistrictName = Rx<String?>(null);
  final Rx<String?> selectedVillageName = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadProvinces();
  }

  @override
  // ignore: unnecessary_overrides
  void onClose() {
    super.onClose();
  }

  Future<void> loadProvinces() async {
    try {
      provinces.value = await kiriminService.fetchProvinces();
    } catch (e) {
      log("Gagal memuat provinsi");
    }
  }

  Future<void> loadCities(int provinceId) async {
    try {
      cities.value = await kiriminService.fetchCities(provinceId);
    } catch (e) {
      log("Gagal memuat kota");
    }
  }

  Future<void> loadSubDistricts(int cityId) async {
    try {
      subDistricts.value = await kiriminService.fetchSubDistricts(cityId);
    } catch (e) {
      log("Gagal memuat kecamatan");
    }
  }

  Future<void> loadVillages(int subDistrictId) async {
    try {
      villages.value = await kiriminService.fetchVillages(subDistrictId);
    } catch (e) {
      log("Gagal memuat kelurahan");
    }
  }

  String getFullAddress() {
    return "${selectedVillage.value?['value'] ?? ''}, "
        "${selectedSubDistrict.value?['value'] ?? ''}, "
        "${selectedCity.value?['value'] ?? ''}, "
        "${selectedProvince.value?['value'] ?? ''}";
  }
}
