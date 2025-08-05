import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildItemNav({
  required String label,
  required String icon,
  required String iconOn,
  bool isActive = false,
  required VoidCallback onTap,
  bool hasDot = false,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        height: 46,
        child: Column(
          children: [
            Image.asset(isActive ? iconOn : icon, height: 24, width: 24),
            const Gap(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(isActive ? 0xffFFBC1C : 0xffFFFFFF),
                  ),
                ),
                if (hasDot)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(left: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xffFF2056),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildItemCircle() {
  return Container(
    height: 50,
    width: 50,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Color(0xffFFBC1C),
    ),
    child: UnconstrainedBox(
      child: Image.asset('assets/ic_status.png', width: 24, height: 24),
    ),
  );
}
