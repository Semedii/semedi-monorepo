import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/menu_item_card.dart';
import 'package:semedi/components/order_confirm_dialog.dart';
import 'package:semedi/components/txt_form_field.dart';
import 'package:semedi/cubits/order/order_cubit.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/pages/home_page.dart';
import 'package:semedi/utils/app_colors.dart';

class OrderPage extends StatelessWidget {
  final int tableNumber;

  const OrderPage({
    required this.tableNumber,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderCubit()..initPage(),
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: _buildAppBar(),
        body: BlocConsumer<OrderCubit, OrderState>(
          listener: _getListener,
          builder: _mapStateToWidget,
        ),
      ),
    );
  }

  Widget _mapStateToWidget(context, OrderState state) {
    if (state is OrderIdle) {
      return _buildPageBody(context, state);
    } else if (state is OrderLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox.shrink();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "Table $tableNumber - Order",
        style: TextStyle(
          color: AppColors.offWhite,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.deepBlue,
      iconTheme: IconThemeData(color: AppColors.offWhite),
    );
  }

  Widget _buildPageBody(BuildContext context, OrderIdle state) {
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSelectedItemsSection(
                          context,
                          state.selectedItems,
                        ),
                        const SizedBox(height: 16),
                        Divider(thickness: 2, color: AppColors.deepBlue),
                        const SizedBox(height: 16),
                        _buildMenuSection(state, context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomSection(context, state),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context, OrderIdle state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNoteField(context),
          const SizedBox(height: 12),
          _buildSubmitButton(context, state),
        ],
      ),
    );
  }

  Padding _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchBar(
        hintText: 'Search menu items...',
        onChanged: context.read<OrderCubit>().updateSearchQuery,
        leading: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildSelectedItemsSection(
      BuildContext context, List<MenuItem> selectedItems) {
    return selectedItems.isEmpty
        ? _buildNoSelectedItemsText()
        : _buildSelectedItemsList(context);
  }

  Widget _buildNoSelectedItemsText() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No items selected yet',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSelectedItemsList(BuildContext context) {
    final orderCubit = BlocProvider.of<OrderCubit>(context);
    final orderItemsWithQuantity = orderCubit.getOrderItemQuantity();
    final itemList = orderItemsWithQuantity.entries.toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = itemList[index];
        return Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.deepBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${entry.value}x',
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(entry.key)),
            IconButton(
              onPressed: () => orderCubit.onRemoveItem(index),
              icon: Icon(
                Icons.remove_circle,
                color: AppColors.softRed,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuSection(OrderIdle state, BuildContext context) {
    return state.filteredMenuItems.isEmpty
        ? const Center(child: Text('No menu items found'))
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            gridDelegate: _getGridDelegate(),
            itemCount: state.filteredMenuItems.length,
            itemBuilder: (context, index) {
              final item = state.filteredMenuItems[index];
              return MenuItemCard(
                item: item,
                onTap: () =>
                    BlocProvider.of<OrderCubit>(context).onSelectedItem(item),
              );
            },
          );
  }

  SliverGridDelegate _getGridDelegate() {
    return const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    );
  }

  _buildNoteField(BuildContext context) {
    return TxtFormField(
      labelText: 'Special note (modifications...)',
      onChanged: BlocProvider.of<OrderCubit>(context).onNoteChanged,
    );
  }

  Widget _buildSubmitButton(BuildContext context, OrderIdle state) {
    return AppButton(
      text: 'Submit order',
      onPressed: () => showConfirmOrderDialog(context, state),
    );
  }

  void showConfirmOrderDialog(BuildContext context, OrderIdle state) {
    final cubit = BlocProvider.of<OrderCubit>(context);

    showDialog(
      context: context,
      builder: (context) => OrderConfirmDialog(
        tableNumber: tableNumber,
        orderCubit: cubit,
      ),
    );
  }

  _getListener(context, state) {
    if (state is OrderSuccess) {
      _getOrderSuccessListener(context, state);
    }
    if (state is OrderFailure) {
      _getOrderFailureListener(context, state);
    }
  }

  _getOrderSuccessListener(BuildContext context, OrderSuccess state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.green,
        content: Text("Order: ${state.orderNumber} created successfully"),
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }

  _getOrderFailureListener(BuildContext context, OrderFailure state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.softRed,
        content: Text("Error: ${state.error}"),
      ),
    );
  }
}
