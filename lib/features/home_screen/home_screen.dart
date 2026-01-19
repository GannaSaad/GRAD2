
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../api/config/di/di.dart';
import '../../core/core/utils/app_assets.dart';
import '../../core/core/utils/app_colors.dart';
import '../tabs/activity_tab/activity_tab.dart';
import '../tabs/chatbot_tab/chatbot_tab.dart';
import '../tabs/home_tab/home_tab.dart';
import '../tabs/profile_tab/profile_tab.dart';
import '../doctors/doctors_listing_screen.dart';
import '../auth/auth_cubit/auth_cubit.dart';
import '../tabs/doctor_home_tab/doctor_home_tab.dart';
import '../tabs/patients_tab/patients_tab.dart';
import '../tabs/availability_tab/availability_tab.dart';
import '../tabs/nurse_tabs/nurse_home_tab.dart';
import '../tabs/nurse_tabs/inventory_management_tab.dart';
import '../tabs/nurse_tabs/supplies_request_tab.dart';
import '../tabs/receptionist_tabs/receptionist_home_tab.dart';
import '../tabs/receptionist_tabs/receptionist_activity_tab.dart';
import '../tabs/admin_tabs/admin_home_tab.dart';
import '../tabs/admin_tabs/admin_patients_tab.dart';
import '../tabs/admin_tabs/doctor_support_tab.dart';
import '../tabs/admin_tabs/patient_support_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showDoctorsListing = false;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _showDoctorsListing = false;
    });
  }

  void navigateToDoctorsListing() {
    setState(() {
      _showDoctorsListing = true;
    });
  }

  void navigateToActivity() {
    setState(() {
      _currentIndex = 1;
      _showDoctorsListing = false;
    });
  }

  void navigateToShagy() {
    setState(() {
      _currentIndex = 2;
      _showDoctorsListing = false;
    });
  }

  Widget _getBody(String role) {
    final normalizedRole = role.toLowerCase();
    
    if (normalizedRole == 'admin') {
      switch (_currentIndex) {
        case 0: return const AdminHomeTab();
        case 1: return const AdminPatientsTab();
        case 2: return const DoctorSupportTab();
        case 3: return const PatientSupportTab();
        case 4: return const ProfileTab();
        default: return const AdminHomeTab();
      }
    } else if (normalizedRole == 'receptionist') {
      switch (_currentIndex) {
        case 0: return const ReceptionistHomeTab();
        case 1: return const ReceptionistActivityTab();
        case 2: return const AvailabilityTab();
        case 3: return const ProfileTab();
        default: return const ReceptionistHomeTab();
      }
    } else if (normalizedRole == 'nurse') {
      switch (_currentIndex) {
        case 0: return const NurseHomeTab();
        case 1: return const InventoryManagementTab();
        case 2: return const SuppliesRequestTab(); 
        case 3: return const ProfileTab();
        default: return const NurseHomeTab();
      }
    } else if (normalizedRole == 'doctor') {
      switch (_currentIndex) {
        case 0: return const DoctorHomeTab();
        case 1: return const PatientsTab();
        case 2: return const AvailabilityTab();
        case 3: return const ChatBotTab(); 
        case 4: return const ProfileTab();
        default: return const DoctorHomeTab();
      }
    } else {
      if (_showDoctorsListing) {
        return const DoctorsListingScreen(isInsideNavbar: true);
      }
      switch (_currentIndex) {
        case 0:
          return PatientHomeTab(
            onBookDoctorTap: navigateToDoctorsListing,
            onAppointmentsTap: navigateToActivity,
            onAssistantTap: navigateToShagy,
          );
        case 1: return const ActivityTab();
        case 2: return const ChatBotTab();
        case 3: return const ProfileTab();
        default: return PatientHomeTab(
          onBookDoctorTap: navigateToDoctorsListing,
          onAppointmentsTap: navigateToActivity,
          onAssistantTap: navigateToShagy,
        );
      }
    }
  }

  List<BottomNavigationBarItem> _getNavItems(String role) {
    final normalizedRole = role.toLowerCase();
    
    if (normalizedRole == 'admin') {
      return [
        const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Patients'),
        const BottomNavigationBarItem(icon: Icon(Icons.support_agent), activeIcon: Icon(Icons.support_agent), label: 'Dr Support'),
        const BottomNavigationBarItem(icon: Icon(Icons.contact_support_outlined), activeIcon: Icon(Icons.contact_support), label: 'Pt Support'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ];
    } else if (normalizedRole == 'receptionist') {
      return [
        const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Activity'),
        const BottomNavigationBarItem(icon: Icon(Icons.event_available_outlined), activeIcon: Icon(Icons.event_available), label: 'Availability'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ];
    } else if (normalizedRole == 'nurse') {
      return [
        const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Inventory'),
        const BottomNavigationBarItem(icon: Icon(Icons.pending_actions_outlined), activeIcon: Icon(Icons.pending_actions), label: 'Requests'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ];
    } else if (normalizedRole == 'doctor') {
      return [
        const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Patients'),
        const BottomNavigationBarItem(icon: Icon(Icons.event_available_outlined), activeIcon: Icon(Icons.event_available), label: 'Availability'),
        BottomNavigationBarItem(
          icon: _buildShagyIcon(false),
          activeIcon: _buildShagyIcon(true),
          label: 'Shagy',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      return [
        const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Activity'),
        BottomNavigationBarItem(
          icon: _buildShagyIcon(false),
          activeIcon: _buildShagyIcon(true),
          label: 'Shagy',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ];
    }
  }

  Widget _buildShagyIcon(bool isActive) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Container(
        height: 24.h,
        width: 24.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? AppColors.primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            AppImages.shagyLogo,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();
    final role = authCubit.currentUser?.role ?? 'patient';

    return Scaffold(
      body: _getBody(role),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.grayColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        items: _getNavItems(role),
      ),
    );
  }
}
