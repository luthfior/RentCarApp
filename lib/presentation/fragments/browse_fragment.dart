import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/utils/app_colors.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';
import 'package:rent_car_app/presentation/widgets/chip_categories.dart';
import 'package:rent_car_app/presentation/widgets/failed_ui.dart';
import 'package:rent_car_app/presentation/widgets/item_featured_car.dart';
import 'package:rent_car_app/presentation/widgets/item_newest_car.dart';

class BrowseFragment extends GetView<BrowseViewModel> {
  const BrowseFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          String status = controller.status;
          if (status == '') return const SizedBox();
          if (status == 'loading') {
            return const Center(child: CircularProgressIndicator());
          }
          if (status != 'success') {
            return Center(child: FailedUi(message: status));
          }
          return ListView(
            padding: const EdgeInsets.all(0),
            children: [
              Gap(10 + MediaQuery.of(context).padding.top),
              buildHeader(),
              Obx(() => buildBookingStatus()),
              const Gap(20),
              chipCategories(controller.categories),
              const Gap(20),
              buildPopular(),
              const Gap(20),
              buildNewest(),
              const Gap(100),
            ],
          );
        }),
      ],
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.translate(
            offset: const Offset(-16, 0),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                AppColors.onSurface,
                BlendMode.srcIn,
              ),
              child: Image.asset('assets/logo_text_16_9.png', width: 130),
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.notifications, color: AppColors.onSurface),
          ),
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
        color: const Color(0xFFFFB86C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                text: 'Booking Produk ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff070623),
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
                    text: ' Anda telah diproses.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff070623),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Populer',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const Gap(10),
        SizedBox(
          height: 250,
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
              color: AppColors.onSurface,
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
            return itemNewestCar(car, margin);
          },
        ),
      ],
    );
  }
}
