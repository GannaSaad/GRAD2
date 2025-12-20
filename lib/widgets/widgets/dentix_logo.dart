import 'package:flutter/material.dart';
import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';

class DentixLogo extends StatelessWidget {
  final double? fontSize;
  final Color? color;

  const DentixLogo({
    super.key,
    this.fontSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Dentix',
      style: AppTextStyles.headlineLarge.copyWith(
        fontSize: fontSize,
        color: color ?? AppColors.primaryBlue,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );
  }
}