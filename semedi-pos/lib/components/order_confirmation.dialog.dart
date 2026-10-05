import 'package:flutter/material.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/models/menu.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class OrderConfirmDialog extends StatelessWidget {
  const OrderConfirmDialog({
    required this.selectedItems,
    this.customerName,
    this.tableNumber,
    required this.total,
    required this.submitOrder,
    this.note,
    super.key,
  });

  final Map<MenuItem, int> selectedItems;
  final String? customerName;
  final int? tableNumber;
  final double total;
  final String? note;
  final Function() submitOrder;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const Divider(height: 24),
                _buildTableInfo(),
                const SizedBox(height: 16),
                _buildOrderItemList(),
                if (note?.isNotEmpty ?? false) _buildSpecialNote(),
                const Divider(height: 24),
                _buildTotalPrice(),
                const SizedBox(height: 24),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Confirm Order',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Container _buildTableInfo() {
    String orderInfo =
        tableNumber == null ? 'Order for $customerName' : 'Table: $tableNumber';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.deepBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        orderInfo,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.deepBlue,
        ),
      ),
    );
  }

  Widget _buildOrderItemList() {
    return Column(
      children: selectedItems.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.deepBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${entry.value}x',
                  style: TextStyle(
                    color: AppColors.deepBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(entry.key.name)),
              Text(
                '\$${(entry.key.price * entry.value).toStringAsFixed(2)}',
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpecialNote() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Special Requests:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 100),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Text(note!),
            ),
          ),
        ],
      ),
    );
  }

  Row _buildTotalPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue,
          ),
        ),
      ],
    );
  }

  Row _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildEditButton(context),
        const SizedBox(width: 16),
        _buildConfirmButton(context),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Expanded(
      child: AppButton(
        isOutlined: true,
        onPressed: () => Navigator.pop(context),
        text: 'EDIT',
      ),
    );
  }

  Expanded _buildConfirmButton(BuildContext context) {
    return Expanded(
      child: AppButton(
        text: 'CONFIRM',
        onPressed: () {
          Navigator.pop(context);
          submitOrder();
        },
      ),
    );
  }
}
