// import 'package:ambient_clean/core/utils/app_routes.dart';
// import 'package:ambient_clean/features/auth/login/login_screen.dart';
// import 'package:ambient_clean/features/auth/register/regsiter_screen.dart';
// import 'package:ambient_clean/features/home_screen/home_screen.dart';
// import 'package:ambient_clean/features/tabs/Map_tab/map_tab.dart';
// import 'package:ambient_clean/features/tabs/chatbot_tab/chatbot_tab.dart';
// import 'package:ambient_clean/features/tabs/home_tab/home_tab.dart';
// import 'package:ambient_clean/features/tabs/profile_tab/profile_tab.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class AppRouter{
//   static Route<dynamic> generateRoute(RouteSettings settings){
//     switch(settings.name){
//       case AppRoutes.login:
//         return MaterialPageRoute(builder: (_)=> LoginScreen());
//       case AppRoutes.register:
//         return MaterialPageRoute(builder: (_)=> RegisterScreen());
//       case AppRoutes.homeScreen:
//         return MaterialPageRoute(builder: (_)=> HomeScreen());
//       case AppRoutes.homeTab:
//         return MaterialPageRoute(builder: (_)=>HomeTab());
//       case AppRoutes.mapTab:
//         return MaterialPageRoute(builder: (_)=>MapTab());
//       case AppRoutes.chatBotTab:
//         return MaterialPageRoute(builder: (_)=>ChatBotTab());
//       case AppRoutes.profileTab:
//         return MaterialPageRoute(builder: (_)=>ProfileTab());
//       default:
//         return MaterialPageRoute(builder: (_)=> LoginScreen());
//     }
//   }
//
// }