import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/cubit/waiterStat/waiter_stat_cubit.dart';
import 'package:semedi_pos/models/order_item.dart';
import 'package:semedi_pos/models/order_model.dart';
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
      appBar: _buildAppBar(context),
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
      return _buildScreenBody(context, state.waitersOrders);
    }
    if (state is WaiterStatLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox.shrink();
  }

  Widget _buildScreenBody(
    BuildContext context,
    List<OrderModel>? waitersOrders,
  ) {
    return Column(
      children: [
        _buildStatsHeader(context),
        _buildOrderGrid(context, waitersOrders),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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

  Widget _buildStatsHeader(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
        scrollDirection: isSmallScreen ? Axis.vertical : Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isSmallScreen
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatCard(
                      title: 'Paid Orders',
                      value: waitersPerfomance.noOfPaidOrders.toString(),
                      icon: Icons.check_circle,
                      color: AppColors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      title: 'Unpaid Orders',
                      value: waitersPerfomance.noOfUnpaidOrders.toString(),
                      icon: Icons.dangerous,
                      color: AppColors.warmOrange,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      title: 'Total Orders',
                      value: waitersPerfomance.totalOrders.toString(),
                      icon: Icons.food_bank,
                      color: AppColors.deepBlue,
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: _getStatsCardDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: color ?? AppColors.darkGrey),
            const SizedBox(width: 12),
            _buildStatsCardTitleValue(title, value, color),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCardTitleValue(String title, String value, Color? color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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

  Widget _buildStatsCardTitle(String title) => Text(
        title,
        style: TextStyle(color: Colors.grey.shade600),
      );

  Widget _buildStatsCardValue(String value, Color? color) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildOrderGrid(BuildContext context, List<OrderModel>? orders) {
    final cubit = BlocProvider.of<WaiterStatCubit>(context);
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

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600
        ? 1
        : screenWidth < 900
            ? 2
            : 3;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(screenWidth < 600 ? 16 : 24),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.8,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) =>
              _buildOrderCard(context, orders[index], cubit),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    WaiterStatCubit cubit,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: _getOrderCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOrderCardHeader(order),
              _buildOrderCardBody(order),
              _buildOrderCardFooter(context, order, cubit),
            ],
          ),
        );
      },
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

  Widget _buildOrderTableAndTotal(OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: _buildOrderTable(order),
        ),
        _buildOrderTotal(order),
      ],
    );
  }

  Widget _buildOrderTable(OrderModel order) {
    final tableOrName = order.tableNumber != null
        ? "TABLE ${order.tableNumber}"
        //todo customer name
        : "Take Away: ${order ?? 'N/A'}";

    return Text(
      tableOrName,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildOrderTotal(OrderModel order) {
    return Text(
      '\$${order.totalPrice.toStringAsFixed(2)}',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildOrderCardBody(OrderModel order) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildOrderItemRow(item, order),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Ordered at: ${DateFormat.jm().format(order.createdAt)}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItem item, OrderModel order) {
    return Row(
      children: [
        _buildItemQuantity(item),
        const SizedBox(width: 12),
        _buildItemName(item),
        _buildItemPrice(order, item),
      ],
    );
  }

  Widget _buildItemQuantity(OrderItem item) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.deepBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${item.itemQuantity}',
        style: TextStyle(
          color: AppColors.deepBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildItemName(OrderItem item) {
    return Expanded(
      child: Text(
        item.itemName,
        style: TextStyle(
          color: AppColors.darkGrey,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildItemPrice(OrderModel order, OrderItem item) {
    return Text(
      '\$ ${item.itemPrice}',
      style: TextStyle(
        color: AppColors.darkGrey.withOpacity(0.7),
      ),
    );
  }

  Widget _buildOrderCardFooter(
      BuildContext context, OrderModel order, WaiterStatCubit cubit) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWaiterName(order),
          const SizedBox(height: 12),
          ...[
            if (isSmallScreen)
              Column(
                children: [
                  _buildMarkPaidButton(cubit, order.id),
                  const SizedBox(height: 8),
                  _buildUnPaidButton(cubit, order.id),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildMarkPaidButton(cubit, order.id),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUnPaidButton(cubit, order.id),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaiterName(OrderModel order) {
    return Text(
      'Waiter: ${order.waiterName}',
      style: TextStyle(
        color: AppColors.darkGrey.withOpacity(0.6),
        fontSize: 12,
      ),
    );
  }

  Widget _buildMarkPaidButton(WaiterStatCubit cubit, String orderNumber) {
    return AppButton(
      color: AppColors.green,
      isSmall: true,
      text: 'Mark as paid',
      onPressed: () => cubit.changeOrderStatus(
        waitersPerfomance.name,
        orderNumber,
        OrderStatusEnum.paid,
      ),
    );
  }

  Widget _buildUnPaidButton(WaiterStatCubit cubit, String orderNumber) {
    return AppButton(
      onPressed: () {
        cubit.changeOrderStatus(
          waitersPerfomance.name,
          orderNumber,
          OrderStatusEnum.unpaid,
        );
      },
      color: AppColors.warmOrange,
      isSmall: true,
      text: "Mark as unpaid",
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return AppColors.green;
      case 'unpaid':
        return AppColors.softRed;
      default:
        return Colors.grey;
    }
  }
}
