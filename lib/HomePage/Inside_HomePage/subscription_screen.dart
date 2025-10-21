import '../../Payments/payment_screen.dart';
import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  /// 0 = Monthly (Free trial), 1 = Yearly
  int _selectedPlan = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Header gradient โค้ง
            ClipPath(
              clipper: _HeaderArcClipper(),
              child: Container(
                height: 340,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFBDEBFF), Color(0xFFE7FAFF)],
                  ),
                ),
              ),
            ),

            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Row(
                  children: [
                    _roundIcon(
                      Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Unlimited Access',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Talk   Heal   Grow   Anytime',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 18),

                const Icon(Icons.groups_2_rounded,
    size: 120, color: Color(0xFF8FA9C8)),

                const SizedBox(height: 16),
                const _FeatureRow(text: 'Ads Free!'),
                const SizedBox(height: 10),
                const _FeatureRow(text: 'Choose Therapist'),
                const SizedBox(height: 10),
                const _FeatureRow(text: 'Unlimited Appointment'),
                const SizedBox(height: 18),

                // การ์ดราคา (เลือกได้)
                Row(
                  children: [
                    Expanded(
                      child: _PlanCard(
                        titleTop: '3-Day Free Trial',
                        price: '\$29.99',
                        subtitle: 'Month',
                        badgeText: null,
                        selected: _selectedPlan == 0,
                        onTap: () => setState(() => _selectedPlan = 0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PlanCard(
                        titleTop: 'Yearly Access',
                        price: '\$129.99',
                        subtitle: 'Year',
                        badgeText: 'Save \$230',
                        selected: _selectedPlan == 1,
                        onTap: () => setState(() => _selectedPlan = 1),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ปุ่ม Unlock ใช้ค่าที่เลือก
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B2E3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final isMonthly = _selectedPlan == 0;
                      final planName = isMonthly
                          ? 'Golden package'
                          : 'Yearly Access';
                      final price = isMonthly ? 49.99 : 129.99;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PaymentScreen(planName: planName, price: price),
                        ),
                      );
                    },
                    child: const Text(
                      'Unlock Access',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _link('Terms of use', () {}),
                    _dotDivider(),
                    _link('Privacy Policy', () {}),
                    _dotDivider(),
                    _link('Restore', () {}),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // helpers
  static Widget _link(String text, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0E88A7),
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );

  static Widget _dotDivider() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 6),
    child: Text('│', style: TextStyle(color: Colors.black38)),
  );

  static Widget _roundIcon(IconData icon, {VoidCallback? onTap}) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(26),
    child: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: Colors.black87),
    ),
  );
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF1CC3FF), width: 3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.check, size: 18, color: Color(0xFF1CC3FF)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C1C1C),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String titleTop;
  final String price;
  final String subtitle;
  final String? badgeText;
  final bool selected;
  final VoidCallback onTap;

  // ❗ เอา const ออกเพื่อให้แก้ฟิลด์แล้ว Hot Reload ได้
  _PlanCard({
    required this.titleTop,
    required this.price,
    required this.subtitle,
    this.badgeText,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xFF16B1E8)
        : const Color(0xFFDFE3EA);
    final bg = Colors.white;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // เนื้อหา
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleTop,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0E1115),
                    ),
                  ),
                  if (badgeText != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeText!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1D3C86),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              // tick มุมขวาบน
              Positioned(
                right: 0,
                top: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF16B1E8)
                          : const Color(0xFFB9C3CF),
                      width: 2,
                    ),
                    color: selected ? const Color(0xFF16B1E8) : Colors.white,
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// โค้งหัว
class _HeaderArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 140);
    p.quadraticBezierTo(
      size.width / 2,
      size.height - 10,
      size.width,
      size.height - 140,
    );
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
