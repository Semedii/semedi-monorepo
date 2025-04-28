import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/service/thermal_reciept_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    required this.order,
    this.exchangeRate,
    required this.onChangeOrderStatus,
    required this.onCancelOrder,
    super.key,
  });
  final OrderModel order;
  final int? exchangeRate;
  final Function(String orderNumber, OrderStatusEnum status)
      onChangeOrderStatus;
  final Function(String orderNumber) onCancelOrder;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _getOrderCardDecoration(),
      child: Column(
        children: [
          _buildOrderCardHeader(context, order),
          _buildOrderCardBody(order),
          const Spacer(),
          _buildOrderCardFooter(context, order),
        ],
      ),
    );
  }

  BoxDecoration _getOrderCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildOrderCardHeader(BuildContext context, OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          if (order.status == OrderStatusEnum.payPending) ...{
            _buildPaymentInfo(order),
          },
          _buildOrderInfoAndPrint(context, order),
        ],
      ),
    );
  }

  Text _buildPaymentInfo(OrderModel order) {
    return Text(
      "From: ${order.paymentInfo}",
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Row _buildOrderInfoAndPrint(BuildContext context, OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildOrderTable(context, order),
        _buildOrderTotal(order),
      ],
    );
  }

  Widget _buildOrderTable(BuildContext context, OrderModel order) {
    String tableOrName = order.tableNumber != null
        ? "TABLE ${order.tableNumber}"
        : "Take Away: ${order.customerName}";
    return Row(
      children: [
        _buildPrintButton(context, order),
        const SizedBox(width: 4),
        _buildTableAndOrderNumber(tableOrName, order),
      ],
    );
  }

  IconButton _buildPrintButton(BuildContext context, OrderModel order) {
    return IconButton(
      onPressed: () => _generateAndPrintReceipt(context, order),
      icon: Icon(
        Icons.print,
        color: AppColors.offWhite,
      ),
      tooltip: 'Print Reciept',
    );
  }

  Column _buildTableAndOrderNumber(String tableOrName, OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTableNumber(tableOrName),
        _buildOrderNumber(order),
      ],
    );
  }

  Text _buildTableNumber(String tableOrName) {
    return Text(
      tableOrName,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Text _buildOrderNumber(OrderModel order) {
    return Text(
      order.orderNumber ?? '',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Text _buildOrderTotal(OrderModel order) {
    return Text(
      '\$${order.total.toStringAsFixed(2)}',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildOrderCardBody(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 100,
          maxHeight: 200,
        ),
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: order.itemsWithQuantity.entries
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        _buildItemQuantity(item),
                        const SizedBox(width: 12),
                        Expanded(child: _buildItemName(item)),
                        _buildItemPrice(order, item),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildItemName(MapEntry<String, int> item) {
    return Text(
      item.key,
      style: TextStyle(
        color: AppColors.darkGrey,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Container _buildItemQuantity(MapEntry<String, int> item) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.deepBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${item.value}',
        style: TextStyle(
          color: AppColors.deepBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Text _buildItemPrice(OrderModel order, MapEntry<String, int> item) {
    final price = order.itemsWithPrices[item.key] ?? 0.0;
    return Text(
      '\$ $price',
      style: TextStyle(
        color: AppColors.darkGrey.withOpacity(0.7),
      ),
    );
  }

  Widget _buildOrderCardFooter(BuildContext context, OrderModel order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWaiterNameAndCancel(context, order),
          const SizedBox(height: 12),
          _buildActionButtons(context, order),
        ],
      ),
    );
  }

  Widget _buildWaiterNameAndCancel(BuildContext context, OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Waiter: ${order.waiter}',
          style: TextStyle(
            color: AppColors.darkGrey.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        if (order.tableNumber == null &&
            order.status == OrderStatusEnum.ordered) ...{
          _buildCancelButton(context, order.orderNumber!),
        }
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderModel order) {
    return order.status == OrderStatusEnum.payPending
        ? _buildPayPendingButtons(context, order)
        : _buildPayActionButtons(context, order);
  }

  Column _buildPayPendingButtons(BuildContext context, OrderModel order) {
    return Column(
      children: [
        _buildPaymentRecievedButton(context, order.orderNumber!),
        const SizedBox(height: 12),
        _buildPaymentNotRecievedButton(context, order.orderNumber!),
      ],
    );
  }

  Column _buildPayActionButtons(BuildContext context, OrderModel order) {
    return Column(
      children: [
        _buildMarkPaidButton(context, order.orderNumber!),
        const SizedBox(height: 12),
        _buildUnPaidButton(context, order.orderNumber!),
      ],
    );
  }

  Widget _buildPaymentRecievedButton(BuildContext context, String orderNumber) {
    return AppButton(
      onPressed: () => onChangeOrderStatus(orderNumber, OrderStatusEnum.paid),
      isSmall: false,
      elevation: 8,
      color: AppColors.green,
      text: "Payment recieved",
    );
  }

  Widget _buildPaymentNotRecievedButton(
      BuildContext context, String orderNumber) {
    return AppButton(
      onPressed: () => onChangeOrderStatus(
        orderNumber,
        OrderStatusEnum.paymentNotRecieved,
      ),
      isSmall: false,
      elevation: 8,
      color: AppColors.softRed,
      text: "Payment not recieved",
    );
  }

  AppButton _buildMarkPaidButton(BuildContext context, String orderNumber) {
    return AppButton(
      color: AppColors.green,
      isSmall: false,
      text: 'Mark as paid',
      onPressed: () => onChangeOrderStatus(orderNumber, OrderStatusEnum.paid),
    );
  }

  AppButton _buildUnPaidButton(BuildContext context, String orderNumber) {
    return AppButton(
        onPressed: () =>
            onChangeOrderStatus(orderNumber, OrderStatusEnum.unpaid),
        color: AppColors.warmOrange,
        isSmall: false,
        text: "Unpaid");
  }

  _buildCancelButton(BuildContext context, String orderNumber) {
    return GestureDetector(
      onTap: () => onCancelOrder(orderNumber),
      child: Chip(
        side: BorderSide(color: AppColors.softRed),
        elevation: 8,
        shadowColor: AppColors.softRed,
        label: Text(
          'Cancel',
          style: TextStyle(color: AppColors.offWhite),
        ),
        backgroundColor: AppColors.softRed,
      ),
    );
  }

  Color _getStatusColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.ordered:
        return AppColors.darkGrey;
      case OrderStatusEnum.preparing:
        return AppColors.warmOrange;
      case OrderStatusEnum.ready:
        return AppColors.green;
      case OrderStatusEnum.delivered:
        return AppColors.deepBlue;
      case OrderStatusEnum.payPending:
        return AppColors.amberGold;
      default:
        return Colors.grey;
    }
  }

  Future<void> _generateAndPrintReceipt(
    BuildContext context,
    OrderModel order,
  ) async {
    try {
      final pdfBytes = await ThermalReceiptService.generateOrderReceiptBytes(
        orderNumber: order.orderNumber ?? 'N/A',
        tableNumber: order.tableNumber.toString(),
        customerName: order.customerName,
        waiter: order.waiter,
        items: order.itemsWithQuantity,
        prices: order.itemsWithPrices,
        total: order.total,
        exchangeRate: exchangeRate,
        dateTime: order.timestamp,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing receipt: ${e.toString()}')),
      );
    }
  }
}
