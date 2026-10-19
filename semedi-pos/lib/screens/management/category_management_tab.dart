import 'package:flutter/material.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/models/menu_category.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class CategoryManagementTab extends StatelessWidget {
  const CategoryManagementTab({
    required this.categories,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
    super.key,
  });

  final List<MenuCategory> categories;
  final Function(MenuCategory category) onDelete;
  final Function(MenuCategory category) onAdd;
  final Function(MenuCategory newCategory, MenuCategory oldCategory) onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildAddItemButton(context),
          const SizedBox(height: 16),
          _buildCategoryList(categories),
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
              "ADD CATEGORY",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        onPressed: () => _showAddCategoryDialog(context),
      ),
    );
  }

  Expanded _buildCategoryList(List<MenuCategory> categories) {
    return Expanded(
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) => Card(
          color: Colors.white,
          child: _buildCategoryTile(categories, index, context),
        ),
      ),
    );
  }

  ListTile _buildCategoryTile(
    List<MenuCategory> categories,
    int index,
    BuildContext context,
  ) {
    return ListTile(
      leading: Icon(Icons.category, color: AppColors.deepBlue),
      title: Text(
        categories[index].name,
        style: _buildCategoryName(),
      ),
      subtitle: _buildSortOrder(categories, index),
      trailing: _buildCategoryTileTrailing(context, categories, index),
    );
  }

  TextStyle _buildCategoryName() {
    return TextStyle(
      color: AppColors.darkGrey,
      fontWeight: FontWeight.bold,
    );
  }

  Text _buildSortOrder(List<MenuCategory> categories, int index) {
    return Text(
      'Sort order: ${categories[index].sortOrder}',
      style: TextStyle(color: AppColors.darkGrey),
    );
  }

  Row _buildCategoryTileTrailing(
      BuildContext context, List<MenuCategory> categories, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEditButton(context, categories, index),
        _buildDeleteIcon(context, categories[index]),
      ],
    );
  }

  IconButton _buildEditButton(
    BuildContext context,
    List<MenuCategory> categories,
    int index,
  ) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: AppColors.deepBlue.withOpacity(0.7),
      ),
      onPressed: () => _showEditCategoryDialog(context, categories[index]),
    );
  }

  Widget _buildDeleteIcon(BuildContext context, MenuCategory category) {
    return IconButton(
        onPressed: () {
          _onDeleteTap(context, category);
        },
        icon: Icon(
          Icons.delete,
          color: Colors.red.shade400,
        ));
  }

  _onDeleteTap(BuildContext context, MenuCategory category) {
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
              _buildDeleteDialogButtons(context, category),
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
      "Are you sure you want to delete this Category?",
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
      ),
    );
  }

  Row _buildDeleteDialogButtons(BuildContext context, MenuCategory category) {
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
            onDelete(category);
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final sortOrderController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: _buildCategoryDialog(nameController, sortOrderController),
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
              MenuCategory newCategory = MenuCategory(
                name: nameController.text,
                sortOrder: sortOrderController.text.isEmpty
                    ? 0
                    : int.parse(sortOrderController.text),
              );
              onAdd(newCategory);
              Navigator.pop(context);
            },
            text: "Add",
          )
        ],
      ),
    );
  }

  Column _buildCategoryDialog(
    TextEditingController nameController,
    TextEditingController sortOrderController,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TxtFormField(
          controller: nameController,
          labelText: 'Category Name',
        ),
        const SizedBox(height: 16),
        TxtFormField(
          controller: sortOrderController,
          labelText: 'Sort Order (optional)',
        ),
      ],
    );
  }

  void _showEditCategoryDialog(BuildContext context, MenuCategory category) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController sortOrderController = TextEditingController();
    nameController.text = category.name;
    sortOrderController.text = category.sortOrder.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${category.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TxtFormField(
              controller: nameController,
              labelText: 'Category Name',
            ),
            const SizedBox(height: 16),
            TxtFormField(
              controller: sortOrderController,
              labelText: 'Sort Order',
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
              MenuCategory newCategory = MenuCategory(
                name: nameController.text,
                sortOrder: sortOrderController.text.isEmpty
                    ? 0
                    : int.parse(sortOrderController.text),
              );
              onEdit(newCategory, category);
              Navigator.pop(context);
            },
            text: "Edit",
          )
        ],
      ),
    );
  }
}
