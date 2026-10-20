import 'package:flutter/material.dart';
import 'package:semedi_pos/models/purchase_order.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class SpendingReportScreen extends StatelessWidget {
  const SpendingReportScreen({required this.orders, super.key});

  final List<PurchaseOrder> orders;

  @override
  Widget build(BuildContext context) {
    final receivedOrders =
        orders.where((o) => o.status == 'received').toList();
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(receivedOrders),
            const SizedBox(height: 24),
            _buildStatusBreakdown(),
            const SizedBox(height: 24),
            _buildSpendingBySupplier(receivedOrders),
            const SizedBox(height: 24),
            _buildRecentOrders(context),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('SPENDING REPORT'),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildSummaryCards(List<PurchaseOrder> receivedOrders) {
    final totalSpent =
        receivedOrders.fold(0.0, (sum, o) => sum + o.totalCost);
    final thisMonth = _filterThisMonth(receivedOrders);
    final thisMonthSpent =
        thisMonth.fold(0.0, (sum, o) => sum + o.totalCost);

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Spent',
            value: '\$${totalSpent.toStringAsFixed(2)}',
            icon: Icons.payments_outlined,
            color: AppColors.deepBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'This Month',
            value: '\$${thisMonthSpent.toStringAsFixed(2)}',
            icon: Icons.calendar_month,
            color: AppColors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Orders Received',
            value: receivedOrders.length.toString(),
            icon: Icons.check_circle_outline,
            color: AppColors.warmOrange,
          ),
        ),
      ],
    );
  }

  Container _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    final draft = orders.where((o) => o.status == 'draft').length;
    final ordered = orders.where((o) => o.status == 'ordered').length;
    final received = orders.where((o) => o.status == 'received').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Status Breakdown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusStat(
                    label: 'Draft',
                    count: draft,
                    color: Colors.grey.shade600),
                _buildDivider(),
                _buildStatusStat(
                    label: 'Ordered',
                    count: ordered,
                    color: AppColors.warmOrange),
                _buildDivider(),
                _buildStatusStat(
                    label: 'Received',
                    count: received,
                    color: AppColors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  VerticalDivider _buildDivider() {
    return VerticalDivider(
      color: Colors.grey.shade200,
      thickness: 1,
      width: 32,
      indent: 4,
      endIndent: 4,
    );
  }

  Column _buildStatusStat({
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSpendingBySupplier(List<PurchaseOrder> receivedOrders) {
    final Map<String, double> bySupplier = {};
    for (final order in receivedOrders) {
      bySupplier[order.supplierName] =
          (bySupplier[order.supplierName] ?? 0) + order.totalCost;
    }
    final sorted = bySupplier.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending by Supplier',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        if (sorted.isEmpty)
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No received orders yet',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
            ),
          )
        else
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: sorted
                    .map((entry) =>
                        _buildSupplierSpendingRow(entry, sorted.first.value))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSupplierSpendingRow(
    MapEntry<String, double> entry,
    double maxValue,
  ) {
    final fraction =
        maxValue > 0 ? (entry.value / maxValue).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.darkGrey),
              ),
              Text(
                '\$${entry.value.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: fraction,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.deepBlue),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    final recent = orders.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Orders',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No orders yet',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
            ),
          )
        else
          Card(
            color: Colors.white,
            child: Column(
              children: recent
                  .map((order) => _buildRecentOrderTile(order))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentOrderTile(PurchaseOrder order) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getStatusColor(order.status).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getStatusIcon(order.status),
          size: 20,
          color: _getStatusColor(order.status),
        ),
      ),
      title: Text(
        order.supplierName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${_formatDate(order.createdAt)}  ·  ${order.items.length} items',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${order.totalCost.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          _buildStatusChip(order.status),
        ],
      ),
    );
  }

  Container _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ordered':
        return AppColors.warmOrange;
      case 'received':
        return AppColors.green;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ordered':
        return Icons.local_shipping_outlined;
      case 'received':
        return Icons.check_circle_outline;
      default:
        return Icons.edit_note;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  List<PurchaseOrder> _filterThisMonth(List<PurchaseOrder> orders) {
    final now = DateTime.now();
    return orders
        .where((o) =>
            o.createdAt.year == now.year && o.createdAt.month == now.month)
        .toList();
  }
}
