import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/profile_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/custom_input.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class EditProfilePage extends GetView<ProfileViewModel> {
  EditProfilePage({super.key});

  final connectivity = Get.find<ConnectivityService>();
  final authVM = Get.find<AuthViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final account = controller.authVM.account.value;
        if (account == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
            ),
          );
        }
        if (controller.status == 'loading') {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
            ),
          );
        }
        return Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  CustomHeader(
                    title: (controller.fromPage == 'setting')
                        ? 'Sunting Profil'
                        : 'Lengkapi Profil',
                    onBackTap: () {
                      if (controller.fromPage == 'setting') {
                        Get.back();
                      } else {
                        Get.back();
                      }
                    },
                  ),
                  const Gap(50),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        if (connectivity.isOnline.value) {
                          await controller.refreshProfile();
                        } else {
                          const OfflineBanner();
                          return;
                        }
                      },
                      color: const Color(0xffFF5722),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Obx(() {
                              final newPhotoPath =
                                  controller.selectedPhotoFile.value?.path;
                              final photoUrl =
                                  controller.authVM.account.value?.photoUrl;
                              return Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    backgroundImage: (newPhotoPath != null)
                                        ? FileImage(File(newPhotoPath))
                                              as ImageProvider
                                        : (photoUrl != null &&
                                              photoUrl.isNotEmpty)
                                        ? NetworkImage(photoUrl)
                                              as ImageProvider
                                        : const AssetImage(
                                            'assets/profile.png',
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: controller.selectProfilePicture,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            const Gap(40),
                            CustomInput(
                              icon: Icons.person,
                              hint: controller.fullName.value.isNotEmpty
                                  ? controller.fullName.value
                                  : 'Masukkan Nama Lengkap',
                              customHintFontSize: 14,
                              editingController: controller.fullNameController,
                              isTextCapital: true,
                            ),
                            const Gap(20),
                            CustomInput(
                              icon: Icons.phone_in_talk_rounded,
                              hint: controller.phoneNumber.value.isNotEmpty
                                  ? controller.phoneNumber.value
                                  : 'Masukkan No.Hp/WhatsApp',
                              customHintFontSize: 14,
                              editingController:
                                  controller.phoneNumberController,
                              keyboardType: TextInputType.number,
                            ),
                            const Gap(20),
                            CustomInput(
                              maxLines: null,
                              minLines: 1,
                              icon: Icons.location_on,
                              hint:
                                  controller.locationController.text.isNotEmpty
                                  ? controller.locationController.text
                                  : 'Pilih Alamat',
                              customHintFontSize: 14,
                              editingController: controller.locationController,
                              onTapBox: () async {
                                if (connectivity.isOnline.value) {
                                  final oldFullAddress =
                                      controller.locationController.text;
                                  final result = await Get.toNamed(
                                    '/location',
                                    arguments: {
                                      "street": controller.selectedStreet.value,
                                      "province":
                                          controller.selectedProvinceName.value,
                                      "city": controller.selectedCityName.value,
                                      "district": controller
                                          .selectedSubDistrictName
                                          .value,
                                      "village":
                                          controller.selectedVillageName.value,
                                      "latLocation":
                                          controller.selectedLatLocation.value,
                                      "longLocation":
                                          controller.selectedLongLocation.value,
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
                                    controller.selectedSubDistrictName.value =
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
                                    controller.markLocationChanged(
                                      oldFullAddress,
                                      result,
                                    );
                                  }
                                } else {
                                  const OfflineBanner();
                                  return;
                                }
                              },
                            ),
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
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonPrimary(
              onTap: () async {
                if (connectivity.isOnline.value) {
                  await controller.updateProfile();
                } else {
                  const OfflineBanner();
                  return;
                }
              },
              text: 'Simpan',
            ),
          ],
        ),
      ),
    );
  }
}
