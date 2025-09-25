import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/detail_order_view_model.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class DetailOrderPage extends GetView<DetailOrderViewModel> {
  DetailOrderPage({super.key});

  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                buildHeader(),
                const Gap(20),
                Expanded(
                  child: Obx(() {
                    if (controller.status == 'loading' &&
                        controller.order.id.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xffFF5722),
                          ),
                        ),
                      );
                    }
                    if (controller.status == 'error') {
                      return const Center(
                        child: Text(
                          "Pesanan tidak ditemukan atau telah dihapus.",
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        if (connectivity.isOnline.value) {
                          await controller.refreshOrder();
                        } else {
                          const OfflineBanner();
                          return;
                        }
                      },
                      color: const Color(0xffFF5722),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          children: [
                            snippetCar(),
                            const Gap(20),
                            buildReceipt(),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          buildSellerActionButtons(context),

          Obx(() {
            if (controller.status == 'loading') {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const OfflineBanner(),
        ],
      ),
    );
  }

  Widget buildSellerActionButtons(BuildContext context) {
    return Obx(() {
      final account = controller.authVM.account.value;
      if (account == null ||
          controller.status != 'success' ||
          controller.order.id.isEmpty) {
        return const SizedBox.shrink();
      }

      final isSeller = controller.isSeller.value;
      final orderStatus = controller.order.orderStatus;

      if (isSeller && orderStatus == 'pending') {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: Get.isDarkMode
                  ? const Color(0xff070623)
                  : const Color(0xffEFEFF0),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (connectivity.isOnline.value) {
                          bool?
                          confirm = await controller.showConfirmationDialog(
                            context: context,
                            title: 'Batalkan Pesanan',
                            content:
                                'Apakah Anda yakin ingin membatalkan pesanan ini?',
                            confirmText: 'Ya, Batalkan',
                          );
                          if (confirm == true) {
                            controller.cancelOrder(
                              controller.order.id,
                              controller.order.customerId,
                              controller.order.sellerId,
                            );
                          }
                        } else {
                          const OfflineBanner();
                          return;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          Get.context!,
                        ).colorScheme.surface,
                        foregroundColor: const Color(0xffFF2056),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Batalkan',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (connectivity.isOnline.value) {
                          bool?
                          confirm = await controller.showConfirmationDialog(
                            context: context,
                            title: 'Konfirmasi Pesanan',
                            content:
                                'Apakah Anda yakin ingin mengonfirmasi pesanan ini?',
                            confirmText: 'Ya, Konfirmasi',
                          );
                          if (confirm == true) {
                            controller.confirmOrder(
                              controller.order.id,
                              controller.order.customerId,
                              controller.order.sellerId,
                              controller.order.orderDetail.totalPrice.round(),
                            );
                          }
                        } else {
                          const OfflineBanner();
                          return;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff75A47F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Konfirmasi',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget buildHeader() {
    return CustomHeader(title: 'Detail Order');
  }

  Widget snippetCar() {
    final String productName =
        controller.order.orderDetail.car.nameProduct.length > 16
        ? '${controller.order.orderDetail.car.nameProduct.substring(0, 14)}...'
        : controller.order.orderDetail.car.nameProduct;

    return Container(
      height: 85,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ExtendedImage.network(
            controller.order.orderDetail.car.imageProduct,
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
          const Gap(5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
                Text(
                  controller.order.orderDetail.car.transmissionProduct,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
                ),
                Text(
                  controller.order.orderDetail.car.categoryProduct,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (connectivity.isOnline.value) {
                final message = (controller.isSeller.value == true)
                    ? null
                    : 'Tolong diproses ya Min';
                await controller.openChatWithPartner(
                  controller.bookedCar!,
                  message: message,
                );
              } else {
                const OfflineBanner();
                return;
              }
            },
            child: Text(
              'Chat',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xffFF5722),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReceipt() {
    Widget buildReceiptRow(
      String title,
      String value, {
      bool isBold = false,
      bool isPrice = false,
      bool isInsurance = false,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: isInsurance ? TextOverflow.ellipsis : null,
                style: GoogleFonts.poppins(
                  fontSize: isBold ? 14 : 12,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                  color: isPrice
                      ? const Color(0xffFF5722)
                      : Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildReceiptRow(
              'Resi',
              isBold: true,
              controller.order.resi.isNotEmpty
                  ? controller.order.resi
                  : 'Tidak Ada',
            ),
            buildReceiptRow(
              'Metode Pembayaran',
              isBold: true,
              controller.order.paymentMethod.isNotEmpty
                  ? controller.order.paymentMethod
                  : 'Tidak Ada',
            ),
            buildReceiptRow(
              'Status Pembayaran',
              isBold: true,
              controller.order.paymentStatus.isNotEmpty
                  ? controller.order.paymentStatus
                  : 'Tidak Ada',
            ),
            buildReceiptRow(
              'Tanggal Order',
              isBold: true,
              controller.order.orderDate.toString().isNotEmpty
                  ? controller.formatTimestamp(controller.order.orderDate)
                  : 'Tidak Ada',
            ),
            buildReceiptRow(
              'Status Pemesanan',
              isBold: true,
              controller.order.orderStatus.toString().isNotEmpty
                  ? controller.formatOrderStatus(controller.order.orderStatus)
                  : 'Tidak Ada',
            ),
            const Divider(color: Color(0xffEFEEF7), height: 24),
            buildReceiptRow(
              'Nama Order',
              isBold: true,
              controller.order.customerFullname.isNotEmpty
                  ? controller.order.customerFullname
                  : 'Tidak Ada',
            ),
            buildReceiptRow(
              'Harga Sewa',
              isBold: true,
              '${controller.formatCurrency(controller.order.orderDetail.car.priceProduct.toDouble())}/hari',
            ),
            if (controller.order.orderDetail.withDriver)
              buildReceiptRow(
                'Biaya Driver',
                isBold: true,
                '${controller.formatCurrency(controller.order.orderDetail.driverCostPerDay.toDouble())}/hari',
              ),
            buildReceiptRow(
              'Tanggal Mulai',
              isBold: true,
              controller.order.orderDetail.startDate.isNotEmpty
                  ? controller.order.orderDetail.startDate
                  : 'Tidak Ada',
            ),
            buildReceiptRow(
              'Tanggal Berakhir',
              isBold: true,
              controller.order.orderDetail.endDate.isNotEmpty
                  ? controller.order.orderDetail.endDate
                  : 'Tidak Ada',
            ),
            buildReceiptRow(
              'Durasi',
              isBold: true,
              '${controller.order.orderDetail.duration} hari',
            ),
            buildReceiptRow(
              'Penyedia',
              isBold: true,
              controller.order.orderDetail.agency.isNotEmpty
                  ? controller.order.orderDetail.agency
                  : 'Tidak Ada',
            ),
            buildReceiptRow(
              'Asuransi',
              isBold: true,
              isInsurance: true,
              controller.order.orderDetail.insurance.isNotEmpty
                  ? controller.order.orderDetail.insurance
                  : 'Tidak Ada',
            ),
            const Divider(color: Color(0xffEFEEF7), height: 24),
            buildReceiptRow(
              'Sub Total',
              isBold: true,
              controller.formatCurrency(
                controller.order.orderDetail.subTotal.toDouble(),
              ),
            ),
            buildReceiptRow(
              'Biaya Asuransi (20%)',
              isBold: true,
              controller.formatCurrency(
                controller.order.orderDetail.totalInsuranceCost.toDouble(),
              ),
            ),
            buildReceiptRow(
              'Biaya Tambahan',
              isBold: true,
              controller.formatCurrency(
                controller.order.orderDetail.additionalCost.toDouble(),
              ),
            ),
            const Divider(color: Color(0xffEFEFF0), height: 24),
            buildReceiptRow(
              'Total Harga',
              isBold: true,
              isPrice: true,
              controller.formatCurrency(
                controller.order.orderDetail.totalPrice.toDouble(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
