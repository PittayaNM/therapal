import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  bool _isValid = false;
  bool _validatePhone(String phone) {
    phone = phone.replaceAll(' ', '');
    final regex = RegExp(r'^[689]\d{8,9}$');
    return regex.hasMatch(phone);
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
                'Enter your phone number to proceed',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 36),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (value) {
                  setState(() {
                    _isValid = _validatePhone(value);
                  });
                },
                decoration: InputDecoration(
                  prefixText: '+66 ',
                  prefixStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: _isValid
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  hintText: '',
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
                  onPressed: _isValid
                      ? () {
                          String phone = _phoneController.text.trim();

                          if (phone.startsWith('0')) {
                            phone = '66${phone.substring(1)}';
                          } else if (!phone.startsWith('66')) {
                            phone = '66$phone';
                          }

                          Navigator.pushNamed(
                            context,
                            '/otp',
                            arguments: phone,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B2E3),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Continue',
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
