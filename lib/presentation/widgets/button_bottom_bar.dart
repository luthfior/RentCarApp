import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildItemNav({
  required String label,
  required dynamic icon,
  required dynamic iconOn,
  bool isActive = false,
  required VoidCallback onTap,
  bool isDisable = false,
  bool hasDot = false,
}) {
  final iconColor = isActive
      ? const Color(0xffFF5722)
      : (isDisable ? Colors.grey : Colors.white);
  final labelColor = isActive
      ? const Color(0xffFF5722)
      : (isDisable ? Colors.grey : Colors.white);

  Widget getIconWidget(dynamic iconData) {
    if (iconData is String) {
      return Image.asset(iconData, height: 24, width: 24);
    } else if (iconData is Icon) {
      return Icon(iconData.icon, color: iconColor, size: 24);
    }
    return Container();
  }

  return Expanded(
    child: GestureDetector(
      onTap: isDisable ? null : onTap,
      child: Container(
        color: Colors.transparent,
        height: 46,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon is String)
              ColorFiltered(
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                child: Image.asset(
                  isActive ? iconOn : icon,
                  height: 24,
                  width: 24,
                ),
              )
            else if (icon is Icon)
              getIconWidget(isActive ? iconOn : icon),
            const Gap(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                ),
                if (hasDot && !isDisable)
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
