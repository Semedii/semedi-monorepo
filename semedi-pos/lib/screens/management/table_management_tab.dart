import 'package:flutter/material.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class TableManagementTab extends StatelessWidget {
  const TableManagementTab({
    required this.totalTableNumber,
    required this.onAdd,
    super.key,
  });
  final int totalTableNumber;
  final Function() onAdd;

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
      child: AppButton(
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.add, color: Colors.white),
            Text(
              "ADD NEW TABLE",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        onPressed: () => _showAddTableDialog(context),
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
        builder: (context) => Dialog(
                child: Container(
              width: MediaQuery.of(context).size.width * .5,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _buildAddDialogTitle(),
                const SizedBox(height: 16),
                _buildAddDialogText(),
                const SizedBox(height: 24),
                _buildAddDialogButtons(context),
              ]),
            )));
  }

  Text _buildAddDialogTitle() {
    return const Text(
      "Confirm Add",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1e78c1),
      ),
    );
  }

  Text _buildAddDialogText() {
    return Text(
      "Are you sure you want to increase your tables to ${totalTableNumber + 1}?",
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
      ),
    );
  }

  Row _buildAddDialogButtons(BuildContext context) {
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
          text: "Yes",
          onPressed: () {
            onAdd();
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
