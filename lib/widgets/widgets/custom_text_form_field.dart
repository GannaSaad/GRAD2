import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';
import '../../core/core/utils/cubit/theme_cubit.dart';

typedef validatorFunction = String? Function(String?)?;
class CustomTextFormField extends StatelessWidget {
   String hintText;
   Icon? prefixIcon;
   IconButton? suffixIcon;
   validatorFunction validator;
   bool? isObscure;
   TextEditingController ? controller;
   TextInputType? keyboardType;
   CustomTextFormField({
     super.key,
     required this.hintText,
     this.prefixIcon = const Icon(null),
     this.suffixIcon,
      this.isObscure = false,
     this.validator,
      this.controller,
     this.keyboardType
   });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration:InputDecoration(
          // labelText:"Email or phone number",
          // labelStyle:AppTextStyles.normal16Grey,
          hintText:hintText,
          hintStyle:AppTextStyles.normal16Grey,
          prefixIcon:prefixIcon,
          suffixIcon:suffixIcon,
          filled:true,
          fillColor:ThemeCubit.isDark()?AppColors.darkCard:AppColors.lightGreyColor,
          enabledBorder:buildBorder(ThemeCubit.isDark()?AppColors.darkCard:AppColors.lightGreyColor),
          focusedBorder:buildBorder(AppColors.primaryColor),
          errorBorder:buildBorder(AppColors.redColor),
          focusedErrorBorder:buildBorder(AppColors.redColor),

      ),
      obscureText:isObscure!,
      validator:validator,
      controller:controller,
      style:Theme.of(context).textTheme.headlineLarge,
      keyboardType: keyboardType??TextInputType.none,
    );
  }
  OutlineInputBorder buildBorder(Color borderColor){
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
            color:borderColor,
            width:1.2.w
        )
    );
  }
}
