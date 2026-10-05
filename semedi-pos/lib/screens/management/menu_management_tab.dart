import 'package:flutter/material.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/models/menu.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class MenuManagementTab extends StatelessWidget {
  const MenuManagementTab({
    required this.menuItems,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
    super.key,
  });
  final List<MenuItem> menuItems;
  final Function(MenuItem menu) onDelete;
  final Function(MenuItem menu) onAdd;
  final Function(MenuItem newMenu, MenuItem oldMenu) onEdit;
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
      child: AppButton(
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.add, color: Colors.white),
            Text(
              "ADD NEW MENU",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        onPressed: () => _showAddItemDialog(context),
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
        _buildDeleteIcon(context, menuItems[index]),
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

  Widget _buildDeleteIcon(BuildContext context, MenuItem menu) {
    return IconButton(
        onPressed: () {
          _onDeleteTap(context, menu);
        },
        icon: Icon(
          Icons.delete,
          color: Colors.red.shade400,
        ));
  }

  _onDeleteTap(BuildContext context, MenuItem menu) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              child: Container(
            width: MediaQuery.of(context).size.width * .5,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _buildDeleteDialogTitle(),
              const SizedBox(height: 16),
              _buildDeleteDialogText(),
              const SizedBox(height: 24),
              _buildDeleteDialogButtons(context, menu),
            ]),
          ));
        });
  }

  Text _buildDeleteDialogTitle() {
    return const Text(
      "Confirm Delete",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1e78c1),
      ),
    );
  }

  Text _buildDeleteDialogText() {
    return Text(
      "Are you sure you want to delete this Menu?",
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
      ),
    );
  }

  Row _buildDeleteDialogButtons(BuildContext context, MenuItem menu) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AppButton(
            isOutlined: true,
            text: "Cancel",
            onPressed: () {
              Navigator.pop(context);
            }),
        AppButton(
          text: "Delete",
          onPressed: () {
            onDelete(menu);
            Navigator.pop(context);
          },
        )
      ],
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
          AppButton(
            onPressed: () {
              Navigator.pop(context);
            },
            isOutlined: true,
            text: "Cancel",
          ),
          const SizedBox(width: 24),
          AppButton(
            onPressed: () {
              MenuItem newMenu = MenuItem(
                name: nameController.text,
                price: double.parse(priceController.text),
              );
              onAdd(newMenu);
              Navigator.pop(context);
            },
            text: "Add",
          )
        ],
      ),
    );
  }

  Column _buildAddItemDialog(
    TextEditingController nameController,
    TextEditingController priceController,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TxtFormField(
          controller: nameController,
          labelText: 'Item Name',
        ),
        const SizedBox(height: 16),
        TxtFormField(
          controller: priceController,
          labelText: 'Price',
        ),
      ],
    );
  }

  void _showEditItemDialog(BuildContext context, MenuItem item) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    nameController.text = item.name;
    priceController.text = item.price.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TxtFormField(
              controller: nameController,
              labelText: 'Item Name',
            ),
            const SizedBox(height: 16),
            TxtFormField(
              controller: priceController,
              labelText: 'Price',
            ),
          ],
        ),
        actions: [
          AppButton(
            onPressed: () {
              Navigator.pop(context);
            },
            isOutlined: true,
            text: "Cancel",
          ),
          const SizedBox(width: 24),
          AppButton(
            onPressed: () {
              MenuItem newMenu = MenuItem(
                name: nameController.text,
                price: double.parse(priceController.text),
              );
              onEdit(newMenu, item);
              Navigator.pop(context);
            },
            text: "Edit",
          )
        ],
      ),
    );
  }
}
