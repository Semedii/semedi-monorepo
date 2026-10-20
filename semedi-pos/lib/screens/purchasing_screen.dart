import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/cubit/purchaseOrder/purchase_order_cubit.dart';
import 'package:semedi_pos/cubit/supplier/supplier_cubit.dart';
import 'package:semedi_pos/models/purchase_order.dart';
import 'package:semedi_pos/models/purchase_order_item.dart';
import 'package:semedi_pos/models/supplier.dart';
import 'package:semedi_pos/screens/purchase_order_detail_screen.dart';
import 'package:semedi_pos/screens/spending_report_screen.dart';
import 'package:semedi_pos/service/purchase_order_service.dart';
import 'package:semedi_pos/service/supplier_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class PurchasingScreen extends StatelessWidget {
  PurchasingScreen({super.key});

  final SupplierService _supplierService = SupplierService();
  final PurchaseOrderService _purchaseOrderService = PurchaseOrderService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PURCHASING'),
          backgroundColor: AppColors.deepBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.store), text: 'Suppliers'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Orders'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Spending'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  SupplierCubit(_supplierService)..initPage(),
            ),
            BlocProvider(
              create: (_) =>
                  PurchaseOrderCubit(_purchaseOrderService, _supplierService)
                    ..initPage(),
            ),
          ],
          child: Builder(
            builder: (context) => BlocListener<SupplierCubit, SupplierState>(
              listener: (context, state) {
                if (state is SupplierFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.softRed,
                    ),
                  );
                }
              },
              child: BlocListener<PurchaseOrderCubit, PurchaseOrderState>(
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
                child: TabBarView(
                  children: [
                    _SuppliersTab(),
                    _OrdersTab(),
                    _SpendingTab(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuppliersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupplierCubit, SupplierState>(
      builder: (context, state) {
        if (state is SupplierLoaded) {
          return _buildBody(context, state);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildBody(BuildContext context, SupplierLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(context, state),
          const SizedBox(height: 16),
          _buildList(context, state.suppliers),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SupplierLoaded state) {
    return Row(
      children: [
        _buildCountChip(state.suppliers.length),
        const Spacer(),
        AppButton(
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.add, color: Colors.white),
              Text('ADD SUPPLIER', style: TextStyle(color: Colors.white)),
            ],
          ),
          onPressed: () => _showAddDialog(context),
        ),
      ],
    );
  }

  Container _buildCountChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.store, size: 16, color: AppColors.deepBlue),
          const SizedBox(width: 6),
          Text(
            '$count supplier${count == 1 ? '' : 's'}',
            style: TextStyle(color: AppColors.darkGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Supplier> suppliers) {
    if (suppliers.isEmpty) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Text(
              'No suppliers yet',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) =>
            _buildCard(context, suppliers[index]),
      ),
    );
  }

  Card _buildCard(BuildContext context, Supplier supplier) {
    final cubit = BlocProvider.of<SupplierCubit>(context);
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.deepBlue,
          child: Text(
            supplier.name[0].toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          supplier.name,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.darkGrey),
        ),
        subtitle: _buildSubtitle(supplier),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit,
                  color: AppColors.deepBlue.withOpacity(0.7)),
              onPressed: () => _showEditDialog(context, supplier, cubit),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade400),
              onPressed: () => _showDeleteDialog(context, supplier, cubit),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildSubtitle(Supplier supplier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.phone, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(supplier.phone,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            if (supplier.email != null && supplier.email!.isNotEmpty) ...[
              const SizedBox(width: 12),
              Icon(Icons.email, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Flexible(
                child: Text(supplier.email!,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ],
        ),
        if (supplier.note != null && supplier.note!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(supplier.note!,
                style:
                    TextStyle(color: Colors.grey.shade400, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    final cubit = BlocProvider.of<SupplierCubit>(context);
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.offWhite,
        title: const Text('Add Supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TxtFormField(controller: nameCtrl, labelText: 'Supplier Name'),
              const SizedBox(height: 12),
              TxtFormField(controller: phoneCtrl, labelText: 'Phone'),
              const SizedBox(height: 12),
              TxtFormField(
                  controller: emailCtrl, labelText: 'Email (optional)'),
              const SizedBox(height: 12),
              TxtFormField(
                  controller: noteCtrl, labelText: 'Note (optional)'),
            ],
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
            text: 'Add',
            onPressed: () {
              cubit.onAddSupplier(Supplier(
                id: '',
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim().isEmpty
                    ? null
                    : emailCtrl.text.trim(),
                note: noteCtrl.text.trim().isEmpty
                    ? null
                    : noteCtrl.text.trim(),
              ));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, Supplier supplier, SupplierCubit cubit) {
    final nameCtrl = TextEditingController(text: supplier.name);
    final phoneCtrl = TextEditingController(text: supplier.phone);
    final emailCtrl =
        TextEditingController(text: supplier.email ?? '');
    final noteCtrl =
        TextEditingController(text: supplier.note ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.offWhite,
        title: Text('Edit ${supplier.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TxtFormField(controller: nameCtrl, labelText: 'Supplier Name'),
              const SizedBox(height: 12),
              TxtFormField(controller: phoneCtrl, labelText: 'Phone'),
              const SizedBox(height: 12),
              TxtFormField(
                  controller: emailCtrl, labelText: 'Email (optional)'),
              const SizedBox(height: 12),
              TxtFormField(
                  controller: noteCtrl, labelText: 'Note (optional)'),
            ],
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
            text: 'Save',
            onPressed: () {
              cubit.onEditSupplier(
                Supplier(
                  id: supplier.id,
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  email: emailCtrl.text.trim().isEmpty
                      ? null
                      : emailCtrl.text.trim(),
                  note: noteCtrl.text.trim().isEmpty
                      ? null
                      : noteCtrl.text.trim(),
                ),
                supplier,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, Supplier supplier, SupplierCubit cubit) {
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
                'Remove ${supplier.name} from suppliers?',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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
                      cubit.onDeleteSupplier(supplier);
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

class _OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseOrderCubit, PurchaseOrderState>(
      builder: (context, state) {
        if (state is PurchaseOrderLoaded) {
          return _buildBody(context, state);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildBody(BuildContext context, PurchaseOrderLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTopBar(context, state),
          const SizedBox(height: 16),
          Expanded(child: _buildList(context, state)),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, PurchaseOrderLoaded state) {
    final draftCount = state.orders.where((o) => o.status == 'draft').length;
    final orderedCount =
        state.orders.where((o) => o.status == 'ordered').length;
    return Row(
      children: [
        _buildChip(
            label: '$draftCount draft', color: Colors.grey.shade600),
        const SizedBox(width: 8),
        _buildChip(
            label: '$orderedCount ordered', color: AppColors.warmOrange),
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

  Container _buildChip(
      {required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildList(BuildContext context, PurchaseOrderLoaded state) {
    if (state.orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Text(
            'No purchase orders yet',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: state.orders.length,
      itemBuilder: (context, index) =>
          _buildOrderCard(context, state.orders[index]),
    );
  }

  Card _buildOrderCard(BuildContext context, PurchaseOrder order) {
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
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildLeading(order),
              const SizedBox(width: 16),
              Expanded(child: _buildInfo(order)),
              _buildTrailing(context, order, cubit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(PurchaseOrder order) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _statusColor(order.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_statusIcon(order.status),
          color: _statusColor(order.status), size: 24),
    );
  }

  Column _buildInfo(PurchaseOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.supplierName,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
              fontSize: 15),
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

  Widget _buildTrailing(
    BuildContext context,
    PurchaseOrder order,
    PurchaseOrderCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusBadge(order.status),
        if (order.status == 'draft') ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => cubit.onMarkOrdered(order),
            child: Text(
              'Mark Ordered',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.deepBlue,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }

  Container _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: _statusColor(status)),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ordered':
        return AppColors.warmOrange;
      case 'received':
        return AppColors.green;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _statusIcon(String status) {
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
          content: const Text(
              'Add a supplier first before creating an order'),
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
              supplierId: supplierId, note: note, items: items);
        },
      ),
    );
  }
}

class _SpendingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseOrderCubit, PurchaseOrderState>(
      builder: (context, state) {
        if (state is PurchaseOrderLoaded) {
          return SpendingReportScreen(orders: state.orders);
        }
        return const Center(child: CircularProgressIndicator());
      },
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
                  labelText: 'Note (optional)'),
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
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
        Text('Items',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.darkGrey)),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.deepBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('${_items.length}',
              style:
                  const TextStyle(color: Colors.white, fontSize: 12)),
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
                    labelText: 'Item name'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TxtFormField(
                    controller: _itemUnitController,
                    labelText: 'Unit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TxtFormField(
                    controller: _itemQtyController, labelText: 'Qty'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TxtFormField(
                    controller: _itemCostController,
                    labelText: 'Unit cost'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addItem,
                icon: Icon(Icons.add_circle,
                    color: AppColors.green, size: 28),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(item.inventoryItemName,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey)),
            ),
            Text(
              '${item.orderedQuantity} ${item.unit}  ·  \$${item.totalCost.toStringAsFixed(2)}',
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removeItem(index),
              child: Icon(Icons.close,
                  size: 18, color: Colors.red.shade400),
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
                fontSize: 15),
          ),
        ],
      ),
    );
  }
}
