
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_textstyles.dart';
import 'cubit/theme_cubit.dart';

class DialogUtils{
  static void  showLoadingDialog(BuildContext context) {
    final isDark = ThemeCubit.isDark();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.whiteColor,
          content: Row(
            children: [
              const SizedBox(width: 20),
              CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 20),
              Text(
                'Loading...',
                style: isDark ? AppTextStyles.regular16White : AppTextStyles.regular16Dark,
              ),
            ],
          ),
        );
      },
    );
  }
  static void hideLoadingDialog(BuildContext context){
    Navigator.pop(context);
  }
  static void showMessageDiaolog(
      {
        required BuildContext context,
        String? title,
        required String message,
        String? postActionName,
        Function? postActionFunction,
        String? negActionName,
        Function? negActionFunction
      }) {
    final isDark = ThemeCubit.isDark();
    showDialog(
      context: context,
      barrierDismissible:false,
      builder: (context) {
        List<Widget>actions=[];
        if(postActionName!=null){
          actions.add(
              TextButton(onPressed: (){
                Navigator.pop(context);
                postActionFunction?.call();

              }, child: Text(postActionName,style: AppTextStyles.medium14LightPrimary,)));
        }
        if(negActionName!=null){
          actions.add(TextButton(onPressed: (){
            Navigator.pop(context);
            negActionFunction?.call();

          }, child: Text(negActionName,style:AppTextStyles.medium14LightPrimary,)));
        }
        return AlertDialog(
            backgroundColor: isDark ? AppColors.darkCard : AppColors.whiteColor,
            title: Text(title??" ",style: AppTextStyles.medium14LightPrimary,),
            content: Text(
              message,
              style: isDark 
                ? AppTextStyles.medium14PrimaryDark.copyWith(color: AppColors.whiteColor) 
                : AppTextStyles.medium14PrimaryDark,
            ),
            actions: actions
        );
      },
    );
  }
}