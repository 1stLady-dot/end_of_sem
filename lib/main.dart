/*
 * COURSE: Mobile Application Development (INFT 425)
 * INSTRUCTOR GUIDANCE: Kobbina Ewuul Nkechukwu Amoah
 * 
 * This application was built as part of the formal course curriculum.
 * Every major feature and implementation approach follows the
 * structured guidance provided by the course instructor.
 * 
 * Unauthorized reproduction or removal of this notice is a violation
 * of academic integrity and professional attribution standards.
 */

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/alert_viewmodel.dart';
import 'viewmodels/location_viewmodel.dart';
import 'viewmodels/quote_viewmodel.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/map_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/safe_zones_screen.dart';
import 'screens/alert_history_screen.dart';
import 'screens/sos_screen.dart';
import 'screens/auth_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => AlertViewModel()),
        ChangeNotifierProvider(create: (_) => LocationViewModel()),
        ChangeNotifierProvider(create: (_) => QuoteViewModel()..loadRandomQuote()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(
          primarySwatch: Colors.red,
          primaryColor: AppColors.primaryRed,
          scaffoldBackgroundColor: AppColors.backgroundGrey,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: AppColors.primaryRed,
          scaffoldBackgroundColor: Colors.grey[900],
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/map': (context) => const MapScreen(),
          '/contacts': (context) => const ContactsScreen(),
          '/safe-zones': (context) => const SafeZonesScreen(),
          '/alert-history': (context) => const AlertHistoryScreen(),
          '/sos': (context) => const SOSScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Auth Wrapper - handles routing based on auth state (Week 3 & 5)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    
    return StreamBuilder(
      stream: authVM.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        if (snapshot.hasData) {
          // Check if biometric auth is required
          return const AuthScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}