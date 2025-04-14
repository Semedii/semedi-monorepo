import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/cubit/management/management_cubit.dart';
import 'package:semedi_pos/models/waiter.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class WaiterManagementTab extends StatelessWidget {
  const WaiterManagementTab({required this.waiterList, super.key});

  final List<Waiter> waiterList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildAddWaiterButton(context),
          const SizedBox(height: 16),
          _buildWaitersList(),
        ],
      ),
    );
  }

  Align _buildAddWaiterButton(BuildContext context) {
    final cubit = BlocProvider.of<ManagementCubit>(context);
    return Align(
      alignment: Alignment.centerRight,
      child: AppButton(
        onPressed: () => _showAddWaiterDialog(context, cubit),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.person_add,
              color: AppColors.offWhite,
            ),
            Text(
              'ADD NEW WAITER',
              style: TextStyle(
                color: AppColors.offWhite,
              ),
            )
          ],
        ),
      ),
    );
  }

  Expanded _buildWaitersList() {
    return Expanded(
      child: ListView.builder(
        itemCount: waiterList.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(waiterList[index].name),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outlined,
                color: AppColors.softRed,
              ),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }

  void _showAddWaiterDialog(BuildContext context, ManagementCubit cubit) {
    TextEditingController? nameController = TextEditingController();
    TextEditingController? emailController = TextEditingController();
    TextEditingController? passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Add New Waiter')),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TxtFormField(
              controller: nameController,
              labelText: ' Name',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.deepBlue),
            ),
            const SizedBox(height: 8),
            TxtFormField(
              controller: emailController,
              labelText: ' Email',
              prefixIcon: Icon(Icons.mail_outline, color: AppColors.deepBlue),
            ),
            const SizedBox(height: 8),
            TxtFormField(
              controller: passwordController,
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.deepBlue),
              isTextObscure: true,
            ),
          ],
        ),
        actions: [
          AppButton(
            isOutlined: true,
            onPressed: () => Navigator.pop(context),
            text: 'cancel',
          ),
          AppButton(
            onPressed: () {
              cubit.onAddNewWaiter(
                nameController.text,
                emailController.text,
                passwordController.text,
              );
              Navigator.pop(context);
            },
            text: 'add',
          ),
        ],
      ),
    );
  }
}
