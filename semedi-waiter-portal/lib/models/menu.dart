class MenuItem {
  final String name;
  final double price;
  bool isAvailable;
  List<String> searchKeywords;

  MenuItem({
    required this.name,
    required this.price,
    this.isAvailable = true,
    this.searchKeywords = const [],
  });
}
