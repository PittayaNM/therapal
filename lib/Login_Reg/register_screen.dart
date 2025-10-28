import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _name = TextEditingController();
  final _dob = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  
  String _selectedRole = 'patient';
  bool _obscure1 = true;
  bool _obscure2 = true;
  DateTime? _dobValue;

  @override
  void dispose() {
    _name.dispose();
    _dob.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    colors: [Color(0xFFBDEBFF), Color(0xFFE7FAFF)],
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // โลโก้
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF7C4DFF),
                        child: Icon(Icons.psychology_alt_rounded,
                            size: 18, color: Colors.white),
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
                  const SizedBox(height: 28),
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 28),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Name'),
                        _roundedField(
                          controller: _name,
                          hint: 'Enter your name...',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            if (!RegExp(r"^[A-Za-z\s]+$").hasMatch(v.trim())) {
                              return 'Name can contain only letters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _label('Date of birth'),
                        _roundedField(
                          controller: _dob,
                          hint: 'Select your date of birth...',
                          readOnly: true,
                          suffix: IconButton(
                            icon: const Icon(Icons.calendar_today_outlined),
                            onPressed: _pickDob,
                          ),
                          validator: (_) {
                            if (_dobValue == null) {
                              return 'Please select your birth date';
                            }
                            final now = DateTime.now();
                            final age = now.year - _dobValue!.year;
                            if (_dobValue!.isAfter(now)) {
                              return 'Birth date cannot be in the future';
                            }
                            if (age < 10 ||
                                (_dobValue!.month == now.month &&
                                    _dobValue!.day > now.day)) {
                              return 'You must be at least 10 years old';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _label('Email'),
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
                            return ok ? null : 'Invalid email format';
                          },
                        ),
                        const SizedBox(height: 16),

                        _label('Phone number'),
                        _roundedField(
                          controller: _phone,
                          hint: 'Enter your phone number...',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            final phone = v.trim();
                            if (!RegExp(r'^\d{9,10}$').hasMatch(phone)) {
                              return 'Phone number must have 9–10 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _label('Password'),
                        _roundedField(
                          controller: _password,
                          hint: 'Enter your password...',
                          obscure: _obscure1,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure1
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure1 = !_obscure1),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (v.length < 6) {
                              return 'At least 6 characters';
                            }
                            if (!RegExp(r'^(?=.*[A-Z])(?=.*[0-9]).+$').hasMatch(v)) {
                              return 'Must contain 1 uppercase letter and 1 number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _label('Password Confirmation'),
                        _roundedField(
                          controller: _confirm,
                          hint: 'Confirm your password...',
                          obscure: _obscure2,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure2
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure2 = !_obscure2),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (v != _password.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _label('Role'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            items: const [
                              DropdownMenuItem(
                                  value: 'patient', child: Text('Patient')),
                              DropdownMenuItem(
                                  value: 'therapist', child: Text('Therapist')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedRole = value);
                              }
                            },
                          ),
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
                            onPressed: _onSubmit,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_right_alt_rounded,
                                    color: Colors.white, size: 26),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginScreen()),
                              );
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: 'Sign In.',
                                    style: TextStyle(
                                        color: Color(0xFF00A3D4),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
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

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 120, 1, 1);
    final last = now;
    final picked = await showDatePicker(
      context: context,
      initialDate: _dobValue ?? DateTime(now.year - 18),
      firstDate: first,
      lastDate: last,
      helpText: 'Select date of birth',
    );
    if (picked != null) {
      setState(() {
        _dobValue = picked;
        _dob.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Creating account...')));

        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
          'dateOfBirth': _dobValue?.toIso8601String(),
          'role': _selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Account created successfully!')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      );

  Widget _roundedField({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
