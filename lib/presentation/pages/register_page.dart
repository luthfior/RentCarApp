import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/presentation/viewModels/register_view_model.dart';
import 'package:rent_car_app/presentation/widgets/custom_input.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final registerVM = Get.find<RegisterViewmodel>();
  final connectivity = Get.find<ConnectivityService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerVM.resetForm();
    });
  }

  @override
  void dispose() {
    Get.delete<RegisterViewmodel>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                    color: const Color(0xff070623),
                  ),
                ),
                const Gap(30),
                Text(
                  'Nama Lengkap',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff070623),
                  ),
                ),
                const Gap(12),
                Obx(
                  () => CustomInput(
                    icon: 'assets/ic_profile.png',
                    hint: 'Masukkan Nama Lengkap Anda',
                    editingController: registerVM.nameController,
                    onChanged: (_) {
                      registerVM.isNameTouched.value = true;
                      registerVM.validateInputs();
                    },
                    errorText: registerVM.nameError.value,
                    focusNode: registerVM.nameFocus,
                    enable: connectivity.isOnline.value,
                  ),
                ),
                const Gap(20),
                Text(
                  'Alamat Email',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff070623),
                  ),
                ),
                const Gap(12),
                Obx(
                  () => CustomInput(
                    icon: 'assets/ic_email.png',
                    hint: 'Masukkan Alamat Email Anda',
                    editingController: registerVM.emailController,
                    onChanged: (_) {
                      registerVM.isEmailTouched.value = true;
                      registerVM.validateInputs();
                    },
                    errorText: registerVM.emailError.value,
                    focusNode: registerVM.emailFocus,
                    enable: connectivity.isOnline.value,
                  ),
                ),
                const Gap(20),
                Text(
                  'Kata Sandi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff070623),
                  ),
                ),
                const Gap(12),
                Obx(
                  () => CustomInput(
                    icon: 'assets/ic_key.png',
                    hint: 'Masukkan Password',
                    editingController: registerVM.passwordController,
                    onChanged: (_) {
                      registerVM.isPasswordTouched.value = true;
                      registerVM.validateInputs();
                    },
                    errorText: registerVM.passwordError.value,
                    obsecure: !registerVM.isPasswordVisible.value,
                    focusNode: registerVM.passwordFocus,
                    suffixIcon: IconButton(
                      onPressed: () => registerVM.isPasswordVisible.toggle(),
                      icon: Icon(
                        registerVM.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    enable: connectivity.isOnline.value,
                  ),
                ),
                const Gap(30),
                // Obx(
                //   () => ButtonPrimary(
                //     text: 'Daftar',
                //     onTap:
                //         (!connectivity.isOnline.value ||
                //             registerVM.isLoading.value)
                //         ? null
                //         : () => registerVM.handleRegister(context),
                //   ),
                // ),
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
                  onTap: (!connectivity.isOnline.value)
                      ? null
                      : () => Get.toNamed('/login'),
                  text: 'Masuk',
                  customBackgroundColor: const Color(0xffFFFFFF),
                ),
                const Gap(50),
              ],
            ),
          ),
          const OfflineBanner(),
          Obx(() {
            if (!registerVM.isLoading.value) return const SizedBox.shrink();
            return Container(
              color: Colors.black.withAlpha(179),
              child: const Center(child: CircularProgressIndicator()),
            );
          }),
        ],
      ),
    );
  }
}
