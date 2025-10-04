import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/presentation/fragments/browse_fragment.dart';
import 'package:rent_car_app/presentation/fragments/chat_list_fragment.dart';
import 'package:rent_car_app/presentation/fragments/favorite_fragment.dart';
import 'package:rent_car_app/presentation/fragments/order_fragment.dart';
import 'package:rent_car_app/presentation/fragments/seller_product_fragment.dart';
import 'package:rent_car_app/presentation/fragments/setting_fragment.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_bottom_bar.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class DiscoverPage extends GetView<DiscoverViewModel> {
  DiscoverPage({super.key});

  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        controller.handleAppExit();
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Obx(() {
              if (controller.userRole.value == 'seller') {
                switch (controller.fragmentIndex.value) {
                  case 0:
                    return SellerProductFragment();
                  case 1:
                    return const OrderFragment();
                  case 2:
                    return ChatListFragment(
                      uid: controller.userId.value,
                      role: controller.userRole.value,
                    );
                  case 3:
                    return SettingFragment();
                  default:
                    return SellerProductFragment();
                }
              } else if (controller.userRole.value == 'admin') {
                switch (controller.fragmentIndex.value) {
                  case 0:
                    return BrowseFragment();
                  case 1:
                    return SellerProductFragment();
                  case 2:
                    return const OrderFragment();
                  case 3:
                    return ChatListFragment(
                      uid: controller.userId.value,
                      role: controller.userRole.value,
                    );
                  case 4:
                    return SettingFragment();
                  default:
                    return BrowseFragment();
                }
              } else {
                switch (controller.fragmentIndex.value) {
                  case 0:
                    return BrowseFragment();
                  case 1:
                    return const OrderFragment();
                  case 2:
                    return ChatListFragment(
                      uid: controller.userId.value,
                      role: controller.userRole.value,
                    );
                  case 3:
                    return const FavoriteFragment();
                  case 4:
                    return SettingFragment();
                  default:
                    return BrowseFragment();
                }
              }
            }),

            const OfflineBanner(),
          ],
        ),

        bottomNavigationBar: Obx(() {
          final List<Widget> navItems = [];
          if (controller.userRole.value == 'seller') {
            navItems.add(
              buildItemNav(
                label: 'Produk',
                icon: const Icon(Icons.add_business_outlined),
                iconOn: const Icon(Icons.add_business_rounded),
                isActive: controller.fragmentIndex.value == 0,
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(0);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
            navItems.add(
              buildItemNav(
                label: 'Pesanan',
                icon: const Icon(Icons.shopping_bag_outlined),
                iconOn: const Icon(Icons.shopping_bag_rounded),
                isActive: controller.fragmentIndex.value == 1,
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(1);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
            navItems.add(
              buildItemNav(
                label: 'Chat',
                icon: const Icon(Icons.chat_outlined),
                iconOn: const Icon(Icons.chat_rounded),
                hasDot: controller.hasNewMessage.value,
                isActive: controller.fragmentIndex.value == 2,
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(2);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
            navItems.add(
              buildItemNav(
                label: 'Pengaturan',
                icon: const Icon(Icons.settings_outlined),
                iconOn: const Icon(Icons.settings_outlined),
                isActive: controller.fragmentIndex.value == 3,
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(3);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
          } else if (controller.userRole.value == 'admin') {
            navItems.add(
              buildItemNav(
                label: 'Beranda',
                icon: const Icon(Icons.grid_view_outlined),
                iconOn: const Icon(Icons.grid_view_rounded),
                isActive: controller.fragmentIndex.value == 0,
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(0);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
            navItems.add(
              buildItemNav(
                label: 'Produk',
                icon: const Icon(Icons.add_business_outlined),
                iconOn: const Icon(Icons.add_business_rounded),
                isActive: controller.fragmentIndex.value == 1,
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(1);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
            navItems.add(
              buildItemNav(
                label: 'Pesanan',
                icon: const Icon(Icons.shopping_bag_outlined),
                iconOn: const Icon(Icons.shopping_bag_rounded),
                isActive: controller.fragmentIndex.value == 2,
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(2);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
            navItems.add(
              buildItemNav(
                label: 'Chat',
                icon: const Icon(Icons.chat_outlined),
                iconOn: const Icon(Icons.chat_rounded),
                hasDot: controller.hasNewMessage.value,
                isDisable: !connectivity.isOnline.value,
                isActive: controller.fragmentIndex.value == 3,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(3);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
            navItems.add(
              buildItemNav(
                label: 'Pengaturan',
                icon: const Icon(Icons.settings_outlined),
                iconOn: const Icon(Icons.settings_outlined),
                isActive: controller.fragmentIndex.value == 4,
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(4);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
          } else {
            navItems.add(
              buildItemNav(
                label: 'Beranda',
                icon: const Icon(Icons.grid_view_outlined),
                iconOn: const Icon(Icons.grid_view_rounded),
                isActive: controller.fragmentIndex.value == 0,
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(0);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
            navItems.add(
              buildItemNav(
                label: 'Pesanan',
                icon: const Icon(Icons.shopping_bag_outlined),
                iconOn: const Icon(Icons.shopping_bag_rounded),
                isActive: controller.fragmentIndex.value == 1,
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(1);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
            navItems.add(
              buildItemNav(
                label: 'Chat',
                icon: const Icon(Icons.chat_outlined),
                iconOn: const Icon(Icons.chat_rounded),
                hasDot: controller.hasNewMessage.value,
                isDisable: !connectivity.isOnline.value,
                isActive: controller.fragmentIndex.value == 2,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(2);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
            navItems.add(
              buildItemNav(
                label: 'Favorit',
                icon: const Icon(Icons.favorite_outline_rounded),
                iconOn: const Icon(Icons.favorite_rounded),
                isActive: controller.fragmentIndex.value == 3,
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(3);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
            navItems.add(
              buildItemNav(
                label: 'Pengaturan',
                icon: const Icon(Icons.settings_outlined),
                iconOn: const Icon(Icons.settings_outlined),
                isActive: controller.fragmentIndex.value == 4,
                isDisable: !connectivity.isOnline.value,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(4);
                  } else {
                    const OfflineBanner();
                    return;
                  }
                },
              ),
            );
          }

          return SafeArea(
            top: false,
            child: Container(
              height: 78,
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xff1F2533),
                borderRadius: BorderRadiusDirectional.circular(30),
              ),
              child: Row(children: navItems),
            ),
          );
        }),
      ),
    );
  }
}
