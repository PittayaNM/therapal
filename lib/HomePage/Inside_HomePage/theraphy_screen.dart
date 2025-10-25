import 'package:flutter/material.dart';
import 'doctor_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TherapyScreen extends StatelessWidget {
  const TherapyScreen({super.key});

  Stream<List<_Therapist>> _getAvailableTherapists() {
    return FirebaseFirestore.instance
        .collection('therapists')
        .where('availability', isNull: false) // Only get therapists with availability
        .snapshots()
        .asyncMap((snapshot) async {
      final therapistsList = <_Therapist>[];
      
      for (var doc in snapshot.docs) {
        final therapistData = doc.data();
        final uid = doc.id; // This is the user's UID
        
        // Get user data from users collection
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        
        if (!userDoc.exists) continue; // Skip if user data not found
        
        final userData = userDoc.data()!;
        
    // Get specialties list and display string (use first with emoji)
    final specialtiesList = (therapistData['specialties'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];
    String specialty = specialtiesList.isNotEmpty
      ? '${_getSpecialtyEmoji(specialtiesList[0])}  ${specialtiesList[0]}'
      : '🧠  General Therapy';

        // Default rating if not set (we can add these fields to therapists collection later)
        final rating = (therapistData['rating'] as num?)?.toDouble() ?? 4.5;
        final reviews = (therapistData['reviews'] as int?) ?? 0;
            
        therapistsList.add(_Therapist(
          name: userData['name'] ?? 'Unknown',
          title: 'Therapist', // We can add title to users or therapists collection later
          specialty: specialty,
          rating: rating,
          reviews: reviews,
          uid: uid,
          about: therapistData['about'] as String?,
          availability: therapistData['availability'] as List<dynamic>?,
          specialties: specialtiesList,
        ));
      }
      
      return therapistsList;
    });
  }

  String _getSpecialtyEmoji(String specialty) {
    // Map specialties to emojis
    final emojiMap = {
      'Anxiety & Stress': '🧠',
      'Depression': '💬',
      'Mindfulness': '🌿',
      'Couple Therapy': '❤️',
      'Anxiety': '🍀',
      'Grief & Loss': '🌸',
      'Trauma Recovery': '💭',
    };

    // Find the first matching key or return default
    return emojiMap.entries
        .firstWhere(
          (entry) => specialty.toLowerCase().contains(entry.key.toLowerCase()),
          orElse: () => MapEntry('default', '🧠'),
        )
        .value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Header gradient curve
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

            StreamBuilder<List<_Therapist>>(
              stream: _getAvailableTherapists(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading therapists',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final therapists = snapshot.data!;

                if (therapists.isEmpty) {
                  return const Center(
                    child: Text(
                      'No therapists available at the moment',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                return ListView(
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

                    // Therapist list
                    for (final t in therapists) _TherapistCard(t: t),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  }


class _Therapist {
  final String name;
  final String title;
  final String specialty;
  final double rating;
  final int reviews;
  final String uid;
  final List<String>? specialties;
  final String? about;
  final List<dynamic>? availability;

  const _Therapist({
    required this.name,
    required this.title,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.uid,
    this.specialties,
    this.about,
    this.availability,
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorDetailScreen(
              args: DoctorDetailArgs(
                name: t.name,
                title: t.title,
                specialty: t.specialty,
                    specialties: t.specialties,
                rating: t.rating,
                reviews: t.reviews,
                about: t.about ?? 'A dedicated therapist here to help you on your journey to better mental health.',
                availability: t.availability,
                licenseName: t.name,
                licenseNo: 'XX-00000-XX', // These could be added to Firestore later
                licenseExpire: '00/00/0000',
                    therapistUid: t.uid,
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
            // Profile picture (use default icon if no photo)
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5FF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipOval(
                child: const Icon(Icons.person, size: 28, color: Color(0xFF6B7AFF)),
              ),
            ),
            const SizedBox(width: 12),

            // Name, title and specialty
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

            // Rating and reviews
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
