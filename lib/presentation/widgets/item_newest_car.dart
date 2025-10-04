import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/models/car.dart';

Widget itemNewestCar(
  Car car,
  String ownerCity,
  String ownerStoreName,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 85,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ExtendedImage.network(
                car.imageProduct,
                fit: BoxFit.cover,
                loadStateChanged: (state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      return const SizedBox(
                        width: 90,
                        height: 85,
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
                        width: 90,
                        height: 85,
                        fit: BoxFit.cover,
                      );
                    case LoadState.failed:
                      return Image.asset(
                        'assets/splash_screen.png',
                        width: 90,
                        height: 85,
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
                    Flexible(
                      child: Text(
                        car.nameProduct,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(Get.context!).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      " (${car.releaseProduct})",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(Get.context!).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  car.brandProduct,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RatingBar.builder(
                      initialRating: car.ratingAverage.toDouble(),
                      itemPadding: const EdgeInsets.all(0),
                      itemSize: 12,
                      unratedColor: Colors.grey[300],
                      itemBuilder: (context, index) =>
                          const Icon(Icons.star, color: Color(0xffFFBC1C)),
                      ignoreGestures: true,
                      allowHalfRating: true,
                      onRatingUpdate: (value) {},
                    ),
                    Flexible(
                      child: Text(
                        '(${car.purchasedProduct}x disewa)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(Get.context!).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Theme.of(Get.context!).colorScheme.secondary,
                      size: 12,
                    ),
                    Expanded(
                      child: Text(
                        " $ownerCity",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(Get.context!).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  ownerStoreName,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xffFF5722),
                ),
              ),
              Text(
                '/hari',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(Get.context!).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
