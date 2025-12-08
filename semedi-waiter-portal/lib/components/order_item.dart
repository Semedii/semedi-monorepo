import 'package:flutter/material.dart';
import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/txt_form_field.dart';
import 'package:semedi/models/order_item.dart';
import 'package:semedi/models/order_model.dart';
import 'package:semedi/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:semedi/utils/extensions.dart';
import 'package:semedi/utils/order_status_enum.dart';
import 'package:semedi/utils/text_validators.dart';

class OrderItemCard extends StatelessWidget {
  final OrderModel order;
  final Function()? onDeliver;
  final Function()? onCancel;
  final Function(String namePhone) onRequestPay;
  OrderItemCard({
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
      color: AppColors.offWhite,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.black.withValues(alpha: .5))),
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
            const SizedBox(height: 12),
            _buildTimestamp(),
            _buildWaiterAndActionButton(context),
          ],
        ),
      ),
    );
  }

  Column _buildOrderAndTableNumber() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Table: ${order.tableNumber}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '#${order.orderNumber.formatOrderNumber()}',
          style: const TextStyle(
            color: Color.fromARGB(255, 27, 27, 27),
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
        color: _getStatusColor(order.status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        order.status.toUpperCase(),
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
      children: order.items.map((item) => _buildItemCard(item)).toList(),
    );
  }

  Padding _buildItemCard(OrderItem item) {
    print("sadfasdf ${item.note}");
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 24,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.deepBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.itemName!,
                  style: TextStyle(
                    color: AppColors.deepBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(item.note ?? '')
            ],
          ),
          Text(
            '${item.itemQuantity}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Text _buildTimestamp() {
    String text =
        order.status == OrderStatusEnum.served.name ? 'Served' : 'Ordered';
    return Text(
      '$text at ${_getTimeFromDateTime(order.createdAt)}',
      style: TextStyle(
        color: AppColors.darkGrey,
        fontSize: 12,
      ),
    );
  }

  Row _buildWaiterAndActionButton(BuildContext context) {
    bool isDelivered = order.status == OrderStatusEnum.served.name;
    bool isReady = order.status == OrderStatusEnum.ready.name;
    bool isPaymentNotRecieved =
        order.status == OrderStatusEnum.paymentNotRecieved;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          order.waiterName,
          style: TextStyle(color: AppColors.deepBlue),
        ),
        if (isReady) _buildDeliverButton(),
        if (isDelivered || isPaymentNotRecieved) ...{
          _buildRequestPayApprovalButton(context),
        }
      ],
    );
  }

  _buildDeliverButton() {
    return GestureDetector(
      onTap: onDeliver,
      child: Chip(
        side: BorderSide(color: AppColors.deepBlue),
        elevation: 1,
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
        elevation: 1,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.darkGrey;
      case 'preparing':
        return AppColors.warmOrange;
      case 'ready':
        return AppColors.green;
      case 'served':
        return AppColors.deepBlue;
      case 'payPending':
        return AppColors.amberGold;
      case 'paymentNotRecieved':
        return AppColors.softRed;
      default:
        return Colors.grey;
    }
  }

  String? _getTimeFromDateTime(DateTime? timestamp) {
    if (timestamp == null) return null;
    return DateFormat('h:mm a').format(timestamp.toLocal());
  }
}
