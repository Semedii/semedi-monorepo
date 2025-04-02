import 'package:flutter/material.dart';
import 'package:semedi/models/order.dart';
import 'package:semedi/utils/app_colors.dart';

class OrderItem extends StatelessWidget {
  final Order order;
  const OrderItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text("Table: ${order.tableNumber}"),
        subtitle: Text(order.orderItems.join(', ')),
        trailing: Chip(
          label: Text(
            order.orderStatus.name.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: order.orderStatus.name.toLowerCase() == 'ready'
              ? AppColors.green
              : AppColors.warmOrange,
        ),
      ),
    );
  }
}
