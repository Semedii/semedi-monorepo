class MenuItem {
  final String id;
  final String name;
  final double price;
  bool isAvailable;
  List<String> searchKeywords;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.isAvailable = true,
    this.searchKeywords = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
        id: json['id'],
        name: json['name'],
        isAvailable: json['available'],
        price: double.parse(json['price'].toString()));
  }
}
