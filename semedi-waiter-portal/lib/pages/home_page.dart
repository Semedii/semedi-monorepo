import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/authentication/auth_provider.dart';

import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/order_item.dart';
import 'package:semedi/cubits/home/home_cubit.dart';
import 'package:semedi/main.dart';
import 'package:semedi/models/order_model.dart';
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
        appBar: _buildAppBar(context, state),
        body: _buildTabBarView(context, state),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, HomeLoaded state) {
    return AppBar(
      leading: _buildMenuButton(context),
      title: _buildAppBarTitle(state),
      centerTitle: true,
      bottom: _buildTabBar(),
    );
  }

  IconButton _buildMenuButton(BuildContext context) {
    return IconButton(
      onPressed: () => _showLogoutConfirmation(context),
      icon: const Icon(Icons.menu),
    );
  }

  Text _buildAppBarTitle(HomeLoaded state) {
    return Text("${state.restaurantName} Waiter Portal");
  }

  TabBar _buildTabBar() {
    return const TabBar(
      tabs: [
        Tab(text: 'ACTIVE ORDERS'),
        Tab(text: 'PAID ORDERS'),
      ],
    );
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
          _buildDineInButton(context, state),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  AppButton _buildDineInButton(BuildContext context, HomeLoaded state) {
    return AppButton(
      text: "DINE-IN",
      onPressed: () => _showTableSelection(context, state),
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
          _buildOrdersListTitle(isPaid),
          _buildOrdersListView(context, orders, isPaid: isPaid),
        ],
      ),
    );
  }

  Padding _buildOrdersListTitle(bool isPaid) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        isPaid ? 'PAID ORDERS' : 'ACTIVE ORDERS',
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

  void _showTableSelection(BuildContext context, HomeLoaded state) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _buildTablesGrid(context, cubit, state),
    );
  }

  GridView _buildTablesGrid(
      BuildContext context, HomeCubit cubit, HomeLoaded state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: _buildGridDelegate(),
      itemCount: state.totalTables,
      itemBuilder: (ctx, index) => _buildTableButton(context, cubit, index),
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate() {
    return const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      childAspectRatio: 1.0,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
    );
  }

  ElevatedButton _buildTableButton(
      BuildContext context, HomeCubit cubit, int index) {
    return ElevatedButton(
      style: _buildTableButtonStyle(cubit, index),
      child: _buildTableButtonText(index),
      onPressed: () => _navigateToOrderPage(context, index),
    );
  }

  ButtonStyle _buildTableButtonStyle(HomeCubit cubit, int index) {
    return ButtonStyle(
      side: cubit.isTableOccupied(index + 1)
          ? WidgetStateProperty.all(BorderSide(color: AppColors.warmOrange))
          : null,
    );
  }

  Text _buildTableButtonText(int index) {
    return Text(
      'Table ${index + 1}',
      textAlign: TextAlign.center,
    );
  }

  void _navigateToOrderPage(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(tableNumber: index + 1),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
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
          _buildLogoutTitle(),
          const SizedBox(height: 16),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Text _buildLogoutTitle() {
    return Text(
      "Logout?".toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  AppButton _buildLogoutButton(BuildContext context) {
    return AppButton(
      text: "Confirm Logout",
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
