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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Section: Back Arrow & Profile Image
              _buildTopSection(context),
              
              SizedBox(height: 24.h),
              
              // Name, Specialty & Reviews
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildNameAndReviews(),
              ),

              SizedBox(height: 20.h),

              // Stats Icons Row
              _buildStatsIcons(),

              SizedBox(height: 24.h),

              // Metrics Row (Patients, Experience, Reviews)
              _buildMetricsRow(),

              SizedBox(height: 30.h),

              // Clinic Location Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildClinicSection(),
              ),

              SizedBox(height: 24.h),

              // About Me Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildAboutSection(),
              ),

              SizedBox(height: 40.h),

              // Book Appointment Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: CustomElevatedButton(
                  buttonText: "Book Appointment",
                  onPressed: () {
                    Navigator.pushNamed(
                      context, 
                      AppRoutes.bookAppointment, 
                      arguments: doctor,
                    );
                  },
                  backgroundColor: AppColors.primaryBlue,
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Container(
              height: 150.h,
              color: AppColors.primaryBlueSoft.withOpacity(0.5),
            ),
            SizedBox(height: 100.h),
          ],
        ),
        Positioned(
          top: 10.h,
          left: 10.w,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: 50.h,
          child: Container(
            padding: EdgeInsets.all(4.r),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 90.r,
              backgroundImage: AssetImage(doctor.image),
            ),
          ),
        ),
        Positioned(
          bottom: 10.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  doctor.name,
                  style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                ),
                Text(
                  doctor.specialty,
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameAndReviews() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            doctor.name,
            style: AppTextStyles.headlineSmall,
          ),
        ),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 20.r),
            SizedBox(width: 4.w),
            Text("${doctor.rating} (${doctor.reviews} reviews)", style: AppTextStyles.labelMedium),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircularIcon(Icons.people_alt_outlined),
        SizedBox(width: 20.w),
        _buildCircularIcon(Icons.verified_outlined),
        SizedBox(width: 20.w),
        _buildCircularIcon(Icons.thumb_up_alt_outlined),
      ],
    );
  }

  Widget _buildCircularIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primaryBlue, size: 24.r),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMetricItem("1,000+", "Patients"),
        _buildMetricItem(doctor.experience, "Experience"),
        _buildMetricItem(doctor.rating, "Rating"),
      ],
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }

  Widget _buildClinicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Clinic Location", style: AppTextStyles.titleLarge),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppColors.primaryBlue, size: 20.r),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                doctor.clinic,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("About Me", style: AppTextStyles.titleLarge),
        SizedBox(height: 12.h),
        Text(
          doctor.bio,
          style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
        ),
      ],
    );
  }
}
