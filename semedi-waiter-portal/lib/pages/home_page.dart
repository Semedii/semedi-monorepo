import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/order_item.dart';
import 'package:semedi/cubits/home/home_cubit.dart';

import 'package:semedi/models/order.dart';
import 'package:semedi/pages/order_page.dart';
import 'package:semedi/services/auth_service.dart';
import 'package:semedi/services/order_service.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/utils/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  Future<String> _getAppBaritle() async {
    final storage = SecureStorageService();
    String? restaurantName = await storage.read('restaurant');
    return "$restaurantName Waiter Portal";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => _buildLogoutSecion(context),
            icon: const Icon(Icons.menu)),
        title: FutureBuilder(
          future: _getAppBaritle(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            return Text(snapshot.data ?? 'Waiter Portal');
          },
        ),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) =>
            HomeCubit(orderService: OrderService())..listenToOrders(),
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return Center(child: Text(state.message));
            }

            if (state is HomeLoaded) {
              return Column(
                children: [
                  _buildActionButtons(context),
                  const Divider(),
                  _buildActiveOrders(context, state.orders),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildDineInButton(context),
          const SizedBox(height: 12),
          _buildTakeAwayButton(context),
        ],
      ),
    );
  }

  AppButton _buildDineInButton(BuildContext context) {
    return AppButton(
      text: "DINE-IN",
      onPressed: () => _showTableSelection(context),
    );
  }

  AppButton _buildTakeAwayButton(BuildContext context) {
    return AppButton(
      isOutlined: true,
      text: "TAKEAWAY",
      onPressed: () {},
    );
  }

  Widget _buildActiveOrders(
    BuildContext context,
    List<OrderModel> activeOrders,
  ) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .65,
      child: Column(
        children: [
          _buildActiveOrdersTitle(),
          _buildActiveOrdersList(context, activeOrders),
        ],
      ),
    );
  }

  Padding _buildActiveOrdersTitle() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child:
          Text('ACTIVE ORDERS', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Expanded _buildActiveOrdersList(
      BuildContext context, List<OrderModel> activeOrders) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    return Expanded(
      child: ListView.builder(
        itemCount: activeOrders.length,
        itemBuilder: (_, index) => OrderItem(
          order: activeOrders[index],
          onDeliver: () =>
              cubit.onDeliverOrder(activeOrders[index].orderNumber),
          onCancel: () => cubit.onCancelOrder(activeOrders[index].orderNumber),
        ),
      ),
    );
  }

  void _showTableSelection(BuildContext context) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: 12,
        itemBuilder: (ctx, index) => ElevatedButton(
          style: ButtonStyle(
            side: cubit.isTableOccupied(index + 1)
                ? WidgetStateProperty.all(
                    BorderSide(color: AppColors.warmOrange))
                : null,
          ),
          child: Text(
            'Table ${index + 1}',
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderPage(
                  tableNumber: index + 1,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _buildLogoutSecion(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Logout?".toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                AppButton(
                    text: "Confirm Logout",
                    onPressed: () {
                      AuthService().logout();
                      Navigator.pop(context);
                    })
              ],
            ),
          );
        });
  }
}
