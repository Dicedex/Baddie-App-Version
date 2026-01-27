import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(255, 242, 106, 22),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 84, color: Colors.white),
            SizedBox(height: 16),
            Text('Baddie', style: TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Swipe. Match. Meet.', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
