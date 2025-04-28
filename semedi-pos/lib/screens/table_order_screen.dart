import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:semedi_pos/components/order_card.dart';
import 'package:semedi_pos/cubit/order/order_cubit.dart';
import 'package:semedi_pos/models/order.dart';
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
    return AppBar(
      title: Text(
        'Table $tableNumber',
        style: const TextStyle(letterSpacing: 1.5),
      ),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [_buildPrintButton(context, tableOrders)],
    );
  }

  IconButton _buildPrintButton(
      BuildContext context, List<OrderModel>? tableOrders) {
    return IconButton(
      onPressed: () => _generateAndPrintReceipt(context, tableOrders),
      icon: Icon(
        Icons.print,
        color: AppColors.offWhite,
      ),
      tooltip: 'Print Reciept',
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
      }

      Map<String, int> itemsWithQuantity = {};
      Map<String, double> itemsWithPrices = {};
      double total = 0;
      final orderNumbers = <String>[];

      for (var order in tableOrders) {
        itemsWithQuantity.addEntries(order.itemsWithQuantity.entries);
        itemsWithPrices.addEntries(order.itemsWithPrices.entries);
        total += order.total;
        orderNumbers.add(order.orderNumber!);
      }

      final pdfBytes = await ThermalReceiptService.generateOrderReceiptBytes(
          orderNumber: orderNumbers.join(', #'),
          tableNumber: tableOrders.first.tableNumber.toString(),
          waiter: tableOrders.first.waiter,
          items: itemsWithQuantity,
          prices: itemsWithPrices,
          total: total,
          exchangeRate: exchangeRate,
          dateTime: tableOrders.last.timestamp);

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
