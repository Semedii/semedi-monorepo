import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/authentication/auth_provider.dart';
import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/order_item.dart';
import 'package:semedi/cubits/home/home_cubit.dart';
import 'package:semedi/main.dart';
import 'package:semedi/models/dining_tables.dart';
import 'package:semedi/models/order_model.dart';
import 'package:semedi/pages/change_password_page.dart';
import 'package:semedi/pages/order_page.dart';
import 'package:semedi/services/auth_service.dart';
import 'package:semedi/services/order_service.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/services/service_locator.dart';
import 'package:semedi/utils/app_colors.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final SecureStorageService secureStorageService =
      getIt<SecureStorageService>();
  final AuthService authService = getIt<AuthService>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _createHomeCubit(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state is HomeError) {
      return Scaffold(body: Center(child: Text(state.message)));
    }

    if (state is HomeLoaded) {
      return _buildPageBody(context, state);
    }

    return Container();
  }

  Widget _buildPageBody(BuildContext context, HomeLoaded state) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: _buildAppBar(context, state),
        body: _buildTabBarView(context, state),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, HomeLoaded state) {
    return AppBar(
      backgroundColor: AppColors.offWhite,
      title: _buildAppBarTitle(state),
      centerTitle: true,
      bottom: _buildTabBar(),
      actions: [
        _buildSettings(context),
      ],
    );
  }

  Widget _buildSettings(BuildContext context) {
    return IconButton(
      onPressed: () => _showLogoutConfirmation(context),
      icon: const Icon(Icons.settings),
    );
  }

  Text _buildAppBarTitle(HomeLoaded state) {
    return Text("${state.restaurantName}");
  }

  TabBar _buildTabBar() {
    return const TabBar(
        tabs: [
          Tab(text: 'ACTIVE ORDERS'),
          Tab(text: 'PAID ORDERS'),
        ],
        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        indicatorColor: Color(0xFF2563EB));
  }

  TabBarView _buildTabBarView(BuildContext context, HomeLoaded state) {
    return TabBarView(
      children: [
        _buildActiveOrdersTab(context, state),
        _buildPaidOrdersTab(context, state),
      ],
    );
  }

  Widget _buildActiveOrdersTab(BuildContext context, HomeLoaded state) {
    List<OrderModel> activeOrders =
        BlocProvider.of<HomeCubit>(context).getActiveOrders();

    return Column(
      children: [
        _buildOrderActionButtons(context, state),
        const Divider(),
        _buildOrdersList(context, activeOrders, isPaid: false),
      ],
    );
  }

  Widget _buildPaidOrdersTab(BuildContext context, HomeLoaded state) {
    List<OrderModel> paidOrders =
        BlocProvider.of<HomeCubit>(context).getPaidOrders();
    return _buildOrdersList(context, paidOrders, isPaid: true);
  }

  Widget _buildOrderActionButtons(BuildContext context, HomeLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildNewOrderButton(context, state),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  AppButton _buildNewOrderButton(BuildContext context, HomeLoaded state) {
    return AppButton(
      text: "New Order",
      onPressed: () => _showTableSelection(context),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    List<OrderModel> orders, {
    required bool isPaid,
  }) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(
        children: [
          _buildOrdersListTitle(context, isPaid),
          _buildOrdersListView(context, orders, isPaid: isPaid),
        ],
      ),
    );
  }

  Padding _buildOrdersListTitle(BuildContext context, bool isPaid) {
    final activeOrdersLength =
        BlocProvider.of<HomeCubit>(context).getActiveOrders().length;
    final paidOrderLength =
        BlocProvider.of<HomeCubit>(context).getPaidOrders().length;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        isPaid
            ? 'PAID ORDERS: $paidOrderLength'
            : 'ACTIVE ORDERS: $activeOrdersLength',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Expanded _buildOrdersListView(
    BuildContext context,
    List<OrderModel> orders, {
    required bool isPaid,
  }) {
    return Expanded(
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (_, index) =>
            _buildOrderItem(context, orders[index], isPaid),
      ),
    );
  }

  OrderItemCard _buildOrderItem(
      BuildContext context, OrderModel order, bool isPaid) {
    return OrderItemCard(
      order: order,
      onDeliver: isPaid ? null : () => _onDeliverOrder(context, order),
      onCancel: isPaid ? null : () => _onCancelOrder(context, order),
      onRequestPay: (namePhone) => _onRequestPay(context, order, namePhone),
    );
  }

  void _onDeliverOrder(BuildContext context, OrderModel order) {
    context.read<HomeCubit>().onDeliverOrder(order.id);
  }

  void _onCancelOrder(BuildContext context, OrderModel order) {
    context.read<HomeCubit>().onCancelOrder(order.id);
  }

  void _onRequestPay(BuildContext context, OrderModel order, String namePhone) {
    context.read<HomeCubit>().onRequestPay(order.id, namePhone);
  }

  void _showTableSelection(BuildContext context) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    showModalBottomSheet(
      backgroundColor: AppColors.offWhite,
      context: context,
      builder: (ctx) {
        return BlocBuilder<HomeCubit, HomeState>(
          bloc: cubit,
          builder: (ctx, state) {
            if (state is! HomeLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildTablesGrid(ctx, cubit, state);
          },
        );
      },
    );
  }

  GridView _buildTablesGrid(
      BuildContext context, HomeCubit cubit, HomeLoaded state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: _buildGridDelegate(),
      itemCount: state.diningTables.length,
      itemBuilder: (ctx, index) =>
          _buildTableButton(context, cubit, state.diningTables[index]),
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate() {
    return const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      childAspectRatio: 0.85,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
    );
  }

  ElevatedButton _buildTableButton(
      BuildContext context, HomeCubit cubit, DiningTables table) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(table.status == 'available'
            ? AppColors.green.withValues(alpha: 0.8)
            : AppColors.warmOrange),
        padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: WidgetStateProperty.all(2),
      ),
      onPressed: () => _navigateToOrderPage(context, table),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.deepBlue,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${table.tableNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                '${table.capacity}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              table.location ?? 'Unknown',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderPage(BuildContext context, DiningTables table) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(table: table),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: AppColors.offWhite,
      context: context,
      builder: (context) => _buildLogoutConfirmationContent(context),
    );
  }

  Padding _buildLogoutConfirmationContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChangePassword(context),
          const SizedBox(height: 16),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildChangePassword(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.lock),
      title: const Text('Change Password'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _navigateToChangePassword(context),
    );
  }

  void _navigateToChangePassword(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordPage(),
      ),
    );
  }

  AppButton _buildLogoutButton(BuildContext context) {
    return AppButton(
      text: "Logout",
      onPressed: () => _performLogout(context),
    );
  }

  void _performLogout(BuildContext context) {
    getIt<AuthProvider>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MyApp()),
      (route) => false,
    );
  }

  HomeCubit _createHomeCubit() {
    return HomeCubit(OrderService(), secureStorageService)..listenToOrders();
  }
}
