import 'package:flutter/material.dart';
import 'package:semedi_pos/models/order_model.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class OrderAnalyticsScreen extends StatelessWidget {
  const OrderAnalyticsScreen({
    required this.orders,
    required this.restaurant,
    super.key,
  });

  final List<OrderModel> orders;
  final String restaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('ORDER ANALYTICS'),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: orders.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection('Key Metrics'),
                _buildAverageMetrics(orders),
                const SizedBox(height: 20),
                _buildSection('Orders by Status'),
                _buildOrdersByStatus(orders),
                const SizedBox(height: 20),
                _buildSection('Top Waiters'),
                _buildTopWaiters(orders),
                const SizedBox(height: 20),
                _buildSection('Orders by Hour'),
                _buildOrdersByHour(orders),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Center _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No order data available',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.deepBlue,
        ),
      ),
    );
  }

  Card _buildAverageMetrics(List<OrderModel> orders) {
    final totalItems =
        orders.fold<int>(0, (sum, o) => sum + o.items.length);
    final avgValue = orders.isEmpty
        ? 0.0
        : orders.fold<double>(0, (sum, o) => sum + o.totalPrice) /
            orders.length;
    final busiest = _buildBusiestHour(orders);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMetricRow('Total Orders', orders.length.toString()),
            _buildMetricRow(
                'Average Order Value', '\$${avgValue.toStringAsFixed(2)}'),
            _buildMetricRow('Total Items Ordered', totalItems.toString()),
            _buildMetricRow('Busiest Hour', busiest),
          ],
        ),
      ),
    );
  }

  Padding _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue,
            ),
          ),
        ],
      ),
    );
  }

  String _buildBusiestHour(List<OrderModel> orders) {
    if (orders.isEmpty) return '—';
    final Map<int, int> byHour = {};
    for (final o in orders) {
      final h = o.createdAt.hour;
      byHour[h] = (byHour[h] ?? 0) + 1;
    }
    final peak = byHour.entries.reduce((a, b) => a.value > b.value ? a : b);
    final h = peak.key;
    return '${h.toString().padLeft(2, '0')}:00 - ${(h + 1).toString().padLeft(2, '0')}:00';
  }

  Card _buildOrdersByStatus(List<OrderModel> orders) {
    final Map<String, int> byStatus = {};
    for (final o in orders) {
      byStatus[o.status] = (byStatus[o.status] ?? 0) + 1;
    }
    final statusColors = {
      'paid': AppColors.green,
      'ordered': AppColors.deepBlue,
      'payPending': AppColors.warmOrange,
      'cancelled': AppColors.softRed,
      'pending': Colors.grey,
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: byStatus.entries.map((entry) {
            final color =
                statusColors[entry.key] ?? AppColors.darkGrey;
            return _buildStatusRow(entry.key, entry.value, color);
          }).toList(),
        ),
      ),
    );
  }

  Padding _buildStatusRow(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(status, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Card _buildTopWaiters(List<OrderModel> orders) {
    final Map<String, int> byWaiter = {};
    for (final o in orders) {
      byWaiter[o.waiterName] = (byWaiter[o.waiterName] ?? 0) + 1;
    }
    final sorted = byWaiter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: top5.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final name = entry.value.key;
          final count = entry.value.value;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.deepBlue,
              radius: 16,
              child: Text(
                '$rank',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(name,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: Text(
              '$count orders',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }).toList(),
      ),
    );
  }

  Card _buildOrdersByHour(List<OrderModel> orders) {
    final Map<int, int> byHour = {};
    for (final o in orders) {
      final h = o.createdAt.hour;
      byHour[h] = (byHour[h] ?? 0) + 1;
    }
    if (byHour.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No data', style: TextStyle(color: Colors.grey.shade500)),
        ),
      );
    }
    final maxCount = byHour.values.reduce((a, b) => a > b ? a : b);
    final sortedHours = byHour.keys.toList()..sort();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedHours.map((h) {
            final count = byHour[h]!;
            final barWidth =
                maxCount > 0 ? (count / maxCount * 200).clamp(4.0, 200.0) : 4.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${h.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: barWidth,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.deepBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
