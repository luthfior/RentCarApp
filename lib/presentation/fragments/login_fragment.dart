import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/login_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_input.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class LoginFragment extends GetView<LoginViewModel> {
  final VoidCallback onSwitchToRegister;
  const LoginFragment({super.key, required this.onSwitchToRegister});

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
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
                child: Image.asset('assets/logo_text_16_9.png', height: 90),
              ),
              const Gap(20),
              Text(
                'Masuk Akun',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
              const Gap(30),
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
                  icon: Icons.person,
                  hint: 'Masukkan Alamat Email Anda',
                  customHintFontSize: 14,
                  editingController: controller.emailController,
                  errorText: controller.emailError.value,
                  focusNode: controller.emailFocus,
                  onChanged: (_) {
                    controller.isEmailTouched.value = true;
                    controller.validateInputs();
                  },
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
                  icon: Icons.key_rounded,
                  hint: 'Masukkan Kata Sandi Anda',
                  customHintFontSize: 14,
                  editingController: controller.passwordController,
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
                  onChanged: (_) {
                    controller.isPasswordTouched.value = true;
                    controller.validateInputs();
                  },
                ),
              ),
              const Gap(30),
              Obx(
                () => ButtonPrimary(
                  text: 'Masuk',
                  onTap:
                      (!connectivity.isOnline.value ||
                          controller.isLoading.value)
                      ? null
                      : () => controller.handleLogin(context),
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
                onTap: (!connectivity.isOnline.value)
                    ? null
                    : onSwitchToRegister,
                text: 'Daftar Akun',
                customTextColor: const Color(0xff070623),
                customBackgroundColor: Colors.white,
                customBorderColor: Get.isDarkMode
                    ? const Color(0xffEFEFF0)
                    : const Color(0xff070623),
              ),
              const Gap(50),
            ],
          ),
        ),
        const OfflineBanner(),
        Obx(() {
          if (!controller.isLoading.value) return const SizedBox.shrink();
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
            ),
          );
        }),
      ],
    );
  }
}
