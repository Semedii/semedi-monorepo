import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory DailySummary.fromMap(Map<String, dynamic> map) {
    return DailySummary(
      date: map['date'] ?? '',
      restaurant: map['restaurant'] ?? '',
      dineIn: (map['dineIn'] ?? 0).toDouble(),
      takeAway: (map['takeAway'] ?? 0).toDouble(),
      totalSales: (map['totalSales'] ?? 0).toDouble(),
      dineInVat: (map['dineInVat'] ?? 0).toDouble(),
      takeAwayVat: (map['takeAwayVat'] ?? 0).toDouble(),
      totalVat: (map['totalVat'] ?? 0).toDouble(),
      dineInNet: (map['dineInNet'] ?? 0).toDouble(),
      takeAwayNet: (map['takeAwayNet'] ?? 0).toDouble(),
      totalNet: (map['totalNet'] ?? 0).toDouble(),
      unpaidDineIn: (map['unpaidDineIn'] ?? 0).toDouble(),
      unpaidTakeAway: (map['unpaidTakeAway'] ?? 0).toDouble(),
      unpaidTotal: (map['unpaidTotal'] ?? 0).toDouble(),
      noOfOrdersDineIn: map['noOfOrdersDineIn'] ?? 0,
      noOfOrdersTakeAway: map['noOfOrdersTakeAway'] ?? 0,
      totalOrders: map['totalOrders'] ?? 0,
      waitersPerfomanceList:
          (map['waitersPerfomanceList'] as List<dynamic>? ?? [])
              .map((e) => WaitersPerfomance.fromMap(e as Map<String, dynamic>))
              .toList(),
    );
  }

  static DailySummary fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    return DailySummary.fromMap(doc.data()!);
  }

  static Map<String, dynamic> toFirestore(
    DailySummary summary,
    SetOptions? options,
  ) {
    return summary.toMap();
  }
}
