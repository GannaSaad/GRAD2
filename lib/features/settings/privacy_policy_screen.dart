import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../auth/auth_cubit/auth_cubit.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();
    final role = authCubit.currentUser?.role?.toLowerCase() ?? 'patient';
    final bool isDoctor = role == 'doctor';
    final bool isNurse = role == 'nurse';
    final bool isReceptionist = role == 'receptionist';
    final bool isAdmin = role == 'admin';

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
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin 
                  ? "Admin Privacy Policy" 
                  : (isDoctor ? "Doctor Privacy & Terms" : (isNurse || isReceptionist ? "Staff Privacy Policy" : "Privacy Policy")),
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              "Last Update: 04/01/2026",
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            if (isAdmin)
              _buildAdminPolicyContent()
            else if (isDoctor)
              _buildDoctorPolicyContent()
            else if (isNurse)
              _buildNursePolicyContent()
            else if (isReceptionist)
              _buildReceptionistPolicyContent()
            else
              _buildPatientPolicyContent(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionText(
          "Dentix is committed to protecting the privacy, security, and integrity of all data accessed and managed by Admin users. Admin accounts are authorized and assigned by the system owner, and provide elevated access to manage doctors, patients, subscriptions, and platform operations. All personal, professional, and system-level data handled by Admins is securely stored and used solely for the operation, management, and improvement of the Dentix platform."
        ),
        SizedBox(height: 24.h),
        _buildSectionText(
          "Admins may access sensitive information including doctor profiles, patient accounts, billing records, subscription details, and support requests. This access must be exercised only for legitimate administrative and operational purposes. Any misuse, unauthorized disclosure, or use of data outside the platform’s scope is strictly prohibited."
        ),
        SizedBox(height: 24.h),
        _buildSectionText(
          "Admins are responsible for maintaining the confidentiality of their login credentials and ensuring secure use of their accounts. All administrative actions—including approvals, rejections, bans, and account modifications—are logged for auditing and accountability."
        ),
        SizedBox(height: 24.h),
        _buildSectionText(
          "Dentix reserves the right to suspend or revoke Admin access in cases of data misuse, security violations, or non-compliance with platform policies. This policy may be updated periodically, and any changes will be communicated through official platform channels."
        ),
      ],
    );
  }

  Widget _buildDoctorPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionText(
            "Dentix is committed to protecting the privacy, security, and confidentiality of all doctors using the platform. All personal, professional, and clinic-related information provided by doctors—including identity details, qualifications, certifications, patient assignments, scheduling data, and billing information—is securely stored and used solely for platform operations, service delivery, and system improvements. Dentix does not share doctor data with third parties except where required by law or necessary to provide core platform services."),
        SizedBox(height: 24.h),
        _buildSectionText(
            "Doctors are responsible for maintaining the confidentiality of their login credentials and ensuring that access to their accounts is restricted to authorized personnel only. All patient-related data accessed through the platform must be handled in compliance with applicable medical privacy and data protection regulations, and may not be used outside the scope of clinical or administrative care."),
        SizedBox(height: 32.h),
        _buildSectionTitle("Subscription Cancellation Policy"),
        _buildSectionText(
            "Doctors may cancel their subscription at any time; however, a minimum notice period of one (1) month is required. Cancellation requests must be submitted at least 30 days before the next billing cycle. If notice is not provided within this timeframe, the subscription will automatically renew for the following billing period, and applicable charges will apply."),
        SizedBox(height: 32.h),
        _buildSectionText(
            "Dentix reserves the right to update these privacy and subscription terms as needed, with advance notice provided to users through the platform."),
      ],
    );
  }

  Widget _buildNursePolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionText(
            "Dentix is committed to protecting the privacy and security of Doctor Assistants (Nurses) using the platform. Nurse accounts are pre-created and assigned by an authorized doctor or system administrator, and access is strictly role-based. All personal information, assignment data, inventory actions, and activity records associated with nurse accounts are securely stored and used only to support clinic operations and patient care workflows."),
        SizedBox(height: 24.h),
        _buildSectionText(
            "Doctor Assistants may access patient information, treatment details, and inventory data only as required to perform assigned duties. This information must remain confidential and may not be shared, copied, or used outside the Dentix platform. All actions performed by nurses—such as viewing patient schedules, managing materials, or submitting supply requests—are logged for accountability and audit purposes."),
        SizedBox(height: 24.h),
        _buildSectionText(
            "Doctor Assistants are responsible for maintaining the confidentiality of their login credentials and ensuring they do not allow unauthorized access to their accounts. Any suspected misuse, data breach, or security concern must be reported immediately to the supervising doctor or system administrator."),
        SizedBox(height: 24.h),
        _buildSectionText(
            "Dentix reserves the right to modify, suspend, or revoke nurse access if there is misuse of data, violation of privacy obligations, or non-compliance with clinic policies. Updates to this policy may be made periodically, with changes communicated through the platform."),
      ],
    );
  }

  Widget _buildReceptionistPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionText(
            "Dentix is committed to protecting the privacy and security of Receptionists using the platform. Receptionist accounts are pre-created and assigned by an authorized doctor or system administrator, and access is strictly role-based. All personal information, scheduling data, patient assignments, and administrative actions associated with receptionist accounts are securely stored and used solely to support clinic operations and patient coordination."),
        SizedBox(height: 24.h),
        _buildSectionText(
            "Receptionists may access patient information, appointment schedules, doctor availability, and basic case details only as required to perform assigned administrative duties. Patient data must remain confidential and must not be shared, copied, or used outside the Dentix platform or beyond the scope of appointment management and clinic coordination."),
        SizedBox(height: 24.h),
        _buildSectionText(
            "Receptionists are responsible for maintaining the confidentiality of their login credentials and ensuring that only authorized individuals access their accounts. Any suspected misuse, data breach, or security incidents must be reported immediately to the supervising doctor or system administrator."),
        SizedBox(height: 24.h),
        _buildSectionText(
            "Dentix reserves the right to modify, suspend, or revoke receptionist access in cases of data misuse, privacy violations, or non-compliance with clinic policies. This policy may be updated periodically, and any changes will be communicated through the platform."),
      ],
    );
  }

  Widget _buildPatientPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionText(
            "Dentix collects basic personal information to create your account, book appointments, and recommend nearby doctors. Location access is used only to improve service accuracy.\n\n"
            "Medical records and treatment plans are uploaded by licensed doctors and are accessible only to authorized healthcare providers. Dentix does not modify medical data.\n\n"
            "Your information is stored securely and is not shared except when required to operate the app or by law. By using Dentix, you agree to this policy."),
        SizedBox(height: 32.h),
        Text("Terms & Conditions", style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        _buildSectionText("By using the Dentix application, you agree to comply with these Terms and Conditions."),
        SizedBox(height: 16.h),
        _buildNumberedItem(1, "Patients are responsible for maintaining account confidentiality."),
        _buildNumberedItem(2, "Appointments are subject to doctor availability and rescheduling rules."),
        _buildNumberedItem(3, "Dentix does not provide medical diagnosis; services are provided by independent professionals."),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
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
          Text("$number. ", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
          Expanded(child: Text(text, style: AppTextStyles.bodyLarge.copyWith(height: 1.6, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
