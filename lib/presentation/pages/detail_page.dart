import 'dart:developer';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/data/sources/chat_source.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/detail_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_chat.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class DetailPage extends GetView<DetailViewModel> {
  DetailPage({super.key});

  final connectivity = Get.find<ConnectivityService>();
  final authVM = Get.find<AuthViewModel>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Car car = controller.car;

      return Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  CustomHeader(
                    title: '',
                    rightIcon: GestureDetector(
                      onTap: () {
                        if (!connectivity.isOnline.value) {
                          null;
                        }
                        controller.toggleFavorite();
                      },
                      child: Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(Get.context!).colorScheme.surface,
                        ),
                        alignment: Alignment.center,
                        child: Obx(() {
                          if (controller.isFavorited.value) {
                            return const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xffFF5722),
                            );
                          } else {
                            return Icon(
                              Icons.favorite_border_outlined,
                              color: Theme.of(
                                Get.context!,
                              ).colorScheme.onSurface,
                            );
                          }
                        }),
                      ),
                    ),
                  ),
                  const Gap(20),
                  if (controller.status == 'loading')
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xffFF5722),
                          ),
                        ),
                      ),
                    ),
                  if (controller.car == Car.empty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Data mobil tidak ditemukan.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(Get.context!).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  if (controller.status != 'loading' &&
                      controller.car != Car.empty)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(10),
                            Center(
                              child: ExtendedImage.network(
                                car.imageProduct,
                                width: 400,
                                height: 250,
                                fit: BoxFit.cover,
                                loadStateChanged: (state) {
                                  switch (state.extendedImageLoadState) {
                                    case LoadState.loading:
                                      return const SizedBox(
                                        width: 450,
                                        height: 250,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xffFF5722),
                                                ),
                                          ),
                                        ),
                                      );
                                    case LoadState.completed:
                                      return ExtendedImage(
                                        image: state.imageProvider,
                                        width: 450,
                                        height: 250,
                                        fit: BoxFit.cover,
                                      );
                                    case LoadState.failed:
                                      return Image.asset(
                                        'assets/splash_screen.png',
                                        width: 220,
                                        height: 170,
                                      );
                                  }
                                },
                              ),
                            ),
                            const Gap(30),
                            Text(
                              car.nameProduct,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(
                                  Get.context!,
                                ).colorScheme.onSurface,
                              ),
                            ),
                            const Gap(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                RichText(
                                  text: TextSpan(
                                    text: '${car.purchasedProduct}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        Get.context!,
                                      ).colorScheme.onSurface,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'x disewa',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(
                                            Get.context!,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Gap(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: Theme.of(
                                    Get.context!,
                                  ).colorScheme.secondary,
                                  size: 20,
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    car.address!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(
                                        Get.context!,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                const Gap(10),
                              ],
                            ),
                            const Gap(12),
                            Text(
                              'Deskripsi',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(
                                  Get.context!,
                                ).colorScheme.onSurface,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              car.descriptionProduct,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(
                                  Get.context!,
                                ).colorScheme.onSurface,
                              ),
                            ),
                            const Gap(10),
                            Row(
                              children: [
                                Text(
                                  'Kategori: ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      Get.context!,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  car.categoryProduct,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      Get.context!,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Tahun Rilis: ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      Get.context!,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '${car.releaseProduct}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      Get.context!,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Transmisi: ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      Get.context!,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  car.transmissionProduct,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      Get.context!,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(30),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const OfflineBanner(),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildCarPrice(car),
              const Gap(10),
              ButtonChat(
                text: 'Chat Sekarang',
                customIconSize: 24,
                onTap: () async {
                  if (connectivity.isOnline.value) {
                    Get.dialog(
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xffFF5722),
                          ),
                        ),
                      ),
                      barrierDismissible: false,
                    );
                    try {
                      String uid = authVM.account.value!.uid;
                      Chat chat = Chat(
                        chatId: uid,
                        message: 'Ready?',
                        receiverId: car.ownerId,
                        senderId: uid,
                        productDetail: {
                          'id': car.id,
                          'categoryProduct': car.categoryProduct,
                          'descriptionProduct': car.descriptionProduct,
                          'imageProduct': car.imageProduct,
                          'nameProduct': car.nameProduct,
                          'priceProduct': car.priceProduct,
                          'purchasedProduct': car.purchasedProduct,
                          'ratingProduct': car.ratingProduct,
                          'releaseProduct': car.releaseProduct,
                          'transmissionProduct': car.transmissionProduct,
                        },
                      );

                      await ChatSource.openChat(
                        buyerId: uid,
                        ownerId: car.ownerId,
                        buyerName: authVM.account.value!.name,
                        buyerEmail: authVM.account.value!.email,
                        buyerPhotoUrl: authVM.account.value!.photoUrl!,
                        ownerName: car.ownerName,
                        ownerEmail: car.ownerEmail,
                        ownerPhotoUrl: car.ownerPhotoUrl,
                        ownerType: car.ownerType,
                      );

                      await ChatSource.send(chat, uid, car.ownerId);

                      Get.back();

                      Get.toNamed(
                        '/chatting',
                        arguments: {
                          'uid': uid,
                          'ownerId': car.ownerId,
                          'ownerType': car.ownerType,
                          'ownerName': car.ownerName,
                          'ownerPhotoUrl': car.ownerPhotoUrl,
                          'from': 'detail',
                        },
                      );
                    } catch (e) {
                      Get.back();
                      log('Gagal membuka chat: $e');
                      Message.error('Gagal membuka chat. Coba lagi.');
                    }
                  } else {
                    null;
                  }
                },
              ),
              const Gap(10),
            ],
          ),
        ),
      );
    });
  }

  Widget buildCarPrice(Car car) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFF52575D),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NumberFormat.currency(
                    decimalDigits: 0,
                    locale: 'id',
                    symbol: 'Rp.',
                  ).format(car.priceProduct),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '/hari',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 160,
            child: ButtonPrimary(
              onTap: () async {
                if (connectivity.isOnline.value) {
                  Get.toNamed('/booking', arguments: car);
                } else {
                  null;
                }
              },
              customBorderRadius: BorderRadius.circular(20),
              text: 'Booking Sekarang',
              customTextSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
