import 'package:flutter/material.dart';

class TxtFormField extends StatelessWidget {
  const TxtFormField({
    this.labelText,
    this.isTextObscure = false,
    this.prefixIcon,
    this.suffixIcon,
    super.key,
  });
  final String? labelText;
  final bool isTextObscure;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

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
        ));
  }
}
