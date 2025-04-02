import 'package:flutter/material.dart';
import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/txt_form_field.dart';
import 'package:semedi/components/waiters_dropdown_list.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(context),
            _buildLoginForm(),
          ],
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

  Padding _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildWelcomeAndSignInText(),
          const SizedBox(height: 32),
          _buildLoginFormText(),
          const SizedBox(height: 8),
          const WaitersDropdownList(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 32),
          _buildLoginButton()
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

  Text _buildLoginFormText() {
    return const Text(
      "Select Waiter",
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: Color(0xFF1E293B),
      ),
    );
  }

  TxtFormField _buildPasswordField() {
    return const TxtFormField(
      isTextObscure: true,
      labelText: "Enter Password",
      prefixIcon: Icon(Icons.lock_outline),
    );
  }

  AppButton _buildLoginButton() {
    return AppButton(
      text: "Sign in",
      onPressed: () {},
    );
  }
}
