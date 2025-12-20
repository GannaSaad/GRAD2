import 'package:flutter/material.dart';

import '../../../features/auth/login/login_screen.dart';
import '../../../features/auth/register/register_screen.dart';
import '../../../features/home_screen/home_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) =>  RegisterScreen());
      case AppRoutes.homeScreen:
        return MaterialPageRoute(builder: (_) =>  HomeScreen());
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
