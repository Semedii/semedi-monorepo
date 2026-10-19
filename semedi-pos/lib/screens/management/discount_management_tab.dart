import 'package:flutter/material.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/models/discount.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class DiscountManagementTab extends StatelessWidget {
  const DiscountManagementTab({
    required this.discounts,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
    super.key,
  });

  final List<Discount> discounts;
  final Function(Discount discount) onDelete;
  final Function(Discount discount) onAdd;
  final Function(Discount newDiscount, Discount oldDiscount) onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildAddItemButton(context),
          const SizedBox(height: 16),
          _buildDiscountList(discounts),
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
              "ADD DISCOUNT",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        onPressed: () => _showAddDiscountDialog(context),
      ),
    );
  }

  Expanded _buildDiscountList(List<Discount> discounts) {
    return Expanded(
      child: ListView.builder(
        itemCount: discounts.length,
        itemBuilder: (context, index) => Card(
          color: discounts[index].isActive ? Colors.white : Colors.grey.shade100,
          child: _buildDiscountTile(discounts, index, context),
        ),
      ),
    );
  }

  ListTile _buildDiscountTile(
    List<Discount> discounts,
    int index,
    BuildContext context,
  ) {
    return ListTile(
      title: Text(
        discounts[index].name,
        style: _buildDiscountName(discounts, index),
      ),
      subtitle: _buildDiscountPercentage(discounts, index),
      trailing: _buildDiscountTileTrailing(context, discounts, index),
    );
  }

  TextStyle _buildDiscountName(List<Discount> discounts, int index) {
    return TextStyle(
      color: discounts[index].isActive ? AppColors.darkGrey : Colors.grey,
      fontWeight: FontWeight.bold,
    );
  }

  Text _buildDiscountPercentage(List<Discount> discounts, int index) {
    return Text(
      '${discounts[index].percentage.toStringAsFixed(0)}% off',
      style: TextStyle(
        color: discounts[index].isActive ? AppColors.green : Colors.grey,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Row _buildDiscountTileTrailing(
      BuildContext context, List<Discount> discounts, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEditButton(context, discounts, index),
        _buildDeleteIcon(context, discounts[index]),
      ],
    );
  }

  IconButton _buildEditButton(
    BuildContext context,
    List<Discount> discounts,
    int index,
  ) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: AppColors.deepBlue.withOpacity(0.7),
      ),
      onPressed: () => _showEditDiscountDialog(context, discounts[index]),
    );
  }

  Widget _buildDeleteIcon(BuildContext context, Discount discount) {
    return IconButton(
        onPressed: () {
          _onDeleteTap(context, discount);
        },
        icon: Icon(
          Icons.delete,
          color: Colors.red.shade400,
        ));
  }

  _onDeleteTap(BuildContext context, Discount discount) {
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
              _buildDeleteDialogButtons(context, discount),
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
      "Are you sure you want to delete this Discount?",
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
      ),
    );
  }

  Row _buildDeleteDialogButtons(BuildContext context, Discount discount) {
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
            onDelete(discount);
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  void _showAddDiscountDialog(BuildContext context) {
    final nameController = TextEditingController();
    final percentageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Discount'),
        content: _buildDiscountDialog(nameController, percentageController),
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
              Discount newDiscount = Discount(
                name: nameController.text,
                percentage: double.parse(percentageController.text),
              );
              onAdd(newDiscount);
              Navigator.pop(context);
            },
            text: "Add",
          )
        ],
      ),
    );
  }

  Column _buildDiscountDialog(
    TextEditingController nameController,
    TextEditingController percentageController,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TxtFormField(
          controller: nameController,
          labelText: 'Discount Name',
        ),
        const SizedBox(height: 16),
        TxtFormField(
          controller: percentageController,
          labelText: 'Percentage (e.g. 10)',
        ),
      ],
    );
  }

  void _showEditDiscountDialog(BuildContext context, Discount discount) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController percentageController = TextEditingController();
    nameController.text = discount.name;
    percentageController.text = discount.percentage.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${discount.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TxtFormField(
              controller: nameController,
              labelText: 'Discount Name',
            ),
            const SizedBox(height: 16),
            TxtFormField(
              controller: percentageController,
              labelText: 'Percentage',
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
              Discount newDiscount = Discount(
                name: nameController.text,
                percentage: double.parse(percentageController.text),
              );
              onEdit(newDiscount, discount);
              Navigator.pop(context);
            },
            text: "Edit",
          )
        ],
      ),
    );
  }
}
