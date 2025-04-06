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
        _buildSelectedItemsSection(state.selectedItems),
        Divider(thickness: 2, color: AppColors.deepBlue),
        _buildMenuSection(state, context),
        _buildNoteField(context),
        _buildSubmitButton(context, state),
      ],
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

  Widget _buildSelectedItemsSection(List<MenuItem> selectedItems) {
    if (selectedItems.isEmpty) {
      return _buildNoSelectedItemsText();
    }
    return _buildSelectedItemsList(selectedItems);
  }

  Widget _buildNoSelectedItemsText() {
    return const Expanded(
      flex: 2,
      child: Center(
        child: Text(
          'No items selected yet',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSelectedItemsList(List<MenuItem> selectedItems) {
    return Expanded(
      flex: 2,
      child: ListView.builder(
        itemCount: selectedItems.length,
        itemBuilder: (context, index) {
          final item = selectedItems[index];
          final orderCubit = BlocProvider.of<OrderCubit>(context);
          final quantity = orderCubit.getQuantityForItem(item);

          return _buildSelectedItemTile(context, item, quantity);
        },
      ),
    );
  }

  Widget _buildSelectedItemTile(
    BuildContext context,
    MenuItem item,
    int quantity,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
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
              '$quantity x',
              style: TextStyle(
                color: AppColors.deepBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(item.name)),
        ],
      ),
    );
  }

  Expanded _buildMenuSection(OrderIdle state, BuildContext context) {
    return Expanded(
      flex: 3,
      child: state.searchQuery.isEmpty
          ? _buildMenuGrid(context, state.filteredMenuItems)
          : _buildSearchResultList(context, state.filteredMenuItems),
    );
  }

  Widget _buildMenuGrid(BuildContext context, List<MenuItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: _getGridDelegate(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
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
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    );
  }

  Widget _buildSearchResultList(BuildContext context, List<MenuItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildSearchResultTile(context, items, index);
      },
    );
  }

  Widget _buildSearchResultTile(
    BuildContext context,
    List<MenuItem> items,
    int index,
  ) {
    final item = items[index];
    return ListTile(
      title: Text(item.name),
      subtitle: Text(item.price.toStringAsFixed(2)),
      trailing: _buildResultTileTrailing(context, item),
      onTap: null,
    );
  }

  Widget _buildResultTileTrailing(BuildContext context, MenuItem item) {
    return item.isAvailable
        ? IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            onPressed: () => context.read<OrderCubit>().onSelectedItem(item),
          )
        : const Text(
            'Not Available',
            style: TextStyle(color: Colors.red),
          );
  }

  _buildNoteField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TxtFormField(
        labelText: 'Special note (modifications...)',
        onChanged: BlocProvider.of<OrderCubit>(context).onNoteChanged,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, OrderIdle state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AppButton(
          text: 'Submit order',
          onPressed: () => showConfirmOrderDialog(context, state)),
    );
  }

  void showConfirmOrderDialog(BuildContext context, OrderIdle state) {
    final cubit = BlocProvider.of<OrderCubit>(context);
    final orderItemsWithQuantity = cubit.getOrderItemQuantity();
    final total = cubit.getTotalPrice();

    showDialog(
        context: context,
        builder: (context) => OrderConfirmDialog(
              orderItemsWithQuantity: orderItemsWithQuantity,
              tableNumber: tableNumber,
              total: total,
              submitOrder: () => cubit.submitOrder(tableNumber),
              note: state.note,
            ));
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
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }

  _getOrderFailureListener(BuildContext context, OrderFailure state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.softRed,
        content: Text("Error: ${state.error} "),
      ),
    );
  }
}
