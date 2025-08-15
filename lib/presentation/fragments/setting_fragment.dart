import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/utils/app_colors.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/services/theme_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class SettingFragment extends StatelessWidget {
  SettingFragment({super.key});

  final authVM = Get.find<AuthViewModel>();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        Gap(30 + MediaQuery.of(context).padding.top),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Pengaturan',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const Gap(20),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              buildProfile(),
              const Gap(40),
              buildDarkMode(),
              const Gap(20),
              buildItemSettings(
                icon: 'assets/ic_profile.png',
                title: 'Sunting Profil',
                onTap: () {},
              ),
              const Gap(20),
              buildItemSettings(
                icon: 'assets/ic_wallet.png',
                title: 'Sunting Pin Dompet Digital',
                onTap: null,
              ),
              const Gap(20),
              buildItemSettings(
                icon: 'assets/ic_key.png',
                title: 'Ganti Kata Sandi',
                onTap: null,
              ),
              const Gap(20),
              buildItemSettings(
                icon: 'assets/ic_logout.png',
                title: 'Keluar',
                onTap: () => authVM.logout(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProfile() {
    return FutureBuilder(
      future: DSession.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        Account account = Account.fromJson(Map.from(snapshot.data!));
        return Row(
          children: [
            Image.asset('assets/profile.png', width: 50, height: 50),
            const Gap(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  account.email,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildItemSettings({
    required String icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xffFF5722),
                BlendMode.srcIn,
              ),
              child: Image.asset(icon, width: 24, height: 24),
            ),
            const Gap(10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Image.asset(
              'assets/ic_arrow_next.png',
              width: 20,
              height: 20,
              color: AppColors.onSurface,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDarkMode() {
    final themeService = Get.find<ThemeService>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mode Malam',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          Obx(() {
            return Switch(
              value: themeService.isDarkMode.value,
              onChanged: (value) {
                themeService.toggleTheme();
              },
            );
          }),
        ],
      ),
    );
  }
}
