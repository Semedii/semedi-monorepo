import 'package:flutter/material.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('HELP & SHORTCUTS'),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildKeyboardSection(),
          const SizedBox(height: 16),
          _buildTableColorsSection(),
          const SizedBox(height: 16),
          _buildOrderStatusSection(),
          const SizedBox(height: 16),
          _buildTipsSection(),
        ],
      ),
    );
  }

  Card _buildSection(String title, List<Widget> rows) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.deepBlue.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.deepBlue,
              ),
            ),
          ),
          ...rows
              .expand((row) => [row, const Divider(height: 1)])
              .toList()
            ..removeLast(),
        ],
      ),
    );
  }

  ListTile _buildHelpRow(
      IconData icon, String action, String description) {
    return ListTile(
      leading: Icon(icon, color: AppColors.deepBlue),
      title: Text(action, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description,
          style: TextStyle(color: Colors.grey.shade600)),
    );
  }

  Container _buildShortcutChip(String key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey.shade100,
      ),
      child: Text(
        key,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Card _buildKeyboardSection() {
    return _buildSection('Keyboard Shortcuts', [
      _buildHelpRow(
        Icons.keyboard,
        'F5 / Refresh',
        'Reload all active orders',
      ),
      _buildHelpRow(
        Icons.search,
        'Ctrl+F',
        'Search menu items',
      ),
      _buildHelpRow(
        Icons.add,
        'Ctrl+N',
        'New takeaway order',
      ),
      _buildHelpRow(
        Icons.payment,
        'Ctrl+P',
        'Open payment dialog',
      ),
    ]);
  }

  Card _buildTableColorsSection() {
    return _buildSection('Table Colors', [
      ListTile(
        leading: CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.green,
        ),
        title: const Text('Green Table',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('No active orders — table is vacant',
            style: TextStyle(color: Colors.grey.shade600)),
      ),
      ListTile(
        leading: CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.deepBlue,
        ),
        title: const Text('Blue Table',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Order in progress',
            style: TextStyle(color: Colors.grey.shade600)),
      ),
      ListTile(
        leading: CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.warmOrange,
        ),
        title: const Text('Orange Table',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Payment pending — guest ready to pay',
            style: TextStyle(color: Colors.grey.shade600)),
      ),
    ]);
  }

  Card _buildOrderStatusSection() {
    return _buildSection('Order Statuses', [
      _buildHelpRow(
        Icons.receipt_long,
        'Ordered',
        'Order placed and being prepared in the kitchen',
      ),
      _buildHelpRow(
        Icons.hourglass_bottom,
        'Pay Pending',
        'Guest has requested the bill — payment needed',
      ),
      _buildHelpRow(
        Icons.check_circle_outline,
        'Paid',
        'Payment received — order complete',
      ),
      _buildHelpRow(
        Icons.cancel_outlined,
        'Cancelled',
        'Order was cancelled before completion',
      ),
    ]);
  }

  Card _buildTipsSection() {
    return _buildSection('Tips', [
      _buildHelpRow(
        Icons.touch_app,
        'Long-press a table',
        'Add or clear a note for that table (e.g. VIP, Birthday)',
      ),
      _buildHelpRow(
        Icons.swap_horiz,
        'Set exchange rate',
        'Tap the exchange rate button to update the SLSH rate for today',
      ),
      _buildHelpRow(
        Icons.bar_chart,
        'Quick stats',
        'Tap the chart icon in the app bar for a real-time overview',
      ),
      _buildHelpRow(
        Icons.settings,
        'Management panel',
        'Use the MANAGE button to add menu items, waiters and tables',
      ),
      _buildHelpRow(
        Icons.print,
        'Print receipt',
        'Open any table or order card and tap Print to send to printer',
      ),
    ]);
  }
}
