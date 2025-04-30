class WaitersPerfomance {
  final String name;
  final int noOfPaidOrders;
  final int noOfUnpaidOrders;
  final double unpaidOrdersTotal;
  final int totalOrders;
  final double totalSales;

  WaitersPerfomance({
    required this.name,
    required this.noOfPaidOrders,
    required this.noOfUnpaidOrders,
    required this.unpaidOrdersTotal,
    required this.totalOrders,
    required this.totalSales,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'noOfPaidOrders': noOfPaidOrders,
      'noOfUnpaidOrders': noOfUnpaidOrders,
      'unpaidOrdersTotal': unpaidOrdersTotal,
      'totalOrders': totalOrders,
      'totalSales': totalSales,
    };
  }

  factory WaitersPerfomance.fromMap(Map<String, dynamic> map) {
    return WaitersPerfomance(
      name: map['name'] ?? '',
      noOfPaidOrders: map['noOfPaidOrders'] ?? 0,
      noOfUnpaidOrders: map['noOfUnpaidOrders'] ?? 0,
      unpaidOrdersTotal: (map['unpaidOrdersTotal'] ?? 0).toDouble(),
      totalOrders: map['totalOrders'] ?? 0,
      totalSales: (map['totalSales'] ?? 0).toDouble(),
    );
  }
}
