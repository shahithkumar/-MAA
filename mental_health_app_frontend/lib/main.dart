import 'package:flutter/material.dart';
import 'screens/splash_screen1.dart';
import 'screens/splash_screen2.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService().loadBaseUrl();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAA',
      theme: AppTheme.lightTheme,
      initialRoute: '/splash1',
      routes: {
        '/splash1': (context) => SplashScreen1(),
        '/splash2': (context) => SplashScreen2(),
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}