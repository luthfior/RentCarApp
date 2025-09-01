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
    return Scaffold(
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
                }
              },
            ),
          );
          navItems.add(
            buildItemNav(
              label: 'Pesanan',
              icon: 'assets/ic_orders.png',
              iconOn: 'assets/ic_orders_on.png',
              isActive: controller.fragmentIndex.value == 1,
              isDisable: !connectivity.isOnline.value,
              onTap: () {
                if (connectivity.isOnline.value) {
                  controller.setFragmentIndex(1);
                }
              },
            ),
          );
          navItems.add(
            buildItemNav(
              label: 'Chat',
              icon: 'assets/ic_chats.png',
              iconOn: 'assets/ic_chats_on.png',
              hasDot: controller.hasNewMessage.value,
              isActive: controller.fragmentIndex.value == 2,
              isDisable: !connectivity.isOnline.value,
              onTap: () {
                if (connectivity.isOnline.value) {
                  controller.setFragmentIndex(2);
                }
              },
            ),
          );
          navItems.add(
            buildItemNav(
              label: 'Pengaturan',
              icon: 'assets/ic_settings.png',
              iconOn: 'assets/ic_settings_on.png',
              isActive: controller.fragmentIndex.value == 3,
              isDisable: !connectivity.isOnline.value,
              onTap: () {
                if (connectivity.isOnline.value) {
                  controller.setFragmentIndex(3);
                }
              },
            ),
          );
        } else if (controller.userRole.value == 'admin') {
          navItems.add(
            buildItemNav(
              label: 'Beranda',
              icon: 'assets/ic_browse.png',
              iconOn: 'assets/ic_browse_on.png',
              isActive: controller.fragmentIndex.value == 0,
              isDisable: !connectivity.isOnline.value,
              onTap: () {
                if (connectivity.isOnline.value) {
                  controller.setFragmentIndex(0);
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
                }
              },
            ),
          );
          navItems.add(
            buildItemNav(
              label: 'Pesanan',
              icon: 'assets/ic_orders.png',
              iconOn: 'assets/ic_orders_on.png',
              isActive: controller.fragmentIndex.value == 2,
              isDisable: !connectivity.isOnline.value,
              onTap: () {
                if (connectivity.isOnline.value) {
                  controller.setFragmentIndex(2);
                }
              },
            ),
          );
          navItems.add(
            buildItemNav(
              label: 'Chat',
              icon: 'assets/ic_chats.png',
              iconOn: 'assets/ic_chats_on.png',
              hasDot: controller.hasNewMessage.value,
              isDisable: !connectivity.isOnline.value,
              isActive: controller.fragmentIndex.value == 3,
              onTap: () {
                if (connectivity.isOnline.value) {
                  controller.setFragmentIndex(3);
                }
              },
            ),
          );
          navItems.add(
            buildItemNav(
              label: 'Pengaturan',
              icon: 'assets/ic_settings.png',
              iconOn: 'assets/ic_settings_on.png',
              isActive: controller.fragmentIndex.value == 4,
              isDisable: !connectivity.isOnline.value,
              onTap: () {
                if (connectivity.isOnline.value) {
                  controller.setFragmentIndex(4);
                }
              },
            ),
          );
        } else {
          navItems.add(
            buildItemNav(
              label: 'Beranda',
              icon: 'assets/ic_browse.png',
              iconOn: 'assets/ic_browse_on.png',
              isActive: controller.fragmentIndex.value == 0,
              isDisable: !connectivity.isOnline.value,
              onTap: () {
                if (connectivity.isOnline.value) {
                  controller.setFragmentIndex(0);
                }
              },
            ),
          );
          navItems.add(
            buildItemNav(
              label: 'Pesanan',
              icon: 'assets/ic_orders.png',
              iconOn: 'assets/ic_orders_on.png',
              isActive: controller.fragmentIndex.value == 1,
              isDisable: !connectivity.isOnline.value,
              onTap: () {
                if (connectivity.isOnline.value) {
                  controller.setFragmentIndex(1);
                }
              },
            ),
          );
          navItems.add(
            buildItemNav(
              label: 'Chat',
              icon: 'assets/ic_chats.png',
              iconOn: 'assets/ic_chats_on.png',
              hasDot: controller.hasNewMessage.value,
              isDisable: !connectivity.isOnline.value,
              isActive: controller.fragmentIndex.value == 2,
              onTap: () {
                if (connectivity.isOnline.value) {
                  controller.setFragmentIndex(2);
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
                }
              },
            ),
          );
          navItems.add(
            buildItemNav(
              label: 'Pengaturan',
              icon: 'assets/ic_settings.png',
              iconOn: 'assets/ic_settings_on.png',
              isActive: controller.fragmentIndex.value == 4,
              isDisable: !connectivity.isOnline.value,
              onTap: () {
                if (connectivity.isOnline.value) {
                  controller.setFragmentIndex(4);
                }
              },
            ),
          );
        }

        return Container(
          height: 78,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? const Color(0xff1F2533)
                : const Color(0xff070623),
            borderRadius: BorderRadiusDirectional.circular(30),
          ),
          child: Row(children: navItems),
        );
      }),
    );
  }
}
