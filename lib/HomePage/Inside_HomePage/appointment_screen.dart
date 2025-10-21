import 'package:flutter/material.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // header gradient โค้ง
            ClipPath(
              clipper: _HeaderArcClipper(),
              child: Container(
                height: 240,
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
                // app bar (back, title, bell)
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Appointment',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),

                const SizedBox(height: 12),
                const Text(
                  'Upcoming',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D1D1D),
                  ),
                ),
                const SizedBox(height: 12),

                // ---- Upcoming cards ----
                _ApptCard(
                  color: const Color(0xFFFFA66B),
                  icon: Icons.groups_2_rounded,
                  title: '1-on-1 therapy',
                  time: '11:00–13:00',
                  date: '30/9/2025',
                  doctor: 'Dr.Ugo David',
                  joinLabel: 'join',
                  joinColor: const Color(0xFF27C07D),
                  // ✅ เพิ่ม nav ไปหน้า CallScreen
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CallScreen()),
                    );
                  },
                ),
                _ApptCard(
                  color: const Color(0xFFB5F0C3),
                  icon: Icons.group_rounded,
                  title: 'Group therapy',
                  time: '13:00–15:00',
                  date: '1/10/2025',
                  doctor: 'Dr.Ugo David',
                  joinLabel: 'join',
                ),
                _ApptCard(
                  color: const Color(0xFFFFC6A1),
                  icon: Icons.groups_2_rounded,
                  title: '1-on-1 therapy',
                  time: '09:00–12:00',
                  date: '5/10/2025',
                  doctor: 'Dr. Elena Park',
                  joinLabel: 'join',
                ),

                const SizedBox(height: 16),
                const Text(
                  'Last Week',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D1D1D),
                  ),
                ),
                const SizedBox(height: 12),

                // ---- Last week cards ----
                _ApptCard(
                  color: const Color(0xFFFFF3B5),
                  icon: Icons.groups_2_rounded,
                  title: '1-on-1 therapy',
                  time: '10:00–12:00',
                  date: '17/9/2025',
                  doctor: 'Dr. Kevin Lee',
                  joinLabel: 'join',
                  muted: true,
                ),
                _ApptCard(
                  color: const Color(0xFFE0C8FF),
                  icon: Icons.groups_2_rounded,
                  title: '1-on-1 therapy',
                  time: '11:00–13:00',
                  date: '15/9/2025',
                  doctor: 'Dr. Kevin Lee',
                  joinLabel: 'join',
                  muted: true,
                ),
                _ApptCard(
                  color: const Color(0xFFD9E6FF),
                  icon: Icons.group_rounded,
                  title: 'Group therapy',
                  time: '16:00–18:00',
                  date: '12/9/2025',
                  doctor: 'Dr. jame Berg',
                  joinLabel: 'join',
                  muted: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- widgets ----------

class _ApptCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String time;
  final String date;
  final String doctor;
  final String joinLabel;
  final Color? joinColor;
  final bool muted;
  final VoidCallback? onTap; // ✅ เพิ่ม callback กด

  const _ApptCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.time,
    required this.date,
    required this.doctor,
    required this.joinLabel,
    this.joinColor,
    this.muted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = muted ? Colors.black54 : const Color(0xFF202020);

    return GestureDetector(
      onTap: onTap, // ✅ ใช้งาน callback ที่ส่งมา
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // left avatar circle
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26, color: Colors.black87),
            ),
            const SizedBox(width: 12),

            // center title + date + join chip
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 13,
                          color: muted ? Colors.black38 : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        label: joinLabel,
                        bg: (joinColor ?? const Color(0xFFEDEEF2))
                            .withOpacity(muted ? .6 : 1),
                        fg: joinColor != null
                            ? Colors.white
                            : Colors.black54,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // right time + doctor
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  doctor,
                  style: TextStyle(
                    fontSize: 13,
                    color: muted ? Colors.black38 : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Chip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: fg,
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
    p.lineTo(0, size.height - 100);
    p.quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 100);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// -------------------------------
// ✅ หน้าจอโทรจำลอง
// -------------------------------
class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/Pin.png'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Dr. Ugo David',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text('Calling…',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded,
                        color: Colors.white, size: 36),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 40),
                  FloatingActionButton(
                    backgroundColor: Colors.redAccent,
                    onPressed: () => Navigator.pop(context),
                    child:
                        const Icon(Icons.call_end_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 40),
                  IconButton(
                    icon: const Icon(Icons.videocam_rounded,
                        color: Colors.white, size: 36),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
