import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/detail_view_model.dart';
import 'package:rent_car_app/presentation/widgets/button_chat.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class DetailPage extends GetView<DetailViewModel> {
  DetailPage({super.key});

  final connectivity = Get.find<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Obx(() {
        if (controller.status == 'loading') {
          return Column(
            children: [
              SafeArea(child: _buildHeader()),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xffFF5722),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        if (controller.car == Car.empty) {
          return Column(
            children: [
              SafeArea(child: _buildHeader()),
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
            ],
          );
        }

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: ExtendedImage.network(
                  controller.car.imageProduct,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.45,
                  fit: BoxFit.cover,
                  loadStateChanged: (state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xffFF5722),
                              ),
                            ),
                          ),
                        );
                      case LoadState.completed:
                        final image = state.extendedImageInfo?.image;
                        if (image != null) {
                          final isPortrait = image.height > image.width;
                          return ExtendedImage(
                            image: state.imageProvider,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.45,
                            fit: isPortrait ? BoxFit.cover : BoxFit.contain,
                          );
                        }
                        return Image.asset(
                          'assets/splash_screen.png',
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.45,
                          fit: BoxFit.cover,
                        );
                      case LoadState.failed:
                        return Image.asset(
                          'assets/splash_screen.png',
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.45,
                          fit: BoxFit.cover,
                        );
                    }
                  },
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(
                    rightIcon: GestureDetector(
                      onTap: () async {
                        if (connectivity.isOnline.value) {
                          controller.toggleFavorite();
                        } else {
                          const OfflineBanner();
                          return;
                        }
                      },
                      child:
                          (controller.authVM.account.value?.role != 'seller' &&
                              controller.authVM.account.value?.role != 'admin')
                          ? Container(
                              height: 46,
                              width: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(
                                  Get.context!,
                                ).colorScheme.surface,
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
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  if (controller.status != 'loading' &&
                      controller.car != Car.empty)
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          if (connectivity.isOnline.value) {
                            await controller.refreshCarDetail();
                          } else {
                            const OfflineBanner();
                            return;
                          }
                        },
                        color: const Color(0xffFF5722),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Container(
                                margin: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.30,
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  40,
                                  24,
                                  40,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    Get.context!,
                                  ).colorScheme.surface,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(60),
                                    topRight: Radius.circular(60),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${controller.car.nameProduct} (${controller.car.releaseProduct})",
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(
                                          Get.context!,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                    const Gap(10),
                                    Row(
                                      children: [
                                        RatingBar.builder(
                                          initialRating: controller
                                              .car
                                              .ratingAverage
                                              .toDouble(),
                                          itemPadding: const EdgeInsets.all(0),
                                          itemSize: 18,
                                          unratedColor: Colors.grey[300],
                                          itemBuilder: (context, index) =>
                                              const Icon(
                                                Icons.star,
                                                color: Color(0xffFFBC1C),
                                              ),
                                          ignoreGestures: true,
                                          allowHalfRating: true,
                                          onRatingUpdate: (value) {},
                                        ),
                                        const Gap(4),
                                        Expanded(
                                          child: Text(
                                            "(${controller.car.ratingAverage})",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                Get.context!,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${controller.car.purchasedProduct}x disewa",
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
                                    const Gap(8),
                                    Obx(() {
                                      if (controller.partner == null) {
                                        return const Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundImage:
                                                  AssetImage(
                                                        'assets/profile.png',
                                                      )
                                                      as ImageProvider,
                                            ),
                                            Gap(8),
                                            SizedBox(
                                              width: 120,
                                              height: 16,
                                              child: ColoredBox(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      final owner = controller.partner!;
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundImage:
                                                (owner.photoUrl != null &&
                                                    owner.photoUrl!.isNotEmpty)
                                                ? NetworkImage(owner.photoUrl!)
                                                : const AssetImage(
                                                        'assets/profile.png',
                                                      )
                                                      as ImageProvider,
                                          ),
                                          const Gap(8),
                                          Text(
                                            owner.storeName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                Get.context!,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                    const Gap(8),
                                    Obx(() {
                                      if (controller.partner == null) {
                                        return const SizedBox(height: 20);
                                      }

                                      final owner = controller.partner!;
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                              owner.fullAddress ?? '',
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
                                      );
                                    }),
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
                                      controller.car.descriptionProduct,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(
                                          Get.context!,
                                        ).colorScheme.onSurface,
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                    const Gap(10),
                                    _buildInfoCards(context, controller.car),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const OfflineBanner(),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
          color: Theme.of(Get.context!).colorScheme.surface,
          child: Obx(() {
            final account = controller.authVM.account.value;
            if (account == null ||
                controller.status == 'loading' ||
                controller.car == Car.empty) {
              return const SizedBox.shrink();
            }

            final isAdmin = account.role == 'admin';
            final isSeller = account.role == 'seller';
            final isOwner = controller.car.ownerId == account.uid;

            if (isSeller || (isAdmin && isOwner)) {
              return buildEditProductButton(controller.car);
            }

            if (isAdmin && !isOwner) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildCarPrice(controller.car),
                  const Gap(10),
                  ButtonChat(
                    text: 'Chat Sekarang',
                    customBorderRadius: BorderRadius.circular(20),
                    customIconSize: 24,
                    onTap: controller.partner != null
                        ? () async {
                            if (connectivity.isOnline.value) {
                              controller.openChat();
                            }
                          }
                        : null,
                  ),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildCarPrice(controller.car),
                const Gap(10),
                ButtonChat(
                  text: 'Chat Sekarang',
                  customBorderRadius: BorderRadius.circular(20),
                  customIconSize: 24,
                  onTap: controller.partner != null
                      ? () async {
                          if (connectivity.isOnline.value) {
                            controller.openChat();
                          }
                        }
                      : null,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader({Widget? rightIcon}) {
    return CustomHeader(title: '', rightIcon: rightIcon);
  }

  Widget _buildInfoCards(BuildContext context, Car car) {
    final List<Map<String, dynamic>> items = [];
    IconData getCategoryIcon() {
      switch (car.categoryProduct.toLowerCase()) {
        case 'truk':
          return Icons.local_shipping;
        case 'mobil':
          return Icons.directions_car_rounded;
        case 'motor':
          return Icons.motorcycle_rounded;
        case 'sepeda':
          return Icons.pedal_bike_rounded;
        default:
          return Icons.category_outlined;
      }
    }

    IconData getEnergySourceIcon() {
      switch (car.energySourceProduct?.toLowerCase()) {
        case 'listrik':
          return Icons.battery_charging_full_rounded;
        case 'hybrid' || 'non-listrik':
          return Icons.energy_savings_leaf;
        default:
          return Icons.local_gas_station_rounded;
      }
    }

    items.add({
      "title": "Kategori",
      "value": car.categoryProduct,
      "icon": getCategoryIcon(),
    });
    items.add({
      "title": "Brand",
      "value": car.brandProduct,
      "icon": Icons.sell_outlined,
    });
    items.add({
      "title": "Tahun Rilis",
      "value": car.releaseProduct.toString(),
      "icon": Icons.calendar_month_outlined,
    });

    if (car.categoryProduct == 'Mobil' ||
        car.categoryProduct == 'Truk' ||
        car.categoryProduct == 'Motor' ||
        car.categoryProduct == 'Sepeda') {
      items.add({
        "title": (car.categoryProduct == 'Sepeda') ? 'Jenis Gigi' : 'Transmisi',
        "value": car.transmissionProduct ?? '-',
        "icon": Icons.settings_suggest_outlined,
      });
    }

    if (car.categoryProduct == 'Mobil' ||
        car.categoryProduct == 'Truk' ||
        car.categoryProduct == 'Motor' ||
        car.categoryProduct == 'Sepeda') {
      items.add({
        "title": "Sumber Energi",
        "value": car.energySourceProduct ?? '-',
        "icon": getEnergySourceIcon(),
      });
    }

    return SizedBox(
      height: 175,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 0, 24, 16),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return _infoCard(
            context,
            item["title"]! as String,
            item["value"]! as String,
            item["icon"]! as IconData,
          );
        },
      ),
    );
  }

  Widget _infoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    List<String> valueParts = [value];
    if (title == 'Brand' && value.contains(' ')) {
      valueParts = value.split(' ').map((part) => part.trim()).toList();
    }
    return SizedBox(
      width: 150,
      child: Card(
        elevation: 8,
        shadowColor: const Color(0xff070623),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xffFF5722), size: 56),
            const Gap(8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Gap(4),
            if (title == 'Kategori' && valueParts.length == 2) ...[
              Text(
                valueParts[0],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff9E9EAA),
                  height: 1.0,
                ),
              ),
              Text(
                valueParts[1],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff9E9EAA),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsetsGeometry.symmetric(horizontal: 8),
                child: Text(
                  valueParts[0],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff9E9EAA),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildCarPrice(Car car) {
    return GestureDetector(
      onTap: () async {
        if (connectivity.isOnline.value) {
          await controller.handleBooked();
        } else {
          const OfflineBanner();
          return;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff1F2533),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Get.isDarkMode
                ? const Color(0xffEFEFF0)
                : const Color(0xff070623),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      color: const Color(0xffEFEFF0),
                    ),
                  ),
                  Text(
                    '/hari',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xffEFEFF0),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xffFF5722),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Text(
                  'Booking Sekarang',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xffEFEFF0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEditProductButton(Car car) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffFF5722),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          if (connectivity.isOnline.value) {
            Get.toNamed(
              '/add-product',
              arguments: {'car': car, 'isEdit': true},
            );
          } else {
            const OfflineBanner();
            return;
          }
        },
        icon: const Icon(Icons.edit, color: Color(0xffEFEFF0)),
        label: Text(
          'Edit Produk',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xffEFEFF0),
          ),
        ),
      ),
    );
  }
}
