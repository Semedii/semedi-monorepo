import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/order_card.dart';
import 'package:semedi_pos/cubit/order/order_cubit.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class TableOrderScreen extends StatelessWidget {
  const TableOrderScreen({
    required this.orderCubit,
    required this.tableNumber,
    super.key,
  });
  final OrderCubit orderCubit;
  final int tableNumber;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: BlocProvider.value(
          value: orderCubit,
          child: BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              if (state is OrderLoaded) {
                List<OrderModel> tableOrders = state.activeOrders
                        ?.where((o) => o.tableNumber == tableNumber)
                        .toList() ??
                    [];
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.builder(
                    gridDelegate: _buildGridDelegate(height),
                    itemCount: tableOrders.length,
                    itemBuilder: (context, index) => OrderCard(
                      order: tableOrders[index],
                      onChangeOrderStatus: orderCubit.changeOrderStatus,
                      onCancelOrder: orderCubit.onCancelOrder,
                    ),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Table $tableNumber',
        style: const TextStyle(letterSpacing: 1.5),
      ),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate(double height) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      mainAxisExtent: height * 0.67,
    );
  }
}
