import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/cubit/order/order_cubit.dart';
import 'package:semedi_pos/cubit/waiterStat/waiter_stat_cubit.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/models/waiters_perfomance.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

class WaiterStatsScreen extends StatelessWidget {
  WaiterStatsScreen({required this.waitersPerfomance, super.key});

  final OrderService _orderService = OrderService();

  final WaitersPerfomance waitersPerfomance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(context, waitersPerfomance),
      body: BlocProvider(
        create: (context) =>
            WaiterStatCubit(_orderService)..initPage(waitersPerfomance.name),
        child: BlocBuilder<WaiterStatCubit, WaiterStatState>(
          builder: _mapStateToWidget,
        ),
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, WaiterStatState state) {
    if (state is WaiterStatLoaded) {
      return _buildScreenBody(state.waitersOrders);
    }
    if (state is WaiterStatLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox.shrink();
  }

  Column _buildScreenBody(List<OrderModel>? waitersOrders) {
    return Column(
      children: [
        _buildStatsHeader(waitersPerfomance),
        _buildOrderGrid(waitersOrders),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WaitersPerfomance waitersPerfomance,
  ) {
    return AppBar(
      title: Text(waitersPerfomance.name,
          style: const TextStyle(letterSpacing: 1.5)),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.offWhite),
    );
  }

  Widget _buildStatsHeader(WaitersPerfomance waitersPerfomance) {
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
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatCard(
                title: 'Paid Orders',
                value: waitersPerfomance.noOfPaidOrders.toString(),
                icon: Icons.check_circle,
                color: AppColors.green,
              ),
              const SizedBox(width: 24),
              _buildStatCard(
                title: 'Unpaid Orders',
                value: waitersPerfomance.noOfUnpaidOrders.toString(),
                icon: Icons.dangerous,
                color: AppColors.warmOrange,
              ),
              const SizedBox(width: 24),
              _buildStatCard(
                title: 'Total Orders',
                value: waitersPerfomance.totalOrders.toString(),
                icon: Icons.food_bank,
                color: AppColors.deepBlue,
              ),
            ],
          ),
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

  Widget _buildOrderGrid(List<OrderModel>? orders) {
    if (orders == null || orders.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No orders available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }
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
          itemBuilder: (context, index) => _buildOrderCard(
            context,
            orders[index],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return Container(
      decoration: _getOrderCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrderCardHeader(order),
          _buildOrderCardBody(order),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              "Ordered at: ${DateFormat.jm().format(order.timestamp)}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          )
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
    String tableOrName = order.tableNumber != null
        ? "TABLE ${order.tableNumber}"
        : "Take Away: ${order.customerName}";
    return Text(
      tableOrName,
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
        children: order.itemsWithQuantity.entries
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
    final price = order.itemsWithPrices[item.key] ?? 0.0;
    return Text(
      '\$ $price',
      style: TextStyle(
        color: AppColors.darkGrey.withOpacity(0.7),
      ),
    );
  }

  Widget _buildOrderCardFooter(BuildContext context, OrderModel order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWaiterName(order),
          const SizedBox(height: 12),
          _buildMarkPaidButton(context, order.orderNumber!),
          const SizedBox(height: 12),
          _buildUnPaidButton(context, order.orderNumber!),
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

  AppButton _buildMarkPaidButton(BuildContext context, String orderNumber) {
    return AppButton(
      color: AppColors.green,
      isSmall: false,
      text: 'Mark as paid',
      onPressed: () => BlocProvider.of<OrderCubit>(context).changeOrderStatus(
        orderNumber,
        OrderStatusEnum.paid,
      ),
    );
  }

  AppButton _buildUnPaidButton(BuildContext context, String orderNumber) {
    return AppButton(
        onPressed: () {
          BlocProvider.of<OrderCubit>(context).changeOrderStatus(
            orderNumber,
            OrderStatusEnum.unpaid,
          );
        },
        color: AppColors.warmOrange,
        isSmall: false,
        text: "Unpaid");
  }

  Color _getStatusColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.paid:
        return AppColors.green;
      case OrderStatusEnum.unpaid:
        return AppColors.warmOrange;
      default:
        return Colors.grey;
    }
  }
}
