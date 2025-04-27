import 'package:flutter/material.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class TableManagementTab extends StatelessWidget {
  const TableManagementTab({
    required this.totalTableNumber,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });
  final int totalTableNumber;
  final Function() onAdd;
  final Function() onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRemoveTableButton(context),
              _buildAddTableButton(context),
            ],
          ),
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
        onPressed: () => _showConfirmDialog(
          context,
          dialogTitle: 'Confirm Add',
          dialogText:
              "Are you sure you want to increase your tables to ${totalTableNumber + 1}?",
          buttonText1: 'Cancel',
          buttonText2: 'Yes',
          onPressed: onAdd,
        ),
      ),
    );
  }

  Widget _buildRemoveTableButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AppButton(
        color: AppColors.softRed,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.remove, color: Colors.white),
            Text(
              "REMOVE TABLE",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        onPressed: () => _showConfirmDialog(
          context,
          dialogTitle: 'Confirm Removal',
          dialogText:
              "Are you sure you want to remove 1 table? You'll have ${totalTableNumber - 1} left.",
          buttonText1: 'Cancel',
          buttonText2: 'Yes',
          onPressed: onRemove,
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

  void _showConfirmDialog(
    BuildContext context, {
    required String dialogTitle,
    required String dialogText,
    required String buttonText1,
    required String buttonText2,
    required Function onPressed,
  }) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
                child: Container(
              width: MediaQuery.of(context).size.width * .5,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _buildDialogTitle(dialogTitle),
                const SizedBox(height: 16),
                _buildDialogText(dialogText),
                const SizedBox(height: 24),
                _buildDialogButtons(
                    context, buttonText1, buttonText2, () => onPressed()),
              ]),
            )));
  }

  Text _buildDialogTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1e78c1),
      ),
    );
  }

  Text _buildDialogText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
      ),
    );
  }

  Row _buildDialogButtons(
    BuildContext context,
    String text1,
    String text2,
    Function() onPressed,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AppButton(
            isOutlined: true,
            text: text1,
            onPressed: () {
              Navigator.pop(context);
            }),
        AppButton(
          text: text2,
          onPressed: () {
            onPressed();
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
