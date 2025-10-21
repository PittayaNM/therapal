import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Login_Reg/login_screen.dart';
import '../services/auth_service.dart';
import 'Inside_HomePage/profile_screen.dart';
import 'Inside_HomePage/theraphy_screen.dart';
import 'Inside_HomePage/appointment_screen.dart';
import 'Inside_HomePage/help_screen.dart';
import 'Inside_HomePage/subscription_screen.dart';
import 'package:therapal/HomePage/Inside_HomePage/Lives_screens.dart';

class HomeScreen extends StatefulWidget {
  final String userRole;
  
  const HomeScreen({
    super.key,
    required this.userRole,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  String? _userName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _userName = userData?['name'] as String?;
      });
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - 24 * 2 - 16) / 2;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // พื้นหลังฟ้าโค้ง
            ClipPath(
              clipper: _HeaderArcClipper(),
              child: Container(
                height: 300,
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
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // โลโก้ + คำว่า Menu อยู่ตรงกลางจริง
                  // โลโก้ซ้าย + "Menu" กลางจริง (ถ่วงด้านขวาให้เท่ากับโลโก้)
                  Row(
                    children: [
                      // โลโก้ซ้าย
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          'assets/therapal.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      // ข้อความ "Menu" ตรงกลางจริง
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Menu',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF454545),
                            ),
                          ),
                        ),
                      ),

                      // กล่องเปล่าด้านขวา กว้างเท่าโลโก้ซ้าย เพื่อให้กึ่งกลางพอดี
                      const SizedBox(width: 50, height: 50),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Avatar → แตะแล้วไปหน้าโปรไฟล์
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 86,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/Pin.png'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  if (_userName != null) Text(
                    'Hi, ${widget.userRole == 'patient' ? 'Patient' : 'Dr.'} $_userName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3C3C3C),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // การ์ด 2x2
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _MenuCard(
                        width: cardWidth,
                        icon: Icons.live_tv_rounded,
                        title: 'Lives',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LivesScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        width: cardWidth,
                        icon: Icons.event_note_rounded,
                        title: 'Appointment',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AppointmentScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        width: cardWidth,
                        icon: Icons.volunteer_activism_rounded,
                        title: 'Therapy',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TherapyScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        width: cardWidth,
                        icon: Icons.support_agent_rounded,
                        title: 'Help',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HelpScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // การ์ด Subscription เต็มแถว
                  _MenuCard(
                    width: double.infinity,
                    icon: Icons.emoji_events_rounded,
                    title: 'Subscription',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tap(String name) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$name tapped')));
  }
}

// --- การ์ดเมนู ---
class _MenuCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF4F7DF3)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black26),
              ],
            ),
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
    p.lineTo(0, size.height - 120);
    p.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 120,
    );
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
