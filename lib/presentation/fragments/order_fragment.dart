import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/models/booked_car.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/order_view_model.dart';
import 'package:rent_car_app/presentation/widgets/item_order_car.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';
import 'package:rent_car_app/presentation/widgets/tutorial_overlay.dart';

class OrderFragment extends GetView<OrderViewModel> {
  const OrderFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();

    return Stack(
      children: [
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  'Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const Gap(20),
              Expanded(
                child: Obx(() {
                  final isSeller =
                      controller.authVM.account.value?.role == 'seller' ||
                      controller.authVM.account.value?.role == 'admin';
                  if (controller.status.value == 'loading') {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xffFF5722),
                        ),
                      ),
                    );
                  }
                  if (controller.status.value == 'empty') {
                    final emptyText = isSeller
                        ? 'Belum ada Pesanan pada Toko kamu untuk saat ini'
                        : 'Anda belum melakukan Booking sebelumnya. Silahkan lakukan Booking terlebih dahulu';
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          emptyText,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (controller.status.value == 'error') {
                    return Center(
                      child: Text(
                        'Gagal memuat daftar Pesanan. Coba lagi nanti.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      if (connectivity.isOnline.value) {
                        await controller.startOrdersListener();
                      } else {
                        const OfflineBanner();
                        return;
                      }
                    },
                    color: const Color(0xffFF5722),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 0,
                      ),
                      separatorBuilder: (context, index) => const Gap(16),
                      itemCount: controller.myOrders.length,
                      itemBuilder: (context, index) {
                        final bookedCar = controller.myOrders[index];
                        return buildSlidableOrderItem(
                          context,
                          isSeller: isSeller,
                          bookedCar: bookedCar,
                          onChat: () async {
                            if (connectivity.isOnline.value) {
                              final message = (isSeller)
                                  ? null
                                  : 'Tolong diproses ya Min';
                              controller.openChatWithPartner(
                                bookedCar,
                                message: message,
                              );
                            } else {
                              const OfflineBanner();
                              return;
                            }
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const OfflineBanner(),
        Obx(() {
          if (controller.hasShownTutorial.value &&
              controller.status.value == 'success') {
            return TutorialOverlay(
              onDismiss: () => controller.dismissTutorial(),
              message: "Geser kiri pada item untuk menampilkan Opsi",
              icon: Icons.swipe_left,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget buildSlidableOrderItem(
    BuildContext context, {
    required BookedCar bookedCar,
    required bool isSeller,
    required VoidCallback onChat,
  }) {
    final connectivity = Get.find<ConnectivityService>();
    final orderStatus = bookedCar.order.orderStatus.toLowerCase();

    return Slidable(
      key: ValueKey(bookedCar.car.id),
      startActionPane: (isSeller && orderStatus == 'pending')
          ? ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    if (connectivity.isOnline.value) {
                      bool? confirm = await controller.showConfirmationDialog(
                        context: context,
                        title: 'Batalkan Pesanan',
                        content:
                            'Apakah Anda yakin ingin membatalkan pesanan ini?',
                        confirmText: 'Ya, Batalkan',
                      );
                      if (confirm == true) {
                        controller.cancelOrder(
                          bookedCar.order.id,
                          bookedCar.order.customerId,
                          bookedCar.order.sellerId,
                        );
                      }
                    } else {
                      const OfflineBanner();
                      return;
                    }
                  },
                  backgroundColor: const Color(0xffFF2056),
                  foregroundColor: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  icon: Icons.clear_rounded,
                ),
                SlidableAction(
                  onPressed: (context) async {
                    if (connectivity.isOnline.value) {
                      bool? confirm = await controller.showConfirmationDialog(
                        context: context,
                        title: 'Konfirmasi Pesanan',
                        content:
                            'Apakah Anda yakin ingin mengonfirmasi pesanan ini?',
                        confirmText: 'Ya, Konfirmasi',
                      );
                      if (confirm == true) {
                        controller.confirmOrder(
                          bookedCar.order.id,
                          bookedCar.order.customerId,
                          bookedCar.order.sellerId,
                          bookedCar.car.id,
                          bookedCar.order.orderDetail.totalPrice,
                        );
                      }
                    } else {
                      const OfflineBanner();
                      return;
                    }
                  },
                  backgroundColor: const Color(0xff75A47F),
                  foregroundColor: Colors.white,
                  icon: Icons.check_rounded,
                ),
              ],
            )
          : null,

      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              if (connectivity.isOnline.value) {
                return onChat();
              } else {
                const OfflineBanner();
                return;
              }
            },
            backgroundColor: const Color(0xffFF5722),
            foregroundColor: Colors.white,
            icon: Icons.chat_bubble_outline_rounded,
            borderRadius:
                (orderStatus == 'success' || orderStatus == 'cancelled')
                ? BorderRadius.zero
                : const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
          ),
          if (orderStatus == 'cancelled')
            SlidableAction(
              onPressed: (context) async {
                if (connectivity.isOnline.value) {
                  bool? confirm = await controller.showConfirmationDialog(
                    context: context,
                    title: 'Hapus Riwayat Pesanan',
                    content:
                        'Apakah Anda yakin ingin menghapus riwayat pesanan ini secara permanen?',
                    confirmText: 'Ya, Konfirmasi',
                  );
                  if (confirm == true) {
                    controller.deleteOrder(
                      bookedCar.order.id,
                      bookedCar.order.customerId,
                    );
                  }
                } else {
                  const OfflineBanner();
                  return;
                }
              },
              backgroundColor: const Color(0xffFF2056),
              foregroundColor: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              icon: Icons.delete_outline_rounded,
            ),
        ],
      ),
      child: itemOrderCar(context, bookedCar: bookedCar, isSeller: isSeller),
    );
  }
}
