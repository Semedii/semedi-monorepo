import 'package:flutter/material.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class NotificationBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;
  final VoidCallback? onDismiss;

  const NotificationBanner({
    required this.message,
    this.icon = Icons.notifications_active,
    this.color,
    this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bannerColor = color ?? AppColors.deepBlue;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: bannerColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: bannerColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 18, color: bannerColor),
            ),
        ],
      ),
    );
  }
}

class LowStockBanner extends StatelessWidget {
  final int count;

  const LowStockBanner({required this.count, super.key});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return NotificationBanner(
      message: '$count item${count == 1 ? '' : 's'} running low on stock — check inventory.',
      icon: Icons.warning_amber_rounded,
      color: AppColors.warmOrange,
    );
  }
}
