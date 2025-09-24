import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/notification_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/seller_view_model.dart';
import 'package:rent_car_app/presentation/widgets/item_grid_car.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';
import 'package:rent_car_app/presentation/widgets/tutorial_overlay.dart';

class SellerProductFragment extends GetView<SellerViewModel> {
  SellerProductFragment({super.key});

  final connectivity = Get.find<ConnectivityService>();
  final AuthViewModel authVM = Get.find<AuthViewModel>();
  final notifVM = Get.find<NotificationViewModel>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              Obx(() {
                final userRole = (authVM.account.value!.role == 'seller')
                    ? 'Seller'
                    : 'Admin';
                return buildHeader(context, userRole);
              }),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (connectivity.isOnline.value) {
                        await controller.fetchMyProducts();
                      } else {
                        const OfflineBanner();
                        return;
                      }
                    },
                    color: const Color(0xffFF5722),
                    child: Obx(() {
                      if (controller.status.value == 'loading') {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xffFF5722),
                            ),
                          ),
                        );
                      }
                      final userRole = (authVM.account.value!.role == 'seller')
                          ? 'Seller'
                          : 'Admin';
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Obx(() {
                            if (controller.currentView.value == 'search') {
                              return buildSearchProducts();
                            } else {
                              return buildHomeView(userRole);
                            }
                          }),
                          const Gap(50),
                        ],
                      );
                    }),
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
                  Get.toNamed('/add-product', arguments: {'isEdit': false});
                } else {
                  const OfflineBanner();
                  return;
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
        Obx(() {
          if (controller.hasShownTutorial.value &&
              controller.status.value == 'success') {
            return TutorialOverlay(
              onDismiss: () => controller.dismissTutorial(),
              message: "Geser kiri pada item untuk menampilkan Opsi",
              icon: Icons.swipe_left,
            );
          }
          return const SizedBox.shrink();
        }),
        const OfflineBanner(),
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
                      return;
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

  Widget buildHomeView(String userRole) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(10),
        Text(
          'Halo, Selamat Datang $userRole!',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(Get.context!).colorScheme.onSurface,
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
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            const Gap(16),
            if (controller.myProducts.isEmpty) ...[
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
                      color: Theme.of(Get.context!).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ] else ...[
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
                        Get.toNamed('/detail', arguments: car.id);
                      } else {
                        const OfflineBanner();
                        return;
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
                        const OfflineBanner();
                        return;
                      }
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget buildSearchProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        else
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
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
                    const OfflineBanner();
                    return;
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
                    const OfflineBanner();
                    return;
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
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              bool confirm = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    'Konfirmasi Hapus',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(Get.context!).colorScheme.onSurface,
                    ),
                  ),
                  content: Text(
                    'Apakah Anda yakin ingin menghapus ${car.nameProduct}?',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(Get.context!).colorScheme.onSurface,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(Get.context!).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF2056),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(
                        'Hapus',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffEFEFF0),
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm) {
                onDelete();
                Message.success('Produk berhasil dihapus');
              }
            },
            backgroundColor: const Color(0xffFF2056),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
          ),
        ],
      ),
      child: itemGridCar(car, () {
        if (connectivity.isOnline.value) {
          Get.toNamed('/detail', arguments: car.id);
        } else {
          const OfflineBanner();
          return;
        }
      }),
    );
  }
}
