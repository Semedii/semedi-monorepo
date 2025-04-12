import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/cubit/waitersPerfomance/waiters_perfomance_cubit.dart';
import 'package:semedi_pos/models/waiters_perfomance.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class WaitersPerfomanceScreen extends StatelessWidget {
  final OrderService _orderService = OrderService();

  WaitersPerfomanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WAITERS PERFORMANCE REPORT',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.offWhite,
            )),
        backgroundColor: AppColors.deepBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => WaitersPerfomanceCubit(_orderService)..initPage(),
        child: BlocBuilder<WaitersPerfomanceCubit, WaitersPerfomanceState>(
          builder: _mapStateToWidget,
        ),
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, WaitersPerfomanceState state) {
    if (state is WaitersPerfomanceLoaded) {
      return _buildPageBody(state.waitersPerfomance);
    }
    if (state is WaitersPerfomanceLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox.shrink();
  }

  Padding _buildPageBody(List<WaitersPerfomance> waitersPerfomance) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: _buildBoxDecoration(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildDataTable(waitersPerfomance),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPrintAndExportButtons(),
        ],
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    );
  }

  DataTable _buildDataTable(List<WaitersPerfomance> waitersPerfomance) {
    return DataTable(
      headingRowColor: WidgetStatePropertyAll<Color>(
        AppColors.deepBlue.withOpacity(0.05),
      ),
      columns: [
        _buildDataColumn("waiter"),
        _buildDataColumn("paid orders"),
        _buildDataColumn("unpaid order"),
        _buildDataColumn("total orders"),
        _buildDataColumn("total sales"),
        _buildDataColumn("view"),
      ],
      rows: _buildDataRow(waitersPerfomance).toList(),
    );
  }

  DataColumn _buildDataColumn(String text) {
    return DataColumn(
      label: Text(
        text.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Iterable<DataRow> _buildDataRow(List<WaitersPerfomance> waitersPerfomance) {
    return waitersPerfomance.map((waiter) {
      return DataRow(
        cells: [
          _buildDataCell(waiter.name),
          _buildDataCell(
            waiter.noOfPaidOrders.toString(),
            color: AppColors.green,
          ),
          _buildDataCell(
            waiter.noOfUnpaidOrders.toString(),
            color: AppColors.warmOrange,
          ),
          _buildDataCell(waiter.totalOrders.toString()),
          _buildDataCell('\$${waiter.totalSales.toStringAsFixed(2)}'),
          _buildVIewButton(),
        ],
      );
    });
  }

  DataCell _buildDataCell(String text, {Color? color}) {
    return DataCell(
      Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  DataCell _buildVIewButton() {
    return DataCell(
      IconButton(
        icon: const Icon(Icons.visibility),
        color: AppColors.deepBlue,
        onPressed: () {
          // View detailed report
        },
      ),
    );
  }

  Row _buildPrintAndExportButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildPrintButton(),
        const SizedBox(width: 16),
        _buildExportButton(),
      ],
    );
  }

  OutlinedButton _buildPrintButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.print),
      label: const Text('PRINT REPORT'),
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(color: AppColors.deepBlue),
      ),
    );
  }

  ElevatedButton _buildExportButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text('EXPORT'),
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deepBlue,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
