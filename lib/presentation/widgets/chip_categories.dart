import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Widget chipCategories(List categories) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Kategori',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xff070623),
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
                return Container(
                  height: 52,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.fromLTRB(16, 14, 30, 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      getCategoryIcon(category),
                      const Gap(10),
                      Text(
                        category,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff070623),
                        ),
                      ),
                    ],
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

Widget getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'mpv (mobil keluarga)':
      return Image.asset('assets/ic_car_mpv.png', width: 19, height: 19);
    case 'suv (mobil tangguh)':
      return Image.asset('assets/ic_car_suv.png', width: 24, height: 24);
    case 'hatchback  (mobil kota)':
      return Image.asset('assets/ic_car_hatchback.png', width: 24, height: 24);
    case 'electric (mobil listrik)':
      return Image.asset('assets/ic_car_electric.png', width: 19, height: 19);
    default:
      return Image.asset('assets/ic_car_hatchback.png', width: 24, height: 24);
  }
}
