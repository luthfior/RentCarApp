import 'package:dotted_line/dotted_line.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/models/booked_car.dart';

Widget itemOrderCar(BookedCar bookedCar, EdgeInsetsGeometry margin) {
  String statusText;
  Color statusColor;

  if (bookedCar.status.toLowerCase().contains('menunggu')) {
    statusText = 'Status: Menunggu untuk diproses.';
    statusColor = const Color(0xffFF5722);
  } else if (bookedCar.status.toLowerCase().contains('berhasil')) {
    statusText = 'Status: Berhasil diproses.';
    statusColor = const Color.fromARGB(255, 76, 175, 80);
  } else if (bookedCar.status.toLowerCase().contains('gagal')) {
    statusText = 'Status: Gagal diproses.';
    statusColor = const Color.fromARGB(255, 244, 67, 54);
  } else {
    statusText = 'Status: Tidak diketahui.';
    statusColor = Colors.grey;
  }

  return Container(
    height: 130,
    margin: margin,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(Get.context!).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 90,
              height: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ExtendedImage.network(
                  bookedCar.car.imageProduct,
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
                          bookedCar.car.nameProduct,
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
                        " (${bookedCar.car.releaseProduct})",
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
                    bookedCar.car.transmissionProduct,
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
                        initialRating: bookedCar.car.ratingProduct.toDouble(),
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
                        '(${bookedCar.car.purchasedProduct}x disewa)',
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
            const Gap(16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(
                    decimalDigits: 0,
                    locale: 'id_ID',
                    symbol: 'Rp.',
                  ).format(bookedCar.car.priceProduct),
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
        const Gap(10),
        const Expanded(
          child: DottedLine(
            dashLength: 5,
            dashGapLength: 5,
            dashColor: Color(0xffCECED5),
          ),
        ),
        const Gap(10),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 2),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const Gap(10),
            Text(
              statusText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
