import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../domain/use_cases/get_doctor_reviews_use_case.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import 'doctors_listing_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    // Ensure specialty is synced if it was old data
    String displaySpecialty = doctor.specialty;
    if (displaySpecialty.toLowerCase() == "dermatology") {
      displaySpecialty = "Oral Surgery & Implantology";
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context),
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameSection(displaySpecialty),
                    SizedBox(height: 24.h),
                    _buildMetricsGrid(),
                    SizedBox(height: 30.h),
                    _buildListSection("Education & Training", doctor.education, Icons.school_outlined),
                    SizedBox(height: 24.h),
                    _buildListSection("Certifications", doctor.certifications, Icons.verified_outlined),
                    SizedBox(height: 30.h),
                    _buildReviewsSection(context),
                    SizedBox(height: 40.h),
                    CustomElevatedButton(
                      buttonText: "Book Appointment",
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.bookAppointment, arguments: doctor);
                      },
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200.h,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40.r),
              bottomRight: Radius.circular(40.r),
            ),
          ),
        ),
        Positioned(
          top: 10.h,
          left: 10.w,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(top: 100.h),
            padding: EdgeInsets.all(4.r),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 70.r,
              backgroundImage: AssetImage(doctor.image),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection(String specialty) {
    return Center(
      child: Column(
        children: [
          Text("Dr. ${doctor.name}", style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(doctor.rank, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(specialty, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMetricItem(doctor.experience, "Years Experience"),
          _buildMetricDivider(),
          _buildMetricItem(doctor.rating, "Rating"),
          _buildMetricDivider(),
          _buildMetricItem(doctor.reviews, "Reviews"),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }

  Widget _buildMetricDivider() => Container(height: 30.h, width: 1, color: AppColors.borderSoft);

  Widget _buildListSection(String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        SizedBox(height: 12.h),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18.r, color: AppColors.primaryGold),
              SizedBox(width: 12.w),
              Expanded(child: Text(item, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    try {
      final getReviewsUseCase = getIt<GetDoctorReviewsUseCase>();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Patient Reviews", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          SizedBox(height: 16.h),
          StreamBuilder(
            stream: getReviewsUseCase.call(doctor.id),
            builder: (context, snapshot) {
              // Show loading only briefly
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 50.h,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              // On error or empty, show placeholder
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined, size: 40.r, color: AppColors.textSecondary),
                        SizedBox(height: 8.h),
                        Text("No reviews yet", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        Text("Be the first to review!", style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                );
              }

              final reviews = snapshot.data!.take(2).toList();

              return Column(
                children: reviews.map((review) => Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16.r,
                            backgroundColor: AppColors.primaryBlueSoft,
                            child: Text(
                              review.patientName.substring(0, 1).toUpperCase(),
                              style: TextStyle(color: AppColors.primaryBlue, fontSize: 12.sp),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              review.patientName, 
                              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)
                            ),
                          ),
                          StarRating(rating: review.rating, size: 14),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(review.comment, style: AppTextStyles.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                )).toList(),
              );
            },
          ),
        ],
      );
    } catch (e) {
      // If GetIt fails, show placeholder
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Patient Reviews", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.rate_review_outlined, size: 40.r, color: AppColors.textSecondary),
                  SizedBox(height: 8.h),
                  Text("No reviews yet", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}
