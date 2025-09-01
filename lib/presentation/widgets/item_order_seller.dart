import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/models/booked_car.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/order_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';

Widget itemOrderSeller(
  BuildContext context, {
  required BookedCar bookedCar,
  required OrderViewModel controller,
}) {
  String statusText;
  Color statusColor;

  final connectivity = Get.find<ConnectivityService>();

  if (bookedCar.order.orderStatus.toLowerCase().contains('pending')) {
    statusText = 'Status: Orderan menunggu untuk kamu Proses.';
    statusColor = const Color(0xffFF5722);
  } else if (bookedCar.order.orderStatus.toLowerCase().contains('success')) {
    statusText = 'Status: Orderan telah kamu Konfirmasi.';
    statusColor = const Color.fromARGB(255, 76, 175, 80);
  } else if (bookedCar.order.orderStatus.toLowerCase().contains('failed')) {
    statusText = 'Status: Orderan telah kamu Batalkan.';
    statusColor = const Color.fromARGB(255, 244, 67, 54);
  } else {
    statusText = 'Status: Tidak diketahui.';
    statusColor = Colors.grey;
  }

  final bool showButtons =
      bookedCar.order.orderStatus.toLowerCase() == 'pending';

  // ignore: unnecessary_type_check
  final String formattedDate = bookedCar.order.orderDate is Timestamp
      ? DateFormat(
          'dd MMMM yyyy HH:mm',
        ).format(bookedCar.order.orderDate.toDate())
      : bookedCar.order.orderDate.toString();

  return Container(
    height: showButtons ? 225 : 180,
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
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
        const Gap(12),
        const DottedLine(
          lineThickness: 2,
          dashLength: 6,
          dashGapLength: 6,
          dashColor: Color(0xffCECED5),
        ),
        const Gap(10),
        Row(
          children: [
            Text(
              "Tanggal Order: ",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            const Gap(10),
            Expanded(
              child: Text(
                formattedDate,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const Gap(8),
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
            Expanded(
              child: Text(
                statusText,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const Gap(16),
        if (showButtons)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ButtonPrimary(
                  onTap: () {
                    if (connectivity.isOnline.value) {
                      controller.cancelOrder(bookedCar.order.id);
                    } else {
                      null;
                    }
                  },
                  text: 'Batalkan',
                  customHeight: 32,
                  customTextSize: 14,
                  customBackgroundColor: const Color.fromARGB(255, 244, 67, 54),
                  customBorderRadius: BorderRadius.circular(10),
                ),
              ),
              const Gap(10),
              Expanded(
                child: ButtonPrimary(
                  onTap: () {
                    if (connectivity.isOnline.value) {
                      controller.confirmOrder(bookedCar.order.id);
                    } else {
                      null;
                    }
                  },
                  text: 'Konfirmasi',
                  customHeight: 32,
                  customTextSize: 14,
                  customBorderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
      ],
    ),
  );
}
