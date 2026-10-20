import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/cubit/purchaseOrder/purchase_order_cubit.dart';
import 'package:semedi_pos/models/purchase_order.dart';
import 'package:semedi_pos/models/purchase_order_item.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class PurchaseOrderDetailScreen extends StatelessWidget {
  const PurchaseOrderDetailScreen({
    required this.order,
    required this.cubit,
    super.key,
  });

  final PurchaseOrder order;
  final PurchaseOrderCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocConsumer<PurchaseOrderCubit, PurchaseOrderState>(
        listener: (context, state) {
          if (state is PurchaseOrderFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: AppColors.softRed,
              ),
            );
          }
          if (state is PurchaseOrderLoaded) {
            final updated = state.orders.where((o) => o.id == order.id);
            if (updated.isEmpty) Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final currentOrder = state is PurchaseOrderLoaded
              ? state.orders.firstWhere(
                  (o) => o.id == order.id,
                  orElse: () => order,
                )
              : order;
          return _buildScreen(context, currentOrder);
        },
      ),
    );
  }

  Scaffold _buildScreen(BuildContext context, PurchaseOrder currentOrder) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(currentOrder),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(currentOrder),
            const SizedBox(height: 20),
            _buildItemsSection(context, currentOrder),
            const SizedBox(height: 20),
            _buildTotalSection(currentOrder),
            const SizedBox(height: 20),
            _buildActionsSection(context, currentOrder),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(PurchaseOrder currentOrder) {
    return AppBar(
      title: Text(currentOrder.supplierName.toUpperCase()),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildOrderHeader(PurchaseOrder currentOrder) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: AppColors.deepBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  currentOrder.supplierName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(currentOrder.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildHeaderRow(
              Icons.calendar_today,
              _formatDate(currentOrder.createdAt),
            ),
            const SizedBox(height: 6),
            _buildHeaderRow(
              Icons.inventory_2_outlined,
              '${currentOrder.items.length} item${currentOrder.items.length == 1 ? '' : 's'}  ·  '
              '${currentOrder.receivedItemCount} received',
            ),
            if (currentOrder.note != null &&
                currentOrder.note!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildHeaderRow(Icons.notes, currentOrder.note!),
            ],
          ],
        ),
      ),
    );
  }

  Row _buildHeaderRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Container _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context, PurchaseOrder currentOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 10),
        ...currentOrder.items.map(
          (item) => _buildItemCard(context, item, currentOrder),
        ),
      ],
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    PurchaseOrderItem item,
    PurchaseOrder currentOrder,
  ) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                _buildItemStatusIcon(item),
                const SizedBox(width: 12),
                Expanded(child: _buildItemInfo(item)),
                _buildItemCostInfo(item),
              ],
            ),
            if (currentOrder.status == 'ordered' && !item.isFullyReceived) ...[
              const SizedBox(height: 10),
              _buildReceiveProgress(item),
              const SizedBox(height: 8),
              _buildReceiveButton(context, item, currentOrder),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemStatusIcon(PurchaseOrderItem item) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: item.isFullyReceived
            ? AppColors.green.withOpacity(0.1)
            : Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        item.isFullyReceived ? Icons.check : Icons.pending_outlined,
        size: 18,
        color: item.isFullyReceived ? AppColors.green : Colors.grey.shade500,
      ),
    );
  }

  Column _buildItemInfo(PurchaseOrderItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.inventoryItemName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${item.orderedQuantity} ${item.unit}  ·  \$${item.unitCost}/unit',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Column _buildItemCostInfo(PurchaseOrderItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${item.totalCost.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        if (item.receivedQuantity > 0)
          Text(
            '${item.receivedQuantity} rcvd',
            style: TextStyle(color: AppColors.green, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildReceiveProgress(PurchaseOrderItem item) {
    final progress = item.orderedQuantity > 0
        ? (item.receivedQuantity / item.orderedQuantity).clamp(0.0, 1.0)
        : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Received: ${item.receivedQuantity} / ${item.orderedQuantity} ${item.unit}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: AppColors.deepBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.deepBlue),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  Align _buildReceiveButton(
    BuildContext context,
    PurchaseOrderItem item,
    PurchaseOrder currentOrder,
  ) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () => _showReceiveDialog(context, item, currentOrder),
        icon: Icon(Icons.move_to_inbox, size: 16, color: AppColors.green),
        label: Text(
          'Receive',
          style: TextStyle(color: AppColors.green, fontSize: 13),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          backgroundColor: AppColors.green.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSection(PurchaseOrder currentOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Order Cost',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
              fontSize: 15,
            ),
          ),
          Text(
            '\$${currentOrder.totalCost.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, PurchaseOrder currentOrder) {
    final cubitRef = BlocProvider.of<PurchaseOrderCubit>(context);
    if (currentOrder.status == 'received') {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (currentOrder.status == 'ordered')
          AppButton(
            isSmall: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.done_all, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'MARK ALL RECEIVED',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            onPressed: () =>
                _showMarkReceivedDialog(context, currentOrder, cubitRef),
          ),
        if (currentOrder.status == 'draft') ...[
          AppButton(
            isSmall: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.local_shipping_outlined, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'MARK AS ORDERED',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            onPressed: () => cubitRef.onMarkOrdered(currentOrder),
          ),
        ],
      ],
    );
  }

  void _showReceiveDialog(
    BuildContext context,
    PurchaseOrderItem item,
    PurchaseOrder currentOrder,
  ) {
    final cubitRef = BlocProvider.of<PurchaseOrderCubit>(context);
    final receivedController = TextEditingController(
      text: item.orderedQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.offWhite,
        title: Text('Receive ${item.inventoryItemName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ordered: ${item.orderedQuantity} ${item.unit}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            TxtFormField(
              controller: receivedController,
              labelText: 'Quantity received',
            ),
          ],
        ),
        actions: [
          AppButton(
            isOutlined: true,
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 24),
          AppButton(
            text: 'Confirm',
            onPressed: () {
              final qty = double.tryParse(receivedController.text.trim());
              if (qty == null) return;
              cubitRef.onReceiveItem(
                order: currentOrder,
                item: item,
                receivedQuantity: qty,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showMarkReceivedDialog(
    BuildContext context,
    PurchaseOrder currentOrder,
    PurchaseOrderCubit cubitRef,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * .5,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Mark Order Received',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e78c1),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mark this entire order as fully received?\nInventory will not be auto-updated for unconfirmed items.',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AppButton(
                    isOutlined: true,
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                  AppButton(
                    text: 'Confirm',
                    onPressed: () {
                      cubitRef.onMarkReceived(currentOrder);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ordered':
        return AppColors.warmOrange;
      case 'received':
        return AppColors.green;
      default:
        return Colors.grey.shade600;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
