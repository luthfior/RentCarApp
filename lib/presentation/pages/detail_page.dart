import 'dart:developer';

import 'package:d_session/d_session.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:rent_car_app/data/sources/chat_source.dart';
import 'package:rent_car_app/presentation/viewModels/details_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_chat.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/failed_ui.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.idProduct});

  final String idProduct;

  @override
  State<DetailPage> createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  final detailMV = Get.put(DetailsViewModel());
  late final Account account;

  @override
  void initState() {
    detailMV.getDetail(widget.idProduct);
    DSession.getUser().then((value) {
      account = Account.fromJson(Map.from(value!));
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<DetailsViewModel>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Gap(30 + MediaQuery.of(context).padding.top),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: buildHeader(),
          ),
          const Gap(20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(() {
                String status = detailMV.status;
                if (status == '') return const SizedBox();
                if (status == 'loading') {
                  return const Center(child: CircularProgressIndicator());
                }
                if (status != 'success') {
                  return Padding(
                    padding: const EdgeInsetsGeometry.all(24),
                    child: FailedUi(message: status),
                  );
                }
                Car car = detailMV.car;
                return Column(
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
                        color: const Color(0xff070623),
                      ),
                    ),
                    const Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RatingBar.builder(
                          initialRating: car.ratingProduct.toDouble(),
                          itemPadding: const EdgeInsetsGeometry.all(0),
                          itemSize: 14,
                          unratedColor: Colors.grey[300],
                          itemBuilder: (context, index) =>
                              const Icon(Icons.star, color: Color(0xffFFBC1C)),
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
                              color: const Color(0xff070623),
                            ),
                            children: [
                              TextSpan(
                                text: ' Terjual',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff070623),
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
                        color: const Color(0xff070623),
                      ),
                    ),
                    const Gap(10),
                    Text(
                      car.descriptionProduct,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff070623),
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
                            color: const Color(0xff070623),
                          ),
                        ),
                        Text(
                          car.categoryProduct,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff070623),
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
                            color: const Color(0xff070623),
                          ),
                        ),
                        Text(
                          '${car.releaseProduct}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff070623),
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
                            color: const Color(0xff070623),
                          ),
                        ),
                        Text(
                          car.transmissionProduct,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff070623),
                          ),
                        ),
                      ],
                    ),
                    const Gap(30),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (detailMV.status == 'success') {
          Car car = detailMV.car;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            color: const Color(0xffEFEFF0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildCarPrice(car),
                const Gap(10),
                ButtonChat(
                  onTap: () async {
                    try {
                      String uid = account.uid;
                      Chat chat = Chat(
                        chatId: uid,
                        message: 'Ready?',
                        receiverId: 'cs',
                        senderId: uid,
                        productDetail: {
                          'categoryProduct': car.categoryProduct,
                          'imageProduct': car.imageProduct,
                          'nameProduct': car.nameProduct,
                          'priceProduct': car.priceProduct,
                          'releaseProduct': car.releaseProduct,
                          'transmissionProduct': car.transmissionProduct,
                        },
                      );
                      ChatSource.openChat(uid, account.name).then((value) {
                        ChatSource.send(chat, uid).then((value) {
                          Get.toNamed(
                            '/chatting',
                            arguments: {
                              'product': car,
                              'uid': uid,
                              'username': account.name,
                            },
                          );
                        });
                      });
                    } catch (e) {
                      log('Gagal membuka chat: $e');
                    }
                  },
                ),
                const Gap(10),
              ],
            ),
          );
        }
        return const SizedBox();
      }),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            height: 46,
            width: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/ic_arrow_back.png',
              height: 24,
              width: 24,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Detail',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xff070623),
            ),
          ),
        ),
        Container(
          height: 46,
          width: 46,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: Image.asset('assets/ic_favorite.png', height: 24, width: 24),
        ),
      ],
    );
  }

  Widget buildCarPrice(Car car) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xff070623),
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
            width: 150,
            child: ButtonPrimary(
              onTap: () {
                Get.toNamed('/booking', arguments: car);
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
