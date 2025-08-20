import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';

Widget itemNewestCar(Car car, EdgeInsetsGeometry margin) {
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
      height: 98,
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 70,
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
                        height: 70,
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
                        height: 70,
                        fit: BoxFit.cover,
                      );
                    case LoadState.failed:
                      return Image.asset(
                        'assets/splash_screen.png',
                        width: 90,
                        height: 70,
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
                      child: Text(
                        car.nameProduct,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(Get.context!).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      " (${car.releaseProduct})",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(Get.context!).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  car.categoryProduct,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
                ),
                const Gap(4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RatingBar.builder(
                      initialRating: car.ratingProduct.toDouble(),
                      itemPadding: const EdgeInsets.all(0),
                      itemSize: 12,
                      unratedColor: Colors.grey[300],
                      itemBuilder: (context, index) =>
                          const Icon(Icons.star, color: Color(0xffFFBC1C)),
                      ignoreGestures: true,
                      allowHalfRating: true,
                      onRatingUpdate: (value) {},
                    ),
                    Text(
                      '(${car.purchasedProduct}x disewa)',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(Get.context!).colorScheme.onSurface,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xffFF5722),
                ),
              ),
              Text(
                '/hari',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
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
