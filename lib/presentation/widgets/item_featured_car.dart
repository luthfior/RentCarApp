import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

Widget itemFeaturedCar(Car car, EdgeInsetsGeometry margin, bool isTrending) {
  final connectivity = Get.find<ConnectivityService>();
  final String productName = car.nameProduct.length > 16
      ? '${car.nameProduct.substring(0, 14)}...'
      : car.nameProduct;

  return GestureDetector(
    onTap: () {
      if (connectivity.isOnline.value) {
        Get.toNamed('/detail', arguments: car.id);
      } else {
        const OfflineBanner();
        return;
      }
    },
    child: Container(
      width: 245,
      margin: margin,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ExtendedImage.network(
                    car.imageProduct,
                    width: 175,
                    height: 125,
                    fit: BoxFit.cover,
                    loadStateChanged: (state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          return const SizedBox(
                            width: 175,
                            height: 125,
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
                            width: 175,
                            height: 125,
                            fit: BoxFit.cover,
                          );
                        case LoadState.failed:
                          return Image.asset(
                            'assets/splash_screen.png',
                            width: 175,
                            height: 125,
                          );
                      }
                    },
                  ),
                ),
              ),
              if (isTrending)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: const Color(0xffFF2055),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                        color: const Color(0xffFF2056).withAlpha(128),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 14,
                  ),
                  child: Text(
                    'TRENDING',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffFFFFFF),
                    ),
                  ),
                ),
            ],
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(Get.context!).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      car.brandProduct,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(Get.context!).colorScheme.secondary,
                      ),
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
                            " ${car.city}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                Get.context!,
                              ).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '(${car.releaseProduct})',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(Get.context!).colorScheme.onSurface,
                    ),
                  ),
                  const Gap(4),
                  RatingBar.builder(
                    initialRating: car.ratingAverage.toDouble(),
                    itemPadding: const EdgeInsets.all(0),
                    itemSize: 16,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(Get.context!).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(4),
          Text(
            car.ownerStoreName,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(Get.context!).colorScheme.secondary,
            ),
          ),
          const Gap(10),
          Row(
            children: [
              Text(
                NumberFormat.currency(
                  decimalDigits: 0,
                  locale: 'id_ID',
                  symbol: 'Rp.',
                ).format(car.priceProduct),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xffFF5722),
                ),
              ),
              const SizedBox(width: 4),
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
