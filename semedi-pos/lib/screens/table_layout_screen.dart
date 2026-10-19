import 'package:flutter/material.dart';
import 'package:semedi_pos/cubit/order/order_cubit.dart';
import 'package:semedi_pos/screens/table_order_screen.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class TableLayoutScreen extends StatelessWidget {
  const TableLayoutScreen({
    required this.state,
    required this.cubit,
    super.key,
  });

  final OrderLoaded state;
  final OrderCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('TABLE LAYOUT'),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildLegend(),
          const Divider(height: 1),
          Expanded(child: _buildLayoutGrid(context)),
        ],
      ),
    );
  }

  Padding _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          _buildLegendItem(AppColors.green, 'Vacant'),
          const SizedBox(width: 24),
          _buildLegendItem(AppColors.deepBlue, 'Occupied'),
          const SizedBox(width: 24),
          _buildLegendItem(AppColors.warmOrange, 'Pay Pending'),
        ],
      ),
    );
  }

  Row _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 8, backgroundColor: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Padding _buildLayoutGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: state.tableNumbers,
        itemBuilder: (context, index) {
          final tableNumber = index + 1;
          return _buildTableCell(context, tableNumber);
        },
      ),
    );
  }

  GestureDetector _buildTableCell(BuildContext context, int tableNumber) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TableOrderScreen(
              tableNumber: tableNumber,
              exchangeRate: state.exchangeRate,
              orderCubit: cubit,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: _getTableBoxDecoration(tableNumber),
            child: _buildTableCellContent(tableNumber),
          ),
          if (cubit.isTablePayPending(tableNumber))
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.softRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Center _buildTableCellContent(int tableNumber) {
    final isVacant = cubit.isTableVacant(tableNumber);
    final waiterName = _getWaiterName(tableNumber);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Table $tableNumber',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (!isVacant && waiterName != null)
            Text(
              waiterName.length > 8
                  ? '${waiterName.substring(0, 8)}...'
                  : waiterName,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  String? _getWaiterName(int tableNumber) {
    final orders = state.activeOrders
        ?.where((o) => o.tableNumber == tableNumber)
        .toList();
    if (orders == null || orders.isEmpty) return null;
    return orders.first.waiterName;
  }

  BoxDecoration _getTableBoxDecoration(int tableNumber) {
    return BoxDecoration(
      color: _getTableColor(tableNumber),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(2, 3),
        ),
      ],
    );
  }

  Color _getTableColor(int tableNumber) {
    if (cubit.isTableVacant(tableNumber)) {
      return AppColors.green;
    } else if (cubit.isTablePayPending(tableNumber)) {
      return AppColors.warmOrange;
    }
    return AppColors.deepBlue;
  }
}
