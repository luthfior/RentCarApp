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
    this.keyboardType,
    this.inputFormatters,
    this.prefixText,
    this.maxLines,
    this.minLines,
    this.customBorderRadius = 50,
    this.suffixText,
    this.isTextCapital = false,
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
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final int? maxLines;
  final int? minLines;
  final double? customBorderRadius;
  final String? suffixText;
  final bool isTextCapital;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: editingController!,
      builder: (context, value, child) {
        final String? conditionalPrefixText = value.text.isNotEmpty
            ? prefixText
            : null;

        final TextStyle? conditionalPrefixStyle = conditionalPrefixText != null
            ? GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              )
            : null;

        final int? effectiveMaxLines = obsecure == true ? 1 : maxLines;

        return GestureDetector(
          onTap: onTapBox,
          child: TextField(
            controller: editingController,
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
                color: const Color(0xff838384),
              ),
              fillColor: Theme.of(Get.context!).colorScheme.surface,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(customBorderRadius!),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              isDense: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(customBorderRadius!),
                borderSide: const BorderSide(
                  color: Color(0xffFF5722),
                  width: 2,
                ),
              ),
              prefixText: conditionalPrefixText,
              prefixStyle: conditionalPrefixStyle,
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
              suffixText: suffixText,
            ),
            maxLines: effectiveMaxLines,
            minLines: minLines,
            textCapitalization: (isTextCapital == true)
                ? TextCapitalization.words
                : TextCapitalization.none,
          ),
        );
      },
    );
  }
}
