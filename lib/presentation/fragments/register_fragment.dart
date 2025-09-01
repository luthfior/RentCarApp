import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/register_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_input.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class RegisterFragment extends GetView<RegisterViewModel> {
  final VoidCallback onSwitchToLogin;
  RegisterFragment({super.key, required this.onSwitchToLogin});
  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
            children: [
              const Gap(20),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
                child: Image.asset('assets/logo_text_16_9.png', height: 90),
              ),
              const Gap(20),
              Text(
                'Daftar Akun',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
              const Gap(20),
              Text(
                'Saya ingin mendaftar sebagai:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
              const Gap(12),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectedRole.value = 'customer',
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: controller.selectedRole.value == 'customer'
                                ? const Color(0xffFF5722)
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: controller.selectedRole.value == 'customer'
                                  ? const Color(0xffFF5722)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            'Pembeli',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: controller.selectedRole.value == 'customer'
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectedRole.value = 'seller',
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: controller.selectedRole.value == 'seller'
                                ? const Color(0xffFF5722)
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: controller.selectedRole.value == 'seller'
                                  ? const Color(0xffFF5722)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            'Penjual',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: controller.selectedRole.value == 'seller'
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),
              Obx(
                () => Text(
                  controller.selectedRole.value == 'seller'
                      ? 'Nama Toko'
                      : 'Nama Lengkap',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
              ),
              const Gap(12),
              Obx(
                () => CustomInput(
                  icon: 'assets/ic_profile.png',
                  hint: controller.selectedRole.value == 'seller'
                      ? 'Masukkan Nama Toko Anda'
                      : 'Masukkan Nama Lengkap Anda',
                  customHintFontSize: 14,
                  editingController: controller.nameController,
                  onChanged: (_) {
                    controller.isNameTouched.value = true;
                    controller.validateInputs();
                  },
                  errorText: controller.nameError.value,
                  focusNode: controller.nameFocus,
                  enable: connectivity.isOnline.value,
                ),
              ),
              const Gap(20),
              Obx(
                () => Text(
                  controller.selectedRole.value == 'seller'
                      ? 'Alamat Email Toko'
                      : 'Alamat Email',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
              ),
              const Gap(12),
              Obx(
                () => CustomInput(
                  icon: 'assets/ic_email.png',
                  hint: controller.selectedRole.value == 'seller'
                      ? 'Masukkan Alamat Email Toko Anda'
                      : 'Masukkan Alamat Email Anda',
                  customHintFontSize: 14,
                  editingController: controller.emailController,
                  onChanged: (_) {
                    controller.isEmailTouched.value = true;
                    controller.validateInputs();
                  },
                  errorText: controller.emailError.value,
                  focusNode: controller.emailFocus,
                  enable: connectivity.isOnline.value,
                ),
              ),
              const Gap(20),
              Obx(
                () => Text(
                  controller.selectedRole.value == 'seller'
                      ? 'Kata Sandi Toko'
                      : 'Kata Sandi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
              ),
              const Gap(12),
              Obx(
                () => CustomInput(
                  icon: 'assets/ic_key.png',
                  hint: controller.selectedRole.value == 'seller'
                      ? 'Masukkan Kata Sandi Toko Anda'
                      : 'Masukkan Kata Sandi Anda',
                  customHintFontSize: 14,
                  editingController: controller.passwordController,
                  onChanged: (_) {
                    controller.isPasswordTouched.value = true;
                    controller.validateInputs();
                  },
                  errorText: controller.passwordError.value,
                  obsecure: !controller.isPasswordVisible.value,
                  focusNode: controller.passwordFocus,
                  suffixIcon: IconButton(
                    onPressed: () => controller.isPasswordVisible.toggle(),
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  enable: connectivity.isOnline.value,
                ),
              ),
              const Gap(30),
              Obx(
                () => ButtonPrimary(
                  text: controller.selectedRole.value == 'seller'
                      ? 'Daftar Toko'
                      : 'Daftar',
                  onTap:
                      (!connectivity.isOnline.value ||
                          controller.isLoading.value)
                      ? null
                      : () => controller.handleRegister(
                          context,
                          onRegisterSuccess: () {
                            onSwitchToLogin();
                          },
                        ),
                ),
              ),
              const Gap(20),
              Row(
                children: [
                  const Expanded(
                    child: DottedLine(
                      lineThickness: 2,
                      dashLength: 6,
                      dashGapLength: 6,
                      dashColor: Color(0xffCECED5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'atau',
                      style: GoogleFonts.poppins(
                        color: const Color(0xff9E9EAA),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: DottedLine(
                      lineThickness: 2,
                      dashLength: 6,
                      dashGapLength: 6,
                      dashColor: Color(0xffCECED5),
                    ),
                  ),
                ],
              ),
              const Gap(20),
              ButtonPrimary(
                onTap: (!connectivity.isOnline.value) ? null : onSwitchToLogin,
                text: 'Masuk',
                customTextColor: const Color(0xff070623),
                customBackgroundColor: Colors.white,
              ),
              const Gap(50),
            ],
          ),
        ),
        const OfflineBanner(),
        Obx(() {
          if (!controller.isLoading.value) return const SizedBox.shrink();
          return Container(
            color: const Color(0xff000000).withAlpha(175),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
              ),
            ),
          );
        }),
      ],
    );
  }
}
