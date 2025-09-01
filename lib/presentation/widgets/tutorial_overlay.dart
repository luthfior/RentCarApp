import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialOverlay extends StatelessWidget {
  final VoidCallback onDismiss;
  final String message;
  final IconData icon;

  const TutorialOverlay({
    super.key,
    required this.onDismiss,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 120),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xff292929).withAlpha(215),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            TextButton(
              onPressed: onDismiss,
              child: Text(
                'Mengerti',
                style: GoogleFonts.poppins(
                  color: const Color(0xffFF5722),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
