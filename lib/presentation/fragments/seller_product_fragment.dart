import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/notification_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/seller_view_model.dart';
import 'package:rent_car_app/presentation/widgets/item_grid_car.dart';

class SellerProductFragment extends GetView<SellerViewModel> {
  SellerProductFragment({super.key});

  final connectivity = Get.find<ConnectivityService>();
  final AuthViewModel authVM = Get.find<AuthViewModel>();
  final notifVM = Get.find<NotificationViewModel>();

  @override
  Widget build(BuildContext context) {
    final userRole = (authVM.account.value!.role == 'seller')
        ? 'Seller'
        : 'Admin';
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              buildHeader(context, userRole),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await controller.fetchMyProducts();
                    },
                    child: ListView(
                      children: [
                        Obx(() {
                          if (controller.currentView.value == 'search') {
                            return buildSearchProducts();
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(10),
                                Text(
                                  'Halo, Selamat Datang $userRole!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      Get.context!,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const Gap(20),
                                const DottedLine(
                                  lineThickness: 2,
                                  dashLength: 6,
                                  dashGapLength: 6,
                                  dashColor: Color(0xffCECED5),
                                ),
                                const Gap(20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Katalog',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(
                                          Get.context!,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                    const Gap(16),
                                    if (controller.myProducts.isEmpty)
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 150,
                                            horizontal: 8,
                                          ),
                                          child: Text(
                                            'Katalog kamu masih kosong nih. Yuk, posting Produk pertama mu dengan menekan tombol Tambah di pojok kanan bawah',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                Get.context!,
                                              ).colorScheme.secondary,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      GridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: controller.myProducts.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 10,
                                              mainAxisSpacing: 10,
                                              childAspectRatio: 0.7,
                                            ),
                                        itemBuilder: (context, index) {
                                          final car =
                                              controller.myProducts[index];
                                          return buildSlidableSellerItem(
                                            context,
                                            car: car,
                                            onEdit: () {
                                              if (connectivity.isOnline.value) {
                                                Get.toNamed(
                                                  '/add-product',
                                                  arguments: {
                                                    'car': car,
                                                    'isEdit': true,
                                                  },
                                                );
                                              } else {
                                                null;
                                              }
                                            },
                                            onDelete: () async {
                                              if (connectivity.isOnline.value) {
                                                controller.myProducts.removeAt(
                                                  index,
                                                );
                                                await controller.sellerSource
                                                    .deleteProduct(
                                                      car.id,
                                                      authVM.account.value!.uid,
                                                      authVM
                                                          .account
                                                          .value!
                                                          .role,
                                                    );
                                              } else {
                                                null;
                                              }
                                            },
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            );
                          }
                        }),
                        const Gap(50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 140,
          right: 32,
          child: SizedBox(
            width: 65,
            height: 65,
            child: FloatingActionButton(
              backgroundColor: Theme.of(Get.context!).colorScheme.surface,
              shape: const CircleBorder(),
              onPressed: () {
                if (connectivity.isOnline.value) {
                  Get.toNamed('/add-product');
                } else {
                  null;
                }
              },
              child: Icon(
                Icons.add,
                size: 30,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHeader(BuildContext context, String userRole) {
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

  Widget buildSearchProducts() {
    return Column(
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
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Produk tidak ditemukan.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(Get.context!).colorScheme.secondary,
                ),
              ),
            ),
          )
        else
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: controller.myProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final car = controller.myProducts[index];
              return buildSlidableSellerItem(
                context,
                car: car,
                onEdit: () {
                  if (connectivity.isOnline.value) {
                    Get.toNamed(
                      '/add-product',
                      arguments: {'car': car, 'isEdit': true},
                    );
                  } else {
                    null;
                  }
                },
                onDelete: () async {
                  if (connectivity.isOnline.value) {
                    controller.myProducts.removeAt(index);
                    await controller.sellerSource.deleteProduct(
                      car.id,
                      authVM.account.value!.uid,
                      authVM.account.value!.role,
                    );
                  } else {
                    null;
                  }
                },
              );
            },
          ),
      ],
    );
  }

  Widget buildSlidableSellerItem(
    BuildContext context, {
    required Car car,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Slidable(
      key: ValueKey(car.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onEdit(),
            backgroundColor: const Color(0xffFF5722),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Sunting',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () => onDelete(),
          closeOnCancel: true,
        ),
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: const Color(0xffFF2056),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
            label: 'Hapus',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => onEdit(),
        child: itemGridCar(car, () {
          if (connectivity.isOnline.value) {
            Get.toNamed(
              '/add-product',
              arguments: {'car': car, 'isEdit': true},
            );
          } else {
            null;
          }
        }),
      ),
    );
  }
}
