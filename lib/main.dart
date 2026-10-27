import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/segment_select_screen.dart';
import 'services/notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'en_KE';
  await NotificationsService.instance.init();
  runApp(const PrimeGrainApp());
}

class PrimeGrainApp extends StatelessWidget {
  const PrimeGrainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrimeGrain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF16794F), // deep green
            secondary: const Color(0xFFFFB300), // warm maize yellow
            brightness: Brightness.light,
          ),
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFFFFBF5), // soft cream
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF16794F),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF16794F), width: 1.5),
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        SegmentSelectScreen.routeName: (_) => const SegmentSelectScreen(),
      },
    );
  }
}

