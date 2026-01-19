import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import 'doctors_listing_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
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
                    _buildNameSection(),
                    SizedBox(height: 24.h),
                    _buildMetricsGrid(),
                    SizedBox(height: 30.h),
                    _buildListSection("Education & Training", doctor.education, Icons.school_outlined),
                    SizedBox(height: 24.h),
                    _buildListSection("Certifications", doctor.certifications, Icons.verified_outlined),
                    SizedBox(height: 30.h),
                    _buildReviewsSection(),
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

  Widget _buildNameSection() {
    return Center(
      child: Column(
        children: [
          Text("Dr. ${doctor.name}", style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(doctor.rank, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(doctor.specialty, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
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

  Widget _buildReviewsSection() {
    final reviews = [
      {"user": "Ahmed M.", "rating": 5, "comment": "Excellent experience, very professional Professor. The implant procedure was painless."},
      {"user": "Sarah K.", "rating": 4, "comment": "Highly skilled specialist. Explained everything clearly during my scaling session."},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Patient Reviews", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            Text("See All", style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryBlue)),
          ],
        ),
        SizedBox(height: 16.h),
        ...reviews.map((rev) => Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(rev['user'] as String, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                  Row(
                    children: List.generate(5, (index) => Icon(
                      Icons.star, 
                      size: 14.r, 
                      color: index < (rev['rating'] as int) ? Colors.amber : AppColors.borderSoft
                    )),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(rev['comment'] as String, style: AppTextStyles.bodySmall),
            ],
          ),
        )),
      ],
    );
  }
}
