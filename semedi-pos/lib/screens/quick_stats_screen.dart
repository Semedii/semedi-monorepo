import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/cubit/order/order_cubit.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class QuickStatsScreen extends StatelessWidget {
  const QuickStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderCubit>().state;
    if (state is! OrderLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _buildScreenBody(context, state);
  }

  Scaffold _buildScreenBody(BuildContext context, OrderLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection("Today's Overview", [
            _buildStatRow('Active Orders', state.activeOrders?.length ?? 0,
                Icons.receipt_long, AppColors.deepBlue),
            _buildStatRow(
                'Paid Orders',
                state.paidOrders?.length ?? 0,
                Icons.check_circle_outline,
                AppColors.green),
            _buildStatRow(
                'Unpaid Orders',
                state.unPaidOrders?.length ?? 0,
                Icons.pending_actions,
                AppColors.warmOrange),
            _buildStatRow('Low Stock Items', state.lowStockCount,
                Icons.warning_amber_rounded, Colors.red),
          ]),
          _buildSection('Tables', [
            _buildStatRow('Total Tables', state.tableNumbers,
                Icons.table_restaurant, AppColors.deepBlue),
            _buildStatRow(
                'Tables With Notes',
                state.tableNotes.length,
                Icons.sticky_note_2_outlined,
                Colors.amber.shade700),
          ]),
          _buildSection('Top Items', [
            _buildPlaceholderTile('Top items will appear here once orders accumulate.'),
          ]),
          _buildSection('Exchange Rate', [
            _buildExchangeRateTile(state.exchangeRate),
          ]),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('QUICK STATS'),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Column _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue,
            ),
          ),
        ),
        const Divider(height: 1),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatRow(
      String label, int value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderTile(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildExchangeRateTile(int? rate) {
    return ListTile(
      leading: Icon(Icons.currency_exchange, color: AppColors.deepBlue),
      title: const Text('1 USD ='),
      trailing: Text(
        rate != null ? 'SLSH $rate' : 'Not set',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: rate != null ? AppColors.deepBlue : Colors.grey,
          fontSize: 15,
        ),
      ),
    );
  }
}
