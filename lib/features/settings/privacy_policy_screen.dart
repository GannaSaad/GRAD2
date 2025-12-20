import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Privacy Policy", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy",
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              "Last Update: 13/12/2025",
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            _buildSectionText(
              "Dentix collects basic personal information to create your account, book appointments, and recommend nearby doctors. Location access is used only to improve service accuracy.\n\n"
              "Medical records and treatment plans are uploaded by licensed doctors and are accessible only to authorized healthcare providers. Dentix does not modify medical data.\n\n"
              "Your information is stored securely and is not shared except when required to operate the app or by law. By using Dentix, you agree to this policy."
            ),
            SizedBox(height: 32.h),
            Text(
              "Terms & Conditions",
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            _buildSectionText(
              "By using the Dentix application, you agree to comply with these Terms and Conditions. If you do not agree, please do not continue using the app."
            ),
            SizedBox(height: 16.h),
            _buildNumberedItem(1, "Patients may browse the app as guests, but booking and managing appointments requires account registration and OTP verification. You are responsible for maintaining the confidentiality of your account information."),
            _buildNumberedItem(2, "Appointments are scheduled based on doctor availability. Patients may cancel or reschedule appointments according to the rules shown in the app. Patient-initiated cancellations may affect the Dentix balance, while doctor-initiated cancellations may result in credit."),
            _buildNumberedItem(3, "Dentix does not provide medical diagnosis or treatment. All medical services are provided by independent healthcare professionals, and Dentix is not responsible for medical outcomes or decisions."),
            _buildNumberedItem(4, "Dentix reserves the right to update these terms at any time. Continued use of the app indicates acceptance of the latest version."),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyLarge.copyWith(height: 1.6, color: AppColors.textPrimary),
    );
  }

  Widget _buildNumberedItem(int number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. ",
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.6, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
