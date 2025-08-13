import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInput extends StatelessWidget {
  const CustomInput({
    super.key,
    required this.icon,
    required this.hint,
    required this.editingController,
    this.obsecure,
    this.enable = true,
    this.onTapBox,
    this.onChanged,
    this.suffixIcon,
    this.errorText,
    this.focusNode,
    this.customHintFontSize = 16,
  });
  final String icon;
  final String hint;
  final TextEditingController editingController;
  final bool? obsecure;
  final bool enable;
  final VoidCallback? onTapBox;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final String? errorText;
  final FocusNode? focusNode;
  final double? customHintFontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapBox,
      child: TextField(
        controller: editingController,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xff070623),
        ),
        obscureText: obsecure ?? false,
        onChanged: onChanged,
        focusNode: focusNode,
        decoration: InputDecoration(
          enabled: enable,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: customHintFontSize,
            fontWeight: FontWeight.w400,
            color: const Color(0xff070623),
          ),
          fillColor: const Color(0xffFFFFFF),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          isDense: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Color(0xff4A1DFF), width: 2),
          ),
          prefixIcon: UnconstrainedBox(
            alignment: const Alignment(0.5, 0),
            child: Image.asset(icon, height: 24, width: 24),
          ),
          suffixIcon: suffixIcon,
          errorText: errorText,
        ),
      ),
    );
  }
}
