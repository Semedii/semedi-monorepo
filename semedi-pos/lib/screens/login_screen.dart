import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/cubit/login/login_cubit.dart';
import 'package:semedi_pos/service/service_locator.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: BlocProvider(
        create: (context) => LoginCubit(getIt(), getIt()),
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

  Widget _buildPageBody(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * .4,
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
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHeaderLogo(),
        const SizedBox(height: 24),
        _buildHeaderTitle(),
      ],
    );
  }

  Widget _buildHeaderLogo() {
    return Image.asset(
      "assets/images/logo.png",
      height: 150,
    );
  }

  Text _buildHeaderTitle() {
    return Text(
      'eDine',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
        letterSpacing: 1.2,
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
      prefixIcon: Icon(
        Icons.email_outlined,
        color: AppColors.darkGrey.withOpacity(0.6),
      ),
      onChanged: cubit.onEmailChanged,
    );
  }

  TxtFormField _buildPasswordField(LoginCubit cubit) {
    return TxtFormField(
      labelText: 'Password',
      isTextObscure: true,
      prefixIcon: Icon(Icons.lock, color: AppColors.darkGrey.withOpacity(0.6)),
      onChanged: cubit.onPasswordChanged,
    );
  }

  AppButton _buildLoginButton(LoginCubit cubit) {
    return AppButton(
      text: 'Login ',
      color: AppColors.deepBlue,
      onPressed: cubit.onLogin,
    );
  }
}
