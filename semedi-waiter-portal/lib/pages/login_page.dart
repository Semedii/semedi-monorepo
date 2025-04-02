import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/txt_form_field.dart';
import 'package:semedi/cubits/cubit/login_cubit.dart';
import 'package:semedi/services/auth_service.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocProvider(
        create: (context) => LoginCubit(_authService),
        child: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            state as LoginInitial;
            final cubit = BlocProvider.of<LoginCubit>(context);
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeaderSection(context),
                  _buildLoginForm(cubit),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Container _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: _getHeaderDecoration(),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getLogo(),
            const SizedBox(height: 16),
            _getHeaderText(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _getHeaderDecoration() {
    return const BoxDecoration(
      color: Color(0xFF2563EB),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    );
  }

  Text _getHeaderText() {
    return const Text(
      "Waiter Portal",
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _getLogo() {
    return const Text(
      "Semedi",
      style: TextStyle(color: Colors.white, fontSize: 52),
    );
  }

  Padding _buildLoginForm(LoginCubit cubit) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildWelcomeAndSignInText(),
          const SizedBox(height: 32),
          _buildEmailField(cubit),
          const SizedBox(height: 16),
          _buildPasswordField(cubit),
          const SizedBox(height: 32),
          _buildLoginButton(cubit)
        ],
      ),
    );
  }

  Widget _buildWelcomeAndSignInText() {
    return Column(
      children: [
        _buildWelcomeText(),
        const SizedBox(height: 8),
        _buildSigninTExt(),
      ],
    );
  }

  Text _buildWelcomeText() {
    return const Text(
        textAlign: TextAlign.center,
        "Welcome Back",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ));
  }

  Text _buildSigninTExt() {
    return const Text(
      "Please sign in to continue",
      style: TextStyle(color: Color(0xFF64748B)),
      textAlign: TextAlign.center,
    );
  }

  TxtFormField _buildEmailField(LoginCubit cubit) {
    return TxtFormField(
      labelText: "Enter Email",
      prefixIcon: const Icon(Icons.email),
      onChanged: cubit.onEmailChanged,
    );
  }

  TxtFormField _buildPasswordField(LoginCubit cubit) {
    return TxtFormField(
      isTextObscure: true,
      labelText: "Enter Password",
      prefixIcon: const Icon(Icons.lock_outline),
      onChanged: cubit.onPasswordChanged,
    );
  }

  AppButton _buildLoginButton(LoginCubit cubit) {
    return AppButton(
      text: "Sign in",
      onPressed: cubit.onLoginPressed,
    );
  }
}
