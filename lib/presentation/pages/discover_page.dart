import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/data/services/theme_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_bottom_bar.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class DiscoverPage extends GetView<DiscoverViewModel> {
  DiscoverPage({super.key});

  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    final authVM = Get.find<AuthViewModel>();
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Obx(() => controller.fragments[controller.fragmentIndex.value]),
          GetBuilder<ThemeService>(
            builder: (themeService) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 38,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              );
            },
          ),
          const OfflineBanner(),
        ],
      ),

      bottomNavigationBar: Obx(() {
        final isOnline = connectivity.isOnline.value;

        return Container(
          height: 78,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? const Color(0xff1F2533)
                : const Color(0xff070623),
            borderRadius: BorderRadiusDirectional.circular(30),
          ),
          child: Row(
            children: [
              buildItemNav(
                label: 'Beranda',
                icon: 'assets/ic_browse.png',
                iconOn: 'assets/ic_browse_on.png',
                isActive: controller.fragmentIndex.value == 0,
                isDisable: !isOnline,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(0);
                  } else {
                    null;
                  }
                },
              ),
              buildItemNav(
                label: 'Order',
                icon: 'assets/ic_orders.png',
                iconOn: 'assets/ic_orders_on.png',
                isActive: controller.fragmentIndex.value == 1,
                isDisable: !isOnline,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(1);
                  } else {
                    null;
                  }
                },
              ),
              buildItemNav(
                label: 'Pesan',
                icon: 'assets/ic_chats.png',
                iconOn: 'assets/ic_chats_on.png',
                hasDot: true,
                isDisable: !isOnline,
                onTap: () {
                  String uid = authVM.account.value!.uid;
                  Get.toNamed(
                    '/chatting',
                    arguments: {
                      'uid': uid,
                      'username': authVM.account.value!.name,
                    },
                  );
                },
              ),
              buildItemNav(
                label: 'Favorit',
                icon: const Icon(Icons.favorite_outline_rounded),
                iconOn: const Icon(Icons.favorite_rounded),
                isActive: controller.fragmentIndex.value == 2,
                isDisable: !isOnline,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(2);
                  } else {
                    null;
                  }
                },
              ),
              buildItemNav(
                label: 'Pengaturan',
                icon: 'assets/ic_settings.png',
                iconOn: 'assets/ic_settings_on.png',
                isActive: controller.fragmentIndex.value == 3,
                isDisable: !isOnline,
                onTap: () {
                  if (connectivity.isOnline.value) {
                    controller.setFragmentIndex(3);
                  } else {
                    null;
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
