import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonPrimary extends StatelessWidget {
  const ButtonPrimary({
    super.key,
    required this.onTap,
    required this.text,
    this.customBackgroundColor = const Color(0xffFF5722),
    this.customTextColor = const Color(0xffEFEFF0),
    this.customTextSize = 16.0,
    this.customBorderRadius = const BorderRadius.all(Radius.circular(50)),
    this.customHeight = 52,
    this.customBorderColor = const Color(0xffFF5722),
  });
  final VoidCallback? onTap;
  final String text;
  final double customTextSize;
  final Color customBackgroundColor;
  final Color? customTextColor;
  final BorderRadius customBorderRadius;
  final double? customHeight;
  final Color customBorderColor;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    return Material(
      borderRadius: customBorderRadius,
      color: isDisabled ? Colors.grey[300] : customBackgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: BoxDecoration(
            color: customBackgroundColor,
            borderRadius: customBorderRadius,
            border: Border.all(color: customBorderColor),
          ),
          width: double.infinity,
          height: customHeight,
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: customTextSize,
                fontWeight: FontWeight.w700,
                color: customTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
