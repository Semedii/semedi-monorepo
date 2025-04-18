import 'package:flutter/material.dart';
import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/txt_form_field.dart';
import 'package:semedi/models/order.dart';
import 'package:semedi/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:semedi/utils/order_status_enum.dart';
import 'package:semedi/utils/text_validators.dart';

class OrderItem extends StatelessWidget {
  final OrderModel order;
  final Function()? onDeliver;
  final Function()? onCancel;
  final Function(String namePhone) onRequestPay;
  OrderItem({
    super.key,
    required this.order,
    this.onCancel,
    this.onDeliver,
    required this.onRequestPay,
  });

  final TextEditingController controller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOrderAndTableNumber(),
                _buildStatusChip(),
              ],
            ),
            const Divider(height: 24),
            _buildItemList(),
            if (order.note != null && order.note!.isNotEmpty) ...{
              _buildNote(),
            },
            const SizedBox(height: 12),
            _buildTimestamp(),
            if (order.tableNumber != null) _buildWaiterAndActionButton(context),
          ],
        ),
      ),
    );
  }

  Column _buildOrderAndTableNumber() {
    String tableOrName = order.tableNumber != null
        ? "TABLE ${order.tableNumber}"
        : "Take Away: ${order.customerName}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order #${order.orderNumber}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tableOrName,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Container _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusChipColor(order.status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        order.status.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Column _buildItemList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: order.itemsWithQuantity.entries
          .map((entry) => _buildItemCard(entry))
          .toList(),
    );
  }

  Padding _buildItemCard(MapEntry<String, int> entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.deepBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${entry.value}',
              style: TextStyle(
                color: AppColors.deepBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            entry.key,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Column _buildNote() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Note: ${order.note!}',
            style: TextStyle(
              color: AppColors.softRed,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Text _buildTimestamp() {
    String text =
        order.status == OrderStatusEnum.delivered ? 'Delivered' : 'Ordered';
    return Text(
      '$text at ${_getTimeFromDateTime(order.timestamp)}',
      style: TextStyle(
        color: AppColors.darkGrey,
        fontSize: 12,
      ),
    );
  }

  Row _buildWaiterAndActionButton(BuildContext context) {
    bool isDelivered = order.status == OrderStatusEnum.delivered;
    bool isOrdered = order.status == OrderStatusEnum.ordered;
    bool isReady = order.status == OrderStatusEnum.ready;
    bool isPaymentNotRecieved =
        order.status == OrderStatusEnum.paymentNotRecieved;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          order.waiter,
          style: TextStyle(color: AppColors.deepBlue),
        ),
        if (isReady) _buildDeliverButton(),
        if (isOrdered) _buildCancelButton(),
        if (isDelivered || isPaymentNotRecieved) ...{
          _buildRequestPayApprovalButton(context),
        }
      ],
    );
  }

  _buildCancelButton() {
    return GestureDetector(
      onTap: onCancel,
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

  _buildDeliverButton() {
    return GestureDetector(
      onTap: onDeliver,
      child: Chip(
        side: BorderSide(color: AppColors.deepBlue),
        elevation: 8,
        shadowColor: AppColors.deepBlue,
        label: Text(
          'Deliver',
          style: TextStyle(color: AppColors.offWhite),
        ),
        backgroundColor: AppColors.deepBlue,
      ),
    );
  }

  _buildRequestPayApprovalButton(BuildContext context) {
    return GestureDetector(
      onTap: () => showNotifyCashierDialog(context),
      child: Chip(
        side: BorderSide(color: AppColors.green),
        elevation: 8,
        shadowColor: AppColors.green,
        label: Text(
          'Notify Cashier',
          style: TextStyle(color: AppColors.offWhite),
        ),
        backgroundColor: AppColors.green,
      ),
    );
  }

  showNotifyCashierDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: AlertDialog(
              title: const Text("From Name/Number"),
              content: Form(
                key: _formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TxtFormField(
                      controller: controller,
                      labelText: "Name or Phone",
                      validator: TextValidators.fieldRequired,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: "Request Approval",
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          onRequestPay(controller.text);
                          Navigator.pop(context);
                        }
                        ;
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Color _getStatusChipColor(OrderStatusEnum status) {
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
      case OrderStatusEnum.paymentNotRecieved:
        return AppColors.softRed;
      default:
        return Colors.grey;
    }
  }

  String? _getTimeFromDateTime(DateTime? timestamp) {
    if (timestamp == null) return null;
    return DateFormat('h:mm a').format(timestamp);
  }
}
