import 'package:flutter/services.dart';

/// Keeps only the 8 local Mauritanian digits. A visible +222 prefix is UI-only.
class MauritanianPhoneDigitsFormatter extends TextInputFormatter {
  const MauritanianPhoneDigitsFormatter();

  static const countryPrefixDigits = '222';
  static const localLength = 8;
  static const placeholder = '48116011';

  static String digitsOf(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith(countryPrefixDigits) &&
        digits.length >= countryPrefixDigits.length + localLength) {
      digits = digits.substring(digits.length - localLength);
    } else if (digits.startsWith(countryPrefixDigits) &&
        digits.length > localLength) {
      digits = digits.substring(countryPrefixDigits.length);
    }
    if (digits.length > localLength) {
      digits = digits.substring(0, localLength);
    }
    return digits;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = digitsOf(newValue.text);
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
