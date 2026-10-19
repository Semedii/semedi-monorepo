import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:semedi_pos/components/order_card.dart';
import 'package:semedi_pos/components/payment_dialog.dart';
import 'package:semedi_pos/components/split_bill_dialog.dart';
import 'package:semedi_pos/cubit/order/order_cubit.dart';
import 'package:semedi_pos/models/order_item.dart';
import 'package:semedi_pos/models/order_model.dart';
import 'package:semedi_pos/screens/take_order_screen.dart';
import 'package:semedi_pos/service/thermal_reciept_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class TableOrderScreen extends StatelessWidget {
  const TableOrderScreen({
    required this.orderCubit,
    required this.tableNumber,
    this.exchangeRate,
    super.key,
  });
  final OrderCubit orderCubit;
  final int tableNumber;
  final int? exchangeRate;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return BlocProvider.value(
      value: orderCubit,
      child: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoaded) {
            List<OrderModel> tableOrders = state.activeOrders
                    ?.where((o) => o.tableNumber == tableNumber)
                    .toList() ??
                [];
            return Scaffold(
              backgroundColor: AppColors.offWhite,
              appBar: _buildAppBar(context, tableOrders),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.builder(
                    gridDelegate: _buildGridDelegate(height),
                    itemCount: tableOrders.length,
                    itemBuilder: (context, index) => OrderCard(
                      order: tableOrders[index],
                      exchangeRate: exchangeRate,
                      onChangeOrderStatus: orderCubit.changeOrderStatus,
                      onCancelOrder: orderCubit.onCancelOrder,
                    ),
                  ),
                ),
              ),
            );
          }
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, List<OrderModel> tableOrders) {
    double total = 0;
    for (var order in tableOrders) {
      total += order.totalPrice;
    }
    return AppBar(
      titleSpacing: 16,
      elevation: 0.8,
      backgroundColor: AppColors.deepBlue,
      foregroundColor: AppColors.offWhite,
      title: Row(
        children: [
          Text(
            "Table $tableNumber    Total: \$$total",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        _buildAppBarButton(
          Icons.print,
          "Print",
          () {
            _generateAndPrintReceipt(context, tableOrders);
          },
        ),
        _buildAppBarButton(Icons.payment, "Pay All",
            () => showPaymentDialog(context, tableOrders, total)),
        _buildAppBarButton(Icons.call_split, "Split",
            () => showSplitBillDialog(context, tableOrders, total)),
        _buildAppBarButton(
          Icons.add_circle_outline,
          "Extras",
          () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TakeOrderScreen(
                          isDineIn: true,
                          tableNumber: tableNumber,
                        )));
          },
        ),
      ],
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate(double height) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      mainAxisExtent: height * 0.67,
    );
  }

  Future<void> _generateAndPrintReceipt(
    BuildContext context,
    List<OrderModel>? tableOrders,
  ) async {
    try {
      if (tableOrders == null || tableOrders.isEmpty) {
        return;
      } //todo
      List<OrderItem> items = [];
      double total = 0;
      for (var order in tableOrders) {
        total += order.totalPrice;
        for (var item in order.items) {
          items.add(item);
        }
      }
      final pdfBytes = await ThermalReceiptService.generateOrderReceiptBytes(
          orderNumber: tableOrders.first.id,
          waiter: tableOrders.first.waiterName,
          items: items,
          total: total,
          dateTime: tableOrders.first.createdAt);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing receipt: ${e.toString()}')),
      );
    }
  }

  _buildAppBarButton(IconData icon, String label, Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          foregroundColor: AppColors.offWhite,
        ),
        icon: Icon(icon, size: 20),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }

  void showPaymentDialog(
      BuildContext context, List<OrderModel> orders, double total) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return PaymentDialog.payAll(orderList: orders, total: total);
      },
    );
  }

  void showSplitBillDialog(
      BuildContext context, List<OrderModel> orders, double total) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SplitBillDialog(
          orders: orders,
          total: total,
          exchangeRate: exchangeRate,
        );
      },
    );
  }
}
