import 'package:flutter/material.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * .35,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildLoginForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHeaderLogo(),
        const SizedBox(width: 12),
        _buildHeaderTitle(),
      ],
    );
  }

  Icon _buildHeaderLogo() {
    return Icon(
      Icons.point_of_sale,
      size: 32,
      color: AppColors.deepBlue,
    );
  }

  Text _buildHeaderTitle() {
    return Text(
      'SEMEDI POS',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
        letterSpacing: 1.2,
      ),
    );
  }

  Column _buildLoginForm(BuildContext context) {
    return Column(
      children: [
        _buildEmailField(),
        const SizedBox(height: 20),
        _buildPasswordField(context),
        const SizedBox(height: 30),
        _buildLoginButton(context),
      ],
    );
  }

  TxtFormField _buildEmailField() {
    return TxtFormField(
      labelText: 'Email',
      prefixIcon: Icon(
        Icons.badge,
        color: AppColors.darkGrey.withOpacity(0.6),
      ),
    );
  }

  TxtFormField _buildPasswordField(BuildContext context) {
    return TxtFormField(
      labelText: 'Password',
      isTextObscure: true,
      prefixIcon: Icon(Icons.lock, color: AppColors.darkGrey.withOpacity(0.6)),
    );
  }

  AppButton _buildLoginButton(BuildContext context) {
    return AppButton(
      text: 'Login ',
      color: AppColors.deepBlue,
      onPressed: () {},
    );
  }
}
