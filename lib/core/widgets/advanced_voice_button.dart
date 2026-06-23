import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../core/utils/app_colors.dart';
import '../core/utils/app_textstyles.dart';

class AdvancedVoiceButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;
  final Color? inactiveColor;

  const AdvancedVoiceButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<AdvancedVoiceButton> createState() => _AdvancedVoiceButtonState();
}

class _AdvancedVoiceButtonState extends State<AdvancedVoiceButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for active state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Wave animation for recording
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(AdvancedVoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
      _waveController.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop();
      _pulseController.reset();
      _waveController.stop();
      _waveController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
        decoration: BoxDecoration(
          gradient: widget.isActive
              ? LinearGradient(
                  colors: [
                    widget.activeColor ?? AppColors.primaryBlue,
                    (widget.activeColor ?? AppColors.primaryBlue).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: widget.isActive ? null : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: widget.isActive
                ? (widget.activeColor ?? AppColors.primaryBlue)
                : AppColors.borderSoft,
            width: 2.5,
          ),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: (widget.activeColor ?? AppColors.primaryBlue)
                        .withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mic icon with animations
            SizedBox(
              width: 60.r,
              height: 60.r,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ripple effect (only when active)
                  if (widget.isActive)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 60.r,
                            height: 60.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Middle ripple
                  if (widget.isActive)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value * 0.85,
                          child: Container(
                            width: 50.r,
                            height: 50.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Icon container
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isActive
                          ? Colors.white.withOpacity(0.25)
                          : AppColors.primaryBlue.withOpacity(0.1),
                    ),
                    child: Icon(
                      widget.isActive ? Icons.mic : Icons.mic_none_rounded,
                      color: widget.isActive
                          ? Colors.white
                          : (widget.inactiveColor ?? AppColors.primaryBlue),
                      size: 24.r,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Label
            Text(
              widget.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: widget.isActive
                    ? Colors.white
                    : (widget.inactiveColor ?? AppColors.primaryBlue),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            
            // Animated wave bars (only when active)
            if (widget.isActive) ...[
              SizedBox(height: 12.h),
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final double height = 3.h +
                          (math.sin((_waveController.value * 2 * math.pi) +
                                      (index * 0.5)) *
                                  2.h)
                              .abs();
                      return Container(
                        width: 3.w,
                        height: height,
                        margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      );
                    }),
                  );
                },
              ),
              SizedBox(height: 4.h),
              Text(
                "Recording...",
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
