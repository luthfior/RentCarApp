import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/core/utils/number_formatter.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/top_up_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/custom_input.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class TopUpPage extends GetView<TopUpViewModel> {
  TopUpPage({super.key});

  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                CustomHeader(title: 'Top Up Saldo'),
                const Gap(20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Gap(50),
                        Text(
                          'Saldo Anda Saat Ini:',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Gap(8),
                        Obx(
                          () => Text(
                            'Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(controller.currentBalance.value ?? 0).replaceAll(',', '.')}',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xffFF5722),
                            ),
                          ),
                        ),
                        const Gap(30),
                        CustomInput(
                          icon: '',
                          hint: 'Masukkan jumlah top up',
                          prefixText: 'Rp. ',
                          keyboardType: TextInputType.number,
                          inputFormatters: [NumberFormatter()],
                          editingController: controller.amountEdt,
                          onChanged: (value) => controller.checkChanges(),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(20),
                Obx(() {
                  final isLoading = controller.status.startsWith('loading');
                  final hasChanges = controller.isChanged.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ButtonPrimary(
                      onTap: isLoading || !hasChanges
                          ? null
                          : () {
                              if (connectivity.isOnline.value) {
                                controller.topUpBalance();
                              }
                            },
                      text: isLoading ? 'Menambah...' : 'Tambah Saldo',
                      customBackgroundColor: (isLoading || !hasChanges)
                          ? const Color(0xffFF5722).withAlpha(157)
                          : const Color(0xffFF5722),
                    ),
                  );
                }),
                const Gap(20),
              ],
            ),
          ),
          const OfflineBanner(),
        ],
      ),
    );
  }
}
