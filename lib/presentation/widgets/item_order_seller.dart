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
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

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
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const Gap(8),
          // if (bookedCar.order.orderStatus.toLowerCase() == 'pending')
          //   buildActionButtons(context, controller, bookedCar),
        ],
      ),
    ),
  );
}

// Widget buildActionButtons(
//   BuildContext context,
//   OrderViewModel controller,
//   BookedCar bookedCar,
// ) {
//   final connectivity = Get.find<ConnectivityService>();
//   return Row(
//     children: [
//       Expanded(
//         child: ElevatedButton(
//           onPressed: () async {
//             if (!connectivity.isOnline.value) return;
//             bool? confirm = await controller.showConfirmationDialog(
//               context: context,
//               title: 'Batalkan Pesanan',
//               content: 'Apakah Anda yakin ingin membatalkan pesanan ini?',
//               confirmText: 'Ya, Batalkan',
//             );
//             if (confirm == true) {
//               controller.cancelOrder(
//                 bookedCar.order.id,
//                 bookedCar.order.customerId,
//                 bookedCar.order.sellerId,
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Get.isDarkMode
//                 ? const Color(0xff292929)
//                 : const Color(0xffEFEFF0),
//             foregroundColor: const Color.fromARGB(255, 244, 67, 54),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             elevation: 4,
//             padding: const EdgeInsets.symmetric(vertical: 8),
//           ),
//           child: Text(
//             'Batalkan',
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           ),
//         ),
//       ),
//       const Gap(16),
//       Expanded(
//         child: ElevatedButton(
//           onPressed: () async {
//             if (!connectivity.isOnline.value) return;
//             bool? confirm = await controller.showConfirmationDialog(
//               context: context,
//               title: 'Konfirmasi Pesanan',
//               content: 'Apakah Anda yakin ingin mengonfirmasi pesanan ini?',
//               confirmText: 'Ya, Konfirmasi',
//             );
//             if (confirm == true) {
//               controller.confirmOrder(
//                 bookedCar.order.id,
//                 bookedCar.order.customerId,
//                 bookedCar.order.sellerId,
//                 bookedCar.car.id,
//                 bookedCar.order.orderDetail.totalPrice.round(),
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color.fromARGB(255, 76, 175, 80),
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             elevation: 4,
//             padding: const EdgeInsets.symmetric(vertical: 8),
//           ),
//           child: Text(
//             'Konfirmasi',
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }
