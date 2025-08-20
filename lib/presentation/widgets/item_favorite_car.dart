import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/widgets/button_chat.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';

Widget itemFavoriteCar(
  BuildContext context, {
  required Car car,
  required VoidCallback onRemoveFavorite,
  required VoidCallback onChat,
  required VoidCallback onBooking,
}) {
  final connectivity = Get.find<ConnectivityService>();
  return GestureDetector(
    onTap: () {
      if (connectivity.isOnline.value) {
        Get.toNamed('/detail', arguments: car.id);
      } else {
        null;
      }
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ExtendedImage.network(
                    car.imageProduct,
                    fit: BoxFit.cover,
                    loadStateChanged: (state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          return const SizedBox(
                            width: 80,
                            height: 60,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xffFF5722),
                                ),
                              ),
                            ),
                          );
                        case LoadState.completed:
                          return ExtendedImage(
                            image: state.imageProvider,
                            width: 80,
                            height: 60,
                            fit: BoxFit.cover,
                          );
                        case LoadState.failed:
                          return Image.asset(
                            'assets/splash_screen.png',
                            width: 80,
                            height: 60,
                          );
                      }
                    },
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      car.nameProduct,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          Get.context!,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    " (${car.releaseProduct})",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        Get.context!,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Text(
                                car.transmissionProduct,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(
                                    Get.context!,
                                  ).colorScheme.secondary,
                                ),
                              ),
                              const Gap(4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  RatingBar.builder(
                                    initialRating: car.ratingProduct.toDouble(),
                                    itemPadding: const EdgeInsets.all(0),
                                    itemSize: 14,
                                    unratedColor: Colors.grey[300],
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Color(0xffFFBC1C),
                                    ),
                                    ignoreGestures: true,
                                    allowHalfRating: true,
                                    onRatingUpdate: (value) {},
                                  ),
                                  Text(
                                    '(${car.purchasedProduct}x disewa)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(
                                        Get.context!,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Gap(14),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              NumberFormat.currency(
                                decimalDigits: 0,
                                locale: 'id_ID',
                                symbol: 'Rp.',
                              ).format(car.priceProduct),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xffFF5722),
                              ),
                            ),
                            Text(
                              '/hari',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(
                                  Get.context!,
                                ).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: ButtonPrimary(
                  onTap: onBooking,
                  customBorderRadius: BorderRadius.circular(8),
                  text: 'Booking',
                  customHeight: 32,
                  customTextSize: 12,
                ),
              ),
              const Gap(8),
              Expanded(
                child: ButtonChat(
                  text: 'Chat',
                  customHeight: 32,
                  customTextSize: 12,
                  customIconSize: 18,
                  customBorderRadius: BorderRadius.circular(8),
                  onTap: onChat,
                ),
              ),
              const Gap(8),
              Expanded(child: _deleteButton(onTap: onRemoveFavorite)),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _deleteButton({required VoidCallback onTap}) {
  return Material(
    borderRadius: BorderRadius.circular(8),
    color: Theme.of(Get.context!).colorScheme.surface,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(Get.context!).colorScheme.onSurface,
          ),
        ),
        width: double.infinity,
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ColorFiltered(
              colorFilter: ColorFilter.mode(Color(0xffFF5722), BlendMode.srcIn),
              child: Icon(Icons.delete_outline_rounded, size: 20),
            ),
            const Gap(8),
            Text(
              'Hapus',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
