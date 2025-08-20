import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/data/sources/chat_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/favorite_view_model.dart';
import 'package:rent_car_app/presentation/widgets/item_favorite_car.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class FavoriteFragment extends GetView<FavoriteViewModel> {
  FavoriteFragment({super.key});

  final connectivity = Get.find<ConnectivityService>();
  final authVM = Get.find<AuthViewModel>();

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const OfflineBanner(),
        const Gap(20),
        Expanded(
          child: Obx(() {
            if (controller.status.value == 'loading') {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
                ),
              );
            }
            if (controller.status.value == 'empty') {
              return Center(
                child: Text(
                  'Anda belum memiliki produk favorit.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (controller.status.value == 'error') {
              return Center(
                child: Text(
                  'Gagal memuat daftar favorit. Coba lagi nanti.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              itemCount: controller.favoriteProducts.length,
              itemBuilder: (context, index) {
                final car = controller.favoriteProducts[index];
                return itemFavoriteCar(
                  context,
                  car: car,
                  onRemoveFavorite: () => controller.deleteFavorite(car),
                  onChat: () async {
                    if (connectivity.isOnline.value) {
                      try {
                        String uid = authVM.account.value!.uid;
                        Chat chat = Chat(
                          chatId: uid,
                          message: '',
                          receiverId: 'cs',
                          senderId: uid,
                          productDetail: {
                            'id': car.id,
                            'categoryProduct': car.categoryProduct,
                            'imageProduct': car.imageProduct,
                            'nameProduct': car.nameProduct,
                            'priceProduct': car.priceProduct,
                            'releaseProduct': car.releaseProduct,
                            'transmissionProduct': car.transmissionProduct,
                          },
                        );
                        ChatSource.openChat(
                          uid,
                          authVM.account.value!.name,
                        ).then((value) {
                          ChatSource.send(chat, uid).then((value) {
                            Get.toNamed(
                              '/chatting',
                              arguments: {
                                'uid': uid,
                                'username': authVM.account.value!.name,
                              },
                            );
                          });
                        });
                      } catch (e) {
                        log('Gagal membuka chat: $e');
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
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
