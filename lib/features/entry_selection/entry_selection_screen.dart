// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'dart:math' as math;
// import '../../core/core/utils/app_colors.dart';
// import '../../core/core/utils/app_textstyles.dart';
// import '../../core/core/utils/app_constants.dart';
// import '../../widgets/widgets/dentix_logo.dart';
// import '../../widgets/widgets/dentix_role_card.dart';
// import '../auth/login/patient_login_or_guest_screen.dart';
// import '../auth/login/doctor_login_screen.dart';
//
// class EntrySelectionScreen extends StatelessWidget {
//   const EntrySelectionScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             // Adaptive hero height: clamp between 240 and 320, default 35% of screen
//             final heroHeight = math.min(320.0, math.max(240.0, constraints.maxHeight * 0.35));
//
//             return Column(
//               children: [
//                 // Hero Image Section (Adaptive height)
//                 SizedBox(
//                   height: heroHeight,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(32.r),
//                       bottomRight: Radius.circular(32.r),
//                     ),
//                     child: Stack(
//                       children: [
//                         // Hero Image with BoxFit.cover
//                         Container(
//                           width: double.infinity,
//                           height: double.infinity,
//                           decoration: const BoxDecoration(
//                             image: DecorationImage(
//                               image: AssetImage('assets/images/doctor.jpg'),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//
//                         // Beige gradient overlay (subtle opacity)
//                         Container(
//                           width: double.infinity,
//                           height: double.infinity,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                               colors: [
//                                 Colors.transparent,
//                                 AppColors.backgroundPrimary.withValues(alpha: 0.15),
//                                 AppColors.backgroundPrimary.withValues(alpha: 0.25),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         // Dentix wordmark (top-left)
//                         Positioned(
//                           top: AppConstants.paddingL,
//                           left: AppConstants.paddingL,
//                           child: DentixLogo(
//                             fontSize: 26.sp,
//                             color: AppColors.whiteColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // Bottom Sheet Section (Expanded to fill remaining space)
//                 Expanded(
//                   child: Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.surface,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(32.r),
//                         topRight: Radius.circular(32.r),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.shadowColor,
//                           blurRadius: AppConstants.elevationMedium * 2,
//                           offset: const Offset(0, -2),
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.all(24.w),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(height: AppConstants.paddingM),
//
//                           // Headline
//                           Text(
//                             'Your Dentist, Just a Tap Away.',
//                             style: AppTextStyles.headlineMedium.copyWith(
//                               color: AppColors.textPrimary,
//                               fontWeight: FontWeight.w700,
//                               height: 1.2,
//                             ),
//                           ),
//
//                           SizedBox(height: AppConstants.paddingS),
//
//                           // Subtitle (limited to 2 lines max)
//                           Text(
//                             'Choose your role to get started with modern dental care.',
//                             style: AppTextStyles.bodyMedium.copyWith(
//                               color: AppColors.textSecondary,
//                               height: 1.3,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//
//                           SizedBox(height: AppConstants.paddingL),
//
//                           // Patient role card
//                           DentixRoleCard(
//                             title: 'Patient',
//                             description: 'Book appointments and manage your dental care journey',
//                             icon: Icons.person_outline,
//                             onTap: () {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (context) => const PatientLoginOrGuestScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//
//                           // Doctor role card
//                           DentixRoleCard(
//                             title: 'Doctor',
//                             description: 'Access your practice dashboard and patient records',
//                             icon: Icons.medical_services_outlined,
//                             onTap: () {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (context) => const DoctorLoginScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//
//                           const Spacer(),
//
//                           // "Already have an account? Log in"
//                           Center(
//                             child: Text(
//                               'Already have an account? Log in',
//                               style: AppTextStyles.bodySmall.copyWith(
//                                 color: AppColors.textTertiary,
//                               ),
//                             ),
//                           ),
//
//                           SizedBox(height: AppConstants.paddingS),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }