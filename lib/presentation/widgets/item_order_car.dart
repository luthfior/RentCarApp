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
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

Widget itemOrderCar(
  BuildContext context, {
  required BookedCar bookedCar,
  required bool isSeller,
}) {
  final connectivity = Get.find<ConnectivityService>();
  String statusText;
  Color statusColor;

  if (bookedCar.order.orderStatus.toLowerCase().contains('pending')) {
    statusText = (isSeller)
        ? 'Status: Menunggu untuk Kamu proses.'
        : 'Status: Menunggu diproses oleh Penyedia.';
    statusColor = const Color(0xffFF5722);
  } else if (bookedCar.order.orderStatus.toLowerCase().contains('success')) {
    statusText = (isSeller)
        ? 'Status: Telah Kamu proses'
        : 'Status: Telah dikonfirmasi oleh Penyedia.';
    statusColor = const Color(0xff75A47F);
  } else if (bookedCar.order.orderStatus.toLowerCase().contains('cancelled')) {
    statusText = (isSeller)
        ? 'Status: Telah Kamu batalkan'
        : 'Status: Dibatalkan oleh Penyedia.';
    statusColor = const Color(0xffFF2056);
  } else {
    statusText = 'Status: Tidak diketahui.';
    statusColor = Colors.grey;
  }

  // ignore: unnecessary_type_check
  final String formattedDate = bookedCar.order.orderDate is Timestamp
      ? DateFormat(
          'dd MMMM yyyy HH:mm',
        ).format(bookedCar.order.orderDate.toDate())
      : bookedCar.order.orderDate.toString();

  return GestureDetector(
    onTap: () {
      if (connectivity.isOnline.value) {
        Get.toNamed('/detail-order', arguments: bookedCar);
      } else {
        const OfflineBanner();
        return;
      }
    },
    child: Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
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
                        Text(
                          bookedCar.car.nameProduct,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(Get.context!).colorScheme.onSurface,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            " (${bookedCar.car.releaseProduct})",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                Get.context!,
                              ).colorScheme.onSurface,
                            ),
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
                          initialRating: bookedCar.car.ratingAverage.toDouble(),
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
          const Gap(8),
          const DottedLine(
            lineThickness: 2,
            dashLength: 6,
            dashGapLength: 6,
            dashColor: Color(0xffCECED5),
          ),
          const Gap(8),
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
              Expanded(
                child: Text(
                  formattedDate,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const Gap(4),
          Row(
            children: [
              Text(
                "Resi: ",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
              Expanded(
                child: Text(
                  bookedCar.order.resi,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const Gap(4),
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
              const Gap(4),
              Expanded(
                child: Text(
                  statusText,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
