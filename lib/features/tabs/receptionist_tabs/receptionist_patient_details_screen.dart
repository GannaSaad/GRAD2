import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';
import '../../auth/auth_cubit/auth_cubit.dart';
import '../../../domain/repos/auth_repo.dart';
import '../../../domain/entities/availability_entity.dart';
import '../../../domain/repos/appointment_repo.dart';
import '../../doctors/cubit/booking_view_model.dart';
import '../../doctors/doctors_listing_screen.dart';

class ReceptionistPatientDetailsScreen extends StatefulWidget {
  final String patientName;
  final String patientImage;
  final String treatment;
  final String time;
  final String? patientId;

  const ReceptionistPatientDetailsScreen({
    super.key,
    required this.patientName,
    required this.patientImage,
    required this.treatment,
    required this.time,
    this.patientId,
  });

  @override
  State<ReceptionistPatientDetailsScreen> createState() => _ReceptionistPatientDetailsScreenState();
}

class _ReceptionistPatientDetailsScreenState extends State<ReceptionistPatientDetailsScreen> {
  final _amountToPayController = TextEditingController();
  final _amountPaidController = TextEditingController();
  bool _isInitialized = false;
  bool _showBooking = false;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedBookingTime;
  final BookingViewModel _bookingViewModel = getIt<BookingViewModel>();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    _loadExistingFinancials();
  }

  void _loadExistingFinancials() async {
    if (widget.patientId != null) {
      try {
        final userData = await getIt<AuthRepo>().getUserData(widget.patientId!);
        setState(() {
          _amountToPayController.text = (userData.totalToPay ?? 0).toStringAsFixed(0);
          _amountPaidController.text = (userData.totalPaid ?? 0).toStringAsFixed(0);
          _isInitialized = true;
        });
      } catch (e) {
        setState(() => _isInitialized = true);
      }
    } else {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double toPay = double.tryParse(_amountToPayController.text) ?? 0;
    double paid = double.tryParse(_amountPaidController.text) ?? 0;
    double remaining = toPay - paid;
    final staff = getIt<AuthCubit>().currentUser;

    return BlocProvider(
      create: (context) => _bookingViewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Patient Management", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: !_isInitialized
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientHeader(),
              SizedBox(height: 32.h),

              if (!_showBooking) ...[
                _buildSectionHeader("Financial Overview"),
                SizedBox(height: 16.h),
                _buildFinancialCard(remaining),

                SizedBox(height: 32.h),
                _buildSectionHeader("Payment Actions"),
                SizedBox(height: 16.h),
                _buildPaymentInputs(),

                SizedBox(height: 32.h),
                _buildSectionHeader("Appointment Actions"),
                SizedBox(height: 16.h),
                _buildActionButton(
                  label: "Book Appointment",
                  icon: Icons.add_alarm,
                  color: AppColors.primaryBlue,
                  onTap: () => setState(() => _showBooking = true),
                ),

                SizedBox(height: 40.h),
                CustomElevatedButton(
                  buttonText: "Update Patient Record",
                  onPressed: () async {
                    if (widget.patientId != null) {
                      await getIt<AuthRepo>().updatePatientFinancials(widget.patientId!, toPay, paid);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Financial records saved!"), backgroundColor: Colors.green));
                    Navigator.pop(context);
                  },
                  backgroundColor: AppColors.primaryBlue,
                ),
              ] else ...[
                _buildBookingFlow(staff),
              ],
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    final String initials = widget.patientName.isNotEmpty
        ? widget.patientName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
        : "?";

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: AppColors.primaryBlueSoft,
            child: Text(initials, style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.patientName, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                Text("Treatment: ${widget.treatment}", style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildFinancialCard(double remaining) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(24.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat("To Pay", "${_amountToPayController.text.isEmpty ? "0" : _amountToPayController.text} EGP", Colors.white70),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStat("Remaining", "${remaining.toStringAsFixed(0)} EGP", remaining > 0 ? Colors.orangeAccent : Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.white60)),
        Text(value, style: AppTextStyles.titleLarge.copyWith(color: valueColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPaymentInputs() {
    return Column(
      children: [
        CustomTextFormField(
          hintText: "Total Amount to Pay",
          controller: _amountToPayController,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.payments_outlined),
          onChanged: (val) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        CustomTextFormField(
          hintText: "Current Amount Paid",
          controller: _amountPaidController,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.check_circle_outline),
          onChanged: (val) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildBookingFlow(dynamic staff) {
    final String doctorId = staff?.assignedDoctorId ?? "";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => setState(() => _showBooking = false)),
            Text("Select New Appointment", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 16.h),
        _buildCalendarSection(),
        SizedBox(height: 24.h),
        _buildDynamicSlotsGrid(doctorId),
        SizedBox(height: 32.h),
        CustomElevatedButton(
          buttonText: "Confirm Booking",
          onPressed: _selectedBookingTime == null ? null : () {
            _bookingViewModel.book(
              doctor: Doctor(id: staff.assignedDoctorId, name: staff.assignedDoctorName, specialty: '', image: 'assets/images/doctor.jpg', rank: '', bio: '', experience: '', rating: '', reviews: '', clinic: '', location: '', latitude: 0, longitude: 0, availability: '', education: [], languages: [], certifications: [], affiliations: []),
              date: _selectedDay!,
              time: _selectedBookingTime!,
              patientName: widget.patientName,
              isReceptionistBooking: true,
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("New appointment booked!"), backgroundColor: Colors.green));
          },
          backgroundColor: AppColors.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(24.r), border: Border.all(color: AppColors.borderSoft)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('MMMM yyyy').format(_focusedDay), style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1))),
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1))),
                ],
              ),
            ],
          ),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1).weekday;
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: daysInMonth + (firstDayOfMonth - 1),
      itemBuilder: (context, index) {
        if (index < firstDayOfMonth - 1) return const SizedBox.shrink();
        final day = index - (firstDayOfMonth - 2);
        final date = DateTime(_focusedDay.year, _focusedDay.month, day);
        final isSelected = _selectedDay != null && DateUtils.isSameDay(_selectedDay!, date);
        return GestureDetector(
          onTap: () {
            setState(() => _selectedDay = date);
            _bookingViewModel.fetchBookedSlots(getIt<AuthCubit>().currentUser!.assignedDoctorId!, date);
          },
          child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: isSelected ? AppColors.primaryBlue : Colors.transparent, shape: BoxShape.circle),
            child: Text("$day", style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary))),
        );
      },
    );
  }

  Widget _buildDynamicSlotsGrid(String doctorId) {
    return StreamBuilder<AvailabilityEntity?>(
      stream: getIt<AppointmentRepo>().getDoctorAvailability(doctorId, _selectedDay!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final liveSlots = snapshot.data?.availableSlots ?? [];
        return GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.2),
          itemCount: liveSlots.length,
          itemBuilder: (context, index) {
            final time = liveSlots[index];
            final isSelected = _selectedBookingTime == time;
            return GestureDetector(
              onTap: () => setState(() => _selectedBookingTime = time),
              child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: isSelected ? AppColors.primaryBlue : AppColors.cardBackground, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.borderSoft)),
                child: Text(time, style: AppTextStyles.labelSmall.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary))),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(onTap: onTap,
      child: Container(width: double.infinity, padding: EdgeInsets.symmetric(vertical: 16.h), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Column(children: [Icon(icon, color: color), SizedBox(height: 8.h), Text(label, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold))]),
      ),
    );
  }
}
