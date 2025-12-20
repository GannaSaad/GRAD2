import 'package:flutter/material.dart';

import '../../../features/auth/login/login_screen.dart';
import '../../../features/auth/register/register_screen.dart';
import '../../../features/home_screen/home_screen.dart';
import '../../../features/doctors/doctors_listing_screen.dart';
import '../../../features/doctors/book_appointment_screen.dart';
import '../../../features/doctors/payment_method_screen.dart';
import '../../../features/settings/privacy_policy_screen.dart';
import '../../../features/settings/settings_screen.dart';
import '../../../features/settings/notification_settings_screen.dart';
import '../../../features/settings/password_manager_screen.dart';
import '../../../features/tabs/profile_tab/profile_editing_screen.dart';
import '../../../features/tabs/activity_tab/medical_records_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case AppRoutes.homeScreen:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case AppRoutes.doctorsListing:
        return MaterialPageRoute(builder: (_) => const DoctorsListingScreen());
      case AppRoutes.bookAppointment:
        final doctor = settings.arguments as Doctor;
        return MaterialPageRoute(builder: (_) => BookAppointmentScreen(doctor: doctor));
      case AppRoutes.paymentMethod:
        return MaterialPageRoute(builder: (_) => const PaymentMethodScreen());
      case AppRoutes.privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.profileEditing:
        return MaterialPageRoute(builder: (_) => const ProfileEditingScreen());
      case AppRoutes.notificationSettings:
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());
      case AppRoutes.passwordManager:
        return MaterialPageRoute(builder: (_) => const PasswordManagerScreen());
      case AppRoutes.medicalRecords:
        return MaterialPageRoute(builder: (_) => const MedicalRecordsScreen());
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
