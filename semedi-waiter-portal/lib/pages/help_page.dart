import 'package:flutter/material.dart';
import 'package:semedi_waiter_portal/utils/app_colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('HELP'),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTakingOrderSection(),
          const SizedBox(height: 16),
          _buildOrderStatusSection(),
          const SizedBox(height: 16),
          _buildCustomerLookupSection(),
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

  Card _buildTakingOrderSection() {
    return _buildSection('Taking an Order', [
      _buildStep(1, 'Select a table from the home screen — tap the table button'),
      _buildStep(2, 'Browse the menu and tap items to add them to the order'),
      _buildStep(3, 'Tap modifier chips below each item to add customisations'),
      _buildStep(4, 'Use quick note chips or type a custom note if needed'),
      _buildStep(5, 'Tap Submit Order — confirm in the dialog that appears'),
    ]);
  }

  Card _buildOrderStatusSection() {
    return _buildSection('Order Statuses', [
      _buildHelpRow(
        Icons.receipt_long,
        'Ordered',
        'Order submitted and being prepared in the kitchen',
      ),
      _buildHelpRow(
        Icons.hourglass_bottom,
        'Pay Pending',
        'Guest has asked for the bill — take payment at the table',
      ),
      _buildHelpRow(
        Icons.check_circle_outline,
        'Completed',
        'Payment received and order is fully complete',
      ),
    ]);
  }

  Card _buildCustomerLookupSection() {
    return _buildSection('Customer Lookup', [
      _buildHelpRow(
        Icons.phone,
        'Search by phone',
        'Enter the customer\'s phone number to find their profile and loyalty points',
      ),
      _buildHelpRow(
        Icons.person_add,
        'Add new customer',
        'If not found, tap "Add Customer" and enter their name and phone number',
      ),
      _buildHelpRow(
        Icons.star,
        'Loyalty points',
        'Returning customers earn points — their balance is shown on the profile chip',
      ),
    ]);
  }

  Card _buildTipsSection() {
    return _buildSection('Tips', [
      _buildHelpRow(
        Icons.speed,
        'Use quick notes',
        'Tap preset note chips (Extra napkins, No rush, etc.) for common requests',
      ),
      _buildHelpRow(
        Icons.call_split,
        'Split bill',
        'Use the Split button to divide the total evenly between guests',
      ),
      _buildHelpRow(
        Icons.refresh,
        'Refresh orders',
        'Pull down on the order list to reload the latest status from the server',
      ),
      _buildHelpRow(
        Icons.calendar_today,
        'Check reservations',
        'Tap the calendar icon in the top bar to see today\'s bookings',
      ),
    ]);
  }
}
