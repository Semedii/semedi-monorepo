import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:semedi_pos/service/secure_storage_service.dart';

class ThermalReceiptService {
  static const double receiptWidth = 58 * PdfPageFormat.mm;
  static const double padding = 4.0;

  static Future<Uint8List> generateOrderReceiptBytes({
    required String orderNumber,
    String? tableNumber,
    String? customerName,
    required String waiter,
    required Map<String, int> items,
    required Map<String, double> prices,
    required double total,
    int? exchangeRate,
    required DateTime dateTime,
  }) async {
    final pdf = pw.Document();

    String? restaurantName = await SecureStorageService().read("restaurant");

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(receiptWidth, double.infinity),
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(padding),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildCenteredHeader(restaurantName ?? ""),
                pw.SizedBox(height: 8),
                _buildOrderInfo(
                  orderNumber,
                  dateTime,
                  tableNumber,
                  customerName,
                  waiter,
                ),
                pw.SizedBox(height: 8),
                _buildItemsTable(items, prices),
                pw.SizedBox(height: 8),
                _buildTotalsSection(total, exchangeRate),
                pw.SizedBox(height: 8),
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildCenteredHeader(String restaurantName) {
    return pw.Center(
      child: pw.Text('${restaurantName.toUpperCase()} RESTAURANT',
          style: _boldStyle(size: 12)),
    );
  }

  static pw.Widget _buildOrderInfo(
    String orderNumber,
    DateTime dateTime,
    String? tableNumber,
    String? customerName,
    String waiter,
  ) {
    String orderLabel = customerName != null
        ? 'TakeAway: $customerName'
        : 'Table: $tableNumber';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Order #$orderNumber', style: _boldStyle()),
        pw.Text(orderLabel, style: _normalStyle()),
        pw.SizedBox(height: 4),
        pw.Text(DateFormat('MM/dd/yyyy hh:mm a').format(dateTime),
            style: _normalStyle()),
        pw.Text('Waiter: $waiter', style: _normalStyle()),
        pw.Divider(thickness: 0.5),
      ],
    );
  }

  static pw.Widget _buildItemsTable(
    Map<String, int> items,
    Map<String, double> prices,
  ) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
      },
      border: pw.TableBorder.all(width: 0),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
          ),
          children: [
            pw.Text('Item', style: _boldStyle()),
            pw.Text('Qty', style: _boldStyle()),
            pw.Text('Price', style: _boldStyle()),
          ],
        ),
        ...items.entries.map((item) => pw.TableRow(
              children: [
                pw.Text(item.key, style: _normalStyle()),
                pw.Text(item.value.toString(), style: _normalStyle()),
                pw.Text('\$${prices[item.key]?.toStringAsFixed(2) ?? '0.00'}',
                    style: _normalStyle()),
              ],
            )),
      ],
    );
  }

  static pw.Widget _buildTotalsSection(double total, int? exchangeRate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Subtotal:'),
            pw.Text('\$${total.toStringAsFixed(2)}'),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Tax (5%):'),
            pw.Text('\$${(total * 0.05).toStringAsFixed(2)}'),
          ],
        ),
        pw.Divider(thickness: 0.5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('TOTAL:', style: _boldStyle()),
            pw.Text('\$${(total * 1.05).toStringAsFixed(2)}',
                style: _boldStyle()),
          ],
        ),
        if (exchangeRate != null)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('TOTAL SLSH:', style: _boldStyle()),
              pw.Text(
                '\$${NumberFormat('#,###.00').format(total * 1.05 * exchangeRate)}',
                style: _boldStyle(),
              )
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text('Thank you for dining with us!', style: _boldStyle(size: 10)),
          pw.Text('Please come again', style: _normalStyle()),
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 0.5),
          pw.Text('Powered by:', style: _normalStyle(size: 6)),
          pw.Text('SEMEDI', style: _boldStyle()),
          pw.Text('www.semedi.dev', style: _normalStyle(size: 6)),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated on ${DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.now())}',
            style: _normalStyle(size: 6),
          ),
        ],
      ),
    );
  }

  static pw.TextStyle _boldStyle({double size = 8}) {
    return pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: size);
  }

  static pw.TextStyle _normalStyle({double size = 8}) {
    return pw.TextStyle(fontSize: size);
  }
}
