import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/models/car.dart';

Widget itemFeaturedCar(Car car, EdgeInsetsGeometry margin, bool isTrending) {
  final String productName = car.nameProduct.length > 16
      ? '${car.nameProduct.substring(0, 14)}...'
      : car.nameProduct;

  return GestureDetector(
    onTap: () {
      Get.toNamed('/detail', arguments: car);
    },
    child: Container(
      width: 245,
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ExtendedImage.network(
                  car.imageProduct,
                  width: 175,
                  height: 125,
                  fit: BoxFit.cover,
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState == LoadState.failed) {
                      return Image.asset(
                        'assets/splash_screen.png',
                        width: 220,
                        height: 170,
                      );
                    }
                    return null;
                  },
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
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(10),
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
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff070623),
                      ),
                    ),
                    Text(
                      car.transmissionProduct,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff838384),
                      ),
                    ),
                    Text(
                      car.categoryProduct,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff838384),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '(${car.releaseProduct})',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff070623),
                    ),
                  ),
                  const Gap(4),
                  RatingBar.builder(
                    initialRating: car.ratingProduct.toDouble(),
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
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff838384),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(10),
          Row(
            children: [
              Text(
                NumberFormat.currency(
                  decimalDigits: 0,
                  locale: 'id',
                  symbol: 'Rp.',
                ).format(car.priceProduct),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff6747E9),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/hari',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff838384),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
