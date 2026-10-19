import 'package:flutter/material.dart';
import 'package:semedi_pos/models/order_model.dart';
import 'package:semedi_pos/screens/waiters_perfomance_screen.dart';
import 'package:semedi_pos/utils/app_colors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class ReportScreen extends StatelessWidget {
  const ReportScreen({
    required this.paidOrders,
    required this.unPaidOrders,
    required this.restaurant,
    super.key,
  });

  final List<OrderModel> paidOrders;
  final List<OrderModel> unPaidOrders;
  final String restaurant;

  Map<String, double> _calculateSales() {
    double dineInTotal = 0;
    double takeAwayTotal = 0;
    double unPaidTotal = 0;
    double unPaidDineIn = 0;
    double unPaidTakeAway = 0;
    double noOfDineInOrders = 0;
    double noOfTakeAwayOrders = 0;

    for (final order in paidOrders) {
      //todo
      if (order.tableNumber == null) {
        takeAwayTotal += order.totalPrice;
        noOfTakeAwayOrders++;
      } else {
        dineInTotal += order.totalPrice;
        noOfDineInOrders++;
      }
    }

    for (final order in unPaidOrders) {
      //todo
      if (order.tableNumber == null) {
        unPaidTakeAway += order.totalPrice;
        takeAwayTotal += order.totalPrice;
        noOfTakeAwayOrders++;
      } else {
        unPaidDineIn += order.totalPrice;
        dineInTotal += order.totalPrice;
        noOfDineInOrders++;
      }
    }

    for (final order in unPaidOrders) {
      unPaidTotal += order.totalPrice;
    }

    final dineInVat = dineInTotal * 0.05;
    final takeAwayVat = takeAwayTotal * 0.05;
    final dineInNetSales = dineInTotal - dineInVat;
    final takeAwayNetSales = takeAwayTotal - takeAwayVat;

    return {
      'dineIn': dineInTotal,
      'takeAway': takeAwayTotal,
      'totalSales': dineInTotal + takeAwayTotal,
      'dineInVat': dineInVat,
      'takeAwayVat': takeAwayVat,
      'totalVat': dineInVat + takeAwayVat,
      'dineInNet': dineInNetSales,
      'takeAwayNet': takeAwayNetSales,
      'totalNet': dineInNetSales + takeAwayNetSales,
      'unPaidTotal': unPaidTotal,
      'unPaidDineIn': unPaidDineIn,
      'unPaidTakeAway': unPaidTakeAway,
      'noOfOrdersDineIn': noOfDineInOrders,
      'noOfOrdersTakeAway': noOfTakeAwayOrders,
    };
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final salesData = _calculateSales();
    final formattedDate = _getFormattedDate();

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleSection(formattedDate),
              const SizedBox(height: 24),
              _buildTable(salesData),
              const SizedBox(height: 16),
              _buildSaveButtons(context, salesData, formattedDate),
              const SizedBox(height: 32),
              _buildPaymentMethodBreakdown(paidOrders),
              const SizedBox(height: 24),
              _buildHourlyBreakdown(paidOrders),
              const SizedBox(height: 24),
              _buildAverageOrderValue(paidOrders),
              const SizedBox(height: 24),
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "END OF DAY REPORT",
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WaitersPerfomanceScreen(_calculateSales()),
              ),
            );
          },
          icon: const Icon(Icons.people),
          tooltip: 'Waiter Perfomances',
        )
      ],
    );
  }

  Widget _buildTitleSection(String formattedDate) {
    return Column(
      children: [
        Text(
          "$restaurant Restaurant",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 12),
        Text(
          "SALES SUMMARY REPORT ($formattedDate)",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
      ],
    );
  }

  Widget _buildTable(Map<String, double> salesData) {
    return SizedBox(
      height: 280,
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
                  _formatCurrency(salesData['dineIn']!),
                  _formatCurrency(salesData['takeAway']!),
                  _formatCurrency(salesData['totalSales']!),
                ),
                _buildTableRow(
                  'VAT 5%',
                  _formatCurrency(salesData['dineInVat']!),
                  _formatCurrency(salesData['takeAwayVat']!),
                  _formatCurrency(salesData['totalVat']!),
                ),
                _buildTableRow(
                  'Unpaid Orders',
                  _formatCurrency(salesData['unPaidDineIn']!),
                  _formatCurrency(salesData['unPaidTakeAway']!),
                  _formatCurrency(salesData['unPaidTotal']!),
                ),
                _buildTableRow(
                  'No of Orders',
                  salesData['noOfOrdersDineIn']!.toStringAsFixed(0),
                  salesData['noOfOrdersTakeAway']!.toStringAsFixed(0),
                  (paidOrders.length + unPaidOrders.length).toString(),
                ),
                _buildTableRow(
                  'Net Sales',
                  _formatCurrency(salesData['dineInNet']!),
                  _formatCurrency(salesData['takeAwayNet']!),
                  _formatCurrency(salesData['totalNet']!),
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
    Map<String, double> salesData,
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
            _generatePdf(context, salesData, formattedDate);
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

  Widget _buildPaymentMethodBreakdown(List<OrderModel> orders) {
    final Map<String, double> breakdown = {};
    for (final order in orders) {
      final method = order.paymentMethod;
      breakdown[method] = (breakdown[method] ?? 0) + order.totalPrice;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: breakdown.isEmpty
                ? const Text('No data available')
                : Column(
                    children: breakdown.entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key.toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  _formatCurrency(entry.value),
                                  style: TextStyle(color: AppColors.deepBlue),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyBreakdown(List<OrderModel> orders) {
    final Map<int, int> hourlyCount = {};
    for (final order in orders) {
      final hour = order.createdAt.hour;
      hourlyCount[hour] = (hourlyCount[hour] ?? 0) + 1;
    }

    final sortedHours = hourlyCount.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hourly Order Volume',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: hourlyCount.isEmpty
                ? const Text('No data available')
                : Column(
                    children: sortedHours
                        .map(
                          (hour) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    '${hour.toString().padLeft(2, '0')}:00',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: hourlyCount[hour]! /
                                        (orders.isNotEmpty
                                            ? orders.length
                                            : 1),
                                    backgroundColor: Colors.grey.shade200,
                                    color: AppColors.deepBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('${hourlyCount[hour]} orders'),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAverageOrderValue(List<OrderModel> orders) {
    final totalRevenue = orders.fold(0.0, (sum, o) => sum + o.totalPrice);
    final average = orders.isEmpty ? 0.0 : totalRevenue / orders.length;
    final highest = orders.isEmpty
        ? 0.0
        : orders.map((o) => o.totalPrice).reduce((a, b) => a > b ? a : b);
    final lowest = orders.isEmpty
        ? 0.0
        : orders.map((o) => o.totalPrice).reduce((a, b) => a < b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Value Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildValueStat(
                    'Average', _formatCurrency(average), AppColors.deepBlue),
                _buildValueStat(
                    'Highest', _formatCurrency(highest), AppColors.green),
                _buildValueStat(
                    'Lowest', _formatCurrency(lowest), AppColors.warmOrange),
                _buildValueStat('Total Orders', orders.length.toString(),
                    AppColors.darkGrey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _generatePdf(BuildContext context, Map<String, double> salesData,
      String formattedDate) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('$restaurant Restaurant',
                  style: pw.TextStyle(fontSize: 40)),
              pw.SizedBox(height: 12),
              pw.Text(
                'SALES SUMMARY REPORT ($formattedDate - $formattedDate)',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 24),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  ['Particulars', 'Dine In', 'Take Away', 'Total'],
                  [
                    'Sales',
                    '\$${salesData['dineIn']!.toStringAsFixed(2)}',
                    '\$${salesData['takeAway']!.toStringAsFixed(2)}',
                    '\$${salesData['totalSales']!.toStringAsFixed(2)}',
                  ],
                  [
                    'VAT 5%',
                    '\$${salesData['dineInVat']!.toStringAsFixed(2)}',
                    '\$${salesData['takeAwayVat']!.toStringAsFixed(2)}',
                    '\$${salesData['totalVat']!.toStringAsFixed(2)}',
                  ],
                  [
                    'Unpaid Orders',
                    _formatCurrency(salesData['unPaidDineIn']!),
                    _formatCurrency(salesData['unPaidTakeAway']!),
                    _formatCurrency(salesData['unPaidTotal']!),
                  ],
                  [
                    'No of Orders',
                    (salesData['noOfOrdersDineIn']!.toStringAsFixed(0)),
                    (salesData['noOfOrdersTakeAway']!.toStringAsFixed(0)),
                    (paidOrders.length + unPaidOrders.length).toString(),
                  ],
                  [
                    'Net Sales',
                    '\$${salesData['dineInNet']!.toStringAsFixed(2)}',
                    '\$${salesData['takeAwayNet']!.toStringAsFixed(2)}',
                    '\$${salesData['totalNet']!.toStringAsFixed(2)}',
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
