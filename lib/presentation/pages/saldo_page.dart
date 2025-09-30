import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class SaldoPage extends StatelessWidget {
  SaldoPage({super.key});

  final connectivity = Get.find<ConnectivityService>();
  final discoverVM = Get.find<DiscoverViewModel>();
  final authVM = Get.find<AuthViewModel>();

  @override
  Widget build(BuildContext context) {
    final userRole = authVM.account.value?.role;
    final String userCollection = userRole == 'admin' ? 'Admin' : 'Users';
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: 'Saldo DompetKu',
              onBackTap: () {
                if (connectivity.isOnline.value) {
                  if (userRole == 'seller') {
                    Get.until((route) => route.settings.name == '/discover');
                    discoverVM.setFragmentIndex(3);
                  } else {
                    Get.until((route) => route.settings.name == '/discover');
                    discoverVM.setFragmentIndex(4);
                  }
                } else {
                  const OfflineBanner();
                  return;
                }
              },
            ),
            const Gap(20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      if (connectivity.isOnline.value) {
                        await authVM.loadUser();
                      } else {
                        const OfflineBanner();
                        return;
                      }
                    },
                    color: const Color(0xffFF5722),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(userCollection)
                              .doc(authVM.account.value?.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xffFF5722),
                                  ),
                                ),
                              );
                            }
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final saldo = data['income'] ?? 0;

                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Saldo Anda Saat Ini:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    'Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(saldo).replaceAll(',', '.')}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xffFF5722),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const OfflineBanner(),
          ],
        ),
      ),
    );
  }
}
