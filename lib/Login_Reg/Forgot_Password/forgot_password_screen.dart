import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  bool _isValid = false;
  bool _isLoading = false;

  bool _validateEmail(String email) {
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    return regex.hasMatch(email.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/therapal.png', width: 36),
                  const SizedBox(width: 8),
                  const Text(
                    'TheraPal',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF184059),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              const Text(
                'Forgot Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your email address to receive a password reset link',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 36),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _isValid = _validateEmail(value);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  suffixIcon: _isValid
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00B2E3), width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_isValid && !_isLoading)
                      ? () async {
                          setState(() => _isLoading = true);
                          try {
                            await _auth.sendPasswordResetEmail(
                              email: _emailController.text.trim(),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Password reset link has been sent to your email',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          } on FirebaseAuthException catch (e) {
                            String message = 'An error occurred';
                            if (e.code == 'user-not-found') {
                              message = 'No user found with this email address';
                            } else if (e.code == 'invalid-email') {
                              message = 'Invalid email address';
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    message,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B2E3),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Send Reset Link',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
