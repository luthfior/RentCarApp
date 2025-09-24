import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonChat extends StatelessWidget {
  const ButtonChat({
    super.key,
    required this.onTap,
    required this.text,
    this.textColor,
    this.customTextSize = 16,
    this.customHeight = 56,
    required this.customIconSize,
    this.customBorderRadius = const BorderRadius.all(Radius.circular(20)),
  });
  final VoidCallback? onTap;
  final String text;
  final Color? textColor;
  final double? customTextSize;
  final double? customHeight;
  final double? customIconSize;
  final BorderRadius customBorderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: customBorderRadius,
      color: Get.isDarkMode ? const Color(0xff070623) : const Color(0xffEFEFF0),
      child: InkWell(
        onTap: onTap,
        borderRadius: customBorderRadius,
        child: Container(
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? const Color(0xff070623)
                : const Color(0xffEFEFF0),
            borderRadius: customBorderRadius,
            border: Border.all(
              color: Theme.of(Get.context!).colorScheme.onSurface,
            ),
          ),
          width: double.infinity,
          height: customHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message_rounded,
                size: customIconSize,
                color: const Color(0xffFF5722),
              ),
              const Gap(8),
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: customTextSize,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
