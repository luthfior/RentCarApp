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

class RegisterFragment extends GetView<RegisterViewmodel> {
  final VoidCallback onSwitchToLogin;
  const RegisterFragment({super.key, required this.onSwitchToLogin});

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();

    return Stack(
      children: [
        SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
            children: [
              const Gap(20),
              Image.asset('assets/logo_text_16_9.png', height: 90),
              const Gap(20),
              Text(
                'Daftar Akun',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
              const Gap(30),
              Text(
                'Nama Lengkap',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
              const Gap(12),
              Obx(
                () => CustomInput(
                  icon: 'assets/ic_profile.png',
                  hint: 'Masukkan Nama Lengkap Anda',
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
              Text(
                'Alamat Email',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
              const Gap(12),
              Obx(
                () => CustomInput(
                  icon: 'assets/ic_email.png',
                  hint: 'Masukkan Alamat Email Anda',
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
              Text(
                'Kata Sandi',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
              const Gap(12),
              Obx(
                () => CustomInput(
                  icon: 'assets/ic_key.png',
                  hint: 'Masukkan Password',
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
                  text: 'Daftar',
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
              const Gap(30),
              Row(
                children: [
                  const Expanded(
                    child: DottedLine(
                      dashLength: 5,
                      dashGapLength: 5,
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
                      dashLength: 5,
                      dashGapLength: 5,
                      dashColor: Color(0xffCECED5),
                    ),
                  ),
                ],
              ),
              const Gap(30),
              ButtonPrimary(
                onTap: (!connectivity.isOnline.value) ? null : onSwitchToLogin,
                text: 'Masuk',
                customTextColor: Theme.of(Get.context!).colorScheme.onSurface,
                customBackgroundColor: const Color(0xffFFFFFF),
              ),
              const Gap(50),
            ],
          ),
        ),
        const OfflineBanner(),
        Obx(() {
          if (!controller.isLoading.value) return const SizedBox.shrink();
          return Container(
            color: const Color(0xff000000).withAlpha(179),
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
