import 'package:flutter/material.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/models/order_model.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class SplitBillDialog extends StatelessWidget {
  SplitBillDialog({
    required this.orders,
    required this.total,
    this.exchangeRate,
    super.key,
  });

  final List<OrderModel> orders;
  final double total;
  final int? exchangeRate;

  final ValueNotifier<int> splitCount = ValueNotifier<int>(2);
  final TextEditingController customCountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.offWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 360, maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: 8),
              _buildTotalRow(),
              const SizedBox(height: 20),
              _buildSplitLabel(),
              const SizedBox(height: 10),
              _buildSplitCountSelector(context),
              const SizedBox(height: 20),
              _buildBreakdownSection(),
              const SizedBox(height: 24),
              _buildDoneButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Split Bill',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.deepBlue,
      ),
    );
  }

  Row _buildTotalRow() {
    return Row(
      children: [
        Text(
          'Total: ',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        if (exchangeRate != null) ...[
          const SizedBox(width: 8),
          Text(
            '≈ SLSH ${(total * exchangeRate!).toStringAsFixed(0)}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Text _buildSplitLabel() {
    return Text(
      'Split between',
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey,
      ),
    );
  }

  Widget _buildSplitCountSelector(BuildContext context) {
    return Row(
      children: [
        _buildCountButton(2),
        const SizedBox(width: 8),
        _buildCountButton(3),
        const SizedBox(width: 8),
        _buildCountButton(4),
        const SizedBox(width: 8),
        _buildCustomButton(context),
      ],
    );
  }

  Widget _buildCountButton(int count) {
    return ValueListenableBuilder<int>(
      valueListenable: splitCount,
      builder: (context, current, _) {
        final isSelected = current == count;
        return GestureDetector(
          onTap: () => splitCount.value = count,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.deepBlue : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.darkGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCustomDialog(context),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Custom',
            style: TextStyle(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownSection() {
    return ValueListenableBuilder<int>(
      valueListenable: splitCount,
      builder: (context, count, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(count, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Person ${index + 1}',
                      style: TextStyle(color: AppColors.darkGrey)),
                  Text(
                    '\$${_buildAmountPerPerson(total, count)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  String _buildAmountPerPerson(double total, int count) {
    return (total / count).toStringAsFixed(2);
  }

  Align _buildDoneButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AppButton(
        text: 'DONE',
        isSmall: true,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Split'),
        content: TxtFormField(
          controller: customCountController,
          labelText: 'Number of people',
        ),
        actions: [
          AppButton(
            isOutlined: true,
            text: 'Cancel',
            isSmall: true,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          AppButton(
            text: 'OK',
            isSmall: true,
            onPressed: () {
              final n = int.tryParse(customCountController.text);
              if (n != null && n > 1) splitCount.value = n;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
