import 'package:flutter/material.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/models/customer.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class LoyaltyPointsDialog extends StatelessWidget {
  LoyaltyPointsDialog({
    required this.customer,
    required this.onAdd,
    super.key,
  });

  final Customer customer;
  final Function(int points) onAdd;

  final TextEditingController pointsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.offWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320, maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: 8),
              _buildCustomerInfo(),
              const SizedBox(height: 20),
              _buildPointsField(),
              const SizedBox(height: 24),
              _buildFooterButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Add Loyalty Points',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.deepBlue,
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.deepBlue,
          radius: 18,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            Text(
              'Current: ${customer.loyaltyPoints} pts',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPointsField() {
    return TxtFormField(
      controller: pointsController,
      labelText: 'Points to add',
    );
  }

  Row _buildFooterButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppButton(
          isOutlined: true,
          text: 'Cancel',
          isSmall: true,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        AppButton(
          text: 'ADD',
          isSmall: true,
          color: AppColors.green,
          onPressed: () {
            final pts = int.tryParse(pointsController.text) ?? 0;
            if (pts > 0) {
              onAdd(pts);
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
