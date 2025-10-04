import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/favorite_view_model.dart';
import 'package:rent_car_app/presentation/widgets/item_newest_car.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rent_car_app/presentation/widgets/tutorial_overlay.dart';

class FavoriteFragment extends GetView<FavoriteViewModel> {
  const FavoriteFragment({super.key});

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
                      if (connectivity.isOnline.value) {
                        await controller.fetchFavorites();
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
                      itemCount: controller.favoriteProducts.length,
                      itemBuilder: (context, index) {
                        final car = controller.favoriteProducts[index];
                        final owner = controller.ownersMap[car.ownerId];
                        return buildSlidableFavoriteItem(
                          context,
                          car: car,
                          ownerCity: owner?.city ?? '',
                          ownerStoreName: owner?.storeName ?? '',
                          onChat: () async {
                            if (connectivity.isOnline.value) {
                              controller.openChat(car);
                            } else {
                              const OfflineBanner();
                              null;
                            }
                          },
                          onBooking: () async {
                            if (connectivity.isOnline.value) {
                              Get.toNamed('/booking', arguments: car);
                            } else {
                              const OfflineBanner();
                              null;
                            }
                          },
                          onRemoveFavorite: () async {
                            if (connectivity.isOnline.value) {
                              controller.favoriteProducts.removeAt(index);
                              controller.deleteFavorite(car);
                            } else {
                              const OfflineBanner();
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
        ),
        const OfflineBanner(),
        Obx(() {
          if (controller.hasShownTutorial.value &&
              controller.status.value == 'success') {
            return TutorialOverlay(
              onDismiss: () => controller.dismissTutorial(),
              message:
                  "Geser ke kiri atau kanan pada item untuk menampilkan Opsi",
              icon: Icons.swipe,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

Widget buildSlidableFavoriteItem(
  BuildContext context, {
  required Car car,
  required String ownerCity,
  required String ownerStoreName,
  required VoidCallback onRemoveFavorite,
  required VoidCallback onChat,
  required VoidCallback onBooking,
}) {
  final connectivity = Get.find<ConnectivityService>();
  return Slidable(
    key: ValueKey(car.id),
    endActionPane: ActionPane(
      motion: const ScrollMotion(),
      dismissible: DismissiblePane(
        onDismissed: () {
          if (connectivity.isOnline.value) {
            return onRemoveFavorite();
          } else {
            const OfflineBanner();
            return;
          }
        },
        closeOnCancel: true,
      ),
      children: [
        SlidableAction(
          onPressed: (context) {
            if (connectivity.isOnline.value) {
              return onRemoveFavorite();
            } else {
              const OfflineBanner();
              return;
            }
          },
          backgroundColor: const Color(0xffFF2056),
          foregroundColor: Colors.white,
          icon: Icons.delete_outline_rounded,
        ),
      ],
    ),
    startActionPane: ActionPane(
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          onPressed: (context) {
            if (connectivity.isOnline.value) {
              return onBooking();
            } else {
              const OfflineBanner();
              return;
            }
          },
          backgroundColor: const Color(0xff52575D),
          foregroundColor: Colors.white,
          icon: Icons.car_rental,
        ),
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
        ),
      ],
    ),
    child: itemNewestCar(car, ownerCity, ownerStoreName, () {
      if (connectivity.isOnline.value) {
        Get.toNamed('/detail', arguments: car.id);
      } else {
        const OfflineBanner();
        return;
      }
    }),
  );
}
