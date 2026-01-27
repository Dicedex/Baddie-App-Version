import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure this file exists!
import 'package:flutter/material.dart';
import 'screens/profile_setup.dart';
import 'screens/splash_screen.dart';
import 'widgets/auth_guard.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/phone_login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
   ); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baddie',
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 255, 255, 255),
        useMaterial3: true,
      ),

      // FIX: Remove 'initialRoute: /' and 'routes: { /: ... }' 
      // because 'home' already defines the root.
      home: const SplashScreen(),

      routes: {
        // REMOVED '/' from here to avoid the assertion error
        '/auth_check': (context) => const AuthGuard(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/phone-login': (context) => const PhoneLoginScreen(),
        '/profile_setup': (context) => const ProfileSetupScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}