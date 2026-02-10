import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';
import '../../core/core/utils/cubit/theme_cubit.dart';

typedef validatorFunction = String? Function(String?)?;

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final Icon? prefixIcon;
  final IconButton? suffixIcon;
  final validatorFunction validator;
  final bool isObscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool readOnly;
  final Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isObscure = false,
    this.validator,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.normal16Grey,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: ThemeCubit.isDark() ? AppColors.darkCard : AppColors.lightGreyColor,
        enabledBorder: buildBorder(ThemeCubit.isDark() ? AppColors.darkCard : AppColors.lightGreyColor),
        focusedBorder: buildBorder(AppColors.primaryColor),
        errorBorder: buildBorder(AppColors.redColor),
        focusedErrorBorder: buildBorder(AppColors.redColor),
      ),
      obscureText: isObscure,
      validator: validator,
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.headlineLarge,
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines,
      readOnly: readOnly,
    );
  }

  OutlineInputBorder buildBorder(Color borderColor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(
        color: borderColor,
        width: 1.2.w,
      ),
    );
  }
}
