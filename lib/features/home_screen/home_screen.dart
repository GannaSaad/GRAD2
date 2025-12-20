
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/core/utils/app_assets.dart';
import '../../core/core/utils/app_colors.dart';
import '../tabs/activity_tab/activity_tab.dart';
import '../tabs/chatbot_tab/chatbot_tab.dart';
import '../tabs/home_tab/home_tab.dart';
import '../tabs/profile_tab/profile_tab.dart';
import '../doctors/doctors_listing_screen.dart';

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

  Widget _getBody() {
    if (_showDoctorsListing) {
      return DoctorsListingScreen(isInsideNavbar: true);
    }
    
    switch (_currentIndex) {
      case 0:
        return PatientHomeTab(
          onBookDoctorTap: navigateToDoctorsListing,
          onAppointmentsTap: navigateToActivity,
          onAssistantTap: navigateToShagy,
        );
      case 1:
        return const ActivityTab();
      case 2:
        return const ChatBotTab();
      case 3:
        return const ProfileTab();
      default:
        return PatientHomeTab(
          onBookDoctorTap: navigateToDoctorsListing,
          onAppointmentsTap: navigateToActivity,
          onAssistantTap: navigateToShagy,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.grayColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Container(
                height: 28.h,
                width: 28.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _currentIndex == 2 ? AppColors.primaryColor : Colors.transparent,
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
            ),
            label: 'Shagy',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
