import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/txt_form_field.dart';
import 'package:semedi/cubits/password/password_cubit.dart';
import 'package:semedi/utils/app_colors.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PasswordCubit(),
      child: BlocBuilder<PasswordCubit, PasswordState>(
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, PasswordState state) {
    if (state is PasswordInitial) {
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: _buildAppBar(),
        body: _buildBody(context),
      );
    }
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.offWhite,
      title: const Text(
        'Change Password',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildPasswordFields(context),
          const SizedBox(height: 32),
          _buildUpdateButton(context),
        ],
      ),
    );
  }

  Widget _buildPasswordFields(BuildContext context) {
    final cubit = context.read<PasswordCubit>();
    return Column(
      children: [
        _buildPasswordField(
          label: 'Current Password',
          hintText: 'Enter your current password',
          onChanged: cubit.onCurrentPasswordFieldChanged,
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          label: 'New Password',
          hintText: 'Enter your new password',
          onChanged: cubit.onNewPasswordFieldChanged,
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          label: 'Confirm New Password',
          hintText: 'Re-enter your new password',
          onChanged: cubit.onConfirmNewPasswordFieldChanged,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        TxtFormField(
          labelText: hintText,
          isTextObscure: true,
          onChanged: onChanged,
        )
      ],
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return AppButton(
      text: "Update Password",
      onPressed: context.read<PasswordCubit>().onSubmit,
    );
  }
}
