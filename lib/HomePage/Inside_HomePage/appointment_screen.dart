import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Call_screen.dart';
import '../../utils/settings.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        _userRole = doc.data()?['role'] as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _userRole == 'therapist' 
        ? const TherapistAppointmentScreen()
        : const PatientAppointmentScreen();
  }
}

// Original patient view
class PatientAppointmentScreen extends StatelessWidget {
  const PatientAppointmentScreen({super.key});

  Stream<List<Map<String, dynamic>>> _getPatientAppointments() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('appointments')
        .where('patientUid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
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
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getPatientAppointments(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final appts = snapshot.data!;
                final uid = FirebaseAuth.instance.currentUser?.uid;
                
                // Debug: Print all appointments to see what we're getting
                print('Debug Copilot 01 Patient appointments fetched: ${appts.length} total');
                for (var appt in appts) {
                  print('Debug Copilot 02  - ${appt['date']} ${appt['timeRange']} | status: ${appt['status']} | patientUid: ${appt['patientUid']} | patientName: ${appt['patientName']} | currentUid: $uid');
                }
                
                final upcoming = appts.where((a) => a['status'] == 'confirmed').toList();
                // For completed section: show completed sessions OR only this patient's own cancelled sessions
                final completed = appts.where((a) {
                  if (a['status'] == 'completed') return true;
                  if (a['status'] == 'cancelled' && a['patientUid'] == uid) return true;
                  return false;
                }).toList();
                
                print('📋 Upcoming: ${upcoming.length}, Completed: ${completed.length}');

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
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
                    if (upcoming.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No upcoming appointments',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    else
                      ...upcoming.map((a) => PatientApptCard(appointment: a)),
                    const SizedBox(height: 16),
                    const Text(
                      'Completed Sessions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D1D1D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (completed.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No completed sessions',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    else
                      ...completed.map((a) => PatientApptCard(appointment: a, muted: true)),
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

// ========================================
// THERAPIST APPOINTMENT SCREEN
// ========================================
class TherapistAppointmentScreen extends StatelessWidget {
  const TherapistAppointmentScreen({super.key});

  Stream<List<Map<String, dynamic>>> _getTherapistAppointments() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorUid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
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
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getTherapistAppointments(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final appointments = snapshot.data!;

                // IMPORTANT: Only group CONFIRMED appointments together
                // Cancelled/completed appointments should not be grouped with new confirmed ones
                final confirmedAppointments = appointments.where((a) => a['status'] == 'confirmed').toList();
                final nonConfirmedAppointments = appointments.where((a) => a['status'] != 'confirmed').toList();

                // Group only confirmed appointments by session (date + timeRange + doctorUid)
                final Map<String, List<Map<String, dynamic>>> groupedAppointments = {};
                for (var appt in confirmedAppointments) {
                  final sessionKey = '${appt['date']}_${appt['timeRange']}_${appt['doctorUid']}';
                  groupedAppointments.putIfAbsent(sessionKey, () => []);
                  groupedAppointments[sessionKey]!.add(appt);
                }

                // Convert grouped confirmed appointments to session objects
                final upcomingSessions = groupedAppointments.entries.map((entry) {
                  final sessionAppointments = entry.value;
                  final session = Map<String, dynamic>.from(sessionAppointments.first);
                  session['allPatients'] = sessionAppointments; // Only confirmed patients
                  session['bookedCount'] = sessionAppointments.length;
                  return session;
                }).toList();

                // For completed/cancelled: DON'T group by session, keep them separate
                // Each cancelled/completed session should be independent
                // Group by BOTH session key AND a unique identifier (first patient UID + timestamp)
                final Map<String, List<Map<String, dynamic>>> completedGrouped = {};
                for (var appt in nonConfirmedAppointments) {
                  // Create unique key: date_time_doctor_status_firstPatientBooking
                  // This ensures each booking session stays separate even if cancelled at different times
                  final uniqueKey = '${appt['date']}_${appt['timeRange']}_${appt['doctorUid']}_${appt['status']}_${appt['createdAt']?.toString() ?? appt['id']}';
                  completedGrouped.putIfAbsent(uniqueKey, () => []);
                  completedGrouped[uniqueKey]!.add(appt);
                }

                final completedSessions = completedGrouped.entries.map((entry) {
                  final sessionAppointments = entry.value;
                  final session = Map<String, dynamic>.from(sessionAppointments.first);
                  session['allPatients'] = sessionAppointments;
                  session['bookedCount'] = sessionAppointments.length;
                  return session;
                }).toList();

                final upcoming = upcomingSessions;
                final completed = completedSessions;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
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
                    if (upcoming.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text('No upcoming appointments', style: TextStyle(color: Colors.black54)),
                        ),
                      )
                    else
                      ...upcoming.map((appt) => TherapistApptCard(appointment: appt)),
                    const SizedBox(height: 16),
                    const Text(
                      'Completed Sessions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D1D1D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (completed.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text('No completed sessions', style: TextStyle(color: Colors.black54)),
                        ),
                      )
                    else
                      ...completed.map((appt) => TherapistApptCard(appointment: appt, muted: true)),
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

// ---------- widgets ----------

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

// Therapist Appointment Card
class TherapistApptCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool muted;

  const TherapistApptCard({
    super.key,
    required this.appointment,
    this.muted = false,
  });

  Color _getCardColor() {
    final type = appointment['type'] as String? ?? '';
    if (type.contains('1-on-1')) return const Color(0xFFFFA66B);
    return const Color(0xFFB5F0C3);
  }

  IconData _getIcon() {
    final type = appointment['type'] as String? ?? '';
    if (type.contains('1-on-1')) return Icons.groups_2_rounded;
    return Icons.group_rounded;
  }

  Future<void> _updateStatus(BuildContext context, String appointmentId, String newStatus) async {
    try {
        // Update all appointments in this session
        final allPatients = appointment['allPatients'] as List<Map<String, dynamic>>? ?? [appointment];
        final batch = FirebaseFirestore.instance.batch();
      
        for (var patient in allPatients) {
          final docId = patient['id'] as String?;
          if (docId != null) {
            final ref = FirebaseFirestore.instance.collection('appointments').doc(docId);
            batch.update(ref, {'status': newStatus});
          }
        }
      
        await batch.commit();

        // Clean up therapist slots when completing or cancelling
        if (newStatus == 'completed' || newStatus == 'cancelled') {
          await _removeAllPatientsFromSlot(allPatients);
        }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment ${newStatus}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _removeAllPatientsFromSlot(List<Map<String, dynamic>> allPatients) async {
    if (allPatients.isEmpty) return;
    
    final firstAppt = allPatients.first;
    final doctorUid = firstAppt['doctorUid'] as String?;
    final dayName = firstAppt['day'] as String?; // Use day field directly from appointment
    final timeRange = firstAppt['timeRange'] as String?;
    final appointmentType = firstAppt['type'] as String?;
    
    if (doctorUid == null || dayName == null || timeRange == null) {
      print('❌ Missing required fields: doctorUid=$doctorUid, dayName=$dayName, timeRange=$timeRange');
      return;
    }
    
    print('🔍 _removeAllPatientsFromSlot called');
    print('  doctorUid: $doctorUid');
    print('  dayName: $dayName (from appointment.day field)');
    print('  timeRange: $timeRange');
    print('  type: $appointmentType');
    
    try {
      final therapistDoc = await FirebaseFirestore.instance
          .collection('therapists')
          .doc(doctorUid)
          .get();
      
      if (!therapistDoc.exists) {
        print('❌ Therapist document not found');
        return;
      }
      
      final availability = therapistDoc.data()?['availability'] as List<dynamic>?;
      if (availability == null) {
        print('❌ No availability data');
        return;
      }
      
      print('  📅 Availability has ${availability.length} days');
      
      // Find the matching day and slot using the day field from appointment
      bool updated = false;
      for (var dayData in availability) {
        print('  Checking day: ${dayData['day']}');
        if (dayData['day'] == dayName) {
          print('    ✅ DAY MATCHED!');
          final slots = dayData['slots'] as List<dynamic>?;
          if (slots != null) {
            print('    Slots in this day: ${slots.length}');
            for (var slot in slots) {
              print('    ⏰ Checking slot: "${slot['time']}" vs "$timeRange"');
              if (slot['time'] == timeRange) {
                print('      ✅ TIME MATCHED!');
                final currentBooked = slot['booked'] as int? ?? 0;
                final currentPatients = slot['bookedPatients'] as List? ?? [];
                print('      📋 Before: booked=$currentBooked, patients=$currentPatients');
                
                // Clear all patient UIDs from this slot
                slot['bookedPatients'] = [];
                // Reset booked count to 0
                slot['booked'] = 0;
                // Reset oneOnOneBooked flag when clearing all patients
                slot['oneOnOneBooked'] = false;
                print('      ✅ After: Cleared all patients, reset booked count to 0, and reset oneOnOneBooked');
                updated = true;
                break;
              }
            }
          }
          if (updated) break;
        }
      }
      
      if (updated) {
        await FirebaseFirestore.instance
            .collection('therapists')
            .doc(doctorUid)
            .update({'availability': availability});
      }
    } catch (e) {
      print('Error removing patients from slot: $e');
    }
  }

  Future<void> _updateCallingStatus(BuildContext context, String appointmentId, String newCallingStatus) async {
    try {
        // Update all appointments in this session
        final allPatients = appointment['allPatients'] as List<Map<String, dynamic>>? ?? [appointment];
        final batch = FirebaseFirestore.instance.batch();
      
        for (var patient in allPatients) {
          final docId = patient['id'] as String?;
          if (docId != null) {
            final ref = FirebaseFirestore.instance.collection('appointments').doc(docId);
            batch.update(ref, {'calling': newCallingStatus});
          }
        }
      
        await batch.commit();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call status updated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showPatientList(BuildContext context) async {
    // Get patient list from grouped appointments
    final allPatients = appointment['allPatients'] as List<Map<String, dynamic>>? ?? [appointment];
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Booked Patients'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: allPatients.isEmpty
                  ? [const Text('No patients booked')]
                  : allPatients.map((data) {
                      final isCancelled = (data['status'] as String?) == 'cancelled';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: (data['patientName'] ?? 'Unknown').toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isCancelled ? Colors.red : Colors.black,
                                  fontSize: 14,
                                ),
                                children: isCancelled
                                    ? const [
                                        TextSpan(
                                          text: ' (cancelled)',
                                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                                        )
                                      ]
                                    : const [],
                              ),
                            ),
                            Text(
                              data['patientEmail'] ?? 'No email',
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                            if (data['patientPhone'] != null && data['patientPhone'].toString().isNotEmpty)
                              Text(
                                data['patientPhone'],
                                style: const TextStyle(fontSize: 13, color: Colors.black54),
                              ),
                            const Divider(),
                          ],
                        ),
                      );
                    }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = appointment['type'] as String? ?? '';
    final timeRange = appointment['timeRange'] as String? ?? '';
    final date = appointment['date'] as String? ?? '';
    final capacity = appointment['capacity'] as int? ?? 1;
    final status = appointment['status'] as String? ?? 'confirmed';
    final calling = appointment['calling'] as String? ?? 'awaiting for therapist';
    final appointmentId = appointment['id'] as String? ?? '';
    final bookedCount = appointment['bookedCount'] as int? ?? 1;
    final participants = (appointment['allPatients'] as List?)?.cast<Map<String, dynamic>>() ?? [appointment];
    // Filter to only confirmed patients for display
    final confirmedParticipants = participants.where((p) => p['status'] == 'confirmed').toList();
    
    // For display purposes, we need to get the current booked count
    // This is a simplified version - in production you'd fetch this from therapist doc
    final textColor = muted ? Colors.black54 : const Color(0xFF202020);

    String _initials(String name) {
      final parts = name.trim().split(RegExp(r"\s+"));
      if (parts.isEmpty) return '?';
      String first = parts.first.isNotEmpty ? parts.first[0] : '';
      String last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
      final res = (first + last).toUpperCase();
      return res.isEmpty ? '?' : res;
    }

    return GestureDetector(
      onTap: muted ? () => _showPatientList(context) : null,
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
      child: Column(
        children: [
          Row(
            children: [
              // Left avatar circle
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _getCardColor(),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getIcon(), size: 26, color: Colors.black87),
                  ),
                  // overlay mini initials for up to 3 confirmed patients only
                  for (int i = 0; i < (confirmedParticipants.length > 3 ? 3 : confirmedParticipants.length); i++)
                    Positioned(
                      right: -6.0 + i * 18.0,
                      bottom: -6,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEDEEF2),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initials((confirmedParticipants[i]['patientName'] ?? 'U') as String),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              
              // Center info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                 'Capacity: $bookedCount/$capacity',
                      style: TextStyle(
                        fontSize: 12,
                        color: muted ? Colors.black38 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: muted ? Colors.black38 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 10),
              
              // Right time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeRange,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _Chip(
                    label: status,
                    bg: status == 'completed' 
                        ? const Color(0xFF27C07D)
                        : status == 'cancelled'
                            ? Colors.red.shade100
                            : const Color(0xFFEDEEF2),
                    fg: status == 'completed' ? Colors.white : Colors.black54,
                  ),
                ],
              ),
            ],
          ),
          
          if (!muted) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            
            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showPatientList(context),
                  icon: const Icon(Icons.people, size: 18),
                  label: const Text('Patients'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F6FF),
                    foregroundColor: const Color(0xFF00B2E3),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                if (calling == 'awaiting for therapist')
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _updateCallingStatus(context, appointmentId, 'calling');
                      // Auto-navigate therapist to call once started
                      String _buildChannelId(Map<String, dynamic> appt) {
                        final doctorUid = (appt['doctorUid'] ?? '').toString();
                        final date = (appt['date'] ?? '').toString();
                        final time = (appt['timeRange'] ?? '').toString();
                        final raw = '${doctorUid}_${date}_${time}';
                        return raw.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
                      }
            final channelId = (defaultChannelId.isNotEmpty)
              ? defaultChannelId
              : _buildChannelId(appointment);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CallScreen(channelId: channelId, token: token),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Start Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27C07D),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                if (calling == 'calling') ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      // Build a deterministic channel id for this session
                      String _buildChannelId(Map<String, dynamic> appt) {
                        final doctorUid = (appt['doctorUid'] ?? '').toString();
                        final date = (appt['date'] ?? '').toString();
                        final time = (appt['timeRange'] ?? '').toString();
                        final raw = '${doctorUid}_${date}_${time}';
                        return raw.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
                      }

                      final channelId = _buildChannelId(appointment);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CallScreen(channelId: channelId, token: token),
                        ),
                      );
                    },
                    icon: const Icon(Icons.video_call, size: 18),
                    label: const Text('Join Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Stop Call'),
                          content: const Text('Stop this call for all participants?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _updateCallingStatus(context, appointmentId, 'awaiting for therapist');
                              },
                              child: const Text('Yes, Stop'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.call_end, size: 18),
                    label: const Text('Stop Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Complete Session'),
                        content: const Text('Mark this session as completed?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _updateStatus(context, appointmentId, 'completed');
                            },
                            child: const Text('Yes, Complete'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Cancel Appointment'),
                        content: const Text('Are you sure you want to cancel this appointment?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _updateStatus(context, appointmentId, 'cancelled');
                            },
                            child: const Text('Yes, Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ] else ...[
            // muted card: still allow quick access to patients list for contact
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => _showPatientList(context),
                icon: const Icon(Icons.people_alt_outlined, size: 18),
                label: const Text('Patients'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }
}

// -------------------------------
// Patient Appointment Card
// -------------------------------
class PatientApptCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool muted;

  const PatientApptCard({super.key, required this.appointment, this.muted = false});

  Color _getCardColor() {
    final type = appointment['type'] as String? ?? '';
    if (type.contains('1-on-1')) return const Color(0xFFFFA66B);
    return const Color(0xFFB5F0C3);
  }

  IconData _getIcon() {
    final type = appointment['type'] as String? ?? '';
    if (type.contains('1-on-1')) return Icons.groups_2_rounded;
    return Icons.group_rounded;
  }

  Future<List<Map<String, dynamic>>> _fetchPeers() async {
    final timeRange = appointment['timeRange'] as String? ?? '';
    final date = appointment['date'] as String? ?? '';
    final doctorUid = appointment['doctorUid'] as String? ?? '';
    final qs = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorUid', isEqualTo: doctorUid)
        .where('date', isEqualTo: date)
        .where('timeRange', isEqualTo: timeRange)
        .get();
    return qs.docs.map((d) => {...d.data(), 'id': d.id}).toList();
  }

  void _showInfoDialog(BuildContext context, List<Map<String, dynamic>> peers) {
    final therapistName = appointment['doctorName'] ?? 'Therapist';
    final therapistTitle = appointment['doctorTitle'] ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Session Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Therapist: $therapistName', style: const TextStyle(fontWeight: FontWeight.w700)),
              if (therapistTitle.toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 8),
                  child: Text(therapistTitle, style: const TextStyle(color: Colors.black54)),
                ),
              const Divider(),
              const SizedBox(height: 6),
              const Text('Other Patients:', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              ...peers.map((p) {
                final isCancelled = (p['status'] as String?) == 'cancelled';
                final name = (p['patientName'] ?? 'Unknown').toString();
                final email = (p['patientEmail'] ?? '').toString();
                final phone = (p['patientPhone'] ?? '').toString();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: name,
                          style: TextStyle(
                            color: isCancelled ? Colors.red : Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          children: isCancelled
                              ? const [
                                  TextSpan(
                                    text: ' (cancelled)',
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                                  )
                                ]
                              : const [],
                        ),
                      ),
                      if (email.isNotEmpty)
                        Text(email, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      if (phone.isNotEmpty)
                        Text(phone, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r"\s+"));
    String first = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first[0] : '';
    String last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    final res = (first + last).toUpperCase();
    return res.isEmpty ? '?' : res;
  }

  // Remove a single patient's UID from the therapist slot bookedPatients array
  Future<void> _removePatientFromSlot(
    String? doctorUid,
    String? date,
    String? timeRange,
    String? patientUid,
    String? dayName,
    String? appointmentType,
  ) async {
    if (doctorUid == null || date == null || timeRange == null || patientUid == null) return;

    try {
      final therapistRef = FirebaseFirestore.instance.collection('therapists').doc(doctorUid);
      final therapistDoc = await therapistRef.get();
      print('Therapist Document fucker:'+therapistDoc.toString());
      if (!therapistDoc.exists) return;

      final availability = (therapistDoc.data()?['availability'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      print('Availability fuck bitch:'+availability.toString());
      if (availability == null) return;

      final isOneOnOne = appointmentType == '1-on-1 Therapy';
      print('Day name fucker:'+(dayName != null ? dayName : 'unknown'));
      print('Appointment type: $appointmentType, Is 1-on-1: $isOneOnOne');
      
      bool updated = false;
      for (final dayData in availability) {
        print('Day data fucker:'+dayData.toString());
        if (dayData['day'] == dayName) {
          final slots = (dayData['slots'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          if (slots == null) continue;
          for (final slot in slots) {
            if (slot['time'] == timeRange) {
              final booked = (slot['bookedPatients'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
              booked.removeWhere((id) => id == patientUid);
              slot['bookedPatients'] = booked;
              
              // Decrement booked count
              final currentBooked = (slot['booked'] as int?) ?? 0;
              slot['booked'] = currentBooked > 0 ? currentBooked - 1 : 0;
              
              // If it's a 1-on-1 session, reset oneOnOneBooked to false
              if (isOneOnOne) {
                slot['oneOnOneBooked'] = false;
                print('Reset oneOnOneBooked to false for 1-on-1 cancellation');
              }
              
              print('Updated bookedPatients for slot fucker: $slot');
              print('Decremented booked count from $currentBooked to ${slot['booked']}');
              // write back the modified slots into the dayData
              dayData['slots'] = slots;
              updated = true;
              break;
            }
          }
          if (updated) break;
        }
      }

      if (updated) {
        await therapistRef.update({'availability': availability});
      }
    } catch (e) {
      // Keep silent but log to console for debugging
      // ignore: avoid_print
      print('Error in _removePatientFromSlot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = appointment['type'] as String? ?? '';
    final timeRange = appointment['timeRange'] as String? ?? '';
    final date = appointment['date'] as String? ?? '';
    final status = appointment['status'] as String? ?? 'confirmed';
    final calling = appointment['calling'] as String? ?? 'awaiting for therapist';

    final textColor = muted ? Colors.black54 : const Color(0xFF202020);
    final canJoin = status == 'confirmed' && calling == 'calling';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with initials overlay from peers
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchPeers(),
                builder: (context, snap) {
                  final peers = snap.data ?? [appointment];
                  final confirmedPeers = peers.where((p) => p['status'] == 'confirmed').toList();
                  final initials = confirmedPeers.take(3).map((p) => _initials((p['patientName'] ?? 'U') as String)).toList();
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(color: _getCardColor(), shape: BoxShape.circle),
                        child: Icon(_getIcon(), size: 26, color: Colors.black87),
                      ),
                      for (int i = 0; i < initials.length; i++)
                        Positioned(
                          right: -6.0 + i * 18.0,
                          bottom: -6,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 4, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Color(0xFFEDEEF2), shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(initials[i], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(date, style: TextStyle(fontSize: 12, color: muted ? Colors.black38 : Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(timeRange, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
                  const SizedBox(height: 4),
                  _Chip(
                    label: status,
                    bg: status == 'completed'
                        ? const Color(0xFF27C07D)
                        : status == 'cancelled'
                            ? Colors.red.shade100
                            : const Color(0xFFEDEEF2),
                    fg: status == 'completed' ? Colors.white : Colors.black54,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Only show Info button for group sessions, not for 1-on-1
              if (!type.contains('1-on-1'))
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchPeers(),
                  builder: (context, snap) {
                    final peers = snap.data ?? const [];
                    // Exclude current user from list for 'Other Patients'
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    final others = peers.where((p) => p['patientUid'] != uid).toList();
                    return OutlinedButton.icon(
                      onPressed: () => _showInfoDialog(context, others),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Info'),
                    );
                  },
                ),
              ElevatedButton.icon(
                onPressed: canJoin
                    ? () {
                        // Build a deterministic channel id for this session so all participants join the same room
                        String _buildChannelId(Map<String, dynamic> appt) {
                          final doctorUid = (appt['doctorUid'] ?? '').toString();
                          final date = (appt['date'] ?? '').toString();
                          final time = (appt['timeRange'] ?? '').toString();
                          final raw = '${doctorUid}_${date}_${time}';
                          return raw.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
                        }
            final channelId = (defaultChannelId.isNotEmpty)
              ? defaultChannelId
              : _buildChannelId(appointment);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CallScreen(channelId: channelId, token: token),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.video_call, size: 18),
                label: const Text('Join'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canJoin ? const Color(0xFF4CAF50) : null,
                  foregroundColor: canJoin ? Colors.white : null,
                  elevation: canJoin ? 0 : 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              if (!muted && status == 'confirmed')
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Cancel Appointment'),
                        content: const Text('Are you sure you want to cancel your appointment?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              try {
                                // 1) Update appointment status
                                await FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc(appointment['id'] as String)
                                    .update({'status': 'cancelled'});

                                // 2) Remove this patient from the therapist slot
                                await _removePatientFromSlot(
                                  appointment['doctorUid'] as String?,
                                  appointment['date'] as String?,
                                  appointment['timeRange'] as String?,
                                  appointment['patientUid'] as String?,
                                  appointment['day'] as String?,
                                  appointment['type'] as String?,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Appointment cancelled')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            child: const Text('Yes, Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
        ],
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
