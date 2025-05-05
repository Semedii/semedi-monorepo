import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/order_confirmation.dialog.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/cubit/login/takeAway/take_order_cubit.dart';
import 'package:semedi_pos/models/menu.dart';
import 'package:semedi_pos/utils/app_colors.dart';
import 'package:semedi_pos/utils/text_validators.dart';

class TakeOrderScreen extends StatelessWidget {
  TakeOrderScreen({this.isDineIn = false, this.tableNumber, super.key});

  final _formKey = GlobalKey<FormState>();
  final bool isDineIn;
  final int? tableNumber;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TakeOrderCubit()..initPage(),
      child: BlocConsumer<TakeOrderCubit, TakeOrderState>(
        listener: (context, state) {
          if (state is TakeOrderStateSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Submited Successfully"),
                backgroundColor: AppColors.green,
              ),
            );
          }
          if (state is TakeOrderStateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.softRed,
              ),
            );
          }
        },
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, TakeOrderState state) {
    if (state is TakeOrderStateInitial) {
      return _buildScreenBody(context, state);
    }
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Scaffold _buildScreenBody(BuildContext context, TakeOrderStateInitial state) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.offWhite),
        backgroundColor: AppColors.deepBlue,
        title: _buildAppBarTitle(),
      ),
      body: Column(
        children: [
          const Divider(),
          Expanded(child: _buildBody(context, state)),
          _buildBottomActions(context, state),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        isDineIn ? 'Table: $tableNumber' : "Take Away Order",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.offWhite,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TakeOrderStateInitial state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!isDineIn) _buildCustomerNameField(context),
              const SizedBox(height: 12),
              _buildSearchField(context),
              const SizedBox(height: 12),
              _buildSelectedItemsSection(context, state),
              const SizedBox(height: 12),
              const Divider(),
              _buildMenuSection(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerNameField(BuildContext context) {
    return TxtFormField(
      labelText: "Customer Name",
      onChanged: context.read<TakeOrderCubit>().onCustomerNameChange,
      validator: TextValidators.fieldRequired,
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TxtFormField(
      labelText: "Search Menu",
      onChanged: context.read<TakeOrderCubit>().onSearchQueryChange,
    );
  }

  Widget _buildSelectedItemsSection(
      BuildContext context, TakeOrderStateInitial state) {
    final selectedItems = state.selectedItems ?? {};
    final cubit = context.read<TakeOrderCubit>();

    if (selectedItems.isEmpty) return const SizedBox();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.deepBlue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selected Items",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView(
              children: selectedItems.entries.map((entry) {
                final item = entry.key;
                final quantity = entry.value;
                return Row(
                  children: [
                    Text('${quantity}x ${item.name}'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => cubit.onRemoveItem(item),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, TakeOrderStateInitial state) {
    final menuItems = state.filteredMenuItems ?? state.menuList ?? [];
    final cubit = context.read<TakeOrderCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Menu",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue,
          ),
        ),
        const SizedBox(height: 8),
        menuItems.isEmpty
            ? const Text("No menu items found.")
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return _buildMenuCard(item, cubit);
                },
              ),
      ],
    );
  }

  Widget _buildMenuCard(MenuItem item, TakeOrderCubit cubit) {
    return GestureDetector(
      onTap: item.isAvailable ? () => cubit.onAddItem(item) : null,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('\$${item.price.toStringAsFixed(2)}'),
              const SizedBox(height: 4),
              item.isAvailable
                  ? Icon(Icons.add_circle, color: AppColors.deepBlue)
                  : const Text('Not Available',
                      style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(
      BuildContext context, TakeOrderStateInitial state) {
    final cubit = context.read<TakeOrderCubit>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Column(
        children: [
          TxtFormField(
            labelText: "Note (optional)",
            onChanged: cubit.onNoteChange,
          ),
          const SizedBox(height: 10),
          AppButton(
            onPressed: () {
              if (!isDineIn) {
                if (_formKey.currentState!.validate() &&
                    state.selectedItems != null) {
                  if (state.selectedItems!.isNotEmpty) {
                    showConfirmOrderDialog(context, state);
                  }
                }
              } else if (state.selectedItems != null &&
                  state.selectedItems!.isNotEmpty) {
                showConfirmOrderDialog(context, state);
              }
            },
            text: "Submit Order",
          ),
        ],
      ),
    );
  }

  void showConfirmOrderDialog(
      BuildContext context, TakeOrderStateInitial state) {
    final cubit = BlocProvider.of<TakeOrderCubit>(context);
    final total = cubit.getTotalPrice();

    showDialog(
        context: context,
        builder: (context) => OrderConfirmDialog(
              selectedItems: state.selectedItems!,
              customerName: state.customerName,
              tableNumber: tableNumber,
              total: total,
              submitOrder: () => cubit.onSubmit(tableNumber),
              note: state.note,
            ));
  }
}
