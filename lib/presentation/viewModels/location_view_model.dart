import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/services/kirimin_service.dart';
import 'package:rent_car_app/data/services/locationiq_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class LocationViewModel extends GetxController {
  final authVM = Get.find<AuthViewModel>();
  final KiriminService kiriminService = KiriminService();
  final LocationIQService locationIQService = LocationIQService();
  final RxString errorMessage = "".obs;
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
  final streetController = TextEditingController();
  final hierarchyController = TextEditingController();
  final locationSearchController = TextEditingController();
  final FocusNode streetFocus = FocusNode();
  final RxList<Map<String, dynamic>> suggestions = <Map<String, dynamic>>[].obs;
  final RxDouble lat = (-6.200000).obs;
  final RxDouble lon = (106.816666).obs;
  final MapController mapController = MapController();
  final apiKey = dotenv.env['LOCATION_IQ_API_KEY'] ?? '';
  LatLng? tappedPoint;
  final debounce = Rx<Timer?>(null);

  late final String initialFullAddress;
  late double initialLat;
  late double initialLon;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      streetController.text = args["street"] ?? '';
      hierarchyController.text = [
        args["village"] ?? '',
        args["district"] ?? '',
        args["city"] ?? '',
        args["province"] ?? '',
      ].where((e) => e.isNotEmpty).join(", ");
      selectedProvinceName.value = args["province"];
      selectedCityName.value = args["city"];
      selectedSubDistrictName.value = args["district"];
      selectedVillageName.value = args["village"];
      lat.value = args["latLocation"] ?? -6.200000;
      lon.value = args["longLocation"] ?? 106.816666;
    } else if (authVM.account.value != null) {
      final acc = authVM.account.value!;
      streetController.text = acc.street ?? '';
      hierarchyController.text = [
        acc.village ?? '',
        acc.district ?? '',
        acc.city ?? '',
        acc.province ?? '',
      ].where((e) => e.isNotEmpty).join(", ");
      selectedProvinceName.value = acc.province;
      selectedCityName.value = acc.city;
      selectedSubDistrictName.value = acc.district;
      selectedVillageName.value = acc.village;
      lat.value = acc.latLocation?.toDouble() ?? -6.200000;
      lon.value = acc.longLocation?.toDouble() ?? 106.816666;
    } else {
      lat.value = -6.200000;
      lon.value = 106.816666;
    }

    initialFullAddress =
        "${streetController.text}, ${hierarchyController.text}";
    initialLat = lat.value;
    initialLon = lon.value;

    loadProvinces();
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
    if (selectedProvince.value == null ||
        selectedCity.value == null ||
        selectedSubDistrict.value == null ||
        selectedVillage.value == null) {
      return hierarchyController.text;
    }
    return "${selectedVillage.value!['value']}, "
        "${selectedSubDistrict.value!['value']}, "
        "${selectedCity.value!['value']}, "
        "${selectedProvince.value!['value']}";
  }

  void debounceSearch(
    String query,
    Function(List<Map<String, dynamic>>) onResult,
  ) {
    debounce.value?.cancel();
    debounce.value = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        try {
          final res = await locationIQService.searchLocation(query);
          errorMessage.value = "";
          onResult(res);
        } catch (e) {
          errorMessage.value =
              "Pencarian alamat sedang ada kendala, harap pilih alamat secara manual pada Map";
          onResult([]);
        }
      } else {
        errorMessage.value = "";
        onResult([]);
      }
    });
  }

  Future<void> updateAddressFromLatLng(double lat, double lon) async {
    try {
      final result = await locationIQService.reverseGeocode(lat, lon);
      errorMessage.value = "";
      locationSearchController.text = result["display_name"];
    } catch (e) {
      errorMessage.value =
          "Map sedang mengalami kendala, saat ini tidak bisa memuat alamat pada titik tesebut";
    }
  }

  Future<void> handleLocation() async {
    bool isValid = true;
    FocusNode? focusToRequest;
    if (streetController.text.isEmpty) {
      focusToRequest ??= streetFocus;
      isValid = false;
    }
    if (hierarchyController.text.isEmpty) {
      isValid = false;
    }
    if (!isValid) {
      Message.error('Mohon lengkapi semua field yang kosong.');
      if (focusToRequest != null) {
        focusToRequest.requestFocus();
      }
      return;
    }
    final street = streetController.text.trim();
    final hierarchy = hierarchyController.text.trim();
    final fullAddress = "$street, $hierarchy";
    try {
      final bool addressIsSame = fullAddress == initialFullAddress;
      final bool locationIsSame =
          lat.value == initialLat && lon.value == initialLon;
      if (addressIsSame && locationIsSame) {
        log('Tidak ada perubahan, batalkan pembaruan.');
        Message.error("Tidak ada perubahan pada Alamat");
        return;
      }
      log(">>> Sebelum Get.back()");
      Get.back(
        result: {
          "fullAddress": fullAddress,
          "street": street,
          "province": selectedProvinceName.value,
          "city": selectedCityName.value,
          "district": selectedSubDistrictName.value,
          "village": selectedVillageName.value,
          "latLocation": lat.value,
          "longLocation": lon.value,
        },
        closeOverlays: true,
      );
      log(">>> Setelah Get.back()");
      log("sukses update lokasi");
    } catch (e) {
      log("Error saat handleLocation: $e");
      Message.error("Gagal menyimpan lokasi");
    }
  }

  @override
  void onClose() {
    locationSearchController.clear();
    streetController.clear();
    hierarchyController.clear();
    selectedProvince.value = null;
    selectedCity.value = null;
    selectedSubDistrict.value = null;
    selectedVillage.value = null;
    provinces.clear();
    cities.clear();
    subDistricts.clear();
    villages.clear();
    super.onClose();
  }
}
