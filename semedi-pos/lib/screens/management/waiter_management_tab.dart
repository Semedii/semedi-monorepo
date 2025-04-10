import 'package:flutter/material.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/models/waiter.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class WaiterManagementTab extends StatelessWidget {
  const WaiterManagementTab({required this.waiterList, super.key});

  final List<Waiter> waiterList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildAddWaiterButton(context),
          const SizedBox(height: 16),
          _buildWaitersList(),
        ],
      ),
    );
  }

  Align _buildAddWaiterButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () => _showAddWaiterDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('ADD WAITER'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBlue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Expanded _buildWaitersList() {
    return Expanded(
      child: ListView.builder(
        itemCount: waiterList.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text(waiterList[index].name),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }

  void _showAddWaiterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Waiter'),
        content: const TxtFormField(labelText: 'Waiter Name'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }
}
