import 'package:flutter/material.dart';
import 'package:semedi_kitchen/components/app_button.dart';
import 'package:semedi_kitchen/components/txt_form_field.dart';
import 'package:semedi_kitchen/utils/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Center(
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
                _buildLoginForm(),
              ],
            ),
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

  Icon _buildHeaderLogo() {
    return Icon(
      Icons.kitchen,
      size: 48,
      color: AppColors.deepBlue,
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

  Column _buildLoginForm() {
    return Column(
      children: [
        _buildEmailField(),
        const SizedBox(height: 20),
        _buildPasswordField(),
        const SizedBox(height: 30),
        _buildLoginButton(),
      ],
    );
  }

  TxtFormField _buildEmailField() {
    return TxtFormField(
      labelText: 'Email',
      prefixIcon: const Icon(
        Icons.email_outlined,
      ),
      onChanged: (s) {},
    );
  }

  TxtFormField _buildPasswordField() {
    return TxtFormField(
      isTextObscure: true,
      labelText: 'Password',
      prefixIcon: const Icon(
        Icons.lock_outlined,
      ),
      onChanged: (s) {},
    );
  }

  AppButton _buildLoginButton() {
    return AppButton(
      isSmall: false,
      onPressed: () {},
      text: "login",
    );
  }
}
