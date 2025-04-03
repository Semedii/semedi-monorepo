import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/menu_item_card.dart';
import 'package:semedi/cubits/order/order_cubit.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/utils/app_colors.dart';

class OrderPage extends StatelessWidget {
  final int tableNumber;
  final List<MenuItem> menuItems;

  const OrderPage({
    required this.tableNumber,
    required this.menuItems,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OrderCubit(tableNumber: tableNumber, menuItems: menuItems),
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: _buildAppBar(),
        body: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            state as OrderInitial;
            return Column(
              children: [
                _buildSearchBar(context),
                _buildSelectedItemsSection(state.selectedItems),
                Divider(thickness: 2, color: AppColors.deepBlue),
                _buildMenuSection(state, context),
                _buildSubmitButton(context)
              ],
            );
          },
        ),
      ),
    );
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
        return _buildSelectedItemTile(context, selectedItems, index);
      },
    ),
  );
}

Widget _buildSelectedItemTile(
  BuildContext context,
  List<MenuItem> selectedItems,
  int index,
) {
  final item = selectedItems[index];
  return ListTile(
    leading: Text('\$${item.price?.toStringAsFixed(2)}'),
    title: Text(item.name),
    trailing: IconButton(
      icon: const Icon(Icons.remove_circle, color: Colors.red),
      onPressed: () => context.read<OrderCubit>().onRemoveItem(index),
    ),
  );
}

Expanded _buildMenuSection(OrderInitial state, BuildContext context) {
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
        onTap: () => BlocProvider.of<OrderCubit>(context).onSelectedItem(item),
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
    subtitle: Text(item.price?.toStringAsFixed(2) ?? ''),
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

Widget _buildSubmitButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: AppButton(
        text: 'Submit order',
        onPressed: () => BlocProvider.of<OrderCubit>(context).submitOrder()),
  );
}
