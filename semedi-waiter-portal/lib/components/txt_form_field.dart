import 'package:flutter/material.dart';

class TxtFormField extends StatelessWidget {
  const TxtFormField({
    this.labelText,
    this.isTextObscure = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    super.key,
  });
  final String? labelText;
  final bool isTextObscure;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isTextObscure,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
