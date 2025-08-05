import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonPrimary extends StatelessWidget {
  const ButtonPrimary({
    super.key,
    required this.onTap,
    required this.text,
    this.backgroundColor = const Color(0xffFFBC1C),
    this.textColor = const Color(0xff070623),
  });
  final VoidCallback? onTap;
  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    return Material(
      borderRadius: BorderRadius.circular(50),
      color: isDisabled ? Colors.grey[300] : backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
