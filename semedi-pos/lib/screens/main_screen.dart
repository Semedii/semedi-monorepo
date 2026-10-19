import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/order_card.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/cubit/order/order_cubit.dart';
import 'package:semedi_pos/models/order_model.dart';
import 'package:semedi_pos/screens/customer_screen.dart';
import 'package:semedi_pos/screens/inventory_screen.dart';
import 'package:semedi_pos/screens/management/management_screen.dart';
import 'package:semedi_pos/screens/report_screen.dart';
import 'package:semedi_pos/screens/sales_history_list_screen.dart';
import 'package:semedi_pos/screens/reservation_screen.dart';
import 'package:semedi_pos/screens/settings_screen.dart';
import 'package:semedi_pos/screens/shift_screen.dart';
import 'package:semedi_pos/screens/table_order_screen.dart';
import 'package:semedi_pos/screens/take_order_screen.dart';
import 'package:semedi_pos/service/auth_service.dart';
import 'package:semedi_pos/service/management_service.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';
import 'package:semedi_pos/utils/text_validators.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final TextEditingController? exchangeRateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _createCubit()..listenToOrders(),
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
    final cubit = BlocProvider.of<OrderCubit>(context);
    List<OrderModel>? takeAwayOrders = cubit.getTakeAwayOrders();
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(context, state),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _buildExchangeRateButton(context, state),
                ),
                Expanded(child: Center(child: _buildStatsHeader(state))),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildTakeAwayButton(context),
                )
              ],
            ),
          ),
          if (takeAwayOrders != null && takeAwayOrders.isNotEmpty)
            _buildTakeAwayGrid(width, takeAwayOrders, cubit, state),
          _buildTableGrid(width, cubit, state),
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
      title: Text(
        '${state.restaurant.toUpperCase()} ACTIVE ORDERS',
        style: const TextStyle(letterSpacing: 1.5),
      ),
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
                  unPaidOrders: state.unPaidOrders ?? [],
                  restaurant: state.restaurant,
                ),
              ),
            );
          },
          tooltip: 'End of Day Report',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            BlocProvider.of<OrderCubit>(context).listenToOrders();
          },
          tooltip: 'Refresh',
        ),
        PopupMenuButton<String>(
          menuPadding: const EdgeInsets.symmetric(horizontal: 16),
          position: PopupMenuPosition.under,
          color: AppColors.deepBlue,
          offset: const Offset(0, 12),
          icon: const Icon(Icons.account_circle),
          itemBuilder: (context) => [
            PopupMenuItem(
              padding: const EdgeInsets.only(bottom: 20, top: 12),
              value: 'history',
              child: Text(
                'Sale History',
                style: TextStyle(color: AppColors.offWhite),
              ),
            ),
            PopupMenuItem(
              value: 'shift',
              child: Text(
                'Shift Management',
                style: TextStyle(color: AppColors.offWhite),
              ),
            ),
            PopupMenuItem(
              value: 'customers',
              child: Text(
                'Customers',
                style: TextStyle(color: AppColors.offWhite),
              ),
            ),
            PopupMenuItem(
              value: 'inventory',
              child: Text(
                'Inventory',
                style: TextStyle(color: AppColors.offWhite),
              ),
            ),
            PopupMenuItem(
              value: 'reservations',
              child: Text(
                'Reservations',
                style: TextStyle(color: AppColors.offWhite),
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Text(
                'Settings',
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
              AuthService().logout();
            }
            if (value == 'settings') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()));
            }
            if (value == 'history') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SalesHistoryListScreen()));
            }
            if (value == 'shift') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ShiftScreen()));
            }
            if (value == 'customers') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CustomerScreen()));
            }
            if (value == 'inventory') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InventoryScreen()));
            }
            if (value == 'reservations') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReservationScreen()));
            }
          },
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildStatsHeader(OrderLoaded state) {
    int paidOrders = state.paidOrders?.length ?? 0;
    int unpaidOrders = state.unPaidOrders?.length ?? 0;
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
              title: 'Completed Orders',
              value: (paidOrders + unpaidOrders).toString(),
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
            const SizedBox(width: 24),
            _buildStatCard(
              title: 'Low Stock',
              value: state.lowStockCount.toString(),
              icon: Icons.warning_amber_rounded,
              color: state.lowStockCount > 0
                  ? AppColors.warmOrange
                  : Colors.grey,
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

  SliverPadding _buildTakeAwayGrid(
    double width,
    List<OrderModel> takeAwayOrders,
    OrderCubit cubit,
    OrderLoaded state,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: width > 1200
              ? 4
              : width > 800
                  ? 4
                  : 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final order = takeAwayOrders[index];
            return OrderCard(
              order: order,
              exchangeRate: state.exchangeRate,
              onChangeOrderStatus: cubit.changeOrderStatus,
              onCancelOrder: cubit.onCancelOrder,
            );
          },
          childCount: takeAwayOrders.length,
        ),
      ),
    );
  }

  SliverPadding _buildTableGrid(
    double width,
    OrderCubit cubit,
    OrderLoaded state,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: width > 1200
              ? 8
              : width > 800
                  ? 6
                  : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            //Todo
            final tableNumber = index + 1;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TableOrderScreen(
                      tableNumber: tableNumber,
                      exchangeRate: state.exchangeRate,
                      orderCubit: cubit,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: _getTableBoxDecoration(cubit, tableNumber),
                child: _getTableText(tableNumber),
              ),
            );
          },
          childCount: state.tableNumbers,
        ),
      ),
    );
  }

  BoxDecoration _getTableBoxDecoration(OrderCubit cubit, int tableNumber) {
    return BoxDecoration(
      color: _getTableColor(cubit, tableNumber),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(2, 4),
        )
      ],
    );
  }

  Center _getTableText(int tableNumber) {
    return Center(
      child: Text(
        'Table $tableNumber',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getTableColor(OrderCubit cubit, int tableNumber) {
    if (cubit.isTableVacant(tableNumber)) {
      return AppColors.green;
    } else if (cubit.isTablePayPending(tableNumber)) {
      return AppColors.warmOrange;
    }
    return AppColors.deepBlue;
  }

  AppButton _buildExchangeRateButton(BuildContext context, OrderLoaded state) {
    return AppButton(
      onPressed: () {
        showExchangeRateField(context);
      },
      elevation: 2,
      isSmall: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "\$ Set Exchange Rate",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
          Text('SLSH ${state.exchangeRate.toString()}',
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  AppButton _buildTakeAwayButton(BuildContext context) {
    return AppButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => TakeOrderScreen()));
      },
      elevation: 2,
      isSmall: true,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.add,
            color: Colors.white,
          ),
          Text(
            "Take Away Order",
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  showExchangeRateField(BuildContext context) {
    final cubit = BlocProvider.of<OrderCubit>(context);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.offWhite,
            title: const Text("Enter Your Exchange Rate of 1\$"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TxtFormField(
                    controller: exchangeRateController,
                    labelText: 'SLSH Value of 1\$',
                    validator: TextValidators.onlyNumbers,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    isSmall: true,
                    text: 'Submit',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        cubit.onSetExchangeRate(exchangeRateController?.text);
                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  OrderCubit _createCubit() {
    return OrderCubit(
      orderService: OrderService(),
      managementService: ManagementService(),
    );
  }
}
