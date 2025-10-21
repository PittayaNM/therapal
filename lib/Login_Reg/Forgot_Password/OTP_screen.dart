import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  int _seconds = 30;
  Timer? _timer;

  String get _otp => _controllers.map((c) => c.text).join();
  bool get _isComplete => _otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(_otp);

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_nodes.isNotEmpty) _nodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _nodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final phone = (arg is String && arg.isNotEmpty) ? '+$arg' : '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 12),

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

              const SizedBox(height: 42),

              const Text(
                'Verify OTP',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Please enter OTP sent to $phone ',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: Color(0xFF00A3D4),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return _OtpBox(
                    controller: _controllers[i],
                    focusNode: _nodes[i],
                    onChanged: (v) => _onChanged(i, v),
                  );
                }),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B2E3),
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isComplete
                      ? () {
                          Navigator.pushNamed(context, '/reset-password');
                        }
                      : null,
                  child: const Text(
                    'Verify',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              if (_seconds > 0)
                Text.rich(
                  TextSpan(
                    text: "Didn't receive the OTP? ",
                    style: const TextStyle(fontSize: 15),
                    children: [
                      TextSpan(
                        text: 'Retry in ${_seconds.toString().padLeft(2, '0')}s',
                        style: const TextStyle(
                          color: Color(0xFF246BFD),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                )
              else
                GestureDetector(
                  onTap: () {
                    for (final c in _controllers) {
                      c.clear();
                    }
                    _nodes.first.requestFocus();
                    _startTimer();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP has been resent.')),
                    );
                  },
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: Color(0xFF246BFD),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
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

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.only(top: 6, bottom: 6),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4CD964), width: 2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4CD964), width: 3),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
