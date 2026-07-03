import 'package:intl/intl.dart';

/// Formats a double amount as a string with appropriate decimals and thousand separators.
String formatAmount(double amount) {
  final formatter = NumberFormat.decimalPattern();
  // If the amount is a whole number, format as integer.
  if (amount == amount.roundToDouble()) {
    return formatter.format(amount.toInt());
  }
  // Otherwise, format with 2 decimal places.
  return NumberFormat('###,###.00').format(amount);
}
