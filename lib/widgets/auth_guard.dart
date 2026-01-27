import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_setup.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // User is logged in - check if profile is completed
        final user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!profileSnapshot.hasData || !profileSnapshot.data!.exists) {
              // No profile doc - shouldn't happen, but redirect to setup as safety
              return const ProfileSetupScreen();
            }

            try {
              final profileData = profileSnapshot.data!.data() as Map<String, dynamic>;
              final profileCompleted = profileData['profileCompleted'] as bool? ?? false;
              final profileName = profileData['name'] as String? ?? 'Unknown';

              debugPrint('AuthGuard: Profile loaded - Name: $profileName, Completed: $profileCompleted');

              // If profile is not completed, redirect to setup
              if (!profileCompleted) {
                debugPrint('AuthGuard: Redirecting to profile setup (incomplete)');
                return const ProfileSetupScreen();
              }

              // Profile is complete - show home screen
              debugPrint('AuthGuard: Redirecting to home (profile complete)');
              return const HomeScreen();
            } catch (e) {
              // Error parsing profile - default to home (graceful degradation)
              debugPrint('AuthGuard: Error parsing profile data: $e');
              return const HomeScreen();
            }
          },
        );
      },
    );
  }
}
