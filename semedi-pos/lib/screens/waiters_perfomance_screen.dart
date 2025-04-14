import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/cubit/waitersPerfomance/waiters_perfomance_cubit.dart';
import 'package:semedi_pos/models/waiters_perfomance.dart';
import 'package:semedi_pos/screens/waiter_stats_screen.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/widgets.dart' as pw;

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
        iconTheme: IconThemeData(color: AppColors.offWhite),
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
      return _buildPageBody(context, state.waitersPerfomance);
    }
    if (state is WaitersPerfomanceLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox.shrink();
  }

  Padding _buildPageBody(
    BuildContext context,
    List<WaitersPerfomance> waitersPerfomance,
  ) {
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
                child: _buildDataTable(context, waitersPerfomance),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSavePdfButton(context, waitersPerfomance),
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

  DataTable _buildDataTable(
    BuildContext context,
    List<WaitersPerfomance> waitersPerfomance,
  ) {
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
      rows: _buildDataRow(context, waitersPerfomance).toList(),
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

  _buildDataRow(
    BuildContext context,
    List<WaitersPerfomance> waitersPerfomance,
  ) {
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
          _buildVIewButton(context, waiter),
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

  DataCell _buildVIewButton(
    BuildContext context,
    WaitersPerfomance waiterPerfomance,
  ) {
    return DataCell(
      IconButton(
        icon: const Icon(Icons.visibility),
        color: AppColors.deepBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WaiterStatsScreen(waitersPerfomance: waiterPerfomance),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSavePdfButton(
    BuildContext context,
    List<WaitersPerfomance> waiterPerfomanceList,
  ) {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.picture_as_pdf,
          color: AppColors.offWhite,
        ),
        label: Text(
          'Save PDF',
          style: TextStyle(color: AppColors.offWhite),
        ),
        onPressed: () => _generatePdf(context, waiterPerfomanceList),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBlue,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  Future<void> _generatePdf(
    BuildContext context,
    List<WaitersPerfomance> waiterPerfomanceList,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Barkulan Restaurant', style: pw.TextStyle(fontSize: 40)),
              pw.SizedBox(height: 12),
              pw.Text(
                'WAITERS PERFOMANCE REPORT (${_getFormattedDate()})',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 24),
              pw.Table.fromTextArray(context: context, data: <List<String>>[
                [
                  "Waiter",
                  "Paid Orders",
                  "Unpaid Orders",
                  "Total Orders",
                  "Total Sales",
                ],
                ...waiterPerfomanceList.map((waiterPerfomance) {
                  return [
                    waiterPerfomance.name,
                    waiterPerfomance.noOfPaidOrders.toString(),
                    waiterPerfomance.noOfUnpaidOrders.toString(),
                    waiterPerfomance.totalOrders.toString(),
                    waiterPerfomance.totalSales.toString(),
                  ];
                })
              ]),
            ],
          );
        },
      ),
    );

    final String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF Report',
      fileName: 'waiters_perfomance(${_getFormattedDate()}).pdf',
    );

    if (outputPath != null) {
      final file = File(outputPath);
      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved to ${path.basename(outputPath)}'),
          backgroundColor: AppColors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Saving canceled'),
          backgroundColor: AppColors.softRed,
        ),
      );
    }
  }
}

String _getFormattedDate() {
  final now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
}
