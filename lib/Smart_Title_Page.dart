import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class SmartTitlePage extends StatefulWidget {
  const SmartTitlePage({super.key});

  @override
  State<SmartTitlePage> createState() => _SmartTitlePageState();
}

class _SmartTitlePageState extends State<SmartTitlePage> {
  @override
  void initState() {
    super.initState();
    // 3 seconds baad Login Screen par bhej dega
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4527A0), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 120, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "BGNU EVALUATION",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Smart System Gateway",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}