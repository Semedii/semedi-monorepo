import 'package:flutter/material.dart';
import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/order_item.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/models/order.dart';
import 'package:semedi/pages/order_page.dart';
import 'package:semedi/utils/order_status_enum.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<Order> _activeOrders = [
    Order(
        tableNumber: 21,
        orderItems: ["Pizza"],
        orderStatus: OrderStatusEnum.preparing,
        note: "note"),
    Order(
        tableNumber: 21,
        orderItems: ["Pizza", "half Pasta"],
        orderStatus: OrderStatusEnum.ready,
        note: "note")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiter Portal')),
      body: Column(
        children: [
          _buildActionButtons(context),
          const Divider(),
          _buildActiveOrders(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildDineInButton(context),
          const SizedBox(height: 12),
          _buildTakeAwayButton(context),
        ],
      ),
    );
  }

  AppButton _buildDineInButton(BuildContext context) {
    return AppButton(
      text: "DINE-IN",
      onPressed: () => _showTableSelection(context),
    );
  }

  AppButton _buildTakeAwayButton(BuildContext context) {
    return AppButton(
      isOutlined: true,
      text: "TAKEAWAY",
      onPressed: () {},
    );
  }

  Widget _buildActiveOrders(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .65,
      child: Column(
        children: [
          _buildActiveOrdersTitle(),
          _buildActiveOrdersList(),
        ],
      ),
    );
  }

  Padding _buildActiveOrdersTitle() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child:
          Text('ACTIVE ORDERS', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Expanded _buildActiveOrdersList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _activeOrders.length,
        itemBuilder: (_, index) => OrderItem(order: _activeOrders[index]),
      ),
    );
  }

  void _showTableSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: 12,
        itemBuilder: (ctx, index) => ElevatedButton(
          child: Text(
            'Table ${index + 1}',
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderPage(
                  tableNumber: index + 1,
                  menuItems: [
                    MenuItem(name: 'Shawarma'),
                    MenuItem(name: 'Pizza', price: 12),
                    MenuItem(name: 'Burger', price: 12),
                    MenuItem(name: 'Sandwich', price: 12),
                    MenuItem(name: 'Chicken', price: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
