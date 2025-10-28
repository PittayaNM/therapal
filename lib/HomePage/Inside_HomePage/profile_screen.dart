import 'package:flutter/material.dart';
import 'package:therapal/Login_Reg/login_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // เนื้อหา
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // แถบบน: back ซ้าย
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 48,
                      backgroundImage: AssetImage('assets/Pin.png'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC83A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Golden',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5B4500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'George Josure',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 24),

                  // Section: Personal Details (หัวข้อ + Edit)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Personal Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  _infoRow(
                    icon: Icons.person_outline_rounded,
                    title: 'Name',
                    value: 'George Josure',
                  ),
                  _infoRow(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: 'grorge404@gmail.com',
                  ),
                  _infoRow(
                    icon: Icons.phone_outlined,
                    title: 'Contact',
                    value: '+66 987654321',
                  ),
                  _infoRow(
                    icon: Icons.cake_outlined,
                    title: 'Date of birth',
                    value: 'Jun 24 1965',
                  ),

                  const SizedBox(height: 24),

                  // Section: Contact Us
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Contact Us',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  _infoRow(
                    icon: Icons.call_outlined,
                    title: 'Phone',
                    value: '02-020-2020',
                  ),
                  _infoRow(
                    icon: Icons.alternate_email_outlined,
                    title: 'Email',
                    value: 'Therapal333@gmail.com',
                  ),

                  const SizedBox(height: 28),

                  // Log out button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCF1E16),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // TODO: ใส่ logic logout (ลบ token ฯลฯ) ก่อน navigate ถ้ามี
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false, // เคลียร์ทุกหน้าที่ค้างอยู่
                        );
                      },
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // home indicator bar
            Positioned(
              bottom: 10,
              left: (MediaQuery.of(context).size.width - 120) / 2,
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
}

// ---- helpers ----
Widget _infoRow({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x11000000)),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4F7DF3)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
