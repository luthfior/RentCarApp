import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
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
                  CustomHeader(title: 'Sunting Profil'),
                  const Gap(50),
                  Expanded(
                    child: SingleChildScrollView(
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
                                      ? NetworkImage(photoUrl) as ImageProvider
                                      : const AssetImage('assets/profile.png'),
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
                            enable: connectivity.isOnline.value,
                            icon: 'assets/ic_profile.png',
                            hint: controller.name.value.isNotEmpty
                                ? controller.name.value
                                : 'Masukkan Nama Lengkap',
                            customHintFontSize: 14,
                            editingController: controller.nameEdt,
                            onChanged: (text) {
                              controller.name.value = text;
                              controller.checkChanges();
                            },
                          ),
                          const Gap(20),
                          CustomInput(
                            enable: connectivity.isOnline.value,
                            icon: 'assets/ic_location.png',
                            hint: controller.address.value.isNotEmpty
                                ? controller.address.value
                                : 'Masukkan Alamat Lengkap',
                            customHintFontSize: 14,
                            onChanged: (text) {
                              controller.address.value = text;
                              controller.checkChanges();
                            },
                            editingController: controller.addressEdt,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(20),
                  Obx(() {
                    final isLoading = controller.status.startsWith('loading');
                    final hasChanges = controller.isChanged.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ButtonPrimary(
                        onTap: isLoading || !hasChanges
                            ? null
                            : () {
                                if (!connectivity.isOnline.value) {
                                  return;
                                } else {
                                  controller.updateProfile();
                                }
                              },
                        text: isLoading ? 'Menyimpan...' : 'Simpan',
                        customBackgroundColor: (isLoading || !hasChanges)
                            ? const Color(0xffFF5722).withAlpha(157)
                            : const Color(0xffFF5722),
                      ),
                    );
                  }),
                  const Gap(20),
                  const OfflineBanner(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
