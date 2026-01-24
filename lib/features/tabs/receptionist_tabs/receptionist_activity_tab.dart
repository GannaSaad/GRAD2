import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../auth/auth_cubit/auth_cubit.dart';
import '../../../domain/entities/availability_entity.dart';
import '../../../domain/repos/appointment_repo.dart';
import '../../doctors/cubit/booking_view_model.dart';
import '../../doctors/doctors_listing_screen.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';

class ReceptionistActivityTab extends StatefulWidget {
  const ReceptionistActivityTab({super.key});

  @override
  State<ReceptionistActivityTab> createState() => _ReceptionistActivityTabState();
}

class _ReceptionistActivityTabState extends State<ReceptionistActivityTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  final BookingViewModel _viewModel = getIt<BookingViewModel>();
  
  final _patientNameController = TextEditingController();
  final _patientPhoneController = TextEditingController();
  final _caseDescriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _fetchDoctorData();
  }

  void _fetchDoctorData() {
    final user = getIt<AuthCubit>().currentUser;
    if (user != null && user.assignedDoctorId != null) {
      _viewModel.fetchBookedSlots(user.assignedDoctorId!, _selectedDay!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staff = getIt<AuthCubit>().currentUser;
    final doctorId = staff?.assignedDoctorId;

    if (doctorId == null) {
      return const Center(child: Text("No doctor assigned to this account."));
    }

    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("Book Patient", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
          centerTitle: true,
        ),
        body: BlocListener<BookingViewModel, BookingState>(
          listener: (context, state) {
            if (state is BookingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Appointment booked successfully!"), backgroundColor: Colors.green),
              );
              setState(() {
                _selectedTime = null;
                _patientNameController.clear();
                _patientPhoneController.clear();
                _caseDescriptionController.clear();
              });
              _fetchDoctorData();
            } else if (state is BookingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorStatusHeader(staff?.assignedDoctorName ?? "Doctor"),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text("Select Appointment Date", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 16.h),
                _buildCalendarSection(),
                if (_selectedDay != null) ...[
                  SizedBox(height: 30.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text("Live Availability", style: AppTextStyles.titleMedium),
                  ),
                  SizedBox(height: 16.h),
                  _buildDynamicSlotsGrid(doctorId),
                ],
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildActionPanel(staff),
      ),
    );
  }

  Widget _buildDoctorStatusHeader(String doctorName) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Scheduling for", style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
          Text("Dr. $doctorName", style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          const Divider(color: Colors.white24),
          Row(
            children: [
              const Icon(Icons.sync, color: Colors.white70, size: 16),
              SizedBox(width: 8.w),
              Text("Real-time availability enabled", style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: AppColors.blackColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: daysInMonth + (firstDayOfMonth - 1),
      itemBuilder: (context, index) {
        if (index < firstDayOfMonth - 1) return const SizedBox.shrink();
        final day = index - (firstDayOfMonth - 2);
        final date = DateTime(_focusedDay.year, _focusedDay.month, day);
        final isSelected = _selectedDay != null && DateUtils.isSameDay(_selectedDay!, date);
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = date;
              _selectedTime = null;
            });
            _fetchDoctorData();
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(color: isSelected ? AppColors.primaryBlue : Colors.transparent, shape: BoxShape.circle),
            child: Text("$day", style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ),
        );
      },
    );
  }

  Widget _buildDynamicSlotsGrid(String doctorId) {
    return StreamBuilder<AvailabilityEntity?>(
      stream: getIt<AppointmentRepo>().getDoctorAvailability(doctorId, _selectedDay!),
      builder: (context, snapshot) {
        return BlocBuilder<BookingViewModel, BookingState>(
          builder: (context, state) {
            if (snapshot.connectionState == ConnectionState.waiting || state is BookingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final liveSlots = snapshot.data?.availableSlots ?? [];
            List<String> booked = [];
            if (state is BookedSlotsLoaded) booked = state.bookedSlots;

            final filtered = liveSlots.where((s) => !booked.contains(s)).toList();

            if (filtered.isEmpty) {
              return Center(child: Text("No slots published by doctor for this day.", style: AppTextStyles.bodySmall));
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.2),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final time = filtered[index];
                  final isSelected = _selectedTime == time;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTime = time),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.borderSoft, width: 1.5),
                      ),
                      child: Text(time, style: AppTextStyles.labelSmall.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionPanel(dynamic staff) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(color: AppColors.whiteColor, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))]),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: (_selectedTime == null) ? null : () => _showPatientDetailsDialog(staff),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
          child: Text("Confirm Selection", style: AppTextStyles.buttonMedium.copyWith(color: Colors.white)),
        ),
      ),
    );
  }

  void _showPatientDetailsDialog(dynamic staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text("Patient Information", style: AppTextStyles.titleMedium),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  hintText: "Patient Full Name",
                  controller: _patientNameController,
                  validator: (val) => val!.isEmpty ? "Enter patient name" : null,
                ),
                SizedBox(height: 16.h),
                CustomTextFormField(
                  hintText: "Phone Number",
                  controller: _patientPhoneController,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val!.isEmpty ? "Enter phone number" : null,
                ),
                SizedBox(height: 16.h),
                CustomTextFormField(
                  hintText: "Reason for Visit",
                  controller: _caseDescriptionController,
                  validator: (val) => val!.isEmpty ? "Enter reason for visit" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                _viewModel.book(
                  doctor: Doctor(
                    id: staff.assignedDoctorId,
                    name: staff.assignedDoctorName,
                    specialty: '',
                    image: 'assets/images/doctor.jpg',
                    rank: '', bio: '', experience: '', rating: '', reviews: '', clinic: '', location: '', latitude: 0, longitude: 0, availability: '', education: [], languages: [], certifications: [], affiliations: []
                  ),
                  date: _selectedDay!,
                  time: _selectedTime!,
                  patientName: _patientNameController.text.trim(),
                  patientPhone: _patientPhoneController.text.trim(),
                  caseDescription: _caseDescriptionController.text.trim(),
                  isReceptionistBooking: true,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text("Book Appointment"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientPhoneController.dispose();
    _caseDescriptionController.dispose();
    super.dispose();
  }
}
