import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../api/config/di/di.dart';
import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';
import '../../core/widgets/star_rating.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/use_cases/delete_review_use_case.dart';
import '../../domain/use_cases/get_doctor_reviews_use_case.dart';
import '../auth/auth_cubit/auth_cubit.dart';

class DoctorReviewsScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final bool isAdmin;

  const DoctorReviewsScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    this.isAdmin = false,
  });

  @override
  State<DoctorReviewsScreen> createState() => _DoctorReviewsScreenState();
}

class _DoctorReviewsScreenState extends State<DoctorReviewsScreen> {
  late final GetDoctorReviewsUseCase _getReviewsUseCase;
  late final DeleteReviewUseCase _deleteReviewUseCase;

  @override
  void initState() {
    super.initState();
    _getReviewsUseCase = getIt<GetDoctorReviewsUseCase>();
    _deleteReviewUseCase = getIt<DeleteReviewUseCase>();
  }

  Future<void> _deleteReview(String reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _deleteReviewUseCase.call(reviewId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete review: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Dr. ${widget.doctorName} Reviews'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ReviewEntity>>(
        stream: _getReviewsUseCase.call(widget.doctorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reviews = snapshot.data ?? [];

          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined,
                      size: 64.r, color: AppColors.textSecondary),
                  SizedBox(height: 16.h),
                  Text(
                    'No reviews yet',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Be the first to review this doctor',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculate average rating
          final avgRating = reviews.fold<double>(
                  0, (sum, review) => sum + review.rating) /
              reviews.length;

          return Column(
            children: [
              // Rating Summary
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    StarRating(rating: avgRating.round(), size: 24),
                    SizedBox(height: 8.h),
                    Text(
                      '${reviews.length} review${reviews.length != 1 ? 's' : ''}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Reviews List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return _buildReviewCard(review);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewEntity review) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Patient Avatar
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.primaryBlueSoft,
                  backgroundImage: review.patientImage != null
                      ? NetworkImage(review.patientImage!)
                      : null,
                  child: review.patientImage == null
                      ? Text(
                          review.patientName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.patientName,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(review.createdAt),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StarRating(rating: review.rating, size: 18),
                if (widget.isAdmin) ...[
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteReview(review.id),
                  ),
                ],
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              review.comment,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
