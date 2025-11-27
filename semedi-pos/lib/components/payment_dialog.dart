import 'package:flutter/material.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/models/order_model.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class PaymentDialog extends StatelessWidget {
  PaymentDialog({required this.order, super.key});

  final OrderModel order;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  String selectedPaymentMethod = 'Cash';

  final List<String> paymentMethods = [
    'Cash',
    'Zaad',
    'Edahab',
    'Premier Wallet',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    amountController.text = order.totalPrice.toString();
    return Dialog(
      backgroundColor: AppColors.offWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 360, // desktop friendly width
          maxWidth: 480,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(),
              const SizedBox(height: 24),
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildPaymentMethodDropdown(),
              const SizedBox(height: 16),
              _buildRemarksField(),
              const SizedBox(height: 28),
              _buildFooterButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Confirm Payment',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.deepBlue,
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TxtFormField(
      controller: amountController,
      labelText: 'Amount',
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: AppColors.offWhite,
      value: selectedPaymentMethod,
      items: paymentMethods
          .map((method) => DropdownMenuItem(
                value: method,
                child: Text(method),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) selectedPaymentMethod = value;
      },
      decoration: InputDecoration(
        labelText: 'Payment Method',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildRemarksField() {
    return TxtFormField(
      controller: remarksController,
      labelText: 'Remarks (optional)',
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppButton(
          isOutlined: true,
          text: 'Cancel',
          isSmall: true,
          color: AppColors.softRed,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        AppButton(
          text: 'Confirm',
          isSmall: true,
          color: AppColors.green,
          onPressed: () {
            final amount = amountController.text.trim();
            final remarks = remarksController.text.trim().isEmpty
                ? null
                : remarksController.text.trim();

            if (amount.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter an amount')),
              );
              return;
            }

            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
