import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/core/utils/app_assets.dart';
import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';
import '../../core/core/utils/cubit/theme_cubit.dart';

class CustomAuthItem extends StatefulWidget {
  final Widget child;
  final String text1;
  final String text2;

  const CustomAuthItem({super.key, required this.child, required this.text1, required this.text2});

  @override
  State<CustomAuthItem> createState() => _CustomAuthItemState();
}

class _CustomAuthItemState extends State<CustomAuthItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            // Blue Header
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.r),
                  bottomRight: Radius.circular(40.r),
                ),
                color: AppColors.primaryColor,
              ),
              height: 280.h, // Slightly reduced height since logo is gone
              width: double.infinity,
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.text1, style: AppTextStyles.semiBold24White),
                    Text(widget.text2, style: AppTextStyles.semiBold24White.copyWith(fontSize: 18.sp)),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            // White Content Card
            Padding(
              padding: EdgeInsets.only(top: 240.h, left: 20.w, right: 20.w, bottom: 40.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: ThemeCubit.isDark() ? AppColors.darkCard : AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeCubit.isDark() ? AppColors.transparentColor : AppColors.grayColor.withOpacity(0.5),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    )
                  ],
                ),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
