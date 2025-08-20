import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/pin_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';
import 'package:rent_car_app/presentation/widgets/pin_layout.dart';
import 'package:rent_car_app/presentation/widgets/pin_number_input.dart';

class PinSetupPage extends GetView<PinViewModel> {
  PinSetupPage({super.key});

  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    final title = controller.isChangingPin ? 'Ganti PIN' : 'Buat PIN';

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Gap(20 + MediaQuery.of(context).padding.top),
              CustomHeader(title: title),
              const Gap(100),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      pinNumberInput(controller.pin1),
                      const Gap(30),
                      pinNumberInput(controller.pin2),
                      const Gap(30),
                      pinNumberInput(controller.pin3),
                      const Gap(30),
                      pinNumberInput(controller.pin4),
                    ],
                  ),
                  const Gap(30),
                  pinLayout(controller),
                ],
              ),
            ],
          ),
          const OfflineBanner(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final onPressed =
                  controller.isPinComplete.value || !connectivity.isOnline.value
                  ? () async {
                      if (connectivity.isOnline.value) {
                        final newPin = controller.getPin;
                        await controller.setPin(newPin);
                      } else {
                        null;
                      }
                    }
                  : null;

              return ButtonPrimary(onTap: onPressed, text: 'Konfirmasi PIN');
            }),
            const Gap(20),
          ],
        ),
      ),
    );
  }
}
