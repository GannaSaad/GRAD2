import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../core/core/utils/validation.dart';
import '../../../widgets/widgets/custom_auth_item.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';
import '../../auth/auth_cubit/auth_states.dart';
import '../../auth/register/cubit/register_view_model.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final RegisterViewModel registerViewModel = getIt<RegisterViewModel>();
  bool isObscure = true;

  @override
  void initState() {
    super.initState();
    // Force the role to 'doctor' for this screen
    registerViewModel.selectedRole = 'doctor';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Add New Doctor", style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<RegisterViewModel, AuthState>(
        bloc: registerViewModel,
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Doctor added successfully!"), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<RegisterViewModel, AuthState>(
          bloc: registerViewModel,
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return CustomAuthItem(
              text1: "Doctor Profile",
              text2: "Enter clinical and personal details",
              child: Form(
                key: registerViewModel.formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSectionTitle("Personal Information"),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Full Name",
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.grayColor),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        controller: registerViewModel.nameController,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              hintText: "Age",
                              keyboardType: TextInputType.number,
                              prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.grayColor),
                              validator: (val) => val == null || val.isEmpty ? "Required" : null,
                              controller: registerViewModel.ageController,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(child: _buildGenderDropdown()),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Phone Number",
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.grayColor),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        controller: registerViewModel.phoneController,
                      ),
                      SizedBox(height: 32.h),
                      _buildSectionTitle("Clinical Details"),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Speciality (e.g. Implantologist)",
                        prefixIcon: Icon(Icons.medical_services_outlined, color: AppColors.grayColor),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        controller: registerViewModel.specialityController,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Rank (e.g. Senior Specialist)",
                        prefixIcon: Icon(Icons.badge_outlined, color: AppColors.grayColor),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        controller: registerViewModel.rankController,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Years Experience",
                        keyboardType: TextInputType.number,
                        prefixIcon: Icon(Icons.history_outlined, color: AppColors.grayColor),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        controller: registerViewModel.experienceController,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Education (e.g. Cairo University)",
                        prefixIcon: Icon(Icons.school_outlined, color: AppColors.grayColor),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        controller: registerViewModel.educationController,
                      ),
                      SizedBox(height: 16.h),
                      _buildCertificatePicker(),
                      SizedBox(height: 32.h),
                      _buildSectionTitle("Account Security"),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.grayColor),
                        validator: (val) => AppValidator.validateEmail(val),
                        controller: registerViewModel.emailController,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Temporary Password",
                        prefixIcon: Icon(Icons.lock_open_sharp, color: AppColors.grayColor),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => isObscure = !isObscure),
                          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: AppColors.grayColor),
                        ),
                        isObscure: isObscure,
                        validator: (val) => AppValidator.validatePassword(val),
                        controller: registerViewModel.passwordController,
                      ),
                      SizedBox(height: 32.h),
                      CustomElevatedButton(
                        buttonText: isLoading ? "Creating Account..." : "Confirm & Register Doctor",
                        onPressed: isLoading ? null : () => registerViewModel.register(),
                        backgroundColor: isLoading ? AppColors.grayColor : AppColors.primaryColor,
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        color: AppColors.primaryBlue,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGenderDropdown() {
     return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderMedium),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: registerViewModel.selectedGender,
          isExpanded: true,
          items: [
            DropdownMenuItem(value: 'male', child: Text("Male", style: AppTextStyles.normal16Grey)),
            DropdownMenuItem(value: 'female', child: Text("Female", style: AppTextStyles.normal16Grey)),
          ],
          onChanged: (val) => setState(() => registerViewModel.selectedGender = val!),
        ),
      ),
    );
  }

  Widget _buildCertificatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Professional Certificate", style: AppTextStyles.normal16Grey),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => registerViewModel.pickCertificate(),
          child: Container(
            height: 100.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderMedium, style: BorderStyle.solid),
              color: AppColors.lightGreyColor,
            ),
            child: registerViewModel.certificateFile != null 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(registerViewModel.certificateFile!, fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: AppColors.primaryColor, size: 24.r),
                    SizedBox(height: 4.h),
                    Text("Select Certificate Photo", style: AppTextStyles.regular12Gray),
                  ],
                ),
          ),
        ),
      ],
    );
  }
}
