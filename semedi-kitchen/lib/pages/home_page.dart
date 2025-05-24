import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:semedi_kitchen/components/app_button.dart';
import 'package:semedi_kitchen/cubit/homepage/home_cubit.dart';
import 'package:semedi_kitchen/pages/menu_management_screen.dart';
import 'package:semedi_kitchen/services/auth_service.dart';
import 'package:semedi_kitchen/services/order_service.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';
import 'package:semedi_kitchen/services/service_locator.dart';
import 'package:semedi_kitchen/services/thermal_reciept_service.dart';
import 'package:semedi_kitchen/utils/app_colors.dart';
import 'package:semedi_kitchen/models/order.dart';
import 'package:semedi_kitchen/utils/order_status_enum.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final OrderService _orderService = OrderService();
  final SecureStorageService _secureStorageService =
      getIt<SecureStorageService>();
  final AuthService _authService = getIt<AuthService>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeCubit(_orderService, _secureStorageService)..listenToOrders(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, HomeState state) {
    if (state is HomeLoaded) {
      return _buildPageBody(context, state);
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Scaffold _buildPageBody(BuildContext context, HomeLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(
          '${state.restaurantName.toUpperCase()} KITCHEN ORDERS',
          style: const TextStyle(letterSpacing: 1.5),
        ),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
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
                _authService.logout();
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(context),
          _buildOrderGrid(state.activeOrders),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuManagementScreen(),
            ),
          );
        },
        icon: const Icon(Icons.settings),
        label: const Text('MANAGE MENU'),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: _buildStatsDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            title: 'New Orders',
            value: cubit.getNewOrdersNumber().toString(),
            icon: Icons.receipt,
            color: AppColors.darkGrey.withOpacity(0.7),
          ),
          _buildStatCard(
            title: 'Preparing Orders',
            value: cubit.getPreparingOrdersNumber().toString(),
            icon: Icons.timer,
            color: AppColors.warmOrange,
          ),
          _buildStatCard(
            title: 'Ready Orders',
            value: cubit.getReadyOrdersNumber().toString(),
            icon: Icons.fastfood,
            color: AppColors.green,
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
          Icon(icon, size: 28, color: color),
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

  Widget _buildOrderGrid(List<OrderModel> orders) {
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
      decoration: _buildOrderCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrderHeader(context, order),
          _buildOrderCardBody(order),
          _buildCardFooter(context, order),
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

  Container _buildOrderHeader(BuildContext context, OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: _buildOrderTableAndStatus(context, order),
    );
  }

  Row _buildOrderTableAndStatus(BuildContext context, OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildOrderTable(context, order),
        _buildOrderStatus(order),
      ],
    );
  }

  Widget _buildOrderTable(BuildContext context, OrderModel order) {
    bool isTakeAway = order.customerName != null && order.tableNumber == null;
    String tableInfo = order.tableNumber != null
        ? 'Table: ${order.tableNumber}'
        : 'TakeAway for ${order.customerName}';
    return Row(
      children: [
        IconButton(
          onPressed: () => _generateAndPrintReceipt(context, order),
          icon: Icon(
            Icons.print,
            color: AppColors.offWhite,
          ),
          tooltip: 'Print Reciept',
        ),
        const SizedBox(width: 4),
        Column(
          children: [
            Text(
              order.orderNumber ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              tableInfo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            )
          ],
        ),
        const SizedBox(width: 12),
        if (isTakeAway) _buildTakeAwayText()
      ],
    );
  }

  Text _buildTakeAwayText() {
    return Text(
      "Take Away",
      style: TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.bold),
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
        '${item.value}x',
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

  Widget _buildCardFooter(BuildContext context, OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWaiterName(order),
        _buildActionButtons(context, order),
      ],
    );
  }

  Padding _buildWaiterName(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        order.waiter,
        style: TextStyle(color: AppColors.deepBlue),
      ),
    );
  }

  Padding _buildActionButtons(BuildContext context, OrderModel order) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // if (order.status != OrderStatusEnum.ordered) ...{
          //   _buildCancelChip(cubit, order.orderNumber!),
          // },
          const SizedBox(width: 8),
          if (order.status == OrderStatusEnum.ordered) ...{
            _buildPrepareButton(cubit, order.orderNumber!),
          },
          if (order.status == OrderStatusEnum.preparing) ...{
            _buildMarkReadyButton(cubit, order.orderNumber!),
          }
        ],
      ),
    );
  }

  Widget _buildCancelChip(HomeCubit cubit, String orderNumber) {
    return GestureDetector(
      onTap: () => cubit.onCancelOrder(orderNumber),
      child: Chip(
        side: BorderSide(color: AppColors.softRed),
        elevation: 4,
        shadowColor: AppColors.softRed,
        label: Text(
          'Cancel',
          style: TextStyle(color: AppColors.offWhite),
        ),
        backgroundColor: AppColors.softRed,
      ),
    );
  }

  AppButton _buildPrepareButton(HomeCubit cubit, String orderNumber) {
    return AppButton(
      color: AppColors.warmOrange,
      onPressed: () =>
          cubit.onOrderStatusChange(orderNumber, OrderStatusEnum.preparing),
      text: 'Start preparing',
    );
  }

  AppButton _buildMarkReadyButton(HomeCubit cubit, String orderNumber) {
    return AppButton(
      color: AppColors.green,
      onPressed: () =>
          cubit.onOrderStatusChange(orderNumber, OrderStatusEnum.ready),
      text: 'mark ready',
    );
  }

  Color _getStatusColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.ordered:
        return AppColors.darkGrey.withOpacity(0.5);
      case OrderStatusEnum.preparing:
        return AppColors.warmOrange;
      case OrderStatusEnum.ready:
        return AppColors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _generateAndPrintReceipt(
    BuildContext context,
    OrderModel order,
  ) async {
    try {
      final pdfBytes = await ThermalReceiptService.generateOrderReceiptBytes(
        orderNumber: order.orderNumber ?? 'N/A',
        tableNumber: order.tableNumber.toString(),
        waiter: order.waiter,
        items: order.itemsWithQuantity,
        prices: order.itemsWithPrices,
        total: order.total,
        dateTime: order.timestamp,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing receipt: ${e.toString()}')),
      );
    }
  }
}
