import 'package:semedi_pos/models/waiters_perfomance.dart';

class DailySummary {
  final String date;
  final String restaurant;
  final double dineIn;
  final double takeAway;
  final double totalSales;
  final double dineInVat;
  final double takeAwayVat;
  final double totalVat;
  final double dineInNet;
  final double takeAwayNet;
  final double totalNet;
  final double unpaidDineIn;
  final double unpaidTakeAway;
  final double unpaidTotal;
  final int noOfOrdersDineIn;
  final int noOfOrdersTakeAway;
  final int totalOrders;
  final List<WaitersPerfomance> waitersPerfomanceList;

  DailySummary({
    required this.date,
    required this.restaurant,
    required this.dineIn,
    required this.takeAway,
    required this.totalSales,
    required this.dineInVat,
    required this.takeAwayVat,
    required this.totalVat,
    required this.dineInNet,
    required this.takeAwayNet,
    required this.totalNet,
    required this.unpaidDineIn,
    required this.unpaidTakeAway,
    required this.unpaidTotal,
    required this.noOfOrdersDineIn,
    required this.noOfOrdersTakeAway,
    required this.totalOrders,
    required this.waitersPerfomanceList,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'restaurant': restaurant,
      'dineIn': dineIn,
      'takeAway': takeAway,
      'totalSales': totalSales,
      'dineInVat': dineInVat,
      'takeAwayVat': takeAwayVat,
      'totalVat': totalVat,
      'dineInNet': dineInNet,
      'takeAwayNet': takeAwayNet,
      'totalNet': totalNet,
      'unpaidDineIn': unpaidDineIn,
      'unpaidTakeAway': unpaidTakeAway,
      'unpaidTotal': unpaidTotal,
      'noOfOrdersDineIn': noOfOrdersDineIn,
      'noOfOrdersTakeAway': noOfOrdersTakeAway,
      'totalOrders': totalOrders,
      'waitersPerfomanceList':
          waitersPerfomanceList.map((waiter) => waiter.toMap()).toList(),
    };
  }
}
