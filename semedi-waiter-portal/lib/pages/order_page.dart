import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/menu_item_card.dart';
import 'package:semedi/components/order_confirm_dialog.dart';
import 'package:semedi/components/txt_form_field.dart';
import 'package:semedi/cubits/order/order_cubit.dart';
import 'package:semedi/models/dining_tables.dart';
import 'package:semedi/models/order_item.dart';
import 'package:semedi/pages/home_page.dart';
import 'package:semedi/utils/app_colors.dart';

class OrderPage extends StatelessWidget {
  final DiningTables table;

  const OrderPage({
    required this.table,
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
        "Table ${table.tableNumber} - Order",
      ),
      centerTitle: true,
      backgroundColor: AppColors.offWhite,
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
                          state.orderItems,
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSubmitButton(context, state),
        ],
      ),
    );
  }

  Padding _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchBar(
        backgroundColor:
            WidgetStateProperty.all(AppColors.offWhite.withValues(alpha: 0.8)),
        hintText: 'Search menu items...',
        onChanged: context.read<OrderCubit>().updateSearchQuery,
        leading: const Icon(Icons.search),
        elevation: const WidgetStatePropertyAll(2),
      ),
    );
  }

  Widget _buildSelectedItemsSection(
      BuildContext context, List<OrderItem> selectedItems) {
    return selectedItems.isEmpty
        ? _buildNoSelectedItemsText()
        : _buildSelectedItemsList(context, selectedItems);
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

  Widget _buildSelectedItemsList(
      BuildContext context, List<OrderItem> selectedItems) {
    final orderCubit = BlocProvider.of<OrderCubit>(context);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: selectedItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = selectedItems[index];
        final noteController = TextEditingController();
        noteController.text = item.note ?? '';
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 2,
            ),
          ),
          child: ExpansionTile(
            title: Row(
              children: [
                Expanded(
                    child: Text(
                  item.itemName ?? '',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                )),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.deepBlue.withValues(alpha: 0.2),
                        width: 1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => orderCubit.onDecrementItem(index),
                        child: Icon(Icons.remove, color: AppColors.deepBlue),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Qty: '),
                      Text(
                        '${item.itemQuantity}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () => orderCubit.onIncrementItem(index),
                        child: Icon(Icons.add, color: AppColors.deepBlue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: item.note != null ? Text(item.note!) : null,
            children: [
              TxtFormField(
                controller: noteController,
                labelText: 'Add note',
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.deepBlue.withValues(alpha: 0.15),
                  ),
                  child: IconButton(
                    onPressed: () {
                      orderCubit.onNoteChanged(noteController.text, index);
                    },
                    icon: const Icon(Icons.check_rounded),
                  ),
                ),
              ),
            ],
          ),
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
        table: table,
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
