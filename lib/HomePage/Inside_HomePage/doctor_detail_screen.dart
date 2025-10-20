import 'package:flutter/material.dart';

class DoctorDetailArgs {
  final String name;
  final String title;
  final String specialty;
  final double rating;
  final int reviews;
  final String about;
  final String licenseName;
  final String licenseNo;
  final String licenseExpire;
  final String? photoAsset; // ถ้ามีรูปใน assets

  const DoctorDetailArgs({
    required this.name,
    required this.title,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.about,
    required this.licenseName,
    required this.licenseNo,
    required this.licenseExpire,
    this.photoAsset, // เช่น 'assets/doctors/ugo.png'
  });
}

class DoctorDetailScreen extends StatelessWidget {
  final DoctorDetailArgs args;
  const DoctorDetailScreen({super.key, required this.args});

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

            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // AppBar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            args.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            args.title,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // รูปหมอ
                Center(
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.08),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: args.photoAsset != null
                          ? Image.asset(args.photoAsset!, fit: BoxFit.cover)
                          : const Icon(Icons.person, size: 80, color: Colors.black38),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // action shortcuts
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleAction(Icons.videocam_rounded, onTap: () {}),
                    const SizedBox(width: 18),
                    _circleAction(Icons.phone_rounded, onTap: () {}),
                    const SizedBox(width: 18),
                    _circleAction(Icons.chat_bubble_rounded, onTap: () {}),
                  ],
                ),

                const SizedBox(height: 18),

                // About Doctor
                _sectionCard(
                  title: 'About Doctor',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFB800), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${args.rating.toStringAsFixed(1)} ( ${args.reviews} Reviews )',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  child: Text(
                    args.about,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),

                // License
                _sectionCard(
                  title: 'license verification',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${args.licenseName}',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text('License No. ${args.licenseNo}',
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 6),
                            Text('Expiration: ${args.licenseExpire}',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      // ใช้ QR placeholder
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEEF2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.qr_code_rounded, size: 40),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                const Text(
                  'Make an appointment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF202020),
                  ),
                ),
                const SizedBox(height: 6),
                const Divider(height: 1),

                const SizedBox(height: 10),
                _appointmentButton(
                  label: '1-on-1 therapy',
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _appointmentButton(
                  label: 'Group therapy',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------- helpers --------

  Widget _circleAction(IconData icon, {required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4FF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF4F7DF3)),
        ),
      ),
    );
  }

  Widget _appointmentButton({required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF202020),
                ),
              ),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF1FD080),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_available_rounded,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBDEBFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C1C1C))),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _HeaderArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 120);
    p.quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 120);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
