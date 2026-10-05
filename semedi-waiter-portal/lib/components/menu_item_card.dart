import 'package:flutter/material.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/utils/app_colors.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.isAvailable ? AppColors.offWhite : Colors.grey[300],
      child: InkWell(
        onTap: item.isAvailable ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildItemName(),
              const SizedBox(height: 4),
              _buildItemPrice(),
              if (!item.isAvailable) _buildNotAvailableText(),
            ],
          ),
        ),
      ),
    );
  }

  Text _buildItemName() {
    return Text(
      item.name,
      style: TextStyle(
        fontSize: 16,
        color: item.isAvailable ? Colors.black : Colors.grey,
      ),
      textAlign: TextAlign.center,
    );
  }

  Text _buildNotAvailableText() {
    return const Text(
      'Not Available',
      style: TextStyle(
        color: Colors.red,
        fontSize: 12,
      ),
    );
  }

  Text _buildItemPrice() {
    return Text(
      item.price.toStringAsFixed(2),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: item.isAvailable ? Colors.green : Colors.grey,
      ),
    );
  }
}
