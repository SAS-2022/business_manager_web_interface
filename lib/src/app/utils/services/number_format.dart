String formatNumber(num value) {
  // Split into whole and decimal parts
  final parts = value.toString().split('.');

  // Format the integer part with commas
  String integerPart = parts[0];
  final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  integerPart = integerPart.replaceAllMapped(regex, (Match m) => '${m[1]},');

  if (parts.length == 1) {
    // No decimal part
    return integerPart;
  } else {
    // Get decimal part and pad with zeros if needed
    var decimalPart = parts[1];
    if (decimalPart.length > 3) {
      decimalPart = decimalPart.substring(0, 3);
    } else {
      decimalPart = decimalPart.padRight(3, '0');
    }

    // Trim trailing zeros
    decimalPart = decimalPart.replaceAll(RegExp(r'0+$'), '');

    return decimalPart.isEmpty ? integerPart : '$integerPart.$decimalPart';
  }
}
