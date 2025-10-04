import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/models/booked_car.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/notification_view_model.dart';
import 'package:rent_car_app/presentation/widgets/chip_categories.dart';
import 'package:rent_car_app/presentation/widgets/failed_ui.dart';
import 'package:rent_car_app/presentation/widgets/item_featured_car.dart';
import 'package:rent_car_app/presentation/widgets/item_grid_car.dart';
import 'package:rent_car_app/presentation/widgets/item_newest_car.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

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
                      if (connectivity.isOnline.value) {
                        await controller.startCarListeners();
                      } else {
                        const OfflineBanner();
                        return;
                      }
                    },
                    color: const Color(0xffFF5722),
                    child: ListView(
                      padding: const EdgeInsets.all(0),
                      children: [
                        Obx(() => buildBookingStatus()),
                        Obx(() {
                          if (controller.currentView.value == 'search') {
                            return buildSearchProducts();
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(10),
                                chipCategories(controller.chipItems),
                                const Gap(20),
                                buildPopular(),
                                const Gap(20),
                                buildNewest(),
                              ],
                            );
                          }
                        }),
                        const Gap(30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const OfflineBanner(),
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
              textCapitalization: TextCapitalization.words,
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
                      const OfflineBanner();
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
                        color: Color(0xffFF2056),
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
    final BookedCar? bookedData = controller.bookedCar.value;
    if (bookedData == null) return const SizedBox();
    final Car car = bookedData.car;

    final description = (controller.authVM.account.value!.role != 'customer')
        ? ' menunggu untuk Kamu Proses.'
        : ' menunggu untuk diproses oleh Penyedia.';

    return GestureDetector(
      onTap: () {
        if (connectivity.isOnline.value) {
          Get.toNamed('/detail-order', arguments: bookedData);
        } else {
          const OfflineBanner();
        }
      },
      child: Container(
        height: 65,
        margin: const EdgeInsets.fromLTRB(24, 12, 24, 12),
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
                  loadStateChanged: (state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                        return const SizedBox(
                          width: 80,
                          height: 80,
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
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        );
                      case LoadState.failed:
                        return Image.asset(
                          'assets/splash_screen.png',
                          width: 80,
                          height: 80,
                        );
                    }
                  },
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffEFEFF0),
                  ),
                  children: [
                    TextSpan(
                      text: car.nameProduct,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xff070623),
                      ),
                    ),
                    TextSpan(
                      text: description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffEFEFF0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPopular() {
    return Obx(() {
      if (controller.featuredList.isEmpty) {
        return const SizedBox.shrink();
      }

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
                Account? owner = controller.ownersMap[car.ownerId];
                final margin = EdgeInsets.only(
                  left: index == 0 ? 24 : 12,
                  right: index == controller.featuredList.length - 1 ? 24 : 12,
                );
                return itemFeaturedCar(
                  car,
                  margin,
                  index == 0,
                  owner?.city ?? '',
                  owner?.storeName ?? '',
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget buildNewest() {
    return Obx(() {
      if (controller.newestList.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
            child: Text(
              'Terbaru',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
          ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            itemCount: controller.newestList.length,
            separatorBuilder: (context, index) => const Gap(16),
            itemBuilder: (context, index) {
              Car car = controller.newestList[index];
              return buildNewestItem(context, car);
            },
          ),
        ],
      );
    });
  }

  Widget buildSearchProducts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.searchQuery.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Text(
                'Pencarian untuk "${controller.searchQuery}"',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ),
          if (controller.searchResults.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 125, 0, 0),
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
              padding: const EdgeInsets.only(top: 30),
              child: Builder(
                builder: (context) {
                  final car = controller.searchResults.first;
                  final owner = controller.ownersMap[car.ownerId];

                  return itemNewestCar(
                    car,
                    owner?.city ?? '',
                    owner?.storeName ?? '',
                    () {
                      if (connectivity.isOnline.value) {
                        Get.toNamed(
                          '/detail',
                          arguments: controller.searchResults.first.id,
                        );
                      } else {
                        const OfflineBanner();
                        null;
                      }
                    },
                  );
                },
              ),
            )
          else
            GridView.builder(
              padding: const EdgeInsets.only(top: 30),
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
                final owner = controller.ownersMap[car.ownerId];
                return itemGridCar(
                  car,
                  owner?.city ?? '',
                  owner?.storeName ?? '',
                  () {
                    if (connectivity.isOnline.value) {
                      Get.toNamed('/detail', arguments: car.id);
                    } else {
                      const OfflineBanner();
                      null;
                    }
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget buildNewestItem(BuildContext context, Car car) {
    Account? owner = controller.ownersMap[car.ownerId];
    Widget itemCar = itemNewestCar(
      car,
      owner?.city ?? '',
      owner?.storeName ?? '',
      () {
        if (connectivity.isOnline.value) {
          Get.toNamed('/detail', arguments: car.id);
        } else {
          const OfflineBanner();
          null;
        }
      },
    );

    if (controller.authVM.account.value!.role == 'admin') {
      return buildSlidableItem(
        context,
        car: car,
        itemCar: itemCar,
        onEdit: () async {
          if (connectivity.isOnline.value) {
            Get.toNamed(
              '/add-product',
              arguments: {'car': car, 'isEdit': true},
            );
          } else {
            const OfflineBanner();
            null;
          }
        },
        onDelete: () async {
          if (connectivity.isOnline.value) {
            await controller.deleteProduct(car.id);
          } else {
            const OfflineBanner();
            null;
          }
        },
      );
    } else {
      return itemCar;
    }
  }

  Widget buildSlidableItem(
    BuildContext context, {
    required Car car,
    required Widget itemCar,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Slidable(
      key: ValueKey(car.id),
      closeOnScroll: true,
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onEdit(),
            backgroundColor: const Color(0xffFF5722),
            foregroundColor: Colors.white,
            icon: Icons.edit,
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              onDelete();
            },
            backgroundColor: const Color(0xffFF2056),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
          ),
        ],
      ),
      child: itemCar,
    );
  }
}
