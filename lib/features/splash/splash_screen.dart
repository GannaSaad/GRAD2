import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';
import '../../core/core/utils/app_constants.dart';
import '../../widgets/widgets/dentix_logo.dart';
import '../../widgets/widgets/dentix_loading.dart';
import '../entry_selection/entry_selection_screen.dart';
import 'cubit/splash_cubit.dart';
import 'cubit/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit()..startSplash(),
      child: const SplashView(),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state.status == SplashStatus.finished) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const EntrySelectionScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.screenMargin,
            ),
            child: Column(
              children: [
                // Top spacer
                const Spacer(flex: 2),
                
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dentix logo
                    DentixLogo(fontSize: 36.sp),
                    
                    SizedBox(height: AppConstants.paddingM),
                    
                    // Subtitle
                    Text(
                      'Modern dental care, simplified.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                
                // Bottom spacer
                const Spacer(flex: 2),
                
                // Loading area
                const DentixLoading(),
                
                SizedBox(height: AppConstants.paddingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}