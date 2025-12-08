extension IntegerExtensions on int {
  String formatOrderNumber() {
    return toString().padLeft(4, '0');
  }
}
