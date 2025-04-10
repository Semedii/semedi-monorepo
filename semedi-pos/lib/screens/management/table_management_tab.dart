import 'package:flutter/material.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class TableManagementTab extends StatelessWidget {
  const TableManagementTab({required this.totalTableNumber, super.key});
  final int totalTableNumber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildAddTableButton(context),
          const SizedBox(height: 16),
          _buildTablesGrid(),
        ],
      ),
    );
  }

  Widget _buildAddTableButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () => _showAddTableDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('ADD TABLE'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBlue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Expanded _buildTablesGrid() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: totalTableNumber,
        itemBuilder: (context, index) => Card(
          color: AppColors.offWhite,
          child: Center(
            child: Text(
              'Table ${index + 1}',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.deepBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Table'),
        content: const TxtFormField(labelText: 'Table Number'),
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
