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
    this.customHeight = 52,
    required this.customIconSize,
    this.customBorderRadius = const BorderRadius.all(Radius.circular(50)),
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
      borderRadius: BorderRadius.circular(50),
      color: Theme.of(Get.context!).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).colorScheme.surface,
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
              ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0xffFF5722),
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/ic_message.png',
                  width: customIconSize,
                  height: customIconSize,
                ),
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
