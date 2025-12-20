import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/core/utils/app_assets.dart';
import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';
import '../../core/core/utils/cubit/theme_cubit.dart';
import 'custom_elevated_button.dart';
import 'custom_text_form_field.dart';

class CustomAuthItem extends StatefulWidget {
  Widget child;
  String text1;
  String text2;

  CustomAuthItem({super.key,required this.child,required this.text1,required this.text2});

  @override
  State<CustomAuthItem> createState() => _CustomAuthItemState();
}

class _CustomAuthItemState extends State<CustomAuthItem> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.r),
                      bottomRight: Radius.circular(40.r),
                    ),
                    color: AppColors.primaryColor
                ),
                height:320.h,
                child:SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      Image.asset(AppImages.dentexLogo,height:100.h,width:100.w,),
                      SizedBox(height:10.h,),
                      Text(widget.text1, style: AppTextStyles.semiBold24White),
                      Text(widget.text2, style: AppTextStyles.semiBold24White.copyWith(fontSize: 18)),
                    ],
                  ),
                )
            ),
            Positioned(
              top:290.h,
              left:20.w,
              right:20.w,
              child:Container(
                padding:EdgeInsets.all(20.w),
                decoration:BoxDecoration(
                    color:ThemeCubit.isDark()?AppColors.darkCard:AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                          color:ThemeCubit.isDark()?AppColors.transparentColor:AppColors.grayColor.withOpacity(0.5),
                          blurRadius:10.r,
                          offset: Offset(0,4.h)
                      )
                    ]
                ),
                child:widget.child,
              ),
            )
          ],
        ),
      ),
    );
  }
}
