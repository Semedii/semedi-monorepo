import 'package:flutter/material.dart';

class TxtFormField extends StatelessWidget {
  const TxtFormField({
    this.labelText,
    this.isTextObscure = false,
    this.isReadOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.controller,
    super.key,
  });
  final String? labelText;
  final bool isTextObscure;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isTextObscure,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelText: labelText,
        filled: isReadOnly,
        fillColor: isReadOnly ? Colors.grey.shade300 : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
