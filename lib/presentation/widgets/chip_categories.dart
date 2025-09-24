import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

Widget chipCategories(List categories) {
  final connectivity = Get.find<ConnectivityService>();
  final browseVm = Get.find<BrowseViewModel>();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Text(
          'Kategori',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(Get.context!).colorScheme.onSurface,
          ),
        ),
      ),
      const Gap(10),
      SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Obx(() {
            return Row(
              children: categories.map((category) {
                final isSelected =
                    browseVm.selectedCategory.value.toLowerCase() ==
                    category.toLowerCase();
                return GestureDetector(
                  onTap: () {
                    if (connectivity.isOnline.value) {
                      browseVm.filterCars(category);
                    } else {
                      const OfflineBanner();
                      return;
                    }
                  },
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected
                          ? Theme.of(Get.context!).colorScheme.onSurface
                          : Theme.of(Get.context!).colorScheme.surface,
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(Get.context!).colorScheme.surface
                            : Theme.of(Get.context!).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
      ),
    ],
  );
}
