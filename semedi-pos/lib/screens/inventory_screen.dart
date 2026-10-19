import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/cubit/inventory/inventory_cubit.dart';
import 'package:semedi_pos/models/inventory_item.dart';
import 'package:semedi_pos/service/inventory_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InventoryCubit(InventoryService())..initPage(),
      child: BlocConsumer<InventoryCubit, InventoryState>(
        listener: (context, state) {
          if (state is InventoryFailure) {
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

  Widget _mapStateToWidget(BuildContext context, InventoryState state) {
    if (state is InventoryLoaded) {
      return _buildScreenBody(context, state);
    }
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _buildScreenBody(BuildContext context, InventoryLoaded state) {
    final cubit = BlocProvider.of<InventoryCubit>(context);
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAddItemButton(context),
            const SizedBox(height: 16),
            _buildInventoryList(context, state.items, cubit),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('INVENTORY'),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Align _buildAddItemButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AppButton(
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.add, color: Colors.white),
            Text(
              "ADD ITEM",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  Expanded _buildInventoryList(
      BuildContext context, List<InventoryItem> items, InventoryCubit cubit) {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildInventoryTile(context, items[index], cubit),
      ),
    );
  }

  Card _buildInventoryTile(
      BuildContext context, InventoryItem item, InventoryCubit cubit) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        subtitle: Row(
          children: [
            Text('${item.quantity} ${item.unit}'),
            const SizedBox(width: 8),
            if (item.isLowStock) _buildLowStockChip(),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAdjustButtons(item, cubit),
            IconButton(
              icon: Icon(Icons.edit,
                  color: AppColors.deepBlue.withOpacity(0.7)),
              onPressed: () => _showEditDialog(context, item, cubit),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade400),
              onPressed: () => _showDeleteDialog(context, item, cubit),
            ),
          ],
        ),
      ),
    );
  }

  Row _buildAdjustButtons(InventoryItem item, InventoryCubit cubit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle_outline, color: AppColors.warmOrange),
          onPressed: () => cubit.onAdjustQuantity(item, -1.0),
          tooltip: 'Remove 1',
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline, color: AppColors.green),
          onPressed: () => cubit.onAdjustQuantity(item, 1.0),
          tooltip: 'Add 1',
        ),
      ],
    );
  }

  Container _buildLowStockChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.softRed,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'LOW STOCK',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final cubit = BlocProvider.of<InventoryCubit>(context);
    final nameController = TextEditingController();
    final unitController = TextEditingController();
    final quantityController = TextEditingController();
    final thresholdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Inventory Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TxtFormField(controller: nameController, labelText: 'Item Name'),
            const SizedBox(height: 12),
            TxtFormField(
                controller: unitController, labelText: 'Unit (e.g. kg, pcs)'),
            const SizedBox(height: 12),
            TxtFormField(
                controller: quantityController, labelText: 'Starting Quantity'),
            const SizedBox(height: 12),
            TxtFormField(
                controller: thresholdController,
                labelText: 'Low Stock Threshold'),
          ],
        ),
        actions: [
          AppButton(
            isOutlined: true,
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 24),
          AppButton(
            text: 'Add',
            onPressed: () {
              final item = InventoryItem(
                name: nameController.text,
                unit: unitController.text,
                quantity:
                    double.tryParse(quantityController.text) ?? 0.0,
                lowStockThreshold:
                    double.tryParse(thresholdController.text) ?? 10.0,
              );
              cubit.onAddItem(item);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, InventoryItem item, InventoryCubit cubit) {
    final nameController = TextEditingController(text: item.name);
    final unitController = TextEditingController(text: item.unit);
    final quantityController =
        TextEditingController(text: item.quantity.toString());
    final thresholdController =
        TextEditingController(text: item.lowStockThreshold.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TxtFormField(controller: nameController, labelText: 'Item Name'),
            const SizedBox(height: 12),
            TxtFormField(controller: unitController, labelText: 'Unit'),
            const SizedBox(height: 12),
            TxtFormField(
                controller: quantityController, labelText: 'Quantity'),
            const SizedBox(height: 12),
            TxtFormField(
                controller: thresholdController,
                labelText: 'Low Stock Threshold'),
          ],
        ),
        actions: [
          AppButton(
            isOutlined: true,
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 24),
          AppButton(
            text: 'Save',
            onPressed: () {
              final newItem = InventoryItem(
                name: nameController.text,
                unit: unitController.text,
                quantity:
                    double.tryParse(quantityController.text) ?? item.quantity,
                lowStockThreshold:
                    double.tryParse(thresholdController.text) ??
                        item.lowStockThreshold,
              );
              cubit.onEditItem(newItem, item);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, InventoryItem item, InventoryCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * .5,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Confirm Delete',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e78c1),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Remove ${item.name} from inventory?',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AppButton(
                    isOutlined: true,
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                  AppButton(
                    text: 'Delete',
                    onPressed: () {
                      cubit.onDeleteItem(item);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
