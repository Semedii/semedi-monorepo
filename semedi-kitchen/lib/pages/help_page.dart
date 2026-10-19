import 'package:flutter/material.dart';
import 'package:semedi_kitchen/utils/app_colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('KITCHEN GUIDE'),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPriorityColorsSection(),
          const SizedBox(height: 16),
          _buildOrderActionsSection(),
          const SizedBox(height: 16),
          _buildFiltersSection(),
          const SizedBox(height: 16),
          _buildStatsPanelSection(),
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
      IconData icon, String action, String description, {Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.deepBlue),
      title: Text(action, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description,
          style: TextStyle(color: Colors.grey.shade600)),
    );
  }

  Padding _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.deepBlue,
            child: Text(
              '$number',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text,
                  style: const TextStyle(fontSize: 14, height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }

  Card _buildPriorityColorsSection() {
    return _buildSection('Order Priority Colors', [
      ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: const Text('Green timer badge',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Under 8 minutes — normal priority',
            style: TextStyle(color: Colors.grey.shade600)),
      ),
      ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.warmOrange,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: const Text('Orange timer badge',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('8–15 minutes — getting late, prioritise this order',
            style: TextStyle(color: Colors.grey.shade600)),
      ),
      ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.softRed,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: const Text('Red timer badge',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('15+ minutes — urgent, prepare immediately',
            style: TextStyle(color: Colors.grey.shade600)),
      ),
    ]);
  }

  Card _buildOrderActionsSection() {
    return _buildSection('Order Actions', [
      _buildHelpRow(
        Icons.check_circle_outline,
        'Mark Done',
        'Tap the Mark Done button on an order card once it is ready to serve',
      ),
      _buildHelpRow(
        Icons.tune,
        'Viewing modifiers',
        'Modifier text (e.g. "+ extra spicy, no onion") appears in italic grey below each item',
      ),
      _buildHelpRow(
        Icons.print,
        'Print order ticket',
        'Tap the print icon on any order card to send to the receipt printer',
      ),
    ]);
  }

  Card _buildFiltersSection() {
    return _buildSection('Filters', [
      _buildHelpRow(
        Icons.filter_list,
        'All',
        'Shows every active order regardless of status',
      ),
      _buildHelpRow(
        Icons.fiber_new,
        'New',
        'Shows only freshly placed orders that have not been started yet',
      ),
      _buildHelpRow(
        Icons.pending_actions,
        'In Progress',
        'Shows orders that are currently being prepared',
      ),
    ]);
  }

  Card _buildStatsPanelSection() {
    return _buildSection('Stats Panel', [
      _buildHelpRow(
        Icons.receipt_long,
        'Active Orders',
        'Total number of orders currently waiting or being prepared',
      ),
      _buildHelpRow(
        Icons.timer_outlined,
        'Avg Wait',
        'Average time in minutes across all active orders since they were placed',
      ),
      _buildHelpRow(
        Icons.warning_amber_rounded,
        'Urgent',
        'Count of orders that have been waiting 15 minutes or more',
        iconColor: AppColors.softRed,
      ),
    ]);
  }
}
