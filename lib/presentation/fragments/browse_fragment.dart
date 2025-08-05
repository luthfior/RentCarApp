import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/viewModels/booking_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';
import 'package:rent_car_app/presentation/widgets/chip_categories.dart';
import 'package:rent_car_app/presentation/widgets/failed_ui.dart';
import 'package:rent_car_app/presentation/widgets/item_featured_car.dart';
import 'package:rent_car_app/presentation/widgets/item_newest_car.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';

class BrowseFragment extends StatefulWidget {
  const BrowseFragment({super.key});

  @override
  State<BrowseFragment> createState() => _BrowseFragmentState();
}

class _BrowseFragmentState extends State<BrowseFragment> {
  final browseVM = Get.put(BrowseViewModel());
  final bookingVM = Get.put(BookingViewModel());
  final connectivity = Get.find<ConnectivityService>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      browseVM.fetchAllCars();
      browseVM.fetchCategories();
      bookingVM.setDummyBook();
    });
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<BrowseViewModel>(force: true);
    Get.delete<BookingViewModel>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          String status = browseVM.loadingStatus;
          if (status == '') return const SizedBox();
          if (status == 'loading') {
            return const Center(child: CircularProgressIndicator());
          }
          if (status != 'success' && status != '') {
            return Center(child: FailedUi(message: status));
          }
          return ListView(
            padding: const EdgeInsets.all(0),
            children: [
              Gap(20 + MediaQuery.of(context).padding.top),
              buildHeader(),
              // buildBookingStatus(),
              const Gap(20),
              chipCategories(browseVM.categories),
              const Gap(30),
              buildPopular(),
              const Gap(30),
              buildNewest(),
              const Gap(100),
            ],
          );
        }),
        const OfflineBanner(),
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
            child: Image.asset('assets/logo_text_16_9.png', width: 130),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/ic_notification.png',
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBookingStatus() {
    return Obx(() {
      Map car = bookingVM.car;
      if (car.isEmpty) return const SizedBox();
      return Container(
        height: 70,
        margin: const EdgeInsets.fromLTRB(24, 30, 24, 0),
        decoration: BoxDecoration(
          color: const Color(0xff393e52),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 12),
              blurRadius: 20,
              color: const Color(0xff393e52).withAlpha(64),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: -45,
              top: 0,
              bottom: 0,
              child: ExtendedImage.network(
                car['image'],
                width: 130,
                height: 130,
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Your booking ',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: car['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xffFFBC1C),
                          ),
                        ),
                        TextSpan(
                          text: '\nhas been delivered to.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
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
              color: const Color(0xff070623),
            ),
          ),
        ),
        const Gap(10),
        SizedBox(
          height: 295,
          child: ListView.builder(
            itemCount: browseVM.featuredList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              Car car = browseVM.featuredList[index];
              final margin = EdgeInsets.only(
                left: index == 0 ? 24 : 12,
                right: index == browseVM.featuredList.length - 1 ? 24 : 12,
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
              color: const Color(0xff070623),
            ),
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          itemCount: browseVM.newestList.length,
          itemBuilder: (context, index) {
            Car car = browseVM.newestList[index];
            final margin = EdgeInsets.only(
              top: index == 0 ? 10 : 9,
              bottom: index == browseVM.newestList.length - 1 ? 16 : 9,
            );
            return itemNewestCar(car, margin);
          },
        ),
      ],
    );
  }
}
