import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:semedi_kitchen/components/app_button.dart';
import 'package:semedi_kitchen/cubit/homepage/home_cubit.dart';
import 'package:semedi_kitchen/models/order_item.dart';
import 'package:semedi_kitchen/pages/menu_management_screen.dart';
import 'package:semedi_kitchen/pages/help_page.dart';
import 'package:semedi_kitchen/pages/settings_page.dart';
import 'package:semedi_kitchen/services/auth_service.dart';
import 'package:semedi_kitchen/services/order_service.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';
import 'package:semedi_kitchen/services/service_locator.dart';
import 'package:semedi_kitchen/services/thermal_reciept_service.dart';
import 'package:semedi_kitchen/utils/app_colors.dart';
import 'package:semedi_kitchen/models/order.dart';
import 'package:semedi_kitchen/models/order_timer.dart';
import 'package:semedi_kitchen/utils/extensions.dart';
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
                value: 'settings',
                child: Text(
                  'Settings',
                  style: TextStyle(color: AppColors.offWhite),
                ),
              ),
              PopupMenuItem(
                value: 'help',
                child: Text(
                  'Kitchen Guide',
                  style: TextStyle(color: AppColors.offWhite),
                ),
              ),
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
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()),
                );
              }
              if (value == 'help') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpPage()),
                );
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(context),
          _buildKitchenStatsPanel(context),
          _buildFilterRow(context, state),
          _buildOrderGrid(context, state.filteredOrders, state.orderTimers),
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
            color: AppColors.darkGrey.withValues(alpha: 0.7),
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
          color: Colors.black.withValues(alpha: 0.05),
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

  Widget _buildFilterRow(BuildContext context, HomeLoaded state) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    final filters = [
      ('all', 'All'),
      ('pending', 'New'),
      ('preparing', 'In Progress'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: filters.map((entry) {
          final key = entry.$1;
          final label = entry.$2;
          final isActive = state.filterStatus == key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => cubit.onFilterOrders(key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.deepBlue : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? AppColors.deepBlue
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade700,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKitchenStatsPanel(BuildContext context) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    final active = cubit.getActiveOrdersCount();
    final urgent = cubit.getUrgentCount();
    final avgWait = cubit.getAvgWaitMinutes();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      color: AppColors.deepBlue.withValues(alpha: 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildKitchenStatChip(
            label: 'Active',
            value: active.toString(),
            icon: Icons.receipt_long,
            color: AppColors.deepBlue,
          ),
          _buildKitchenStatChip(
            label: 'Avg Wait',
            value: '${avgWait.toStringAsFixed(0)}m',
            icon: Icons.timer_outlined,
            color: AppColors.warmOrange,
          ),
          _buildKitchenStatChip(
            label: 'Urgent',
            value: urgent.toString(),
            icon: Icons.priority_high,
            color: urgent > 0 ? Colors.red : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenStatChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderGrid(BuildContext context, List<OrderModel> orders,
      Map<String, OrderTimer> timers) {
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
            timers[orders[index].id],
          ),
        ),
      ),
    );
  }

  Container _buildTimerBadge(OrderTimer timer) {
    Color color;
    if (timer.isUrgent) {
      color = Colors.red;
    } else if (timer.isWarning) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${timer.elapsedMinutes}m',
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, OrderModel order, OrderTimer? timer) {
    return Stack(
      children: [
        Container(
          decoration: _buildOrderCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOrderHeader(context, order),
              _buildOrderCardBody(order),
              _buildMarkDoneButton(context, order),
              _buildCardFooter(context, order),
            ],
          ),
        ),
        if (timer != null)
          Positioned(
            top: 8,
            right: 8,
            child: _buildTimerBadge(timer),
          ),
      ],
    );
  }

  Widget _buildMarkDoneButton(BuildContext context, OrderModel order) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () => cubit.onMarkComplete(order.id),
        child: const Text('MARK DONE', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  BoxDecoration _buildOrderCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
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
    bool isTakeAway =
        false; //todo order.customerName != null && order.tableNumber == null;
    String tableInfo = order.tableNumber != null
        ? 'Table: ${order.tableNumber}'
        : 'TakeAway for ${order.waiterName}'; //todo
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
              '#${order.orderNumber.formatOrderNumber()}',
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
      order.status.toUpperCase(),
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
              children: order.items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          _buildItemQuantity(item),
                          const SizedBox(width: 12),
                          _buildItemName(item),
                          const SizedBox(width: 12),
                          Text(
                            item.note?.toUpperCase() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildItemQuantity(OrderItem item) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: _buildItemQuantityDecoration(),
      child: Text(
        '${item.itemQuantity}x',
        style: TextStyle(
          color: AppColors.deepBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  BoxDecoration _buildItemQuantityDecoration() {
    return BoxDecoration(
      color: AppColors.deepBlue.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    );
  }

  Text _buildModifierText(List<String> modifiers) {
    return Text(
      '+ ${modifiers.join(', ')}',
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Expanded _buildItemName(OrderItem item) {
    if (item.modifiers.isEmpty) {
      return Expanded(child: Text(item.itemName));
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.itemName),
          _buildModifierText(item.modifiers),
        ],
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
        order.waiterName,
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
          const SizedBox(width: 8),
          if (order.status == OrderStatusEnum.pending.name) ...{
            _buildPrepareButton(cubit, order.id),
          },
          if (order.status == OrderStatusEnum.preparing.name) ...{
            _buildMarkReadyButton(cubit, order.id),
          }
        ],
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.darkGrey;
      case 'preparing':
        return AppColors.warmOrange;
      case 'ready':
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
        orderNumber: order.id,
        tableNumber: order.tableNumber.toString(),
        customerName: order.waiterName, // todo customer name
        waiter: order.waiterName,
        items: order.items,
        total: order.totalPrice,
        exchangeRate: 10000, //todo
        dateTime: order.createdAt,
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
