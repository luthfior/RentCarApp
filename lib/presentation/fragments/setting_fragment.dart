import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/data/services/theme_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class SettingFragment extends StatelessWidget {
  SettingFragment({super.key});

  final authVM = Get.find<AuthViewModel>();
  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
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
                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
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
                            child: RefreshIndicator(
                              onRefresh: () async {
                                if (connectivity.isOnline.value) {
                                  await authVM.loadUser();
                                } else {
                                  const OfflineBanner();
                                  return;
                                }
                              },
                              color: const Color(0xffFF5722),
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  buildDarkMode(),
                                  const Gap(20),
                                  buildItemSettings(
                                    icon: Icons.perm_contact_calendar_rounded,
                                    title: 'Sunting Profil',
                                    isDisable: !connectivity.isOnline.value,
                                    onTap: () {
                                      Get.toNamed(
                                        '/edit-profile',
                                        arguments: {'from': 'setting'},
                                      );
                                    },
                                  ),
                                  const Gap(20),
                                  Obx(() {
                                    final account = authVM.account.value;
                                    if (account == null) {
                                      return const SizedBox();
                                    }
                                    if (account.role == 'seller') {
                                      return buildItemSettings(
                                        icon: Icons.wallet,
                                        title: 'Saldo Dompet Ku',
                                        isDisable: !connectivity.isOnline.value,
                                        onTap: () {
                                          if (connectivity.isOnline.value) {
                                            Get.toNamed('/saldo');
                                          } else {
                                            const OfflineBanner();
                                            return;
                                          }
                                        },
                                      );
                                    } else if (account.role == 'admin') {
                                      return Column(
                                        children: [
                                          buildItemSettings(
                                            icon: Icons.wallet,
                                            title: 'Saldo Dompet Ku',
                                            isDisable:
                                                !connectivity.isOnline.value,
                                            onTap: () {
                                              if (connectivity.isOnline.value) {
                                                Get.toNamed('/saldo');
                                              } else {
                                                const OfflineBanner();
                                                return;
                                              }
                                            },
                                          ),
                                          const Gap(20),
                                          buildItemSettings(
                                            icon: Icons.payments_rounded,
                                            title: 'Top Up Saldo',
                                            isDisable:
                                                !connectivity.isOnline.value,
                                            onTap: () {
                                              if (connectivity.isOnline.value) {
                                                Get.toNamed('/top-up');
                                              } else {
                                                const OfflineBanner();
                                                return;
                                              }
                                            },
                                          ),
                                          const Gap(20),
                                          buildItemSettings(
                                            icon: Icons.pin,
                                            title: 'Ganti Pin Dompet Ku',
                                            isDisable:
                                                !connectivity.isOnline.value,
                                            onTap: () {
                                              if (connectivity.isOnline.value) {
                                                final pin =
                                                    authVM.account.value?.pin;
                                                if (pin != null &&
                                                    pin.isNotEmpty) {
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
                                                const OfflineBanner();
                                                return;
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          buildItemSettings(
                                            icon: Icons.payments_rounded,
                                            title: 'Top Up Saldo',
                                            isDisable:
                                                !connectivity.isOnline.value,
                                            onTap: () {
                                              if (connectivity.isOnline.value) {
                                                Get.toNamed('/top-up');
                                              } else {
                                                const OfflineBanner();
                                                return;
                                              }
                                            },
                                          ),
                                          const Gap(20),
                                          buildItemSettings(
                                            icon: Icons.pin,
                                            title: 'Ganti Pin Dompet Ku',
                                            isDisable:
                                                !connectivity.isOnline.value,
                                            onTap: () {
                                              if (connectivity.isOnline.value) {
                                                final pin =
                                                    authVM.account.value?.pin;
                                                if (pin != null &&
                                                    pin.isNotEmpty) {
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
                                                const OfflineBanner();
                                                return;
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                  }),
                                  const Gap(20),
                                  buildItemSettings(
                                    icon: Icons.power_settings_new_rounded,
                                    title: 'Keluar',
                                    isDisable: !connectivity.isOnline.value,
                                    onTap: () {
                                      if (connectivity.isOnline.value) {
                                        authVM.logout();
                                      } else {
                                        const OfflineBanner();
                                        return;
                                      }
                                    },
                                  ),
                                ],
                              ),
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
          const OfflineBanner(),
        ],
      ),
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
    required IconData icon,
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
                  child: Icon(icon),
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
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20,
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
