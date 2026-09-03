String formatOuguiya(num value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < rounded.length; i++) {
    final remaining = rounded.length - i;
    buffer.write(rounded[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(' ');
    }
  }

  return '${buffer.toString()} MRU';
}
