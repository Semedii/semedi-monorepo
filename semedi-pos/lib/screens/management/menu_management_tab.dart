import 'package:flutter/material.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/models/menu.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class MenuManagementTab extends StatelessWidget {
  const MenuManagementTab({required this.menuItems, super.key});
  final List<MenuItem> menuItems;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildAddItemButton(context),
          const SizedBox(height: 16),
          _buildMenuList(menuItems),
        ],
      ),
    );
  }

  Align _buildAddItemButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () => _showAddItemDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('ADD ITEM'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBlue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Expanded _buildMenuList(List<MenuItem> menuItems) {
    return Expanded(
      child: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) => Card(
          color: menuItems[index].isAvailable
              ? Colors.white
              : Colors.grey.shade100,
          child: _buildMenuTile(menuItems, index, context),
        ),
      ),
    );
  }

  ListTile _buildMenuTile(
    List<MenuItem> menuItems,
    int index,
    BuildContext context,
  ) {
    return ListTile(
      title: Text(
        menuItems[index].name,
        style: _buildMenuName(menuItems, index),
      ),
      subtitle: _buildMenuPrice(menuItems, index),
      trailing: _buildMenuTileTrailing(context, menuItems, index),
    );
  }

  TextStyle _buildMenuName(List<MenuItem> menuItems, int index) {
    return TextStyle(
      color: menuItems[index].isAvailable ? AppColors.darkGrey : Colors.grey,
      fontWeight: FontWeight.bold,
    );
  }

  Text _buildMenuPrice(List<MenuItem> menuItems, int index) {
    return Text(
      '\$${menuItems[index].price.toStringAsFixed(2)}',
      style: TextStyle(
        color: menuItems[index].isAvailable ? AppColors.darkGrey : Colors.grey,
      ),
    );
  }

  Row _buildMenuTileTrailing(
      BuildContext context, List<MenuItem> menuItems, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEditButton(context, menuItems, index),
        _buildDisableToggle(menuItems, index),
      ],
    );
  }

  IconButton _buildEditButton(
    BuildContext context,
    List<MenuItem> menuItems,
    int index,
  ) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: AppColors.deepBlue.withOpacity(0.7),
      ),
      onPressed: () => _showEditItemDialog(
        context,
        menuItems[index],
      ),
    );
  }

  Switch _buildDisableToggle(List<MenuItem> menuItems, int index) {
    return Switch(
      value: menuItems[index].isAvailable,
      activeColor: AppColors.green,
      onChanged: (value) {
        debugPrint('Toggled ${menuItems[index].name} to $value');
      },
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Menu Item'),
        content: _buildAddItemDialog(nameController, priceController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepBlue,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  Column _buildAddItemDialog(
    TextEditingController nameController,
    TextEditingController priceController,
  ) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TxtFormField(
          labelText: 'Item Name',
        ),
        SizedBox(height: 16),
        TxtFormField(
          labelText: 'Price',
        ),
      ],
    );
  }

  void _showEditItemDialog(BuildContext context, MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Menu Item'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TxtFormField(
              labelText: 'Item Name',
            ),
            SizedBox(height: 16),
            TxtFormField(
              labelText: 'Price',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warmOrange,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }
}
