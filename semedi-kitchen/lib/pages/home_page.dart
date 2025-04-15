import 'package:flutter/material.dart';
import 'package:semedi_kitchen/components/app_button.dart';
import 'package:semedi_kitchen/utils/app_colors.dart';
import 'package:semedi_kitchen/models/order.dart';
import 'package:semedi_kitchen/utils/order_status_enum.dart';

class HomePage extends StatelessWidget {
  final List<OrderModel> orders = [
    OrderModel(
      orderNumber: "K-1001",
      itemsWithQuantity: {"Shawarma": 2, "Fries": 1},
      itemsWithPrices: {"Shawarma": 9.5, "Fries": 3.0},
      status: OrderStatusEnum.ordered,
      total: 22.0,
      waiter: "abdis",
      note: "Extra spicy",
    ),
    OrderModel(
      orderNumber: "K-1002",
      itemsWithQuantity: {"Pasta": 1},
      itemsWithPrices: {"Pasta": 12.0},
      status: OrderStatusEnum.preparing,
      total: 12.0,
      waiter: "maryam",
    ),
    OrderModel(
      orderNumber: "K-1001",
      itemsWithQuantity: {"Shawarma": 2, "Fries": 1},
      itemsWithPrices: {"Shawarma": 9.5, "Fries": 3.0},
      status: OrderStatusEnum.ready,
      total: 22.0,
      waiter: "abdis",
      note: "Extra spicy",
    ),
    OrderModel(
      orderNumber: "K-1001",
      itemsWithQuantity: {"Shawarma": 2, "Fries": 1},
      itemsWithPrices: {"Shawarma": 9.5, "Fries": 3.0},
      status: OrderStatusEnum.ordered,
      total: 22.0,
      waiter: "abdis",
      note: "Extra spicy",
    ),
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title:
            const Text('KITCHEN ORDERS', style: TextStyle(letterSpacing: 1.5)),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStatsHeader(),
          _buildOrderGrid(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.settings),
        label: const Text('MANAGE MENU'),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: _buildStatsDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            title: 'New Orders',
            value: '1',
            icon: Icons.receipt,
          ),
          _buildStatCard(
            title: 'Preparing',
            value: '1',
            icon: Icons.timer,
            color: AppColors.warmOrange,
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildStatsDecoration() {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
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
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: color ?? AppColors.darkGrey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderGrid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.1,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) => _buildOrderCard(orders[index]),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      decoration: _buildOrderCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrderHeader(order),
          _buildOrderCardBody(order),
          _buildActionButtons(order),
        ],
      ),
    );
  }

  BoxDecoration _buildOrderCardDecoration() {
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

  Container _buildOrderHeader(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: _buildOrderTableAndStatus(order),
    );
  }

  Row _buildOrderTableAndStatus(OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildOrderTable(order),
        _buildOrderStatus(order),
      ],
    );
  }

  Text _buildOrderTable(OrderModel order) {
    return Text(
      'Order #${order.orderNumber}',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Text _buildOrderStatus(OrderModel order) {
    return Text(
      order.status.name.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Expanded _buildOrderCardBody(OrderModel order) {
    return Expanded(
      child: _buildItemList(order),
    );
  }

  Padding _buildItemList(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: order.itemsWithQuantity.entries
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          _buildItemQuantity(item),
                          const SizedBox(width: 12),
                          _buildItemName(item),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (order.note != null && order.note!.isNotEmpty) _buildNote(order),
        ],
      ),
    );
  }

  Container _buildItemQuantity(MapEntry<String, int> item) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: _buildItemQuantityDecoration(),
      child: Text(
        '${item.value}',
        style: TextStyle(
          color: AppColors.deepBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  BoxDecoration _buildItemQuantityDecoration() {
    return BoxDecoration(
      color: AppColors.deepBlue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    );
  }

  Expanded _buildItemName(MapEntry<String, int> item) =>
      Expanded(child: Text(item.key));

  Padding _buildNote(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'Note: ${order.note!}',
        style: TextStyle(
          color: AppColors.softRed,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Padding _buildActionButtons(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildCancelChip(),
          const SizedBox(width: 8),
          if (order.status == OrderStatusEnum.ordered) _buildPrepareButton(),
          if (order.status == OrderStatusEnum.preparing)
            _buildMarkReadyButton(),
        ],
      ),
    );
  }

  Chip _buildCancelChip() {
    return Chip(
      side: BorderSide(color: AppColors.softRed),
      elevation: 8,
      shadowColor: AppColors.softRed,
      label: Text(
        'Cancel',
        style: TextStyle(color: AppColors.offWhite),
      ),
      backgroundColor: AppColors.softRed,
    );
  }

  AppButton _buildPrepareButton() {
    return AppButton(
      color: AppColors.warmOrange,
      onPressed: () {},
      text: 'Start preparing',
    );
  }

  AppButton _buildMarkReadyButton() {
    return AppButton(
      color: AppColors.green,
      onPressed: () {},
      text: 'mark ready',
    );
  }

  Color _getStatusColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.ordered:
        return AppColors.darkGrey;
      case OrderStatusEnum.preparing:
        return AppColors.warmOrange;
      case OrderStatusEnum.ready:
        return AppColors.green;
      default:
        return Colors.grey;
    }
  }
}
