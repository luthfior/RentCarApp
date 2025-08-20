import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/data/services/theme_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class SettingFragment extends StatelessWidget {
  SettingFragment({super.key});

  final authVM = Get.find<AuthViewModel>();
  final connectivity = Get.find<ConnectivityService>();

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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const Gap(30),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  Get.toNamed('/edit-profile');
                },
              ),
              const Gap(20),
              buildItemSettings(
                icon: 'assets/ic_wallet.png',
                title: 'Ganti Pin Dompet Ku',
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  final pin = authVM.account.value?.pin;
                  if (pin != null && pin.isNotEmpty) {
                    Get.toNamed('/pin', arguments: {'isForVerification': true});
                  } else {
                    Get.toNamed('/pin-setup');
                  }
                },
              ),
              const Gap(20),
              buildItemSettings(
                icon: 'assets/ic_key.png',
                title: 'Ganti Kata Sandi',
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  return Message.neutral(
                    'Maaf. Saat ini, fitur tersebut belum tersedia',
                  );
                },
              ),
              const Gap(20),
              buildItemSettings(
                icon: 'assets/ic_logout.png',
                title: 'Keluar',
                isDisable: !connectivity.isOnline.value,
                onTap: () => authVM.logout(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProfile() {
    return Obx(() {
      final account = authVM.account.value;
      if (account == null) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
          ),
        );
      }
      return Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(Get.context!).colorScheme.secondary,
            backgroundImage:
                (account.photoUrl != null && account.photoUrl!.isNotEmpty)
                ? NetworkImage(account.photoUrl!)
                : const AssetImage('assets/profile.png'),
          ),
          const Gap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
                Text(
                  account.email,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget buildItemSettings({
    required String icon,
    required String title,
    VoidCallback? onTap,
    bool isDisable = false,
  }) {
    return GestureDetector(
      onTap: isDisable ? null : onTap,
      child: Builder(
        builder: (context) {
          return Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: const Color(0xff393e52), width: 1),
            ),
            child: Row(
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/ic_arrow_next.png',
                  width: 20,
                  height: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildDarkMode() {
    final themeService = Get.find<ThemeService>();
    return Obx(() {
      final textStyle = GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(Get.context!).colorScheme.onSurface,
      );
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mode Malam', style: textStyle),
            Switch(
              value: themeService.isDarkMode.value,
              onChanged: (value) {
                themeService.toggleTheme();
              },
            ),
          ],
        ),
      );
    });
  }
}
