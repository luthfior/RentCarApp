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
  final isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;

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
              Image.asset(
                isDarkMode
                    ? 'assets/logo_text_16_9_dark_mode.png'
                    : 'assets/logo_text_16_9.png',
                height: 90,
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
                                  ? const Color(0xffEFEFF0)
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
                            'Penyedia',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: controller.selectedRole.value == 'seller'
                                  ? const Color(0xffEFEFF0)
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
              Obx(() {
                final role = controller.selectedRole.value;
                final isSeller = role == 'seller';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSeller) ...[
                      Text(
                        'Nama Toko',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Gap(12),
                      CustomInput(
                        icon: Icons.store,
                        hint: 'Masukkan Nama Toko',
                        customHintFontSize: 14,
                        editingController: controller.storeNameController,
                        onChanged: (_) {
                          controller.isStoreNameTouched.value = true;
                          controller.validateInputs();
                        },
                        errorText: controller.storeNameError.value,
                        focusNode: controller.storeNameFocus,
                        isTextCapital: true,
                      ),
                      if (controller.storeNameSuggestion.value.isNotEmpty)
                        Text(
                          controller.storeNameSuggestion.value,
                          style: const TextStyle(
                            color: Color(0xffFF2056),
                            fontSize: 12,
                          ),
                        ),
                      const Gap(20),
                    ],

                    Text(
                      isSeller ? 'Nama Lengkap Penyedia' : 'Nama Lengkap',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Gap(12),
                    CustomInput(
                      icon: Icons.person,
                      hint: isSeller
                          ? 'Masukkan Nama Penyedia'
                          : 'Masukkan Nama Lengkap',
                      customHintFontSize: 14,
                      editingController: controller.fullNameController,
                      onChanged: (_) {
                        controller.isFullNameTouched.value = true;
                        controller.validateInputs();
                      },
                      errorText: controller.fullNameError.value,
                      focusNode: controller.fullNameFocus,
                      isTextCapital: true,
                    ),
                    const Gap(20),

                    Text(
                      isSeller ? 'Alamat Email Penyedia' : 'Alamat Email',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Gap(12),
                    CustomInput(
                      icon: Icons.email_rounded,
                      hint: isSeller
                          ? 'Masukkan Alamat Email Penyedia'
                          : 'Masukkan Alamat Email',
                      customHintFontSize: 14,
                      editingController: controller.emailController,
                      onChanged: (_) {
                        controller.isEmailTouched.value = true;
                        controller.validateInputs();
                      },
                      errorText: controller.emailError.value,
                      focusNode: controller.emailFocus,
                    ),
                    const Gap(20),

                    Text(
                      isSeller ? 'Kata Sandi Penyedia' : 'Kata Sandi',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Gap(12),
                    CustomInput(
                      icon: Icons.key_rounded,
                      hint: isSeller
                          ? 'Masukkan Kata Sandi Penyedia'
                          : 'Masukkan Kata Sandi',
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
                        onPressed: controller.togglePasswordVisibility,
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    const Gap(30),

                    ButtonPrimary(
                      text: isSeller ? 'Daftar Toko' : 'Daftar',
                      onTap: controller.isLoading.value
                          ? null
                          : () async {
                              if (connectivity.isOnline.value) {
                                await controller.handleRegister(
                                  context,
                                  onRegisterSuccess: onSwitchToLogin,
                                );
                              } else {
                                const OfflineBanner();
                                null;
                              }
                            },
                    ),
                  ],
                );
              }),
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
