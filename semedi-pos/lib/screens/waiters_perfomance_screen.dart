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
  final Map<String, double> salesData;
  WaitersPerfomanceScreen(this.salesData, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WaitersPerfomanceCubit(_orderService)..initPage(),
      child: BlocConsumer<WaitersPerfomanceCubit, WaitersPerfomanceState>(
        listener: _getListener,
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, WaitersPerfomanceState state) {
    if (state is WaitersPerfomanceLoaded) {
      return _buildPageBody(context, state);
    }
    if (state is WaitersPerfomanceLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox.shrink();
  }

  Widget _buildPageBody(
    BuildContext context,
    WaitersPerfomanceLoaded state,
  ) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: _buildBoxDecoration(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildDataTable(context, state),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context, state),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final cubit = BlocProvider.of<WaitersPerfomanceCubit>(context);
    return AppBar(
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
      actions: [
        IconButton(
          padding: const EdgeInsets.only(right: 16),
          onPressed: cubit.initPage,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        )
      ],
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
    WaitersPerfomanceLoaded state,
  ) {
    return DataTable(
      headingRowColor: WidgetStatePropertyAll<Color>(
        AppColors.deepBlue.withOpacity(0.05),
      ),
      columns: [
        _buildDataColumn("waiter"),
        _buildDataColumn("no of orders"),
        _buildDataColumn("unpaid orders total"),
        _buildDataColumn("total sales"),
        _buildDataColumn("view"),
      ],
      rows: _buildDataRow(context, state).toList(),
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

  _buildDataRow(BuildContext context, WaitersPerfomanceLoaded state) {
    return state.waitersPerfomance.map((waiter) {
      return DataRow(
        cells: [
          _buildDataCell(waiter.name),
          _buildDataCell(
            waiter.totalOrders.toString(),
            color: AppColors.warmOrange,
          ),
          _buildDataCell('\$${waiter.unpaidOrdersTotal.toString()}'),
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

  Widget _buildActionButtons(
    BuildContext context,
    WaitersPerfomanceLoaded state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSimpleButton(
          Icons.archive,
          'End The Day',
          AppColors.green,
          () => _showEndDayDialog(context),
        ),
        _buildSimpleButton(
          Icons.picture_as_pdf,
          'Save PDF',
          AppColors.deepBlue,
          () => _generatePdf(context, state),
        ),
      ],
    );
  }

  _showEndDayDialog(BuildContext context) {
    final cubit = BlocProvider.of<WaitersPerfomanceCubit>(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are You Sure You Want To End The Day'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  "Please Make Sure You Printed The Summary and Waiter's Perfomance And Double Check It Before Proceeding"),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSimpleButton(Icons.archive, 'END', AppColors.softRed,
                      () async {
                    await cubit.endDay(
                      salesData,
                    );
                    Navigator.pop(context);
                  }),
                  _buildSimpleButton(Icons.cancel, 'CANCEL', AppColors.deepBlue,
                      () => Navigator.pop(context)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  _buildSimpleButton(
    IconData icon,
    String text,
    Color color,
    Function()? onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: onPressed,
    );
  }

  Future<void> _generatePdf(
    BuildContext context,
    WaitersPerfomanceLoaded state,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('${state.restaurant.toUpperCase()} Restaurant',
                  style: pw.TextStyle(fontSize: 40)),
              pw.SizedBox(height: 12),
              pw.Text(
                'WAITERS PERFOMANCE REPORT (${_getFormattedDate()})',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 24),
              pw.Table.fromTextArray(context: context, data: <List<String>>[
                [
                  "Waiter",
                  "no of Orders",
                  "Unpaid Orders Total",
                  "Total Sales",
                ],
                ...state.waitersPerfomance.map((waiterPerfomance) {
                  return [
                    waiterPerfomance.name,
                    waiterPerfomance.totalOrders.toString(),
                    waiterPerfomance.unpaidOrdersTotal.toString(),
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

_getListener(context, state) {
  if (state is ClearDataSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Cleared Successfully"),
        backgroundColor: AppColors.green,
      ),
    );
  } else if (state is ClearDataFailure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: AppColors.softRed,
      ),
    );
  }
}

String _getFormattedDate() {
  final now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
}
