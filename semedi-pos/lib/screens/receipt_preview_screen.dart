import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:semedi_pos/models/order_model.dart';
import 'package:semedi_pos/service/thermal_reciept_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class ReceiptPreviewScreen extends StatelessWidget {
  final OrderModel order;
  final int? exchangeRate;

  const ReceiptPreviewScreen({
    required this.order,
    this.exchangeRate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReceiptCard(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('RECEIPT PREVIEW'),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.print),
          onPressed: () => _onPrint(context),
          tooltip: 'Print Receipt',
        ),
      ],
    );
  }

  Widget _buildReceiptCard(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildReceiptHeader(),
            const Divider(height: 1),
            _buildReceiptMeta(),
            const Divider(height: 1),
            _buildReceiptItems(),
            const Divider(height: 1),
            _buildReceiptTotals(),
            _buildReceiptFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.deepBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Text(
            'SEMEDI RESTAURANT',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'RECEIPT',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptMeta() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetaRow('Order #', order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()),
          _buildMetaRow('Table', order.tableNumber.toString()),
          _buildMetaRow('Waiter', order.waiterName),
          _buildMetaRow('Date', _formatDate(order.createdAt)),
          _buildMetaRow('Time', _formatTime(order.createdAt)),
          _buildMetaRow('Payment', order.paymentMethod.toUpperCase()),
        ],
      ),
    );
  }

  Row _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  Widget _buildReceiptItems() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ITEMS',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 10),
          ...order.items.map((item) => _buildReceiptItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildReceiptItemRow(item) {
    final lineTotal = (item.itemPrice as double) * (item.itemQuantity as int);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text('${item.itemQuantity}x ',
              style: TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
          Expanded(child: Text(item.itemName ?? '')),
          Text(
            '\$${lineTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptTotals() {
    final slsh = exchangeRate != null
        ? 'SLSH ${(order.totalPrice * exchangeRate!).toStringAsFixed(0)}'
        : null;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '\$${order.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.deepBlue),
              ),
            ],
          ),
          if (slsh != null)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                slsh,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReceiptFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Thank you for dining with us!',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => _onPrint(context),
            icon: const Icon(Icons.print),
            label: const Text('PRINT RECEIPT'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _onPrint(BuildContext context) async {
    try {
      final pdfBytes = await ThermalReceiptService.generateOrderReceiptBytes(
        orderNumber: order.id,
        tableNumber: order.tableNumber.toString(),
        customerName: order.waiterName,
        waiter: order.waiterName,
        items: order.items,
        total: order.totalPrice,
        exchangeRate: exchangeRate ?? 0,
        dateTime: order.createdAt,
      );
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print error: ${e.toString()}')),
      );
    }
  }
}
