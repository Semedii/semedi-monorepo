import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:semedi_pos/models/daily_summary.dart';
import 'package:semedi_pos/utils/app_colors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;

class SalesHistoryData extends StatelessWidget {
  const SalesHistoryData(this.dailySummary, {super.key});
  final DailySummary dailySummary;
  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _getFormattedDate();

    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTitleSection(formattedDate),
              const SizedBox(height: 24),
              _buildTable(),
              const SizedBox(height: 16),
              _buildSaveButtons(context, formattedDate),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.deepBlue,
      iconTheme: IconThemeData(color: AppColors.offWhite),
      title: Text(
        dailySummary.date,
        style: TextStyle(color: AppColors.offWhite),
      ),
    );
  }

  Widget _buildTitleSection(String formattedDate) {
    return Column(
      children: [
        Text(
          "${dailySummary.restaurant} Restaurant",
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 12),
        Text(
          "SALES SUMMARY REPORT ($formattedDate)",
          style: const TextStyle(fontSize: 24),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
              columnWidths: const {
                0: FixedColumnWidth(200.0),
                1: FixedColumnWidth(150.0),
                2: FixedColumnWidth(150.0),
                3: FixedColumnWidth(150.0),
              },
              children: [
                _buildTableHeader(),
                _buildTableRow(
                  'Sales',
                  _formatCurrency(dailySummary.dineIn),
                  _formatCurrency(dailySummary.takeAway),
                  _formatCurrency(dailySummary.totalSales),
                ),
                _buildTableRow(
                  'VAT 5%',
                  _formatCurrency(dailySummary.dineInVat),
                  _formatCurrency(dailySummary.takeAwayVat),
                  _formatCurrency(dailySummary.totalVat),
                ),
                _buildTableRow(
                  'Unpaid Orders',
                  _formatCurrency(dailySummary.unpaidDineIn),
                  _formatCurrency(dailySummary.unpaidTakeAway),
                  _formatCurrency(dailySummary.unpaidTotal),
                ),
                _buildTableRow(
                  'No of Orders',
                  dailySummary.noOfOrdersDineIn.toStringAsFixed(0),
                  dailySummary.noOfOrdersTakeAway.toStringAsFixed(0),
                  dailySummary.totalOrders.toString(),
                ),
                _buildTableRow(
                  'Net Sales',
                  _formatCurrency(dailySummary.dineInNet),
                  _formatCurrency(dailySummary.takeAwayNet),
                  _formatCurrency(dailySummary.totalNet),
                  isFooter: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButtons(
    BuildContext context,
    String formattedDate,
  ) {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          label: const Text(
            'Save PDF',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            _generatePdf(context, formattedDate);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepBlue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          )),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: AppColors.deepBlue.withOpacity(0.05),
      ),
      children: [
        _buildTableCell('Particulars', isHeader: true),
        _buildTableCell('Dine In', isHeader: true, alignRight: true),
        _buildTableCell('Take Away', isHeader: true, alignRight: true),
        _buildTableCell('Total', isHeader: true, alignRight: true),
      ],
    );
  }

  TableRow _buildTableRow(
    String label,
    String dineIn,
    String takeAway,
    String total, {
    bool isFooter = false,
  }) {
    return TableRow(
      decoration: isFooter
          ? BoxDecoration(
              color: AppColors.deepBlue.withOpacity(0.03),
              border: const Border(
                top: BorderSide(color: Colors.grey, width: 1.0),
              ),
            )
          : null,
      children: [
        _buildTableCell(label, isFooter: isFooter),
        _buildTableCell(dineIn, isFooter: isFooter, alignRight: true),
        _buildTableCell(takeAway, isFooter: isFooter, alignRight: true),
        _buildTableCell(total, isFooter: isFooter, alignRight: true),
      ],
    );
  }

  static Widget _buildTableCell(
    String content, {
    bool isHeader = false,
    bool isFooter = false,
    bool alignRight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          content,
          style: TextStyle(
            fontWeight:
                isHeader || isFooter ? FontWeight.bold : FontWeight.normal,
            color: isFooter ? AppColors.deepBlue : Colors.black,
          ),
        ),
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context, String formattedDate) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('${dailySummary.restaurant} Restaurant',
                  style: const pw.TextStyle(fontSize: 40)),
              pw.SizedBox(height: 12),
              pw.Text(
                'SALES SUMMARY REPORT ($formattedDate - $formattedDate)',
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 24),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  ['Particulars', 'Dine In', 'Take Away', 'Total'],
                  [
                    'Sales',
                    '\$${dailySummary.dineIn.toStringAsFixed(2)}',
                    '\$${dailySummary.takeAway.toStringAsFixed(2)}',
                    '\$${dailySummary.totalSales.toStringAsFixed(2)}',
                  ],
                  [
                    'VAT 5%',
                    '\$${dailySummary.dineInVat.toStringAsFixed(2)}',
                    '\$${dailySummary.takeAwayVat.toStringAsFixed(2)}',
                    '\$${dailySummary.totalVat.toStringAsFixed(2)}',
                  ],
                  [
                    'Unpaid Orders',
                    _formatCurrency(dailySummary.unpaidDineIn),
                    _formatCurrency(dailySummary.unpaidTakeAway),
                    _formatCurrency(dailySummary.unpaidTotal),
                  ],
                  [
                    'No of Orders',
                    (dailySummary.noOfOrdersDineIn.toStringAsFixed(0)),
                    (dailySummary.noOfOrdersTakeAway.toStringAsFixed(0)),
                    dailySummary.totalOrders.toString(),
                  ],
                  [
                    'Net Sales',
                    '\$${dailySummary.dineInNet.toStringAsFixed(2)}',
                    '\$${dailySummary.takeAwayNet.toStringAsFixed(2)}',
                    '\$${dailySummary.totalNet.toStringAsFixed(2)}',
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );

    final String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF Report',
      fileName: 'sales_report_$formattedDate.pdf',
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
