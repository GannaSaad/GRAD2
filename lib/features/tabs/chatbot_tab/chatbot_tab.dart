import 'package:dentex_clean/domain/entities/appointment_entity.dart';
import 'package:dentex_clean/domain/use_cases/book_appointment_use_case.dart';
import 'package:dentex_clean/domain/use_cases/get_booked_slots_use_case.dart';
import 'package:dentex_clean/features/auth/auth_cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../api/config/di/di.dart';
import '../../../api/web_services.dart';
import '../../../api/models/chat_response.dart';
import '../../../core/core/utils/app_assets.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../doctors/cubit/doctors_listing_view_model.dart';
import '../../doctors/doctors_listing_screen.dart';

enum ChatStep { initial, choosingSpeciality, choosingDoctor, choosingDate, choosingTime, booking, success, chatting }

class ChatBotTab extends StatefulWidget {
  const ChatBotTab({super.key});

  @override
  State<ChatBotTab> createState() => _ChatBotTabState();
}

class _ChatBotTabState extends State<ChatBotTab> {
  ChatStep _currentStep = ChatStep.initial;
  String _selectedSpeciality = "";
  Doctor? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTime;
  List<String> _availableSlots = [];
  bool _isLoadingSlots = false;

  // Chat-specific state
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  final DoctorsListingViewModel _doctorsViewModel = getIt<DoctorsListingViewModel>();
  final GetBookedSlotsUseCase _getBookedSlotsUseCase = getIt<GetBookedSlotsUseCase>();
  final BookAppointmentUseCase _bookAppointmentUseCase = getIt<BookAppointmentUseCase>();
  final WebServices _webServices = getIt<WebServices>();

  final List<String> _specialities = [
    "Oral Surgery & Implantology",
    "Orthadatory",
    "Implantologist",
    "Dental Medicine and Surgery",
    "Pediatric Dentist",
    "Periodontist",
    "General Dentist",
  ];

  final List<String> _recommendedQuestions = [
    "Why does it happen?",
    "How can I prevent it?",
    "How can I reduce discomfort?",
  ];

  final List<String> _allTimeSlots = [
    "09:00 AM", "10:00 AM", "11:00 AM", "12:00 PM",
    "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM"
  ];

  @override
  void initState() {
    super.initState();
    _doctorsViewModel.getAllDoctors();
  }

  void _onBookAppointmentTap() {
    setState(() => _currentStep = ChatStep.choosingSpeciality);
  }

  void _onAskShagyTap() {
    setState(() {
      _currentStep = ChatStep.chatting;
      if (_messages.isEmpty) {
        _messages.add({"role": "shagy", "content": "I'm ready! Ask me anything about your dental health or our services."});
      }
    });
  }

  void _onSpecialitySelected(String speciality) {
    setState(() {
      _selectedSpeciality = speciality;
      _currentStep = ChatStep.choosingDoctor;
    });
  }

  void _onDoctorSelected(Doctor doctor) {
    setState(() {
      _selectedDoctor = doctor;
      _currentStep = ChatStep.choosingDate;
    });
  }

  void _onDateSelected(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _isLoadingSlots = true;
      _currentStep = ChatStep.choosingTime;
    });

    try {
      // SYNC CHECK: Fetch real booked slots from Firestore via use case
      final booked = await _getBookedSlotsUseCase.call(_selectedDoctor!.id, date);
      
      if (mounted) {
        setState(() {
          // EXCLUSION LOGIC: Filter out slots that are already in the booked list
          _availableSlots = _allTimeSlots.where((slot) => !booked.contains(slot)).toList();
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  void _onTimeSelected(String time) async {
    setState(() {
      _selectedTime = time;
      _currentStep = ChatStep.booking;
    });

    final patient = getIt<AuthCubit>().currentUser;
    if (patient == null) return;

    final appointment = AppointmentEntity(
      id: const Uuid().v4(),
      doctorId: _selectedDoctor!.id,
      patientId: patient.uid,
      doctorName: _selectedDoctor!.name,
      patientName: patient.fullName ?? "Patient",
      date: _selectedDate!,
      time: time,
      status: 'Pending',
      caseDescription: "Booked via Shagy AI Assistant",
      clinicName: "Dentix Clinic",
      doctorImage: _selectedDoctor!.image,
      patientImage: 'assets/images/patient.jpeg',
    );

    try {
      // SYNC ACTION: Save to Firestore
      await _bookAppointmentUseCase.call(appointment);
      if (mounted) setState(() => _currentStep = ChatStep.success);
    } catch (e) {
      if (mounted) {
        setState(() => _currentStep = ChatStep.initial);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking failed: $e")));
      }
    }
  }

  Future<void> _sendMessage([String? textOverride]) async {
    final text = textOverride ?? _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      if (textOverride == null) _chatController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final response = await _webServices.getShagyReply({"message": text});
      if (mounted) {
        setState(() {
          _messages.add({"role": "shagy", "content": response.reply});
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({"role": "shagy", "content": "Connectivity error. Please ensure the AI service is active."});
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String get _shagyMessage {
    switch (_currentStep) {
      case ChatStep.initial: return "Hello! I am Shagy, your dental assistant. What would you like to do today?";
      case ChatStep.choosingSpeciality: return "Sure! Which specialty do you want?";
      case ChatStep.choosingDoctor: return "Great! Choose a doctor from our best experts in $_selectedSpeciality:";
      case ChatStep.choosingDate: return "When would you like to visit Dr. ${_selectedDoctor?.name}?";
      case ChatStep.choosingTime: return "Almost there! What time works best for you on ${DateFormat('MMM d').format(_selectedDate!)}?";
      case ChatStep.booking: return "Booking your appointment...";
      case ChatStep.success: return "Congratulations! Your appointment is booked and synced. Anything else?";
      case ChatStep.chatting: return "Ask me anything!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _doctorsViewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: Text("Dentix Shagy", style: AppTextStyles.medium18White.copyWith(color: AppColors.primaryBlue)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: _currentStep != ChatStep.initial
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
                  onPressed: () {
                    setState(() {
                      if (_currentStep == ChatStep.chatting) _currentStep = ChatStep.initial;
                      else if (_currentStep == ChatStep.choosingTime) _currentStep = ChatStep.choosingDate;
                      else if (_currentStep == ChatStep.choosingDate) _currentStep = ChatStep.choosingDoctor;
                      else if (_currentStep == ChatStep.choosingDoctor) _currentStep = ChatStep.choosingSpeciality;
                      else _currentStep = ChatStep.initial;
                    });
                  },
                )
              : null,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: _currentStep == ChatStep.chatting ? 0 : constraints.maxHeight - AppBar().preferredSize.height),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                        child: Column(
                          mainAxisAlignment: _currentStep == ChatStep.chatting ? MainAxisAlignment.start : MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_currentStep != ChatStep.chatting) ...[
                              _buildShagyAvatar(),
                              SizedBox(height: 32.h),
                              _buildShagyMessage(),
                              SizedBox(height: 40.h),
                            ],
                            _buildStepContent(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_currentStep == ChatStep.chatting) _buildChatInputSection(),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildShagyAvatar() {
    return Container(
      height: 120.r,
      width: 120.r,
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSoft, 
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        image: const DecorationImage(
          image: AssetImage(AppImages.shagyLogo),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildShagyMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _shagyMessage,
        key: ValueKey(_shagyMessage),
        textAlign: TextAlign.center,
        style: AppTextStyles.titleLarge.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.4,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _getContentForStep(),
    );
  }

  Widget _getContentForStep() {
    switch (_currentStep) {
      case ChatStep.initial: return _buildInitialOptions();
      case ChatStep.choosingSpeciality: return _buildSpecialityList();
      case ChatStep.choosingDoctor: return _buildDoctorList();
      case ChatStep.choosingDate: return _buildDatePicker();
      case ChatStep.choosingTime: return _buildTimePicker();
      case ChatStep.booking: return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
      case ChatStep.success: return _buildSuccessActions();
      case ChatStep.chatting: return _buildChatHistory();
    }
  }

  Widget _buildInitialOptions() {
    return Column(
      key: const ValueKey("initial"),
      children: [
        _buildOptionCard(
          icon: Icons.calendar_month_outlined, 
          title: "Book an Appointment", 
          subtitle: "Schedule a visit with one of our doctors.", 
          onTap: _onBookAppointmentTap
        ),
        SizedBox(height: 20.h),
        _buildOptionCard(
          icon: Icons.chat_bubble_outline, 
          title: "Ask Shagy", 
          subtitle: "Ask me anything about your dental health.", 
          onTap: _onAskShagyTap
        ),
      ],
    );
  }

  Widget _buildChatHistory() {
    return Column(
      key: const ValueKey("chat_history"),
      children: _messages.map((m) => _buildChatBubble(m)).toList(),
    );
  }

  Widget _buildChatBubble(Map<String, String> message) {
    bool isShagy = message["role"] == "shagy";
    return Align(
      alignment: isShagy ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isShagy ? AppColors.primaryBlueSoft : AppColors.primaryBlue,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isShagy ? 0 : 16.r),
            bottomRight: Radius.circular(isShagy ? 16.r : 0),
          ),
        ),
        child: Text(
          message["content"]!,
          style: TextStyle(color: isShagy ? AppColors.textPrimary : Colors.white),
        ),
      ),
    );
  }

  Widget _buildChatInputSection() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_messages.length > 1) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _recommendedQuestions.map((q) => _buildQuestionChip(q)).toList(),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: _isTyping ? "Shagy is thinking..." : "Type your question...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                  ),
                  enabled: !_isTyping,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              SizedBox(width: 8.w),
              CircleAvatar(
                backgroundColor: AppColors.primaryBlue,
                child: IconButton(
                  icon: Icon(_isTyping ? Icons.hourglass_empty : Icons.send, color: Colors.white),
                  onPressed: _isTyping ? null : () => _sendMessage(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionChip(String question) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ActionChip(
        label: Text(question),
        onPressed: () => _sendMessage(question),
        backgroundColor: AppColors.primaryBlueSoft,
        labelStyle: TextStyle(color: AppColors.primaryBlue, fontSize: 11.sp, fontWeight: FontWeight.bold),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),
    );
  }

  Widget _buildSpecialityList() {
    return Column(
      key: const ValueKey("speciality"),
      children: _specialities.map((s) => _buildItemCard(s, () => _onSpecialitySelected(s))).toList(),
    );
  }

  Widget _buildDoctorList() {
    return BlocBuilder<DoctorsListingViewModel, DoctorsListingState>(
      key: const ValueKey("doctors"),
      builder: (context, state) {
        if (state is DoctorsListingLoading) return const CircularProgressIndicator(color: AppColors.primaryBlue);
        final doctors = (state is DoctorsListingSuccess) 
            ? state.doctors.where((d) => d.specialty.toLowerCase().contains(_selectedSpeciality.toLowerCase())).toList() 
            : [];
        if (doctors.isEmpty) return const Text("No doctors found for this speciality.");
        return Column(children: doctors.map((d) => _buildDoctorSmallCard(d)).toList());
      },
    );
  }

  Widget _buildDatePicker() {
    return Theme(
      key: const ValueKey("date"),
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryBlue,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: CalendarDatePicker(
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          onDateChanged: _onDateSelected,
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    if (_isLoadingSlots) return const CircularProgressIndicator(color: AppColors.primaryBlue);
    if (_availableSlots.isEmpty) return const Text("No time slots available for this day.");
    return Column(
      key: const ValueKey("time"),
      children: [
        Text(
          "Available Times:",
          style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          alignment: WrapAlignment.center,
          children: _availableSlots.map((time) => _buildTimeChip(time)).toList(),
        ),
      ],
    );
  }

  Widget _buildSuccessActions() {
    return Column(
      key: const ValueKey("success"),
      children: [
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Icons.check_circle_outline, color: AppColors.success, size: 80.r),
        ),
        SizedBox(height: 32.h),
        _buildOptionCard(
          icon: Icons.chat_bubble_outline, 
          title: "Ask Shagy", 
          subtitle: "Do you have another question?", 
          onTap: () => setState(() => _currentStep = ChatStep.initial)
        ),
      ],
    );
  }

  Widget _buildDoctorSmallCard(Doctor doctor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: _buildOptionCard(
        icon: Icons.person_outline,
        title: "Dr. ${doctor.name}",
        subtitle: doctor.rank,
        onTap: () => _onDoctorSelected(doctor),
      ),
    );
  }

  Widget _buildItemCard(String title, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground, 
            borderRadius: BorderRadius.circular(16.r), 
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: [BoxShadow(color: AppColors.shadowColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600)), 
              Icon(Icons.chevron_right, color: AppColors.primaryBlue)
            ]
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(String time) {
    return ActionChip(
      label: Text(time),
      onPressed: () => _onTimeSelected(time),
      backgroundColor: AppColors.cardBackground,
      labelStyle: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13.sp),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: const BorderSide(color: AppColors.borderSoft)),
    );
  }

  Widget _buildOptionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground, 
          borderRadius: BorderRadius.circular(24.r), 
          border: Border.all(color: AppColors.borderSoft), 
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor, 
              blurRadius: 15, 
              offset: const Offset(0, 8)
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r), 
              decoration: BoxDecoration(color: AppColors.primaryBlueSoft, borderRadius: BorderRadius.circular(16.r)), 
              child: Icon(icon, color: AppColors.primaryBlue, size: 28.r)
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)), 
                  SizedBox(height: 4.h),
                  Text(subtitle, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, height: 1.3))
                ]
              )
            ),
            Icon(Icons.arrow_forward_ios, size: 14.r, color: AppColors.textPlaceholder),
          ],
        ),
      ),
    );
  }
}
