import 'package:flutter/material.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    this.text,
    this.child,
    this.color,
    this.onPressed,
    this.elevation,
    this.isOutlined = false,
    this.isSmall = true,
    super.key,
  });

  final String? text;
  final Color? color;
  final Widget? child;
  final bool isOutlined;
  final double? elevation;
  final Function()? onPressed;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isSmall ? 200 : double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          backgroundColor: isOutlined ? null : color ?? AppColors.deepBlue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.deepBlue)),
        ),
        child: child ??
            Text(
              "${text?.toUpperCase()}",
              style: TextStyle(color: isOutlined ? Colors.black : Colors.white),
            ),
      ),
    );
  }
}
