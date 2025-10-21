// main.dart
import 'package:flutter/material.dart';
import 'package:therapal/Login_Reg/login_screen.dart';
import 'package:therapal/Login_Reg/Forgot_Password/forgot_password_screen.dart';
import 'package:therapal/Login_Reg/Forgot_Password/OTP_screen.dart';
import 'package:therapal/Login_Reg/Forgot_Password/reset_password_screen.dart';
import 'package:therapal/HomePage/home_screen.dart';

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
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/otp': (_) => const OtpVerifyScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
        '/home': (_) => const HomeScreen(), 
      },
    );
  }
}
