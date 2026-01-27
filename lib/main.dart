import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/profile_setup.dart';
import 'firebase_options.dart';
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
        primarySwatch: Colors.pink,
        useMaterial3: true,
      ),

      /// ✅ AuthGuard handles splash + auth automatically
      home: const AuthGuard(),

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/phone-login': (context) => const PhoneLoginScreen(),
        '/profile_setup': (context) => const ProfileSetupScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
