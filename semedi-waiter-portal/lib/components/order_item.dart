import 'package:flutter/material.dart';

class OrderItem extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(order['table']),
        subtitle: Text(order['items'].join(', ')),
        trailing: Chip(
          label: Text(order['status'].toUpperCase()),
          backgroundColor:
              order['status'] == 'ready' ? Colors.green[100] : Colors.blue[100],
        ),
      ),
    );
  }
}
