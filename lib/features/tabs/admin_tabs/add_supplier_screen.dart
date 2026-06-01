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

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final RegisterViewModel registerViewModel = getIt<RegisterViewModel>();
  bool isObscure = true;
  String? _selectedCompany;
  
  final List<String> _companies = ["DentalCare Supplies", "Medipro Ltd.", "Global Health"];

  @override
  void initState() {
    super.initState();
    registerViewModel.selectedRole = 'supplier';
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
        title: Text("Add New Supplier", style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
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
              const SnackBar(content: Text("Supplier account created and linked successfully!"), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<RegisterViewModel, AuthState>(
          bloc: registerViewModel,
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return CustomAuthItem(
              text1: "Supplier Profile",
              text2: "Create a linked company account",
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
                      CustomTextFormField(
                        hintText: "Phone Number",
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.grayColor),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        controller: registerViewModel.phoneController,
                      ),
                      SizedBox(height: 32.h),
                      _buildSectionTitle("Company Link"),
                      SizedBox(height: 16.h),
                      _buildCompanyDropdown(),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Office Address",
                        prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.grayColor),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        controller: registerViewModel.addressController, 
                      ),
                      SizedBox(height: 32.h),
                      _buildSectionTitle("Account Access"),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.grayColor),
                        validator: (val) => AppValidator.validateEmail(val),
                        controller: registerViewModel.emailController,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Initial Password",
                        prefixIcon: Icon(Icons.lock_open_sharp, color: AppColors.grayColor),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => isObscure = !isObscure),
                          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: AppColors.grayColor),
                        ),
                        isObscure: isObscure,
                        validator: (val) => AppValidator.validatePassword(val),
                        controller: registerViewModel.passwordController,
                      ),
                      SizedBox(height: 40.h),
                      CustomElevatedButton(
                        buttonText: isLoading ? "Processing..." : "Create & Link Account",
                        onPressed: isLoading ? null : () {
                          if (registerViewModel.formKey.currentState!.validate()) {
                            if (_selectedCompany == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please select a company")),
                              );
                              return;
                            }
                            registerViewModel.selectedCompany = _selectedCompany;
                            registerViewModel.register(); 
                          }
                        },
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
    return Text(title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold));
  }

  Widget _buildCompanyDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderMedium),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCompany,
          isExpanded: true,
          hint: Text("Select Company", style: AppTextStyles.normal16Grey),
          items: _companies.map((String company) {
            return DropdownMenuItem(value: company, child: Text(company, style: AppTextStyles.normal16Grey));
          }).toList(),
          onChanged: (val) => setState(() => _selectedCompany = val),
        ),
      ),
    );
  }
}
