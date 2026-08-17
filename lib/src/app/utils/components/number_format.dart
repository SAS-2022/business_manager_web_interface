import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NumberWithCommas {
  TextEditingValue formatNumber(TextEditingController controller) {
    String text = controller.text;
    int cursorPosition = controller.selection.baseOffset;

    // Remove all non-digit characters except decimal point
    String unformattedText = text.replaceAll(RegExp(r'[^\d.]'), '');

    // Split into integer and decimal parts
    List<String> parts = unformattedText.split('.');
    String integerPart = parts[0];
    String decimalPart =
        parts.length > 1 ? '.${parts[1].replaceAll(RegExp(r'\D'), '')}' : '';

    // Limit decimal part to 2 digits if present
    if (decimalPart.length > 3) {
      decimalPart = decimalPart.substring(0, 3);
    }

    // Format the integer part with commas
    String formattedInteger = _formatWithCommas(integerPart);

    String formattedText = formattedInteger + decimalPart;

    // Calculate new cursor position
    int newCursorPosition = cursorPosition;
    if (formattedText != text) {
      // Get the numeric character count before cursor in original text
      int numericCharsBeforeCursor = text
          .substring(0, cursorPosition)
          .replaceAll(RegExp(r'[^\d]'), '')
          .length;

      // Now find equivalent position in new text
      String numericPart = formattedText.replaceAll(RegExp(r'[^\d]'), '');
      numericCharsBeforeCursor =
          numericCharsBeforeCursor.clamp(0, numericPart.length);

      if (numericCharsBeforeCursor == 0) {
        newCursorPosition = 0;
      } else {
        // Get the numeric part up to our cursor position
        String partialNumeric =
            numericPart.substring(0, numericCharsBeforeCursor);
        // Format just this part to see where commas would be
        String partialFormatted = _formatWithCommas(partialNumeric);
        newCursorPosition = partialFormatted.length;
      }

      // Ensure we don't place cursor in the middle of a decimal
      if (decimalPart.isNotEmpty &&
          newCursorPosition > formattedText.length - decimalPart.length) {
        newCursorPosition = formattedText.length - decimalPart.length;
      }
    }

    // Update the controller value
    controller.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );

    return controller.value;
  }

  String _formatWithCommas(String number) {
    if (number.isEmpty) return number;

    // Remove all non-digit characters
    String cleanNumber = number.replaceAll(RegExp(r'[^\d]'), '');

    // Use NumberFormat for more reliable formatting
    try {
      return NumberFormat('#,###').format(int.parse(cleanNumber));
    } catch (e) {
      return cleanNumber; // Fallback if parsing fails
    }
  }
}
