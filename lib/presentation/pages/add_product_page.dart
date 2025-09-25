import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/core/utils/number_formatter.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/add_product_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/custom_input.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class AddProductPage extends GetView<AddProductViewModel> {
  AddProductPage({super.key});
  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: !controller.isLoading.value,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && controller.isLoading.value) {
            Message.neutral('Tunggu, Proses sedang berlangsung...');
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Obx(
                      () => CustomHeader(
                        title: (controller.arguments['isEdit'])
                            ? 'Sunting Produk'
                            : 'Tambah Produk',
                        onBackTap: controller.isLoading.value
                            ? () {
                                Message.neutral(
                                  'Tunggu, Proses sedang berlangsung...',
                                );
                                return;
                              }
                            : () {
                                Get.back();
                              },
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xffFF5722),
                              ),
                            ),
                          );
                        }
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(30),
                                Text(
                                  'Informasi Produk',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const Gap(12),
                                _buildInputForm(
                                  context,
                                  controller.nameProductController,
                                  'Nama Produk',
                                  controller.nameError.value,
                                  controller.nameFocus,
                                  customBorderRadius: 20,
                                  isTextCapital: true,
                                  maxLines: null,
                                  minLines: 1,
                                ),
                                const Gap(16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputForm(
                                        context,
                                        controller.priceController,
                                        'Harga /hari',
                                        controller.priceError.value,
                                        controller.priceFocus,
                                        isNumeric: true,
                                        isNumberFormatter: true,
                                        prefixText: 'Rp. ',
                                        isSuffixText: '/hari',
                                        customBorderRadius: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDropdown(
                                        context,
                                        'Tahun Rilis',
                                        controller.releaseYearError.value,
                                        controller.releaseYearFocus,
                                        controller.releaseYears,
                                        controller.selectedReleaseYear,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown(
                                        context,
                                        'Kategori',
                                        controller.categoryError.value,
                                        controller.categoryFocus,
                                        controller.categories,
                                        controller.selectedCategory,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDropdown(
                                        context,
                                        'Transmisi',
                                        controller.transmissionError.value,
                                        controller.transmissionFocus,
                                        controller.transmissions,
                                        controller.selectedTransmission,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(16),
                                Obx(
                                  () => _buildInputForm(
                                    context,
                                    controller.descriptionController,
                                    'Deskripsi Produk',
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
                                  controller.locationController,
                                  'Pilih Alamat Toko',
                                  controller.locationError.value,
                                  controller.locationFocus,
                                  maxLines: null,
                                  minLines: 1,
                                  customBorderRadius: 20,
                                  onTapBox: () async {
                                    if (connectivity.isOnline.value) {
                                      final result = await Get.toNamed(
                                        '/location',
                                        arguments: {
                                          "street":
                                              controller.selectedStreet.value,
                                          "province": controller
                                              .selectedProvinceName
                                              .value,
                                          "city":
                                              controller.selectedCityName.value,
                                          "district": controller
                                              .selectedSubDistrictName
                                              .value,
                                          "village": controller
                                              .selectedVillageName
                                              .value,
                                          "latLocation": controller
                                              .selectedLatLocation
                                              .value,
                                          "longLocation": controller
                                              .selectedLongLocation
                                              .value,
                                        },
                                      );
                                      if (result != null && result is Map) {
                                        controller.locationController.text =
                                            result["fullAddress"];
                                        controller.selectedStreet.value =
                                            result["street"];
                                        controller.selectedProvinceName.value =
                                            result["province"];
                                        controller.selectedCityName.value =
                                            result["city"];
                                        controller
                                                .selectedSubDistrictName
                                                .value =
                                            result["district"];
                                        controller.selectedVillageName.value =
                                            result["village"];
                                        controller.selectedLatLocation.value =
                                            result["latLocation"];
                                        controller.selectedLongLocation.value =
                                            result["longLocation"];
                                        Message.success(
                                          'Alamat Akun berhasil disimpan',
                                        );
                                      }
                                    } else {
                                      const OfflineBanner();
                                      return;
                                    }
                                  },
                                ),
                                const Gap(16),
                                _buildInputForm(
                                  context,
                                  controller.phoneNumberController,
                                  'Masukkan No.Telp/WhatsApp',
                                  controller.phoneNumberError.value,
                                  controller.phoneNumberFocus,
                                  isNumeric: true,
                                  customBorderRadius: 20,
                                ),
                                const Gap(16),
                                Text(
                                  'Upload Gambar Produk',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
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
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const OfflineBanner(),
            ],
          ),
          bottomNavigationBar: Obx(
            () => Container(
              padding: controller.isLoading.value
                  ? EdgeInsets.zero
                  : const EdgeInsets.fromLTRB(24, 0, 24, 24),
              color: Colors.transparent,
              child: controller.isLoading.value
                  ? const SizedBox.shrink()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ButtonPrimary(
                          onTap: controller.isLoading.value
                              ? null
                              : () async {
                                  if (connectivity.isOnline.value) {
                                    if (connectivity.isOnline.value) {
                                      bool? confirm = await controller
                                          .showConfirmationDialog(
                                            context: context,
                                            title: 'Hapus Produk',
                                            content:
                                                'Apakah Anda yakin ingin menghapus produk ini secara permanen?',
                                            confirmText: 'Ya, Hapus',
                                          );
                                      if (confirm == true) {
                                        await controller.handleAddProduct();
                                      }
                                    } else {
                                      const OfflineBanner();
                                      return;
                                    }
                                  } else {
                                    const OfflineBanner();
                                    return;
                                  }
                                },
                          text: (controller.arguments?['isEdit'] ?? false)
                              ? 'Sunting Produk'
                              : 'Tambah Produk',
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
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
    VoidCallback? onTapBox,
    bool isTextCapital = false,
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
          onTapBox: onTapBox,
          isTextCapital: isTextCapital,
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
              isDense: true,
              isExpanded: true,
              value: selectedValue.value,
              items: items.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    overflow: TextOverflow.ellipsis,
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
                  label,
                  overflow: TextOverflow.ellipsis,
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
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              focusNode: focusNode,
            ),
          );
        }),
      ],
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
          height: 250,
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
                      const Icon(
                        Icons.edit,
                        size: 32,
                        color: Color(0xffEFEFF0),
                      ),
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
