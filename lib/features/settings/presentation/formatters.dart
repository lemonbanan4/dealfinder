/// Formats a double price with thousands-space separators
/// (e.g. 1234567.0 → "1 234 567").
String formatAmount(double price) {
  final rounded = price.round();
  final s = rounded.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    // Add a space for thousands separator, but not at the beginning.
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}
