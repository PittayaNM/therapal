import 'package:flutter/material.dart';
import 'Login_Reg/login_screen.dart';

void main() {
  runApp(const TheraPalApp());
}

class TheraPalApp extends StatelessWidget {
  const TheraPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheraPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFF2ECE7),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
