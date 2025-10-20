import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // พื้นหลังฟ้าโค้ง
            ClipPath(
              clipper: _HeaderArcClipper(),
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

            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // AppBar แถวบน
                Row(
                  children: [
                    _roundIcon(
                      Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Help Center',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                    const Spacer(),
                    _roundIcon(Icons.notifications_none_rounded),
                  ],
                ),
                const SizedBox(height: 20),

                // แถบ Tab – เน้น "Contact Us"
                const _TabHeader(activeLabel: 'Contact Us'),

                const SizedBox(height: 16),

                // การ์ด “Contact Information”
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 14),

                      _InfoTile(
                        icon: Icons.support_agent_rounded,
                        iconBg: Color(0xFFE5F6FF),
                        title: 'Phone Support',
                        primary: '02-020-2020',
                        secondary: 'Available Monday–Friday, 9AM–6PM',
                      ),
                      SizedBox(height: 12),

                      _InfoTile(
                        icon: Icons.mail_outline_rounded,
                        iconBg: Color(0xFFEFF4FF),
                        title: 'Email Support',
                        primary: 'Therapal333@gmail.com',
                        secondary: 'We typically respond within 24 hours',
                      ),
                      SizedBox(height: 12),

                      _InfoTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconBg: Color(0xFFEAFBF1),
                        title: 'Live Chat',
                        primary: 'Available in the app',
                        secondary:
                            'Chat with our support team in real-time',
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                // *** ไม่ใส่ส่วน "Send Us a Message" ตามที่ขอ ***
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ปุ่มกลมบนแอปบาร์
  static Widget _roundIcon(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }
}

// แถบชื่อแท็บ + เส้น underline
class _TabHeader extends StatelessWidget {
  final String activeLabel;
  const _TabHeader({required this.activeLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          activeLabel,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1D1D1D),
          ),
        ),
        const SizedBox(height: 8),
        // เส้นหนาใต้ tab
        Row(
          children: [
            Container(
              width: 140,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Expanded(
              child: Divider(
                height: 3,
                thickness: 1,
                color: Color(0xFFE6E8ED),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// แถวข้อมูลติดต่อ
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String primary;
  final String secondary;

  const _InfoTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 26, color: const Color(0xFF3A78D0)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                primary,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                secondary,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// โค้งหัวแบบเดียวกับหน้าก่อน ๆ
class _HeaderArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 100);
    p.quadraticBezierTo(size.width / 2, size.height + 40, size.width, size.height - 100);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
