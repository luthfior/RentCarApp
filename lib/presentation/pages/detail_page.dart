import 'dart:developer';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/core/utils/app_colors.dart';
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
      if (controller.status == 'loading') {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.car == Car.empty) {
        return const Center(child: Text('Data mobil tidak ditemukan.'));
      }

      final Car car = controller.car;

      return Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Gap(20 + MediaQuery.of(context).padding.top),
                CustomHeader(
                  title: '',
                  rightIcon: Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/ic_favorite.png',
                      height: 24,
                      width: 24,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const Gap(20),
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
                              if (state.extendedImageLoadState ==
                                  LoadState.failed) {
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
                        const Gap(30),
                        Text(
                          car.nameProduct,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
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
                                  color: AppColors.onSurface,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' kali disewa',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        Text(
                          'Tentang',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Gap(10),
                        Text(
                          car.descriptionProduct,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
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
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              car.categoryProduct,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurface,
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
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              '${car.releaseProduct}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurface,
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
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              car.transmissionProduct,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurface,
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
                onTap: () async {
                  if (connectivity.isOnline.value) {
                    try {
                      String uid = authVM.account.value!.uid;
                      Chat chat = Chat(
                        chatId: uid,
                        message: 'Ready?',
                        receiverId: 'cs',
                        senderId: uid,
                        productDetail: {
                          'id': car.id,
                          'categoryProduct': car.categoryProduct,
                          'imageProduct': car.imageProduct,
                          'nameProduct': car.nameProduct,
                          'priceProduct': car.priceProduct,
                          'releaseProduct': car.releaseProduct,
                          'transmissionProduct': car.transmissionProduct,
                        },
                      );
                      ChatSource.openChat(uid, authVM.account.value!.name).then(
                        (value) {
                          ChatSource.send(chat, uid).then((value) {
                            Get.toNamed(
                              '/chatting',
                              arguments: {
                                'uid': uid,
                                'username': authVM.account.value!.name,
                              },
                            );
                          });
                        },
                      );
                    } catch (e) {
                      log('Gagal membuka chat: $e');
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
        color: const Color(0xFFFFB86C),
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
                    color: Colors.black,
                  ),
                ),
                Text(
                  '/hari',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: ButtonPrimary(
              onTap: () {
                if (connectivity.isOnline.value) {
                  Get.toNamed('/booking', arguments: car);
                } else {
                  null;
                }
              },
              customBorderRadius: BorderRadius.circular(20),
              text: 'Pesan Sekarang',
              customTextSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
