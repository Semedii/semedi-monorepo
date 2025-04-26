import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_kitchen/components/app_button.dart';
import 'package:semedi_kitchen/components/txt_form_field.dart';
import 'package:semedi_kitchen/cubit/login/login_cubit.dart';
import 'package:semedi_kitchen/services/auth_service.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';
import 'package:semedi_kitchen/services/service_locator.dart';
import 'package:semedi_kitchen/utils/app_colors.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final _authService = getIt<AuthService>();
  final _secureStorageService = getIt<SecureStorageService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: BlocProvider(
        create: (context) => LoginCubit(_authService, _secureStorageService),
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          builder: _mapStateToWidget,
        ),
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, LoginState state) {
    if (state is LoginInitial) {
      return _buildPageBody(context);
    }
    return const Center(child: CircularProgressIndicator());
  }

  Center _buildPageBody(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          padding: const EdgeInsets.all(40),
          decoration: _buildBoxDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 40),
              _buildLoginForm(context),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }

  Column _buildHeaderSection() {
    return Column(
      children: [
        _buildHeaderLogo(),
        const SizedBox(height: 16),
        _buildHeaderTitle(),
        const SizedBox(height: 8),
        _buildHeaderSubtitle(),
      ],
    );
  }

  Widget _buildHeaderLogo() {
    return Image.asset(
      'assets/images/logo.png',
      height: 120,
    );
  }

  Text _buildHeaderTitle() {
    return Text(
      'KITCHEN PORTAL',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
      ),
    );
  }

  Text _buildHeaderSubtitle() {
    return Text(
      'Login to manage orders',
      style: TextStyle(
        color: AppColors.darkGrey.withOpacity(0.6),
      ),
    );
  }

  Column _buildLoginForm(BuildContext context) {
    final cubit = BlocProvider.of<LoginCubit>(context);
    return Column(
      children: [
        _buildEmailField(cubit),
        const SizedBox(height: 20),
        _buildPasswordField(cubit),
        const SizedBox(height: 30),
        _buildLoginButton(cubit),
      ],
    );
  }

  TxtFormField _buildEmailField(LoginCubit cubit) {
    return TxtFormField(
      labelText: 'Email',
      prefixIcon: const Icon(
        Icons.email_outlined,
      ),
      onChanged: cubit.onEmailChanged,
    );
  }

  TxtFormField _buildPasswordField(LoginCubit cubit) {
    return TxtFormField(
      isTextObscure: true,
      labelText: 'Password',
      prefixIcon: const Icon(
        Icons.lock_outlined,
      ),
      onChanged: cubit.onPasswordChanged,
    );
  }

  AppButton _buildLoginButton(LoginCubit cubit) {
    return AppButton(
      isSmall: false,
      onPressed: cubit.onLogIn,
      text: "login",
    );
  }
}
