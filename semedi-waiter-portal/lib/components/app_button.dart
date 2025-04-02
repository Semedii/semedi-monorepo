import 'package:flutter/material.dart';
import 'package:semedi/utils/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    this.color,
    this.onPressed,
    this.isOutlined = false,
    super.key,
  });

  final String text;
  final Color? color;
  final bool isOutlined;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? null : color ?? AppColors.deepBlue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.deepBlue)),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(color: isOutlined ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}
