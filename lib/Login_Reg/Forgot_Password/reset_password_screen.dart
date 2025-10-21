import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _pw1 = TextEditingController();
  final _pw2 = TextEditingController();
  bool _ob1 = true, _ob2 = true;

  @override
  void dispose() {
    _pw1.dispose();
    _pw2.dispose();
    super.dispose();
  }

  bool get _valid =>
      _pw1.text.isNotEmpty &&
      _pw2.text.isNotEmpty &&
      _pw1.text == _pw2.text &&
      _pw1.text.length >= 8;

  @override
  Widget build(BuildContext context) {
    final String phoneOrToken =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              const Text(
                'Re-set\nPassword',
                style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please enter a new password for your account',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              if (phoneOrToken.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  phoneOrToken, 
                  style: const TextStyle(fontSize: 13, color: Colors.black38),
                ),
              ],
              const SizedBox(height: 28),

              _field(
                controller: _pw1,
                label: 'New Password',
                obscure: _ob1,
                toggle: () => setState(() => _ob1 = !_ob1),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              _field(
                controller: _pw2,
                label: 'Confirm Password',
                obscure: _ob2,
                toggle: () => setState(() => _ob2 = !_ob2),
                onChanged: (_) => setState(() {}),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _valid
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password updated')),
                          );
                          Navigator.popUntil(context, (r) => r.isFirst);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B2E3),
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          onPressed: toggle,
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
