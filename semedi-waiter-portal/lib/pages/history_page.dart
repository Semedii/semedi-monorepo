import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/cubits/history/history_cubit.dart';
import 'package:semedi/models/order_model.dart';
import 'package:semedi/services/order_service.dart';
import 'package:semedi/utils/app_colors.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(OrderService())..initPage(),
      child: BlocBuilder<HistoryCubit, HistoryState>(
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, HistoryState state) {
    if (state is HistoryLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state is HistoryFailure) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(child: Text(state.message)),
      );
    }

    if (state is HistoryLoaded) {
      return _buildPageBody(context, state);
    }

    return Scaffold(appBar: _buildAppBar(), body: const SizedBox());
  }

  Scaffold _buildPageBody(BuildContext context, HistoryLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: state.orders.isEmpty
          ? _buildEmptyState()
          : _buildOrderList(state.orders),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Order History',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: AppColors.offWhite,
      elevation: 0,
      foregroundColor: Colors.black87,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No orders completed today',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOrderCardHeader(order),
          _buildOrderCardItems(order),
          _buildOrderCardFooter(order),
        ],
      ),
    );
  }

  Widget _buildOrderCardHeader(OrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.deepBlue.withValues(alpha: 0.04),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Order #${order.orderNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            'Table ${order.tableNumber}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCardItems(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: order.items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.deepBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.itemQuantity}x',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.deepBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.itemName ?? '')),
                    Text(
                      '\$${((item.itemPrice ?? 0) * (item.itemQuantity ?? 1)).toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildOrderCardFooter(OrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            order.waiterName,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          Text(
            '\$${order.totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.deepBlue,
            ),
          ),
        ],
      ),
    );
  }
}
