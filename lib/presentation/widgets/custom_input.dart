import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInput extends StatelessWidget {
  const CustomInput({
    super.key,
    this.icon,
    required this.hint,
    this.editingController,
    this.obsecure = false,
    this.enable = true,
    this.onTapBox,
    this.onChanged,
    this.suffixIcon,
    this.errorText,
    this.focusNode,
    this.customHintFontSize = 16,
    this.initialValue,
    this.keyboardType,
    this.inputFormatters,
    this.prefixText,
  });

  final String? icon;
  final String hint;
  final TextEditingController? editingController;
  final bool? obsecure;
  final bool enable;
  final VoidCallback? onTapBox;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final String? errorText;
  final FocusNode? focusNode;
  final double? customHintFontSize;
  final String? initialValue;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    final localController =
        editingController ?? TextEditingController(text: initialValue);

    return GestureDetector(
      onTap: onTapBox,
      child: TextField(
        controller: localController,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Theme.of(Get.context!).colorScheme.onSurface,
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
            color: Theme.of(Get.context!).colorScheme.onSurface,
          ),
          fillColor: Theme.of(Get.context!).colorScheme.surface,
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
            borderSide: const BorderSide(color: Color(0xffFF5722), width: 2),
          ),
          prefix: prefixText != null && prefixText!.isNotEmpty
              ? Text(
                  prefixText!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                )
              : null,
          prefixIcon: (icon != null && icon!.isNotEmpty)
              ? UnconstrainedBox(
                  alignment: const Alignment(0.5, 0),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Color(0xffFF5722),
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(icon!, height: 24, width: 24),
                  ),
                )
              : null,
          suffixIcon: suffixIcon,
          errorText: errorText,
        ),
      ),
    );
  }
}
