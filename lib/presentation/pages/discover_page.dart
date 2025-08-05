import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/presentation/fragments/browse_fragment.dart';
import 'package:rent_car_app/presentation/fragments/order_fragment.dart';
import 'package:rent_car_app/presentation/fragments/setting_fragment.dart';
import 'package:rent_car_app/presentation/widgets/button_bottom_bar.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';

class DiscoverPage extends StatelessWidget {
  DiscoverPage({super.key});

  final connectivity = Get.find<ConnectivityService>();
  final fragmentIndex = 0.obs;
  final fragments = [BrowseFragment(), OrderFragment(), SettingFragment()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Obx(() => fragments[fragmentIndex.value]),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(height: 38, color: const Color(0xffEFEFF0)),
          ),
        ],
      ),

      bottomNavigationBar: Obx(() {
        return Container(
          height: 78,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xff070623),
            borderRadius: BorderRadiusDirectional.circular(30),
          ),
          child: Row(
            children: [
              buildItemNav(
                label: 'Browse',
                icon: 'assets/ic_browse.png',
                iconOn: 'assets/ic_browse_on.png',
                isActive: fragmentIndex.value == 0,
                onTap: () {
                  fragmentIndex.value = 0;
                },
              ),
              buildItemNav(
                label: 'Orders',
                icon: 'assets/ic_orders.png',
                iconOn: 'assets/ic_orders_on.png',
                isActive: fragmentIndex.value == 1,
                onTap: () {
                  fragmentIndex.value = 1;
                },
              ),
              buildItemCircle(),
              buildItemNav(
                label: 'Chats',
                icon: 'assets/ic_chats.png',
                iconOn: 'assets/ic_chats_on.png',
                hasDot: true,
                onTap: () {},
              ),
              buildItemNav(
                label: 'Settings',
                icon: 'assets/ic_settings.png',
                iconOn: 'assets/ic_settings_on.png',
                isActive: fragmentIndex.value == 2,
                onTap: () {
                  fragmentIndex.value = 2;
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
