import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_car_app/core/utils/number_formatter.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/add_product_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/address_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/custom_input.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class AddProductPage extends GetView<AddProductViewModel> {
  AddProductPage({super.key});
  final connectivity = Get.find<ConnectivityService>();
  final addressVM = Get.find<AddressViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                CustomHeader(title: 'Tambah Produk Baru'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(20),
                          Text(
                            'Informasi Produk',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const Gap(12),
                          _buildInputForm(
                            context,
                            controller.nameController,
                            'Masukkan Nama Produk',
                            controller.nameError.value,
                            controller.nameFocus,
                            customBorderRadius: 20,
                          ),
                          const Gap(16),
                          _buildInputForm(
                            context,
                            controller.priceController,
                            'Masukkan Harga Produk /hari',
                            controller.priceError.value,
                            controller.priceFocus,
                            isNumeric: true,
                            isNumberFormatter: true,
                            prefixText: 'Rp. ',
                            isSuffixText: '/hari',
                            customBorderRadius: 20,
                          ),
                          const Gap(16),
                          _buildDropdown(
                            context,
                            'Masukkan Tahun Rilis Produk',
                            controller.releaseYearError.value,
                            controller.releaseYearFocus,
                            controller.releaseYears,
                            controller.selectedReleaseYear,
                          ),
                          const Gap(16),
                          _buildDropdown(
                            context,
                            'Kategori Produk',
                            controller.categoryError.value,
                            controller.categoryFocus,
                            controller.categories,
                            controller.selectedCategory,
                          ),
                          const Gap(16),
                          _buildDropdown(
                            context,
                            'Transmisi Produk',
                            controller.transmissionError.value,
                            controller.transmissionFocus,
                            controller.transmissions,
                            controller.selectedTransmission,
                          ),
                          const Gap(16),
                          Obx(
                            () => _buildInputForm(
                              context,
                              controller.descriptionController,
                              'Masukkan Deskripsi Produk',
                              controller.descriptionError.value,
                              controller.descriptionFocus,
                              maxLines: null,
                              minLines: 1,
                              customBorderRadius: 20,
                            ),
                          ),
                          const Gap(16),
                          _buildInputForm(
                            context,
                            controller.streetController,
                            'Masukkan Nama Jalan / Detail Alamat',
                            controller.streetError.value,
                            controller.streetFocus,
                            customBorderRadius: 20,
                          ),
                          const Gap(16),
                          Obx(
                            () => _buildDropdownDynamic(
                              context,
                              'Provinsi',
                              controller.provinceError.value,
                              controller.provinceFocus,
                              addressVM.provinces
                                  .where((e) => e['value'] != null)
                                  .map((e) => e['value'] as String)
                                  .toList(),
                              addressVM.selectedProvinceName,
                              (val) {
                                if (val == null) return;
                                final prov = addressVM.provinces.firstWhere(
                                  (e) => e['value'] == val,
                                );
                                addressVM.selectedProvince.value = prov;
                                addressVM.selectedProvinceName.value = val;

                                addressVM.selectedCity.value = null;
                                addressVM.selectedSubDistrict.value = null;
                                addressVM.selectedVillage.value = null;
                                addressVM.selectedCityName.value = null;
                                addressVM.selectedSubDistrictName.value = null;
                                addressVM.selectedVillageName.value = null;
                                addressVM.cities.clear();
                                addressVM.subDistricts.clear();
                                addressVM.villages.clear();

                                addressVM.loadCities(prov['id']);
                              },
                            ),
                          ),
                          const Gap(16),
                          Obx(
                            () => _buildDropdownDynamic(
                              context,
                              'Kota/Kabupaten',
                              controller.cityError.value,
                              controller.cityFocus,
                              addressVM.cities
                                  .where((e) => e['value'] != null)
                                  .map((e) => e['value'] as String)
                                  .toList(),
                              addressVM.selectedCityName,
                              (val) {
                                if (val == null) return;
                                final city = addressVM.cities.firstWhere(
                                  (e) => e['value'] == val,
                                );
                                addressVM.selectedCity.value = city;
                                addressVM.selectedCityName.value = val;

                                addressVM.selectedSubDistrict.value = null;
                                addressVM.selectedVillage.value = null;
                                addressVM.selectedSubDistrictName.value = null;
                                addressVM.selectedVillageName.value = null;
                                addressVM.subDistricts.clear();
                                addressVM.villages.clear();

                                addressVM.loadSubDistricts(city['id']);
                              },
                            ),
                          ),
                          const Gap(16),
                          Obx(
                            () => _buildDropdownDynamic(
                              context,
                              'Kecamatan',
                              controller.districtError.value,
                              controller.districtFocus,
                              addressVM.subDistricts
                                  .where((e) => e['value'] != null)
                                  .map((e) => e['value'] as String)
                                  .toList(),
                              addressVM.selectedSubDistrictName,
                              (val) {
                                if (val == null) return;
                                final sub = addressVM.subDistricts.firstWhere(
                                  (e) => e['value'] == val,
                                );
                                addressVM.selectedSubDistrict.value = sub;
                                addressVM.selectedSubDistrictName.value = val;

                                addressVM.selectedVillage.value = null;
                                addressVM.selectedVillageName.value = null;
                                addressVM.villages.clear();
                                addressVM.loadVillages(sub['id']);
                              },
                            ),
                          ),
                          const Gap(16),
                          Obx(
                            () => _buildDropdownDynamic(
                              context,
                              'Kelurahan/Desa',
                              controller.villageError.value,
                              controller.villageFocus,
                              addressVM.villages
                                  .where((e) => e['value'] != null)
                                  .map((e) => e['value'] as String)
                                  .toList(),
                              addressVM.selectedVillageName,
                              (val) {
                                if (val == null) return;
                                final vil = addressVM.villages.firstWhere(
                                  (e) => e['value'] == val,
                                );
                                addressVM.selectedVillage.value = vil;
                                addressVM.selectedVillageName.value = val;
                              },
                            ),
                          ),
                          const Gap(20),
                          Text(
                            'Upload Gambar Produk',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const Gap(10),
                          _buildImagePicker(
                            context,
                            controller.pickedImage,
                            controller.imageUrl,
                            controller.pickImage,
                          ),
                          const Gap(50),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const OfflineBanner(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonPrimary(
              onTap: () async {
                if (connectivity.isOnline.value) {
                  await controller.handleAddProduct();
                  Get.back(result: true);
                } else {
                  null;
                }
              },
              text: 'Tambah Produk',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm(
    BuildContext context,
    TextEditingController controller,
    String hintText,
    String? errorText,
    FocusNode focusNode, {
    double? customBorderRadius,
    int? maxLines = 1,
    int? minLines,
    bool isNumeric = false,
    bool isNumberFormatter = false,
    String? isSuffixText,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInput(
          hint: hintText,
          customHintFontSize: 14,
          editingController: controller,
          maxLines: maxLines,
          minLines: minLines,
          customBorderRadius: customBorderRadius,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumberFormatter ? [NumberFormatter()] : null,
          suffixText: isSuffixText,
          prefixText: prefixText,
          errorText: errorText,
          focusNode: focusNode,
        ),
      ],
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    String label,
    String? errorText,
    FocusNode focusNode,
    List<String> items,
    Rx<String?> selectedValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          return SizedBox(
            height: 50,
            child: DropdownButtonFormField<String>(
              menuMaxHeight: 250,
              value: selectedValue.value,
              items: items.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                hint: Text(
                  'Pilih $label',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff838384),
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.fromLTRB(16, 24, 18, 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    width: 2,
                    color: Color(0xffFF5722),
                  ),
                ),
                errorText: errorText,
              ),
              onChanged: (String? value) {
                selectedValue.value = value;
                log('Pilihan $label: $value');
              },
              icon: Image.asset(
                'assets/ic_arrow_down.png',
                width: 18,
                height: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              focusNode: focusNode,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDropdownDynamic(
    BuildContext context,
    String label,
    String? errorText,
    FocusNode focusNode,
    List<String> items,
    Rx<String?> selectedValue,
    Function(String?) onChanged,
  ) {
    return SizedBox(
      height: 50,
      child: DropdownButtonFormField<String>(
        menuMaxHeight: 250,
        value: selectedValue.value,
        items: items.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e, style: GoogleFonts.poppins(fontSize: 14)),
          );
        }).toList(),
        decoration: InputDecoration(
          hint: Text(
            'Pilih $label',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xff838384),
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.fromLTRB(16, 24, 18, 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 2, color: Color(0xffFF5722)),
          ),
          errorText: errorText,
        ),
        onChanged: (val) {
          selectedValue.value = val;
          onChanged(val);
        },
        icon: Image.asset(
          'assets/ic_arrow_down.png',
          width: 18,
          height: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        focusNode: focusNode,
      ),
    );
  }

  Widget _buildImagePicker(
    BuildContext context,
    Rx<XFile?> pickedImage,
    Rx<String?> imageUrl,
    VoidCallback onTap,
  ) {
    return Obx(() {
      final hasImage = pickedImage.value != null || imageUrl.value != null;
      final displayImage = pickedImage.value != null
          ? Image.file(File(pickedImage.value!.path), fit: BoxFit.cover)
          : imageUrl.value != null
          ? Image.network(imageUrl.value!, fit: BoxFit.cover)
          : null;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(child: displayImage!),
                      Positioned.fill(
                        child: Container(color: Colors.black.withAlpha(128)),
                      ),
                      const Icon(Icons.edit, size: 32, color: Colors.white),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      size: 32,
                      color: Color(0xffFF5722),
                    ),
                    const Gap(10),
                    Text(
                      'Ketuk untuk memilih gambar',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff838384),
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
