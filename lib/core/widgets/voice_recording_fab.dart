import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../core/utils/app_colors.dart';

class VoiceRecordingFAB extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onPressed;
  final String? label;

  const VoiceRecordingFAB({
    super.key,
    required this.isRecording,
    required this.onPressed,
    this.label,
  });

  @override
  State<VoiceRecordingFAB> createState() => _VoiceRecordingFABState();
}

class _VoiceRecordingFABState extends State<VoiceRecordingFAB>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Scale pulse animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    // Rotation animation for stop icon
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Ripple animation
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(VoiceRecordingFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _scaleController.repeat(reverse: true);
      _rippleController.repeat();
      _rotationController.forward();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _scaleController.stop();
      _scaleController.reset();
      _rippleController.stop();
      _rippleController.reset();
      _rotationController.reverse();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _rippleController,
      ]),
      builder: (context, child) {
        return SizedBox(
          width: 80.r,
          height: 80.r,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ripple (largest)
              if (widget.isRecording)
                Transform.scale(
                  scale: 1.0 + (_rippleController.value * 0.8),
                  child: Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withOpacity(
                        (1 - _rippleController.value) * 0.3,
                      ),
                    ),
                  ),
                ),

              // Middle ripple
              if (widget.isRecording)
                Transform.scale(
                  scale: 1.0 + (_rippleController.value * 0.5),
                  child: Container(
                    width: 70.r,
                    height: 70.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withOpacity(
                        (1 - _rippleController.value) * 0.4,
                      ),
                    ),
                  ),
                ),

              // Main button
              Transform.scale(
                scale: widget.isRecording ? _scaleAnimation.value : 1.0,
                child: Container(
                  width: 65.r,
                  height: 65.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: widget.isRecording
                          ? [
                              Colors.red.shade400,
                              Colors.red.shade600,
                            ]
                          : [
                              AppColors.primaryBlue,
                              AppColors.primaryBlue.withOpacity(0.8),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isRecording
                                ? Colors.red
                                : AppColors.primaryBlue)
                            .withOpacity(0.5),
                        blurRadius: widget.isRecording ? 25 : 15,
                        spreadRadius: widget.isRecording ? 3 : 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100.r),
                      onTap: widget.onPressed,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            widget.isRecording
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            key: ValueKey(widget.isRecording),
                            color: Colors.white,
                            size: 32.r,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
