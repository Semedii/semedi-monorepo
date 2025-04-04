import 'package:flutter/material.dart';
import 'package:semedi/models/order.dart';
import 'package:semedi/utils/app_colors.dart';

class OrderItem extends StatelessWidget {
  final OrderModel order;
  const OrderItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text("Table: ${order.tableNumber}"),
        subtitle: Text(order.items.keys.join(', ')),
        trailing: Chip(
          label: Text(
            order.status.name.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: order.status.name.toLowerCase() == 'ready'
              ? AppColors.green
              : AppColors.warmOrange,
        ),
      ),
    );
  }
}
