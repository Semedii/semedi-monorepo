import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/components/menu_item_card.dart';
import 'package:semedi/cubits/order/order_cubit.dart';
import 'package:semedi/models/menu.dart';

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
        appBar: AppBar(
          title: Text("Table $tableNumber - Order"),
          centerTitle: true,
        ),
        body: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            state as OrderInitial;
            return Column(
              children: [
                _buildSearchBar(context),
                _buildSelectedItemList(state.selectedItems),
                const Divider(thickness: 2),
                _buildMenuResult(state, context),
                _buildSubmitButton(context)
              ],
            );
          },
        ),
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
}

Widget _buildSelectedItemList(List<MenuItem> selectedItems) {
  if (selectedItems.isEmpty) {
    return const Expanded(
      flex: 2,
      child: Center(
        child:
            Text('No items selected yet', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
  return Expanded(
    flex: 2,
    child: ListView.builder(
      itemCount: selectedItems.length,
      itemBuilder: (context, index) {
        final item = selectedItems[index];
        return ListTile(
          leading: Text('\$${item.price?.toStringAsFixed(2)}'),
          title: Text(item.name),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => context.read<OrderCubit>().onRemoveItem(index),
          ),
        );
      },
    ),
  );
}

Expanded _buildMenuResult(OrderInitial state, BuildContext context) {
  return Expanded(
    flex: 3,
    child: state.searchQuery.isEmpty
        ? _buildMenuGrid(
            state.filteredMenuItems,
            (item) {
              if (item.isAvailable) {
                context.read<OrderCubit>().onSelectedItem(item);
              }
            },
          )
        : _buildSearchResult(
            state.filteredMenuItems,
            (item) {
              if (item.isAvailable) {
                context.read<OrderCubit>().onSelectedItem(item);
              }
            },
          ),
  );
}

_buildMenuGrid(List<MenuItem> items, Function(MenuItem) onItemSelected) {
  if (items.isEmpty) {
    return const Center(
      child:
          Text('No menu items available', style: TextStyle(color: Colors.grey)),
    );
  }
  return GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return MenuItemCard(
        item: item,
        onTap: () => onItemSelected(item),
      );
    },
  );
}

_buildSearchResult(List<MenuItem> items, Function(MenuItem) onItemSelected) {
  if (items.isEmpty) {
    return const Center(
      child:
          Text('No matching items found', style: TextStyle(color: Colors.grey)),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return ListTile(
        title: Text(item.name),
        subtitle: Text('\$${item.price?.toStringAsFixed(2)}'),
        trailing: item.isAvailable
            ? IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: () => onItemSelected(item),
              )
            : const Text('Not Available', style: TextStyle(color: Colors.red)),
        onTap: item.isAvailable ? () => onItemSelected(item) : null,
      );
    },
  );
}

_buildSubmitButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ElevatedButton(
      onPressed: () => BlocProvider.of<OrderCubit>(context).submitOrder(),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Submit Order'),
    ),
  );
}
