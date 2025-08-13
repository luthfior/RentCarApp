import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FailedUi extends StatelessWidget {
  const FailedUi({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
