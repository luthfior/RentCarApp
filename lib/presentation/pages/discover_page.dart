import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/fragments/browse_fragment.dart';
import 'package:rent_car_app/presentation/fragments/order_fragment.dart';
import 'package:rent_car_app/presentation/fragments/setting_fragment.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_bottom_bar.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';

class DiscoverPage extends GetView<DiscoverViewModel> {
  DiscoverPage({super.key}) {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      if (args.containsKey('fragmentIndex')) {
        controller.setFragmentIndex(args['fragmentIndex']);
      }

      if (args.containsKey('bookedCar')) {
        final browseVM = Get.find<BrowseViewModel>();
        browseVM.car.value = args['bookedCar'] as Car;
      }
    }
  }

  final connectivity = Get.find<ConnectivityService>();
  final fragments = [
    const BrowseFragment(),
    const OrderFragment(),
    SettingFragment(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Obx(() => fragments[controller.fragmentIndex.value]),
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
                isActive: controller.fragmentIndex.value == 0,
                onTap: () {
                  controller.setFragmentIndex(0);
                },
              ),
              buildItemNav(
                label: 'Orders',
                icon: 'assets/ic_orders.png',
                iconOn: 'assets/ic_orders_on.png',
                isActive: controller.fragmentIndex.value == 1,
                onTap: () {
                  controller.setFragmentIndex(1);
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
                isActive: controller.fragmentIndex.value == 2,
                onTap: () {
                  controller.setFragmentIndex(2);
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
