import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    String cleanedText = newValue.text.replaceAll('.', '');

    if (cleanedText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    try {
      int parsedValue = int.parse(cleanedText);
      final formatter = NumberFormat('#,###', 'en_US');
      String newText = formatter.format(parsedValue).replaceAll(',', '.');

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } catch (e) {
      return oldValue;
    }
  }
}
