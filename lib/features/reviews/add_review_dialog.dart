import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../api/config/di/di.dart';
import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';
import '../../core/widgets/star_rating.dart';
import '../../domain/use_cases/add_review_use_case.dart';
import '../auth/auth_cubit/auth_cubit.dart';

class AddReviewDialog extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const AddReviewDialog({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = getIt<AuthCubit>().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final addReviewUseCase = getIt<AddReviewUseCase>();
      await addReviewUseCase.execute(
        doctorId: widget.doctorId,
        patientId: user.uid,
        patientName: user.fullName ?? 'Anonymous',
        patientImage: user.profileImage,
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true on success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.rate_review, color: AppColors.primaryBlue, size: 28.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rate Your Experience',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'with Dr. ${widget.doctorName}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Rating
              Center(
                child: Column(
                  children: [
                    Text(
                      'How was your visit?',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    StarRating(
                      rating: _rating,
                      size: 40,
                      activeColor: Colors.amber,
                      onRatingChanged: (rating) {
                        setState(() => _rating = rating);
                      },
                    ),
                    SizedBox(height: 8.h),
                    if (_rating > 0)
                      Text(
                        _getRatingText(_rating),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Comment
              Text(
                'Share your thoughts',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Tell us about your experience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
