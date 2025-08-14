import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final Widget? rightIcon;

  final connectivity = Get.find<ConnectivityService>();

  CustomHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.rightIcon,
  });

  final Widget _backIcon = Image.asset(
    'assets/ic_arrow_back.png',
    height: 24,
    width: 24,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: () {
                if (connectivity.isOnline.value) {
                  Get.back();
                } else {
                  null;
                }
              },
              child: Container(
                height: 46,
                width: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: _backIcon,
              ),
            )
          else
            const SizedBox(width: 46),

          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xff070623),
              ),
            ),
          ),

          if (rightIcon != null) rightIcon! else const SizedBox(width: 46),
        ],
      ),
    );
  }
}
