
import 'package:flutter/material.dart';

import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';

class CustomElevatedButton extends StatelessWidget {
  final String? buttonText;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? borderSideColor;
  final Widget? child;
  final bool iconExists;

  const CustomElevatedButton({
    super.key,
    this.buttonText,
    this.textStyle,
    required this.onPressed,
    this.backgroundColor,
    this.borderSideColor,
    this.child,
    this.iconExists = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Correctly handle null to disable the button
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderSideColor ?? Colors.transparent, width: 1),
        ),
        backgroundColor: backgroundColor ?? AppColors.primaryColor,
        disabledBackgroundColor: AppColors.grayColor.withOpacity(0.5), // Visual for disabled state
        elevation: 0,
      ),
      child: iconExists
          ? child
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(buttonText ?? '', style: textStyle ?? AppTextStyles.medium16White),
              ],
            ),
    );
  }
}
