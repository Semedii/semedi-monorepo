import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/cubit/purchaseOrder/purchase_order_cubit.dart';
import 'package:semedi_pos/models/purchase_order.dart';
import 'package:semedi_pos/models/purchase_order_item.dart';
import 'package:semedi_pos/models/supplier.dart';
import 'package:semedi_pos/screens/purchase_order_detail_screen.dart';
import 'package:semedi_pos/service/purchase_order_service.dart';
import 'package:semedi_pos/service/supplier_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class PurchaseOrdersScreen extends StatelessWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PurchaseOrderCubit(
        PurchaseOrderService(),
        SupplierService(),
      )..initPage(),
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
        },
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, PurchaseOrderState state) {
    if (state is PurchaseOrderLoaded) {
      return _buildScreenBody(context, state);
    }
    return Scaffold(
      appBar: _buildAppBar(),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _buildScreenBody(BuildContext context, PurchaseOrderLoaded state) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: _buildAppBarWithTabs(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTopBar(context, state),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildOrderList(context, state.orders, state),
                    _buildOrderList(
                      context,
                      state.orders
                          .where((o) => o.status == 'draft')
                          .toList(),
                      state,
                    ),
                    _buildOrderList(
                      context,
                      state.orders
                          .where((o) => o.status == 'ordered')
                          .toList(),
                      state,
                    ),
                    _buildOrderList(
                      context,
                      state.orders
                          .where((o) => o.status == 'received')
                          .toList(),
                      state,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('PURCHASE ORDERS'),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  PreferredSizeWidget _buildAppBarWithTabs() {
    return AppBar(
      title: const Text('PURCHASE ORDERS'),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      bottom: const TabBar(
        tabs: [
          Tab(text: 'All'),
          Tab(text: 'Draft'),
          Tab(text: 'Ordered'),
          Tab(text: 'Received'),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, PurchaseOrderLoaded state) {
    return Row(
      children: [
        _buildSummaryChips(state),
        const Spacer(),
        AppButton(
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.add, color: Colors.white),
              Text('NEW ORDER', style: TextStyle(color: Colors.white)),
            ],
          ),
          onPressed: () => _showCreateDialog(context, state.suppliers),
        ),
      ],
    );
  }

  Row _buildSummaryChips(PurchaseOrderLoaded state) {
    final draftCount = state.orders.where((o) => o.status == 'draft').length;
    final orderedCount =
        state.orders.where((o) => o.status == 'ordered').length;
    return Row(
      children: [
        _buildChip(
          label: '$draftCount draft',
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        _buildChip(
          label: '$orderedCount ordered',
          color: AppColors.warmOrange,
        ),
      ],
    );
  }

  Container _buildChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    List<PurchaseOrder> orders,
    PurchaseOrderLoaded state,
  ) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Text(
            'No orders here',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) =>
          _buildOrderCard(context, orders[index], state),
    );
  }

  Card _buildOrderCard(
    BuildContext context,
    PurchaseOrder order,
    PurchaseOrderLoaded state,
  ) {
    final cubit = BlocProvider.of<PurchaseOrderCubit>(context);
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseOrderDetailScreen(
              order: order,
              cubit: cubit,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildOrderLeading(order),
              const SizedBox(width: 16),
              Expanded(child: _buildOrderInfo(order)),
              _buildOrderTrailing(context, order, cubit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderLeading(PurchaseOrder order) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getStatusColor(order.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _getStatusIcon(order.status),
        color: _getStatusColor(order.status),
        size: 24,
      ),
    );
  }

  Column _buildOrderInfo(PurchaseOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.supplierName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${order.items.length} item${order.items.length == 1 ? '' : 's'}  ·  \$${order.totalCost.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(order.createdAt),
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildOrderTrailing(
    BuildContext context,
    PurchaseOrder order,
    PurchaseOrderCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusBadge(order.status),
        const SizedBox(height: 8),
        if (order.status == 'draft')
          GestureDetector(
            onTap: () => cubit.onMarkOrdered(order),
            child: Text(
              'Mark Ordered',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.deepBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (order.status == 'draft')
          GestureDetector(
            onTap: () => _showDeleteDialog(context, order, cubit),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.softRed,
              ),
            ),
          ),
      ],
    );
  }

  Container _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ordered':
        return Icons.local_shipping_outlined;
      case 'received':
        return Icons.check_circle_outline;
      default:
        return Icons.edit_note;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  void _showCreateDialog(BuildContext context, List<Supplier> suppliers) {
    final cubit = BlocProvider.of<PurchaseOrderCubit>(context);

    if (suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add a supplier first before creating an order'),
          backgroundColor: AppColors.warmOrange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _CreateOrderDialog(
        suppliers: suppliers,
        onConfirm: (supplierId, note, items) {
          cubit.onCreateOrder(
            supplierId: supplierId,
            note: note,
            items: items,
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    PurchaseOrder order,
    PurchaseOrderCubit cubit,
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
                'Confirm Delete',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e78c1),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete draft order from ${order.supplierName}?',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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
                    text: 'Delete',
                    onPressed: () {
                      cubit.onDeleteOrder(order);
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
}

class _CreateOrderDialog extends StatefulWidget {
  const _CreateOrderDialog({
    required this.suppliers,
    required this.onConfirm,
  });

  final List<Supplier> suppliers;
  final void Function(
    String supplierId,
    String? note,
    List<PurchaseOrderItem> items,
  ) onConfirm;

  @override
  State<_CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _CreateOrderDialogState extends State<_CreateOrderDialog> {
  late Supplier _selectedSupplier;
  final _noteController = TextEditingController();
  final List<PurchaseOrderItem> _items = [];

  final _itemNameController = TextEditingController();
  final _itemUnitController = TextEditingController();
  final _itemQtyController = TextEditingController();
  final _itemCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSupplier = widget.suppliers.first;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _itemNameController.dispose();
    _itemUnitController.dispose();
    _itemQtyController.dispose();
    _itemCostController.dispose();
    super.dispose();
  }

  void _addItem() {
    final name = _itemNameController.text.trim();
    final unit = _itemUnitController.text.trim();
    final qty = double.tryParse(_itemQtyController.text.trim());
    final cost = double.tryParse(_itemCostController.text.trim());

    if (name.isEmpty || unit.isEmpty || qty == null || cost == null) return;

    setState(() {
      _items.add(PurchaseOrderItem(
        inventoryItemName: name,
        unit: unit,
        orderedQuantity: qty,
        unitCost: cost,
      ));
      _itemNameController.clear();
      _itemUnitController.clear();
      _itemQtyController.clear();
      _itemCostController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.offWhite,
      title: const Text('New Purchase Order'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSupplierDropdown(),
              const SizedBox(height: 12),
              TxtFormField(
                controller: _noteController,
                labelText: 'Note (optional)',
              ),
              const SizedBox(height: 20),
              _buildItemsHeader(),
              const SizedBox(height: 8),
              _buildAddItemRow(),
              const SizedBox(height: 8),
              ..._buildItemsList(),
              if (_items.isNotEmpty) _buildTotalRow(),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          isOutlined: true,
          text: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 24),
        AppButton(
          text: 'Create',
          onPressed: _items.isEmpty
              ? null
              : () {
                  widget.onConfirm(
                    _selectedSupplier.id,
                    _noteController.text.trim().isEmpty
                        ? null
                        : _noteController.text.trim(),
                    _items,
                  );
                  Navigator.pop(context);
                },
        ),
      ],
    );
  }

  Widget _buildSupplierDropdown() {
    return DropdownButtonFormField<Supplier>(
      value: _selectedSupplier,
      decoration: InputDecoration(
        labelText: 'Supplier',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: widget.suppliers
          .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
          .toList(),
      onChanged: (s) {
        if (s != null) setState(() => _selectedSupplier = s);
      },
    );
  }

  Row _buildItemsHeader() {
    return Row(
      children: [
        Text(
          'Items',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.deepBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${_items.length}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAddItemRow() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TxtFormField(
                  controller: _itemNameController,
                  labelText: 'Item name',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TxtFormField(
                  controller: _itemUnitController,
                  labelText: 'Unit',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TxtFormField(
                  controller: _itemQtyController,
                  labelText: 'Qty',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TxtFormField(
                  controller: _itemCostController,
                  labelText: 'Unit cost',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addItem,
                icon: Icon(Icons.add_circle, color: AppColors.green, size: 28),
                tooltip: 'Add item',
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItemsList() {
    return _items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.inventoryItemName,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.darkGrey),
              ),
            ),
            Text(
              '${item.orderedQuantity} ${item.unit}  ·  \$${item.totalCost.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removeItem(index),
              child: Icon(Icons.close, size: 18, color: Colors.red.shade400),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildTotalRow() {
    final total =
        _items.fold(0.0, (sum, item) => sum + item.totalCost);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Total:  \$${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
