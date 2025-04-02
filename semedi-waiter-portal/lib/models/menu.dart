class MenuItem {
  final String name;
  final double? price;
  bool isAvailable;
  List<String> searchKeywords; // For better search

  MenuItem({
    required this.name,
    this.price,
    this.isAvailable = true,
    this.searchKeywords = const [],
  });
}
