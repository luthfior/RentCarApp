import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/notification_view_model.dart';
import 'package:rent_car_app/presentation/widgets/chip_categories.dart';
import 'package:rent_car_app/presentation/widgets/failed_ui.dart';
import 'package:rent_car_app/presentation/widgets/item_featured_car.dart';
import 'package:rent_car_app/presentation/widgets/item_grid_car.dart';
import 'package:rent_car_app/presentation/widgets/item_newest_car.dart';

class BrowseFragment extends GetView<BrowseViewModel> {
  BrowseFragment({super.key});

  final connectivity = Get.find<ConnectivityService>();
  final notifVM = Get.find<NotificationViewModel>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          String status = controller.status;
          if (status == '') return const SizedBox();
          if (status == 'loading') {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
              ),
            );
          }
          if (status != 'success') {
            return Center(child: FailedUi(message: status));
          }
          return SafeArea(
            child: Column(
              children: [
                buildHeader(context),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await controller.startCarListeners();
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(0),
                      children: [
                        Obx(() => buildBookingStatus()),
                        Obx(() {
                          if (controller.currentView.value == 'search') {
                            return buildSearchProducts(controller.car.value!);
                          } else {
                            return Column(
                              children: [
                                const Gap(10),
                                chipCategories(controller.categories),
                                const Gap(20),
                                buildPopular(),
                                const Gap(20),
                                buildNewest(),
                              ],
                            );
                          }
                        }),
                        const Gap(100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              enabled: connectivity.isOnline.value,
              controller: controller.searchController,
              onSubmitted: (query) {
                controller.handleSearchSubmit();
              },
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Cari Produk ...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
                fillColor: Theme.of(Get.context!).colorScheme.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(
                    color: Color(0xffFF5722),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.isNotEmpty) {
                    return IconButton(
                      onPressed: controller.clearSearch,
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(Get.context!).colorScheme.onSurface,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),
            ),
          ),
          const Gap(16),
          Obx(() {
            final hasUnread = notifVM.hasUnread;
            return Stack(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (connectivity.isOnline.value) {
                      Get.toNamed('/notification');
                    } else {
                      null;
                    }
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.notifications,
                      color: Theme.of(Get.context!).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget buildBookingStatus() {
    final Car? car = controller.car.value;
    if (car == null) return const SizedBox();

    return Container(
      height: 65,
      margin: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffFF5722),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ExtendedImage.network(
                car.imageProduct,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              text: TextSpan(
                text: 'Produk ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: car.nameProduct,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xff070623),
                    ),
                  ),
                  TextSpan(
                    text: ' yang Anda Booking sedang menunggu untuk diproses.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPopular() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
          child: Text(
            'Populer',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(Get.context!).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 275,
          child: ListView.builder(
            itemCount: controller.featuredList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              Car car = controller.featuredList[index];
              final margin = EdgeInsets.only(
                left: index == 0 ? 24 : 12,
                right: index == controller.featuredList.length - 1 ? 24 : 12,
              );
              bool isTrending = index == 0;
              return itemFeaturedCar(car, margin, isTrending);
            },
          ),
        ),
      ],
    );
  }

  Widget buildNewest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Terbaru',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(Get.context!).colorScheme.onSurface,
            ),
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          itemCount: controller.newestList.length,
          itemBuilder: (context, index) {
            Car car = controller.newestList[index];
            final margin = EdgeInsets.only(
              top: index == 0 ? 10 : 9,
              bottom: index == controller.newestList.length - 1 ? 16 : 9,
            );
            return itemNewestCar(car, margin, () {
              if (connectivity.isOnline.value) {
                Get.toNamed('/detail', arguments: car.id);
              } else {
                null;
              }
            });
          },
        ),
      ],
    );
  }

  Widget buildSearchProducts(Car car) {
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pencarian untuk "${controller.searchQuery}"',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(Get.context!).colorScheme.onSurface,
            ),
          ),
          if (controller.searchResults.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  'Produk tidak ditemukan.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
                ),
              ),
            )
          else if (controller.searchResults.length == 1)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: itemNewestCar(
                controller.searchResults.first,
                EdgeInsets.zero,
                () {
                  if (connectivity.isOnline.value) {
                    Get.toNamed('/detail', arguments: car.id);
                  } else {
                    null;
                  }
                },
              ),
            )
          else
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: controller.searchResults.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final car = controller.searchResults[index];
                return itemGridCar(car, () {
                  if (connectivity.isOnline.value) {
                    Get.toNamed('/detail', arguments: car.id);
                  } else {
                    null;
                  }
                });
              },
            ),
        ],
      ),
    );
  }
}
