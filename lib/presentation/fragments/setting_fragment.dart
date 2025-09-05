import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/data/services/theme_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class SettingFragment extends StatelessWidget {
  SettingFragment({super.key});

  final authVM = Get.find<AuthViewModel>();
  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const Gap(20),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final containerHeight = constraints.maxHeight * 0.85;
              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: containerHeight,
                  child: Container(
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
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
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
                              Obx(() {
                                final account = authVM.account.value;
                                if (account == null) return const SizedBox();
                                if (account.role == 'seller') {
                                  return buildItemSettings(
                                    icon: 'assets/ic_wallet.png',
                                    title: 'Saldo Dompet Ku',
                                    isDisable: !connectivity.isOnline.value,
                                    onTap: () {
                                      if (connectivity.isOnline.value) {
                                        Get.toNamed('/saldo');
                                      } else {
                                        null;
                                      }
                                    },
                                  );
                                } else if (account.role == 'admin') {
                                  return Column(
                                    children: [
                                      buildItemSettings(
                                        icon: 'assets/ic_wallet.png',
                                        title: 'Saldo Dompet Ku',
                                        isDisable: !connectivity.isOnline.value,
                                        onTap: () {
                                          if (connectivity.isOnline.value) {
                                            Get.toNamed('/saldo');
                                          } else {
                                            null;
                                          }
                                        },
                                      ),
                                      const Gap(20),
                                      buildItemSettings(
                                        icon: 'assets/cards.png',
                                        title: 'Top Up Saldo',
                                        isDisable: !connectivity.isOnline.value,
                                        onTap: () {
                                          if (connectivity.isOnline.value) {
                                            Get.toNamed('/top-up');
                                          } else {
                                            null;
                                          }
                                        },
                                      ),
                                      const Gap(20),
                                      buildItemSettings(
                                        icon: 'assets/ic_key.png',
                                        title: 'Ganti Pin Dompet Ku',
                                        isDisable: !connectivity.isOnline.value,
                                        onTap: () {
                                          if (connectivity.isOnline.value) {
                                            final pin =
                                                authVM.account.value?.pin;
                                            if (pin != null && pin.isNotEmpty) {
                                              Get.toNamed(
                                                '/pin',
                                                arguments: {
                                                  'isForVerification': true,
                                                },
                                              );
                                            } else {
                                              Get.toNamed('/pin-setup');
                                            }
                                          } else {
                                            null;
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      buildItemSettings(
                                        icon: 'assets/cards.png',
                                        title: 'Top Up Saldo',
                                        isDisable: !connectivity.isOnline.value,
                                        onTap: () {
                                          if (connectivity.isOnline.value) {
                                            Get.toNamed('/top-up');
                                          } else {
                                            null;
                                          }
                                        },
                                      ),
                                      const Gap(20),
                                      buildItemSettings(
                                        icon: 'assets/ic_key.png',
                                        title: 'Ganti Pin Dompet Ku',
                                        isDisable: !connectivity.isOnline.value,
                                        onTap: () {
                                          if (connectivity.isOnline.value) {
                                            final pin =
                                                authVM.account.value?.pin;
                                            if (pin != null && pin.isNotEmpty) {
                                              Get.toNamed(
                                                '/pin',
                                                arguments: {
                                                  'isForVerification': true,
                                                },
                                              );
                                            } else {
                                              Get.toNamed('/pin-setup');
                                            }
                                          } else {
                                            null;
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                }
                              }),
                              const Gap(20),
                              buildItemSettings(
                                icon: 'assets/ic_logout.png',
                                title: 'Keluar',
                                isDisable: !connectivity.isOnline.value,
                                onTap: () {
                                  if (connectivity.isOnline.value) {
                                    authVM.logout();
                                  } else {
                                    null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Gap(20),
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
                  account.fullName,
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
