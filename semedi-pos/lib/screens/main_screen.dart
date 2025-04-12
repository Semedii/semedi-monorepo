import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/cubit/order/order_cubit.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/screens/management/management_screen.dart';
import 'package:semedi_pos/screens/report_screen.dart';
import 'package:semedi_pos/service/auth_service.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OrderCubit(orderService: OrderService())..listenToOrders(),
      child: BlocBuilder<OrderCubit, OrderState>(
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, OrderState state) {
    if (state is OrderLoaded) {
      return _buildScreenBody(context, state);
    }
    if (state is OrderLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state is OrderLoadingFailed) {
      return Scaffold(body: Center(child: Text(state.message)));
    }
    return const SizedBox.shrink();
  }

  Widget _buildScreenBody(BuildContext context, OrderLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(context, state),
      body: Column(
        children: [
          _buildStatsHeader(state),
          _buildOrderGrid(state.activeOrders),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ManagementScreen(),
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

  PreferredSizeWidget _buildAppBar(BuildContext context, OrderLoaded state) {
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
                builder: (context) => ReportScreen(
                  paidOrders: state.paidOrders ?? [],
                ),
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
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          color: AppColors.deepBlue,
          offset: const Offset(0, 12),
          icon: const Icon(Icons.account_circle),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'logout',
              child: Text(
                'Logout',
                style: TextStyle(color: AppColors.offWhite),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'logout') {
              AuthService().logout();
            }
          },
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildStatsHeader(OrderLoaded state) {
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
              value: state.activeOrders!.length.toString(),
              icon: Icons.receipt_long,
            ),
            const SizedBox(width: 24),
            _buildStatCard(
              title: 'Paid Orders',
              value: state.paidOrders?.length.toString() ?? '0',
              icon: Icons.check_circle,
              color: AppColors.green,
            ),
            const SizedBox(width: 24),
            _buildStatCard(
              title: 'Total Revenue',
              value: state.totalRevenue.toStringAsFixed(2),
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
          _buildOrderCardFooter(context, order),
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
