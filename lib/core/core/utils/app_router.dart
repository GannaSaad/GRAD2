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
import '../../../features/tabs/patients_tab/patient_details_screen.dart';
import '../../../features/tabs/patients_tab/add_record_screen.dart';
import '../../../features/tabs/profile_tab/managerial_staff_screen.dart';
import '../../../features/tabs/nurse_tabs/nurse_patient_details_screen.dart';
import '../../../features/tabs/admin_tabs/admin_doctor_detail_screen.dart';
import '../../../features/onboarding/onboarding_screen.dart';
import '../../../features/tabs/receptionist_tabs/receptionist_patient_details_screen.dart';
import '../../../widgets/widgets/auth_gate.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case AppRoutes.homeScreen:
        // homeScreen now points to AuthGate to handle role-based navigation and email verification
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case AppRoutes.doctorsListing:
        return MaterialPageRoute(builder: (_) => const DoctorsListingScreen());
      case AppRoutes.bookAppointment:
        final doctor = settings.arguments as Doctor;
        return MaterialPageRoute(builder: (_) => BookAppointmentScreen(doctor: doctor));
      case AppRoutes.paymentMethod:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PaymentMethodScreen(
            doctor: args['doctor'] as Doctor,
            date: args['date'] as DateTime,
            time: args['time'] as String,
          ),
        );
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
      case AppRoutes.patientDetails:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(builder: (_) => PatientDetailsScreen(patientName: args['name']!, patientImage: args['image']!));
      case AppRoutes.addRecord:
        final name = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => AddRecordScreen(patientName: name));
      case AppRoutes.managerialStaff:
        return MaterialPageRoute(builder: (_) => const ManagerialStaffScreen());
      case AppRoutes.nursePatientDetails:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(builder: (_) => NursePatientDetailsScreen(patientName: args['name']!, patientImage: args['image']!));
      case AppRoutes.adminDoctorDetail:
        final doctor = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => AdminDoctorDetailScreen(doctor: doctor));
      case AppRoutes.receptionistPatientDetails:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(builder: (_) => ReceptionistPatientDetailsScreen(
          patientName: args['name']!, 
          patientImage: args['image']!,
          treatment: args['case']!,
          time: args['time']!,
        ));
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
