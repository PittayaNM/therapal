import 'package:flutter/material.dart';
import 'doctor_detail_screen.dart';

class TherapyScreen extends StatelessWidget {
  const TherapyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final therapists = <_Therapist>[
      _Therapist(
        name: 'Dr. Ugo David',
        title: 'Sr.Psychologist',
        specialty: '🧠  Anxiety & Stress Management',
        rating: 4.9,
        reviews: 280,
        photoAsset: 'assets/Pin.png',
      ),
      _Therapist(
        name: 'Dr. Maya Chan',
        title: 'Psychologist',
        specialty: '💬  Depression & Emotional Regulation',
        rating: 4.8,
        reviews: 180,
      ),
      _Therapist(
        name: 'Dr. Elena Park',
        title: 'Psychotherapist',
        specialty: '🌿  Mindfulness & Work Burnout',
        rating: 4.5,
        reviews: 190,
      ),
      _Therapist(
        name: 'Dr. Kevin Lee',
        title: 'Couple Therapist',
        specialty: '❤️  Couple Therapy & Communication',
        rating: 4.7,
        reviews: 150,
      ),
      _Therapist(
        name: 'Dr. jame Berg',
        title: 'Clinical Psychologist',
        specialty: '🍀  Anxiety, OCD, and Self-Esteem',
        rating: 4.8,
        reviews: 320,
      ),
      _Therapist(
        name: 'Dr. Napat S.',
        title: 'Psychologist',
        specialty: '🌸  Grief & Emotional Healing',
        rating: 4.9,
        reviews: 100,
      ),
      _Therapist(
        name: 'Dr. Jessy Wong',
        title: 'Psychotherapist',
        specialty: '💭  Trauma Recovery & Self-Growth',
        rating: 4.8,
        reviews: 147,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // header gradient โค้ง
            ClipPath(
              clipper: _HeaderArcClipper(),
              child: Container(
                height: 220,
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
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Therapy',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find Your Therapist',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D1D1D),
                  ),
                ),
                const SizedBox(height: 12),

                // รายการนักบำบัด
                for (final t in therapists) _TherapistCard(t: t),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Therapist {
  final String name;
  final String title;        // เพิ่มตำแหน่งใต้ชื่อ
  final String specialty;    // รวมอีโมจิไว้หน้า text เพื่อให้เหมือนแบบ
  final double rating;
  final int reviews;
  final String? photoAsset;  // path รูปจาก assets (ถ้ามี)

  const _Therapist({
    required this.name,
    required this.title,
    required this.specialty,
    required this.rating,
    required this.reviews,
    this.photoAsset,
  });
}

class _TherapistCard extends StatelessWidget {
  final _Therapist t;
  const _TherapistCard({required this.t});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        // ส่ง args ไปหน้า DoctorDetail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorDetailScreen(
              args: DoctorDetailArgs(
                name: t.name,
                title: t.title,
                specialty: t.specialty,
                rating: t.rating,
                reviews: t.reviews,
                about:
                    'A doctor is someone who is experienced and certified to practice medicine to help maintain or restore physical and mental health.',
                licenseName: t.name,
                licenseNo: 'XX-00000-XX',
                licenseExpire: '00/00/0000',
                photoAsset: t.photoAsset,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
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
            // avatar วงกลม (ใช้รูปถ้ามี ไม่งั้นใช้ไอคอน)
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5FF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipOval(
                child: t.photoAsset != null
                    ? Image.asset(t.photoAsset!, fit: BoxFit.cover)
                    : const Icon(Icons.person, size: 28, color: Color(0xFF6B7AFF)),
              ),
            ),
            const SizedBox(width: 12),

            // ชื่อและสเปเชียลตี้
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // เรตติ้ง + รีวิว
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Color(0xFFFFB800), size: 18),
                const SizedBox(width: 4),
                Text(
                  t.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    ' ${t.reviews} Reviews ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
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

// โค้งหัว
class _HeaderArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 100);
    p.quadraticBezierTo(size.width / 2, size.height + 30, size.width, size.height - 100);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
