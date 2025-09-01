import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/booked_car.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/data/sources/chat_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/order_view_model.dart';
import 'package:rent_car_app/presentation/widgets/item_order_car.dart';
import 'package:rent_car_app/presentation/widgets/item_order_seller.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';
import 'package:rent_car_app/presentation/widgets/tutorial_overlay.dart';

class OrderFragment extends GetView<OrderViewModel> {
  const OrderFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();
    final authVM = Get.find<AuthViewModel>();

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(30 + MediaQuery.of(context).padding.top),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    await controller.startOrdersListener();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 0,
                    ),
                    itemCount: controller.myOrders.length,
                    itemBuilder: (context, index) {
                      final car = controller.myOrders[index];
                      if (isSeller) {
                        return itemOrderSeller(
                          context,
                          bookedCar: car,
                          controller: controller,
                        );
                      } else {
                        return buildSlidableOrderItem(
                          context,
                          bookedCar: car,
                          onChat: () async {
                            if (connectivity.isOnline.value) {
                              Get.dialog(
                                const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xffFF5722),
                                    ),
                                  ),
                                ),
                                barrierDismissible: false,
                              );
                              try {
                                String uid = authVM.account.value!.uid;
                                Chat chat = Chat(
                                  chatId: uid,
                                  message: 'Tolong diproses ya Min!',
                                  receiverId: car.car.ownerId,
                                  senderId: uid,
                                  productDetail: {
                                    'id': car.car.id,
                                    'categoryProduct': car.car.categoryProduct,
                                    'descriptionProduct':
                                        car.car.descriptionProduct,
                                    'imageProduct': car.car.imageProduct,
                                    'nameProduct': car.car.nameProduct,
                                    'priceProduct': car.car.priceProduct,
                                    'purchasedProduct':
                                        car.car.purchasedProduct,
                                    'ratingProduct': car.car.ratingProduct,
                                    'releaseProduct': car.car.releaseProduct,
                                    'transmissionProduct':
                                        car.car.transmissionProduct,
                                  },
                                );
                                ChatSource.openChat(
                                  buyerId: uid,
                                  ownerId: car.car.ownerId,
                                  buyerName: authVM.account.value!.name,
                                  buyerEmail: authVM.account.value!.email,
                                  buyerPhotoUrl:
                                      authVM.account.value!.photoUrl!,
                                  ownerName: car.car.ownerName,
                                  ownerEmail: car.car.ownerEmail,
                                  ownerPhotoUrl: car.car.ownerPhotoUrl,
                                  ownerType: car.car.ownerType,
                                ).then((value) {
                                  ChatSource.send(
                                    chat,
                                    uid,
                                    car.car.ownerId,
                                  ).then((value) {
                                    final partnerInfo = {
                                      'id': uid,
                                      'type': authVM.account.value!.role,
                                      'name': authVM.account.value!.name,
                                      'email': authVM.account.value!.email,
                                      'photoUrl':
                                          authVM.account.value!.photoUrl,
                                    };
                                    Get.back();
                                    Get.toNamed(
                                      '/chatting',
                                      arguments: {
                                        'uid': uid,
                                        'ownerId': car.car.ownerId,
                                        'ownerType': car.car.ownerType,
                                        'partner': partnerInfo,
                                        'from': 'order',
                                      },
                                    );
                                  });
                                });
                              } catch (e) {
                                Get.back();
                                log('Gagal membuka chat: $e');
                                Message.error('Gagal membuka chat. Coba lagi.');
                              }
                            } else {
                              null;
                            }
                          },
                        );
                      }
                    },
                  ),
                );
              }),
            ),
          ],
        ),
        const OfflineBanner(),
        Obx(() {
          if (!controller.hasShownTutorial.value &&
              controller.status.value == 'success') {
            return TutorialOverlay(
              onDismiss: () => controller.dismissTutorial(),
              message: "Geser kiri pada item untuk menampilkan Opsi",
              icon: Icons.swipe_left,
            );
          }
          return Container();
        }),
      ],
    );
  }

  Widget buildSlidableOrderItem(
    BuildContext context, {
    required BookedCar bookedCar,
    required VoidCallback onChat,
  }) {
    return Slidable(
      key: ValueKey(bookedCar.car.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () => onChat(),
          closeOnCancel: true,
        ),
        children: [
          SlidableAction(
            onPressed: (context) => onChat(),
            backgroundColor: const Color(0xffFF5722),
            foregroundColor: Colors.white,
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
          ),
        ],
      ),
      child: itemOrderCar(context, bookedCar: bookedCar),
    );
  }
}
