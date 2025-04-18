import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/txt_form_field.dart';
import 'package:semedi/cubits/login/login_cubit.dart';
import 'package:semedi/services/auth_service.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/services/service_locator.dart';
import 'package:semedi/utils/text_validators.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final authService = getIt<AuthService>();
  final secureStorageService = getIt<SecureStorageService>();
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocProvider(
        create: (context) => LoginCubit(authService, secureStorageService),
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
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
    if (state is LoginLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox.shrink();
  }

  _buildPageBody(BuildContext context) {
    final cubit = BlocProvider.of<LoginCubit>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderSection(context),
          _buildLoginForm(cubit),
        ],
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
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _getLogo() {
    return Image.asset(
      'assets/images/logo.png',
      height: 200,
    );
  }

  Padding _buildLoginForm(LoginCubit cubit) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formkey,
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
      validator: TextValidators.fieldRequired,
    );
  }

  TxtFormField _buildPasswordField(LoginCubit cubit) {
    return TxtFormField(
      isTextObscure: true,
      labelText: "Enter Password",
      prefixIcon: const Icon(Icons.lock_outline),
      onChanged: cubit.onPasswordChanged,
      validator: TextValidators.fieldRequired,
    );
  }

  AppButton _buildLoginButton(LoginCubit cubit) {
    return AppButton(
        text: "Sign in",
        onPressed: () {
          if (_formkey.currentState!.validate()) {
            cubit.onLoginPressed();
          }
        });
  }
}
