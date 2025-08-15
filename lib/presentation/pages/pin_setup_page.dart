import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/pin_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class PinSetupPage extends GetView<PinViewModel> {
  PinSetupPage({super.key});

  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Gap(20 + MediaQuery.of(context).padding.top),
              CustomHeader(title: 'Buat PIN'),
              const Gap(100),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _inputPin(controller.pin1),
                      const Gap(30),
                      _inputPin(controller.pin2),
                      const Gap(30),
                      _inputPin(controller.pin3),
                      const Gap(30),
                      _inputPin(controller.pin4),
                    ],
                  ),
                  const Gap(30),
                  _buildNumberInput(controller),
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
              final Function()? onPressed = controller.isPinComplete.value
                  ? () async {
                      if (connectivity.isOnline.value) {
                        (!controller.isPinComplete.value)
                            ? null
                            : () {
                                final newPin =
                                    controller.pin1.text +
                                    controller.pin2.text +
                                    controller.pin3.text +
                                    controller.pin4.text;
                                controller.setPin(newPin);
                              };
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

  Widget _inputPin(TextEditingController editingController) {
    InputBorder inputBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(Get.context!).colorScheme.onSurface,
        width: 3,
      ),
    );
    return SizedBox(
      width: 30,
      child: TextField(
        controller: editingController,
        obscureText: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          enabled: false,
          focusedBorder: inputBorder,
          enabledBorder: inputBorder,
          border: inputBorder,
          disabledBorder: inputBorder,
        ),
        style: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: Theme.of(Get.context!).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildNumberInput(PinViewModel pinVm) {
    return SizedBox(
      width: 300,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.25,
        mainAxisSpacing: 25,
        crossAxisSpacing: 25,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          _buildNumberButton(pinVm, 1),
          _buildNumberButton(pinVm, 2),
          _buildNumberButton(pinVm, 3),
          _buildNumberButton(pinVm, 4),
          _buildNumberButton(pinVm, 5),
          _buildNumberButton(pinVm, 6),
          _buildNumberButton(pinVm, 7),
          _buildNumberButton(pinVm, 8),
          _buildNumberButton(pinVm, 9),
          _buildNumberButton(pinVm, null),
          _buildNumberButton(pinVm, 0),
          _buildNumberButton(pinVm, Icons.backspace),
        ],
      ),
    );
  }

  Widget _buildNumberButton(PinViewModel pinVm, dynamic input) {
    if (input == null) {
      return Container();
    }

    Widget content;
    VoidCallback? onPressed;

    if (input is int) {
      content = Text(
        '$input',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Theme.of(Get.context!).colorScheme.onSurface,
        ),
      );
      onPressed = () => pinVm.handlePinInput(input);
    } else {
      content = Icon(
        input as IconData,
        color: Theme.of(Get.context!).colorScheme.onSurface,
        size: 28,
      );
      onPressed = () => pinVm.handlePinInput(input);
    }

    return Center(
      child: IconButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(Get.context!).colorScheme.onSurface,
          ),
        ),
        constraints: const BoxConstraints(
          minHeight: 65,
          minWidth: 65,
          maxHeight: 65,
          maxWidth: 65,
        ),
        icon: content,
      ),
    );
  }
}
