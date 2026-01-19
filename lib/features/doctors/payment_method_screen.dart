import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';
import 'cubit/booking_view_model.dart';
import 'doctors_listing_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Doctor doctor;
  final DateTime date;
  final String time;

  const PaymentMethodScreen({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _LoginScreenState {} // Unused but kept for structure

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedMethod = 'card';
  final _bookingViewModel = getIt<BookingViewModel>();

  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bookingViewModel,
      child: Scaffold(
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
        body: BlocListener<BookingViewModel, BookingState>(
          listener: (context, state) {
            if (state is BookingSuccess) {
              _showSuccessDialog();
            } else if (state is BookingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Choose Payment Method", style: AppTextStyles.titleMedium),
                SizedBox(height: 20.h),
                _buildPaymentOption(id: 'card', title: "Credit & Debit Card", icon: Icons.credit_card_outlined),
                if (_selectedMethod == 'card') ...[
                  SizedBox(height: 16.h),
                  _buildCardEntrySection(),
                ],
                SizedBox(height: 16.h),
                _buildPaymentOption(id: 'onsite', title: "Pay On-Site", icon: Icons.payments_outlined),
                SizedBox(height: 40.h),
                if (_selectedMethod == 'onsite')
                  BlocBuilder<BookingViewModel, BookingState>(
                    builder: (context, state) {
                      final isLoading = state is BookingLoading;
                      return CustomElevatedButton(
                        buttonText: isLoading ? "Booking..." : "Confirm Booking",
                        onPressed: isLoading ? null : () => _bookingViewModel.book(
                          doctor: widget.doctor,
                          date: widget.date,
                          time: widget.time,
                        ),
                        backgroundColor: AppColors.primaryBlue,
                      );
                    },
                  ),
              ],
            ),
          ),
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
            Expanded(child: Text(title, style: AppTextStyles.titleSmall)),
            Container(
              height: 20.r,
              width: 20.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.borderMedium, width: 2),
              ),
              child: isSelected ? Center(child: Container(height: 10.r, width: 10.r, decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle))) : null,
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
        children: [
          CustomTextFormField(hintText: "Cardholder Name", controller: _cardNameController, prefixIcon: const Icon(Icons.person_outline)),
          SizedBox(height: 16.h),
          CustomTextFormField(hintText: "Card Number", controller: _cardNumberController, keyboardType: TextInputType.number, prefixIcon: const Icon(Icons.credit_card_outlined)),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: CustomTextFormField(hintText: "MM/YY", controller: _expiryController, keyboardType: TextInputType.datetime)),
              SizedBox(width: 16.w),
              Expanded(child: CustomTextFormField(hintText: "CVV", controller: _cvvController, keyboardType: TextInputType.number, isObscure: true)),
            ],
          ),
          SizedBox(height: 30.h),
          BlocBuilder<BookingViewModel, BookingState>(
            builder: (context, state) {
              final isLoading = state is BookingLoading;
              return CustomElevatedButton(
                buttonText: isLoading ? "Processing..." : "Confirm & Pay",
                onPressed: isLoading ? null : () => _bookingViewModel.book(
                  doctor: widget.doctor,
                  date: widget.date,
                  time: widget.time,
                ),
                backgroundColor: AppColors.primaryBlue,
              );
            },
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
            Container(padding: EdgeInsets.all(16.r), decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: AppColors.success, size: 60)),
            SizedBox(height: 24.h),
            Text("Booking Confirmed!", style: AppTextStyles.headlineSmall),
            SizedBox(height: 12.h),
            const Text("Your appointment has been successfully booked and synced across all clinic roles.", textAlign: TextAlign.center),
            SizedBox(height: 30.h),
            CustomElevatedButton(
              buttonText: "Back to Home",
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homeScreen, (route) => false),
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
