import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/cubit/customer/customer_cubit.dart';
import 'package:semedi_pos/models/customer.dart';
import 'package:semedi_pos/service/customer_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class CustomerScreen extends StatelessWidget {
  CustomerScreen({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerCubit(CustomerService())..initPage(),
      child: BlocConsumer<CustomerCubit, CustomerState>(
        listener: (context, state) {
          if (state is CustomerFailure) {
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

  Widget _mapStateToWidget(BuildContext context, CustomerState state) {
    if (state is CustomerLoaded) {
      return _buildScreenBody(context, state);
    }
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _buildScreenBody(BuildContext context, CustomerLoaded state) {
    final cubit = BlocProvider.of<CustomerCubit>(context);
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(context, cubit),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAddCustomerButton(context),
            const SizedBox(height: 16),
            _buildCustomerList(context, state.filtered, cubit),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, CustomerCubit cubit) {
    return AppBar(
      title: const Text('CUSTOMERS'),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TxtFormField(
            controller: searchController,
            labelText: 'Search by name or phone',
            onChanged: cubit.onSearch,
          ),
        ),
      ),
    );
  }

  Align _buildAddCustomerButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AppButton(
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.person_add, color: Colors.white),
            Text(
              "ADD CUSTOMER",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        onPressed: () => _buildAddDialog(context),
      ),
    );
  }

  Expanded _buildCustomerList(
      BuildContext context, List<Customer> customers, CustomerCubit cubit) {
    if (customers.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'No customers found.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) =>
            _buildCustomerCard(context, customers[index], cubit),
      ),
    );
  }

  Card _buildCustomerCard(
      BuildContext context, Customer customer, CustomerCubit cubit) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.deepBlue,
          child: Text(
            customer.name.isNotEmpty
                ? customer.name[0].toUpperCase()
                : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          customer.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        subtitle: Text(customer.phone),
        trailing: _buildCustomerCardTrailing(context, customer, cubit),
      ),
    );
  }

  Row _buildCustomerCardTrailing(
      BuildContext context, Customer customer, CustomerCubit cubit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: AppColors.amberGold ?? Colors.amber, size: 18),
        const SizedBox(width: 2),
        Text(
          '${customer.loyaltyPoints}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(Icons.add_circle_outline, color: AppColors.green),
          onPressed: () => _showLoyaltyDialog(context, customer, cubit),
          tooltip: 'Add points',
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red.shade400),
          onPressed: () => _buildDeleteDialog(context, customer, cubit),
        ),
      ],
    );
  }

  void _buildAddDialog(BuildContext context) {
    final cubit = BlocProvider.of<CustomerCubit>(context);
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TxtFormField(controller: nameController, labelText: 'Full Name'),
            const SizedBox(height: 16),
            TxtFormField(
                controller: phoneController, labelText: 'Phone Number'),
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
            text: 'Add',
            onPressed: () {
              cubit.onAddCustomer(nameController.text, phoneController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _buildDeleteDialog(
      BuildContext context, Customer customer, CustomerCubit cubit) {
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
                'Remove ${customer.name} from customers?',
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
                      cubit.onDeleteCustomer(customer);
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

  void _showLoyaltyDialog(
      BuildContext context, Customer customer, CustomerCubit cubit) {
    final pointsController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Points — ${customer.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current: ${customer.loyaltyPoints} pts',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            TxtFormField(
                controller: pointsController, labelText: 'Points to add'),
          ],
        ),
        actions: [
          AppButton(
            isOutlined: true,
            text: 'Cancel',
            isSmall: true,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          AppButton(
            text: 'Add',
            isSmall: true,
            onPressed: () {
              final pts = int.tryParse(pointsController.text) ?? 0;
              if (pts > 0) cubit.onAddLoyaltyPoints(customer, pts);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
