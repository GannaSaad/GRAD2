import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../api/config/di/di.dart';
import '../../../data/data_sources/remote/auth_remote_data_source.dart';
import '../../../data/models/user_model.dart';
import '../../features/auth/auth_cubit/auth_cubit.dart';
import '../../features/auth/login/login_screen.dart';
import '../../features/auth/register/email_verification_screen.dart';
import '../../features/home_screen/home_screen.dart';
import 'main_loading.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: MainLoading(),
          );
        }

        final firebaseUser = snapshot.data;
        if (firebaseUser == null) {
          return LoginScreen();
        }

        // User is logged in, now we fetch role and check verification
        return FutureBuilder<UserModel>(
          future: getIt<AuthRemoteDataSource>().getUserData(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: MainLoading(),
              );
            }

            if (userSnapshot.hasData) {
              final user = userSnapshot.data!;
              // Cache user data in Cubit
              getIt<AuthCubit>().updateAuthenticatedUser(user.toEntity());

              final role = (user.role ?? 'patient').toLowerCase();
              
              // Only Doctors and Patients require email verification
              if ((role == 'doctor' || role == 'patient') && !firebaseUser.emailVerified) {
                return const EmailVerificationScreen();
              }

              return const HomeScreen();
            }

            // If Firestore data fails, fallback to login
            return LoginScreen();
          },
        );
      },
    );
  }
}
