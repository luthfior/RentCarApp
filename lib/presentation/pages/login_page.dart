import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/presentation/viewModels/login_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_input.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginVM = Get.find<LoginViewModel>();
  final connectivity = Get.find<ConnectivityService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginVM.resetForm();
    });
  }

  @override
  void dispose() {
    Get.delete<LoginViewModel>(force: true);
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
                  'Masuk Akun',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff070623),
                  ),
                ),
                const Gap(30),
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
                    icon: 'assets/ic_profile.png',
                    hint: 'Masukkan Alamat Email Anda',
                    editingController: loginVM.emailController,
                    errorText: loginVM.emailError.value,
                    focusNode: loginVM.emailFocus,
                    enable: connectivity.isOnline.value,
                    onChanged: (_) {
                      loginVM.isEmailTouched.value = true;
                      loginVM.validateInputs();
                    },
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
                    editingController: loginVM.passwordController,
                    errorText: loginVM.passwordError.value,
                    obsecure: !loginVM.isPasswordVisible.value,
                    focusNode: loginVM.passwordFocus,
                    suffixIcon: IconButton(
                      onPressed: () => loginVM.isPasswordVisible.toggle(),
                      icon: Icon(
                        loginVM.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    enable: connectivity.isOnline.value,
                    onChanged: (_) {
                      loginVM.isPasswordTouched.value = true;
                      loginVM.validateInputs();
                    },
                  ),
                ),
                const Gap(30),
                Obx(
                  () => ButtonPrimary(
                    text: 'Masuk',
                    onTap:
                        (!connectivity.isOnline.value ||
                            loginVM.isLoading.value)
                        ? null
                        : () => loginVM.handleLogin(context),
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
                  onTap: (!connectivity.isOnline.value)
                      ? null
                      : () => Get.toNamed('/register'),
                  text: 'Daftar',
                  backgroundColor: const Color(0xffFFFFFF),
                ),
                const Gap(50),
              ],
            ),
          ),
          const OfflineBanner(),
          Obx(() {
            if (!loginVM.isLoading.value) return const SizedBox.shrink();
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
