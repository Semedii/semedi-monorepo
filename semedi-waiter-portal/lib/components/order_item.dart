import 'package:flutter/material.dart';
import 'package:semedi/models/order.dart';
import 'package:semedi/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:semedi/utils/order_status_enum.dart';

class OrderItem extends StatelessWidget {
  final OrderModel order;
  final Function()? onDeliver;
  const OrderItem({super.key, required this.order, this.onDeliver});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOrderAndTableNumber(),
                _buildStatusChip(),
              ],
            ),
            const Divider(height: 24),
            _buildItemList(),
            if (order.note != null && order.note!.isNotEmpty) ...{
              _buildNote(),
            },
            const SizedBox(height: 12),
            _buildTimestampAndDeliverButton(),
          ],
        ),
      ),
    );
  }

  Column _buildOrderAndTableNumber() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order #${order.orderNumber}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Table ${order.tableNumber}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Container _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusChipColor(order.status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        order.status.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Column _buildItemList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          order.items.entries.map((entry) => _buildItemCard(entry)).toList(),
    );
  }

  Padding _buildItemCard(MapEntry<String, int> entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.deepBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${entry.value}',
              style: TextStyle(
                color: AppColors.deepBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            entry.key,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Column _buildNote() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Note: ${order.note!}',
            style: TextStyle(
              color: AppColors.softRed,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  _buildTimestampAndDeliverButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimestamp(),
        if (order.status == OrderStatusEnum.ready) _buildDeliverButton()
      ],
    );
  }

  Text _buildTimestamp() {
    String text =
        order.status == OrderStatusEnum.delivered ? 'Delivered' : 'Ordered';
    return Text(
      '$text at ${_getTimeFromDateTime(order.timestamp)}',
      style: TextStyle(
        color: AppColors.darkGrey,
        fontSize: 12,
      ),
    );
  }

  _buildDeliverButton() {
    return GestureDetector(
      onTap: onDeliver,
      child: Chip(
        elevation: 8,
        shadowColor: AppColors.deepBlue,
        label: Text(
          'Deliver',
          style: TextStyle(color: AppColors.offWhite),
        ),
        backgroundColor: AppColors.deepBlue,
      ),
    );
  }

  Color _getStatusChipColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.ready:
        return AppColors.green;
      case OrderStatusEnum.delivered:
        return AppColors.deepBlue;
      case OrderStatusEnum.preparing:
        return AppColors.warmOrange;
      default:
        return Colors.grey;
    }
  }

  String? _getTimeFromDateTime(DateTime? timestamp) {
    if (timestamp == null) return null;
    return DateFormat('h:mm a').format(timestamp);
  }
}
