import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedMethod = 'card'; // 'card' or 'onsite'

  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Payment Method", style: AppTextStyles.titleLarge),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Choose Payment Method", style: AppTextStyles.titleMedium),
            SizedBox(height: 20.h),
            
            // Payment Options
            _buildPaymentOption(
              id: 'card',
              title: "Credit & Debit Card",
              icon: Icons.credit_card_outlined,
            ),
            
            if (_selectedMethod == 'card') ...[
              SizedBox(height: 16.h),
              _buildCardEntrySection(),
            ],
            
            SizedBox(height: 16.h),
            
            _buildPaymentOption(
              id: 'onsite',
              title: "Pay On-Site",
              icon: Icons.payments_outlined,
            ),

            SizedBox(height: 40.h),

            // Main Confirm Button
            if (_selectedMethod == 'onsite')
              CustomElevatedButton(
                buttonText: "Confirm Booking",
                onPressed: () {
                  _showSuccessDialog();
                },
                backgroundColor: AppColors.primaryBlue,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({required String id, required String title, required IconData icon}) {
    bool isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderSoft,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(title, style: AppTextStyles.titleSmall),
            ),
            Container(
              height: 20.r,
              width: 20.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.borderMedium,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        height: 10.r,
                        width: 10.r,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardEntrySection() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primaryBlueSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Card Preview
          Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.primaryBlueLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("PLATINUM", style: AppTextStyles.labelSmall.copyWith(color: Colors.white70, letterSpacing: 2)),
                    Icon(Icons.contactless, color: Colors.white.withOpacity(0.8), size: 24.r),
                  ],
                ),
                Text(
                  _cardNumberController.text.isEmpty ? "**** **** **** ****" : _cardNumberController.text,
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white, letterSpacing: 2, fontSize: 20.sp),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CARD HOLDER", style: AppTextStyles.labelSmall.copyWith(color: Colors.white70, fontSize: 8.sp)),
                        Text(
                          _cardNameController.text.isEmpty ? "FULL NAME" : _cardNameController.text.toUpperCase(),
                          style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("EXPIRES", style: AppTextStyles.labelSmall.copyWith(color: Colors.white70, fontSize: 8.sp)),
                        Text(
                          _expiryController.text.isEmpty ? "MM/YY" : _expiryController.text,
                          style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          
          // Form Fields
          CustomTextFormField(
            hintText: "Cardholder Name",
            controller: _cardNameController,
            prefixIcon: const Icon(Icons.person_outline),
            validator: (val) => val!.isEmpty ? "Required" : null,
          ),
          SizedBox(height: 16.h),
          CustomTextFormField(
            hintText: "Card Number",
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.credit_card_outlined),
            validator: (val) => val!.isEmpty ? "Required" : null,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  hintText: "MM/YY",
                  controller: _expiryController,
                  keyboardType: TextInputType.datetime,
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomTextFormField(
                  hintText: "CVV",
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  isObscure: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 30.h),
          
          CustomElevatedButton(
            buttonText: "Save Card & Confirm",
            onPressed: () {
              _showSuccessDialog();
            },
            backgroundColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 60),
            ),
            SizedBox(height: 24.h),
            Text("Booking Confirmed!", style: AppTextStyles.headlineSmall),
            SizedBox(height: 12.h),
            Text(
              "Your appointment has been successfully booked. You can view details in your activity tab.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 30.h),
            CustomElevatedButton(
              buttonText: "Back to Home",
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              backgroundColor: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}
