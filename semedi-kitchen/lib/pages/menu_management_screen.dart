import 'package:flutter/material.dart';
import 'package:semedi_kitchen/models/menu.dart';
import 'package:semedi_kitchen/utils/app_colors.dart';

class MenuManagementScreen extends StatelessWidget {
  final List<MenuItem> menuItems = [
    MenuItem(name: "Shawarma", price: 9.5, searchKeywords: ["wrap", "chicken"]),
    MenuItem(name: "Pasta Carbonara", price: 12.0, isAvailable: false),
    MenuItem(name: "Margherita Pizza", price: 10.5),
    MenuItem(name: "Caesar Salad", price: 8.0),
    MenuItem(name: "Beef Burger", price: 7.5, isAvailable: false),
  ];

  MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildMenuList(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Manage Menu'),
      centerTitle: true,
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildMenuList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: menuItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _buildMenuItemCard(menuItems[index]),
    );
  }

  Card _buildMenuItemCard(MenuItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildItemInfo(item),
            const Spacer(),
            _buildAvailabilitySwitch(item),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInfo(MenuItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${item.price.toStringAsFixed(2)}',
          style: TextStyle(
            color: AppColors.darkGrey.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySwitch(MenuItem item) {
    return Switch(
      value: item.isAvailable,
      activeColor: AppColors.green,
      inactiveTrackColor: AppColors.softRed.withOpacity(0.5),
      onChanged: (_) {},
    );
  }
}
