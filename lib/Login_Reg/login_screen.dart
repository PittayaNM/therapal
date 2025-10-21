import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../HomePage/home_screen.dart';
import 'package:therapal/Login_Reg/Forgot_Password/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ClipPath(
              clipper: _BottomArcClipper(),
              child: Container(
                height: 0,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFBDEBFF),
                      Color(0xFFE7FAFF),
                    ],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF7C4DFF),
                        child: Icon(
                          Icons.psychology_alt_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'TheraPal',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0C4A6E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Sign In',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Therapal',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Address',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _roundedField(
                          controller: _email,
                          hint: 'Enter your email...',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            final ok = RegExp(
                              r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$',
                            ).hasMatch(v.trim());
                            if (!ok) return 'Invalid email format';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _roundedField(
                          controller: _password,
                          hint: 'Enter your password...',
                          obscure: _obscure,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (v.length < 6) return 'At least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B2E3),
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_right_alt_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialCircle(Icons.facebook),
                            const SizedBox(width: 20),
                            _socialCircle(Icons.g_mobiledata, labelG: true),
                            const SizedBox(width: 20),
                            _socialCircle(Icons.camera_alt_outlined),
                          ],
                        ),
                        const SizedBox(height: 32),

                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Text.rich(
                                TextSpan(
                                  text: "Don't have an account? ",
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RegisterScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            color: Color(0xFF00A3D4),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password',
                                style: TextStyle(
                                  color: Color(0xFFD27A2B),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 10,
              left: (width - 120) / 2,
              child: Container(
                width: 120,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4A3A),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _socialCircle(IconData icon, {bool labelG = false}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
      child: Center(
        child: labelG
            ? const Text(
                'G',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              )
            : Icon(icon, size: 24, color: Colors.black87),
      ),
    );
  }
}

class _BottomArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 100,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
