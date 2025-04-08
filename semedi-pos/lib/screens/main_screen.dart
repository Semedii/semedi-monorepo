import 'package:flutter/material.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/screens/management/management_screen.dart';
import 'package:semedi_pos/screens/report_screen.dart';
import 'package:semedi_pos/utils/app_colors.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

class MainScreen extends StatelessWidget {
  final List<OrderModel> orders = [
    OrderModel(
      tableNumber: 5,
      items: {'Burger': 2, 'Coke': 1},
      itemDetails: {
        'Burger': {'price': 250.0},
        'Coke': {'price': 120.0}
      },
      status: OrderStatusEnum.delivered,
      total: 620.0,
      waiter: 'Juan Dela Cruz',
    ),
    OrderModel(
      tableNumber: 2,
      items: {'Pizza': 3, 'Beer': 2},
      itemDetails: {
        'Pizza': {'price': 300.0},
        'Beer': {'price': 170.0}
      },
      status: OrderStatusEnum.delivered,
      total: 1240.0,
      waiter: 'Maria Santos',
    ),
    // Add more orders as needed...
  ];

  @override
  Widget build(BuildContext context) {
    final deliveredOrders = orders
        .where((order) => order.status == OrderStatusEnum.delivered)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildStatsHeader(),
          _buildOrderGrid(deliveredOrders),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ManagementScreen(),
            ),
          );
        },
        icon: const Icon(Icons.settings),
        label: const Text('MANAGE'),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('ACTIVE ORDERS', style: TextStyle(letterSpacing: 1.5)),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today_sharp),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ReportScreen(),
              ),
            );
          },
          tooltip: 'End of Day Report',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {},
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatCard(
              title: 'Active Orders',
              value: orders.length.toString(),
              icon: Icons.receipt_long,
            ),
            const SizedBox(width: 24),
            _buildStatCard(
              title: 'Paid Orders',
              value: orders
                  .where((o) => o.status == OrderStatusEnum.paid)
                  .length
                  .toString(),
              icon: Icons.check_circle,
              color: AppColors.green,
            ),
            const SizedBox(width: 24),
            _buildStatCard(
              title: 'Total Revenue',
              value:
                  '\$${orders.fold(0.0, (sum, order) => sum + order.total).toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: AppColors.deepBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: _getStatsCardDecoration(),
      child: Row(
        children: [
          Icon(icon, size: 28, color: color ?? AppColors.darkGrey),
          const SizedBox(width: 12),
          _buildStatsCardTitleValue(title, value, color),
        ],
      ),
    );
  }

  Column _buildStatsCardTitleValue(String title, String value, Color? color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsCardTitle(title),
        const SizedBox(height: 4),
        _buildStatsCardValue(value, color),
      ],
    );
  }

  BoxDecoration _getStatsCardDecoration() {
    return BoxDecoration(
      color: AppColors.offWhite,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade200),
    );
  }

  Text _buildStatsCardTitle(String title) =>
      Text(title, style: TextStyle(color: Colors.grey.shade600));

  Text _buildStatsCardValue(String value, Color? color) {
    return Text(value,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ));
  }

  Widget _buildOrderGrid(List<OrderModel> orders) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.2,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) => _buildOrderCard(orders[index]),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      decoration: _getOrderCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrderCardHeader(order),
          _buildOrderCardBody(order),
          _buildOrderCardFooter(order),
        ],
      ),
    );
  }

  BoxDecoration _getOrderCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildOrderCardHeader(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: _buildOrderTableAndTotal(order),
    );
  }

  Row _buildOrderTableAndTotal(OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildOrderTable(order),
        _buildOrderTotal(order),
      ],
    );
  }

  Text _buildOrderTable(OrderModel order) {
    return Text(
      'TABLE ${order.tableNumber}',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Text _buildOrderTotal(OrderModel order) {
    return Text(
      '\$${order.total.toStringAsFixed(2)}',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildOrderCardBody(OrderModel order) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildItemList(order),
      ),
    );
  }

  Expanded _buildItemList(OrderModel order) {
    return Expanded(
      child: ListView(
        children: order.items.entries
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      _buildItemQuantity(item),
                      const SizedBox(width: 12),
                      _buildItemName(item),
                      _buildItemPrice(order, item),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Container _buildItemQuantity(MapEntry<String, int> item) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.deepBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${item.value}',
        style: TextStyle(
          color: AppColors.deepBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Expanded _buildItemName(MapEntry<String, int> item) {
    return Expanded(
      child: Text(
        item.key,
        style: TextStyle(
          color: AppColors.darkGrey,
        ),
      ),
    );
  }

  Text _buildItemPrice(OrderModel order, MapEntry<String, int> item) {
    return Text(
      '\$${order.itemDetails[item.key]!['price']!.toStringAsFixed(2)}',
      style: TextStyle(
        color: AppColors.darkGrey.withOpacity(0.7),
      ),
    );
  }

  Widget _buildOrderCardFooter(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWaiterName(order),
          const SizedBox(height: 12),
          _buildMarkPaidButton(),
        ],
      ),
    );
  }

  Text _buildWaiterName(OrderModel order) {
    return Text(
      'Waiter: ${order.waiter}',
      style: TextStyle(
        color: AppColors.darkGrey.withOpacity(0.6),
        fontSize: 12,
      ),
    );
  }

  AppButton _buildMarkPaidButton() {
    return AppButton(
      text: 'Mark as paid',
      onPressed: () {},
    );
  }

  Color _getStatusColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.ready:
        return AppColors.green;
      case OrderStatusEnum.ordered:
        return AppColors.warmOrange;
      case OrderStatusEnum.delivered:
        return AppColors.deepBlue; // Changed to match your primary color
      default:
        return Colors.grey;
    }
  }
}
