
import 'package:flutter/material.dart';

import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';

class CustomElevatedButton extends StatelessWidget {
  String? buttonText;
  TextStyle? textStyle;
  VoidCallback? onPressed;
  Color? backgroundColor;
  Color? borderSideColor;
  Widget? child;
  bool iconExists;

  CustomElevatedButton({
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
      onPressed: () {
        onPressed!();
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderSideColor ?? Colors.transparent,width:1),
        ),
        backgroundColor: backgroundColor ?? AppColors.primaryColor,
        elevation:0
      ),
      child: iconExists
          ? child
          : Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              Text(buttonText??'', style: textStyle ?? AppTextStyles.medium16White),
            ],
          ),
    );
  }
}
