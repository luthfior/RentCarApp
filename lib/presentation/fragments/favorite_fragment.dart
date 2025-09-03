import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/data/sources/chat_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/favorite_view_model.dart';
import 'package:rent_car_app/presentation/widgets/item_favorite_car.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rent_car_app/presentation/widgets/tutorial_overlay.dart';

class FavoriteFragment extends GetView<FavoriteViewModel> {
  const FavoriteFragment({super.key});

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
                'Favorit',
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
                final status = controller.status.value;
                if (status == 'loading') {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xffFF5722),
                      ),
                    ),
                  );
                }
                if (status == 'empty') {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Anda belum memiliki Produk Favorit saat ini. Silahkan pilih Produk Favorit Anda',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (status == 'error') {
                  return Center(
                    child: Text(
                      'Gagal memuat daftar Favorit. Coba lagi nanti.',
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
                    await controller.fetchFavorites();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 0,
                    ),
                    itemCount: controller.favoriteProducts.length,
                    itemBuilder: (context, index) {
                      final car = controller.favoriteProducts[index];
                      return buildSlidableFavoriteItem(
                        context,
                        car: car,
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
                                message: 'Ready?',
                                receiverId: car.ownerId,
                                senderId: uid,
                                productDetail: {
                                  'id': car.id,
                                  'categoryProduct': car.categoryProduct,
                                  'descriptionProduct': car.descriptionProduct,
                                  'imageProduct': car.imageProduct,
                                  'nameProduct': car.nameProduct,
                                  'priceProduct': car.priceProduct,
                                  'purchasedProduct': car.purchasedProduct,
                                  'ratingProduct': car.ratingProduct,
                                  'releaseProduct': car.releaseProduct,
                                  'transmissionProduct':
                                      car.transmissionProduct,
                                },
                              );
                              ChatSource.openChat(
                                buyerId: uid,
                                ownerId: car.ownerId,
                                buyerName: authVM.account.value!.name,
                                buyerEmail: authVM.account.value!.email,
                                buyerPhotoUrl: authVM.account.value!.photoUrl!,
                                ownerName: car.ownerName,
                                ownerEmail: car.ownerEmail,
                                ownerPhotoUrl: car.ownerPhotoUrl,
                                ownerType: car.ownerType,
                              ).then((value) {
                                ChatSource.send(chat, uid, car.ownerId).then((
                                  value,
                                ) {
                                  final partnerInfo = {
                                    'id': uid,
                                    'type': authVM.account.value!.role,
                                    'name': authVM.account.value!.name,
                                    'email': authVM.account.value!.email,
                                    'photoUrl': authVM.account.value!.photoUrl,
                                  };
                                  Get.back();
                                  Get.toNamed(
                                    '/chatting',
                                    arguments: {
                                      'roomId': '${uid}_${car.ownerId}',
                                      'uid': uid,
                                      'ownerId': car.ownerId,
                                      'ownerType': car.ownerType,
                                      'partner': partnerInfo,
                                      'from': 'favorite',
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
                        onBooking: () async {
                          if (connectivity.isOnline.value) {
                            Get.toNamed('/booking', arguments: car);
                          } else {
                            null;
                          }
                        },
                        onRemoveFavorite: () async {
                          if (connectivity.isOnline.value) {
                            controller.favoriteProducts.removeAt(index);
                            controller.deleteFavorite(car);
                          } else {
                            null;
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
        const OfflineBanner(),
        Obx(() {
          if (!controller.hasShownTutorial.value &&
              controller.status.value == 'success') {
            return TutorialOverlay(
              onDismiss: () => controller.dismissTutorial(),
              message: "Geser kiri atau kanan pada item untuk menampilkan Opsi",
              icon: Icons.swipe,
            );
          }
          return Container();
        }),
      ],
    );
  }
}

Widget buildSlidableFavoriteItem(
  BuildContext context, {
  required Car car,
  required VoidCallback onRemoveFavorite,
  required VoidCallback onChat,
  required VoidCallback onBooking,
}) {
  return Slidable(
    key: ValueKey(car.id),
    endActionPane: ActionPane(
      motion: const ScrollMotion(),
      dismissible: DismissiblePane(
        onDismissed: () => onRemoveFavorite(),
        closeOnCancel: true,
      ),
      children: [
        SlidableAction(
          onPressed: (context) => onRemoveFavorite(),
          backgroundColor: const Color(0xffFF2056),
          foregroundColor: Colors.white,
          icon: Icons.delete_outline_rounded,
          label: 'Hapus',
        ),
      ],
    ),
    startActionPane: ActionPane(
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          onPressed: (context) => onBooking(),
          backgroundColor: const Color(0xff52575D),
          foregroundColor: Colors.white,
          icon: Icons.car_rental,
          label: 'Order',
        ),
        SlidableAction(
          onPressed: (context) => onChat(),
          backgroundColor: const Color(0xffFF5722),
          foregroundColor: Colors.white,
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Chat',
        ),
      ],
    ),
    child: itemFavoriteCar(context, car: car),
  );
}
