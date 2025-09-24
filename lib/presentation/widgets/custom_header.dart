import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final Widget? rightIcon;
  final VoidCallback? onBackTap;

  final connectivity = Get.find<ConnectivityService>();

  CustomHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.rightIcon,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: () {
                if (connectivity.isOnline.value) {
                  if (onBackTap != null) {
                    onBackTap!();
                  } else {
                    Get.back();
                  }
                } else {
                  const OfflineBanner();
                  return;
                }
              },
              child: Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(Get.context!).colorScheme.surface,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 24,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
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
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
          ),

          if (rightIcon != null) rightIcon! else const SizedBox(width: 46),
        ],
      ),
    );
  }
}
