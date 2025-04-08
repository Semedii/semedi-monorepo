import 'package:flutter/material.dart';
import 'package:semedi_pos/utils/app_colors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTitleSection(),
            const SizedBox(height: 24),
            _buildTable(),
            const SizedBox(height: 16),
            _buildFooterButtons(context),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "END OF DAY REPORT",
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildTitleSection() {
    return const Column(
      children: [
        Text(
          "Barkulan Restaurant",
          style: TextStyle(fontSize: 40),
        ),
        SizedBox(height: 12),
        Text(
          "SALES SUMMARY REPORT (07/04/2025 - 07/04/2025)",
          style: TextStyle(fontSize: 24),
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
                  '\$10,200.00',
                  '\$5,120.00',
                  '\$15,320.00',
                ),
                _buildTableRow('VAT 5%', '\$510.00', '\$256.00', '\$766.00'),
                _buildTableRow(
                  'Net Sales',
                  '\$9,690.00',
                  '\$4,864.00',
                  '\$14,554.00',
                  isFooter: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.print),
          label: const Text('PRINT REPORT'),
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            side: BorderSide(color: AppColors.deepBlue),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          label: const Text(
            'EXPORT PDF',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            _generatePdf(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepBlue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
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
}

Future<void> _generatePdf(BuildContext context) async {
  final pdf = pw.Document();

  pdf.addPage(pw.Page(
    build: (pw.Context context) {
      return pw.Column(
        children: [
          pw.Text('Barkulan Restaurant', style: pw.TextStyle(fontSize: 40)),
          pw.SizedBox(height: 12),
          pw.Text(
            'SALES SUMMARY REPORT (07/04/2025 - 07/04/2025)',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 24),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              ['Particulars', 'Dine In', 'Take Away', 'Total'],
              ['Sales', '\$10,200.00', '\$5,120.00', '\$15,320.00'],
              ['VAT 5%', '\$510.00', '\$256.00', '\$766.00'],
              ['Net Sales', '\$9,690.00', '\$4,864.00', '\$14,554.00'],
            ],
          ),
        ],
      );
    },
  ));
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save());
}
