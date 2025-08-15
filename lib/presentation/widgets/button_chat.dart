import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/utils/app_colors.dart';

class ButtonChat extends StatelessWidget {
  const ButtonChat({
    super.key,
    required this.onTap,
    this.backgroundColor = const Color(0xffFFFFFF),
    this.textColor,
    this.customBorderRadius = const BorderRadius.all(Radius.circular(50)),
  });
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color? textColor;
  final BorderRadius customBorderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(50),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/ic_message.png', width: 24, height: 24),
              const Gap(10),
              Text(
                'Chat Sekarang',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
