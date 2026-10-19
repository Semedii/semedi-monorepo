import 'package:flutter/material.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/models/menu_modifier.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class ModifierManagementTab extends StatelessWidget {
  const ModifierManagementTab({
    required this.modifiers,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
    super.key,
  });

  final List<MenuModifier> modifiers;
  final Function(MenuModifier modifier) onDelete;
  final Function(MenuModifier modifier) onAdd;
  final Function(MenuModifier newModifier, MenuModifier oldModifier) onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildAddItemButton(context),
          const SizedBox(height: 16),
          _buildModifierList(modifiers),
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
              "ADD MODIFIER",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        onPressed: () => _showAddModifierDialog(context),
      ),
    );
  }

  Expanded _buildModifierList(List<MenuModifier> modifiers) {
    return Expanded(
      child: ListView.builder(
        itemCount: modifiers.length,
        itemBuilder: (context, index) => Card(
          color: modifiers[index].isAvailable
              ? Colors.white
              : Colors.grey.shade100,
          child: _buildModifierTile(modifiers, index, context),
        ),
      ),
    );
  }

  ListTile _buildModifierTile(
    List<MenuModifier> modifiers,
    int index,
    BuildContext context,
  ) {
    return ListTile(
      title: Text(
        modifiers[index].name,
        style: _buildModifierName(modifiers, index),
      ),
      subtitle: _buildModifierCharge(modifiers, index),
      trailing: _buildModifierTileTrailing(context, modifiers, index),
    );
  }

  TextStyle _buildModifierName(List<MenuModifier> modifiers, int index) {
    return TextStyle(
      color: modifiers[index].isAvailable ? AppColors.darkGrey : Colors.grey,
      fontWeight: FontWeight.bold,
    );
  }

  Text _buildModifierCharge(List<MenuModifier> modifiers, int index) {
    final charge = modifiers[index].extraCharge;
    return Text(
      charge > 0 ? '+\$${charge.toStringAsFixed(2)}' : 'No extra charge',
      style: TextStyle(
        color: modifiers[index].isAvailable ? AppColors.darkGrey : Colors.grey,
      ),
    );
  }

  Row _buildModifierTileTrailing(
      BuildContext context, List<MenuModifier> modifiers, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEditButton(context, modifiers, index),
        _buildDeleteIcon(context, modifiers[index]),
      ],
    );
  }

  IconButton _buildEditButton(
    BuildContext context,
    List<MenuModifier> modifiers,
    int index,
  ) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: AppColors.deepBlue.withOpacity(0.7),
      ),
      onPressed: () => _showEditModifierDialog(context, modifiers[index]),
    );
  }

  Widget _buildDeleteIcon(BuildContext context, MenuModifier modifier) {
    return IconButton(
        onPressed: () {
          _onDeleteTap(context, modifier);
        },
        icon: Icon(
          Icons.delete,
          color: Colors.red.shade400,
        ));
  }

  _onDeleteTap(BuildContext context, MenuModifier modifier) {
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
              _buildDeleteDialogButtons(context, modifier),
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
      "Are you sure you want to delete this Modifier?",
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
      ),
    );
  }

  Row _buildDeleteDialogButtons(BuildContext context, MenuModifier modifier) {
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
            onDelete(modifier);
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  void _showAddModifierDialog(BuildContext context) {
    final nameController = TextEditingController();
    final chargeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Modifier'),
        content: _buildModifierDialog(nameController, chargeController),
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
              MenuModifier newModifier = MenuModifier(
                name: nameController.text,
                extraCharge: chargeController.text.isEmpty
                    ? 0.0
                    : double.parse(chargeController.text),
              );
              onAdd(newModifier);
              Navigator.pop(context);
            },
            text: "Add",
          )
        ],
      ),
    );
  }

  Column _buildModifierDialog(
    TextEditingController nameController,
    TextEditingController chargeController,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TxtFormField(
          controller: nameController,
          labelText: 'Modifier Name',
        ),
        const SizedBox(height: 16),
        TxtFormField(
          controller: chargeController,
          labelText: 'Extra Charge (optional)',
        ),
      ],
    );
  }

  void _showEditModifierDialog(BuildContext context, MenuModifier modifier) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController chargeController = TextEditingController();
    nameController.text = modifier.name;
    chargeController.text =
        modifier.extraCharge > 0 ? modifier.extraCharge.toString() : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${modifier.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TxtFormField(
              controller: nameController,
              labelText: 'Modifier Name',
            ),
            const SizedBox(height: 16),
            TxtFormField(
              controller: chargeController,
              labelText: 'Extra Charge',
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
              MenuModifier newModifier = MenuModifier(
                name: nameController.text,
                extraCharge: chargeController.text.isEmpty
                    ? 0.0
                    : double.parse(chargeController.text),
              );
              onEdit(newModifier, modifier);
              Navigator.pop(context);
            },
            text: "Edit",
          )
        ],
      ),
    );
  }
}
