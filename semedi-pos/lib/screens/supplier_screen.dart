import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/cubit/supplier/supplier_cubit.dart';
import 'package:semedi_pos/models/supplier.dart';
import 'package:semedi_pos/service/supplier_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class SupplierScreen extends StatelessWidget {
  const SupplierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SupplierCubit(SupplierService())..initPage(),
      child: BlocConsumer<SupplierCubit, SupplierState>(
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
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, SupplierState state) {
    if (state is SupplierLoaded) {
      return _buildScreenBody(context, state);
    }
    return Scaffold(
      appBar: _buildAppBar(),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _buildScreenBody(BuildContext context, SupplierLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(context, state),
            const SizedBox(height: 16),
            _buildSupplierList(context, state.suppliers),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('SUPPLIERS'),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
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

  Widget _buildSupplierList(BuildContext context, List<Supplier> suppliers) {
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
            _buildSupplierCard(context, suppliers[index]),
      ),
    );
  }

  Card _buildSupplierCard(BuildContext context, Supplier supplier) {
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
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          supplier.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        subtitle: _buildSupplierSubtitle(supplier),
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

  Column _buildSupplierSubtitle(Supplier supplier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.phone, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              supplier.phone,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            if (supplier.email != null && supplier.email!.isNotEmpty) ...[
              const SizedBox(width: 12),
              Icon(Icons.email, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  supplier.email!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        if (supplier.note != null && supplier.note!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              supplier.note!,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    final cubit = BlocProvider.of<SupplierCubit>(context);
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.offWhite,
        title: const Text('Add Supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TxtFormField(
                controller: nameController,
                labelText: 'Supplier Name',
              ),
              const SizedBox(height: 12),
              TxtFormField(
                controller: phoneController,
                labelText: 'Phone',
              ),
              const SizedBox(height: 12),
              TxtFormField(
                controller: emailController,
                labelText: 'Email (optional)',
              ),
              const SizedBox(height: 12),
              TxtFormField(
                controller: noteController,
                labelText: 'Note (optional)',
              ),
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
              final supplier = Supplier(
                id: '',
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                email: emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                note: noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim(),
              );
              cubit.onAddSupplier(supplier);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, Supplier supplier, SupplierCubit cubit) {
    final nameController = TextEditingController(text: supplier.name);
    final phoneController = TextEditingController(text: supplier.phone);
    final emailController =
        TextEditingController(text: supplier.email ?? '');
    final noteController =
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
              TxtFormField(
                controller: nameController,
                labelText: 'Supplier Name',
              ),
              const SizedBox(height: 12),
              TxtFormField(
                controller: phoneController,
                labelText: 'Phone',
              ),
              const SizedBox(height: 12),
              TxtFormField(
                controller: emailController,
                labelText: 'Email (optional)',
              ),
              const SizedBox(height: 12),
              TxtFormField(
                controller: noteController,
                labelText: 'Note (optional)',
              ),
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
              final updated = Supplier(
                id: supplier.id,
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                email: emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                note: noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim(),
              );
              cubit.onEditSupplier(updated, supplier);
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
