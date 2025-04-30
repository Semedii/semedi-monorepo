import 'package:flutter/material.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class SalesHistoryListScreen extends StatelessWidget {
  const SalesHistoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 12,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _buildDayCard();
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: IconThemeData(color: AppColors.offWhite),
      backgroundColor: AppColors.deepBlue,
      title: Text(
        "Sales History",
        style: TextStyle(
          color: AppColors.offWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Card _buildDayCard() {
    return Card(
      elevation: 0,
      color: AppColors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // Handle tap to view details
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayData(),
              _buildTrailingIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildDayData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDate(),
        const SizedBox(height: 4),
        _buildOrderData(),
      ],
    );
  }

  Text _buildDate() {
    return Text(
      '30-04-2025',
      style: TextStyle(
        color: AppColors.offWhite,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Text _buildOrderData() {
    return Text(
      '14 Orders • \$1,240.50',
      style: TextStyle(
        color: AppColors.offWhite.withOpacity(0.8),
      ),
    );
  }

  Icon _buildTrailingIcon() {
    return Icon(
      Icons.chevron_right,
      color: AppColors.offWhite.withOpacity(0.6),
    );
  }
}
