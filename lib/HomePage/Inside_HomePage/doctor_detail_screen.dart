import 'package:flutter/material.dart';

/// =======================
/// Doctor Detail (มีปุ่ม Continue -> ConfirmAppointmentScreen)
/// =======================
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
  final String? photoAsset;

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
    this.photoAsset,
  });
}

class DoctorDetailScreen extends StatefulWidget {
  final DoctorDetailArgs args;
  const DoctorDetailScreen({super.key, required this.args});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  DateTime? _selectedDate;
  String? _selectedType; // '1-on-1 Therapy' | 'Group Therapy'

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
      helpText: 'Select appointment date',
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00B2E3),
              onPrimary: Colors.white,
              onSurface: Color(0xFF222222),
            ),
          ),
          child: child!,
        );
      },
    );
    if (result != null) setState(() => _selectedDate = result);
  }

  String _formatDate(DateTime d) {
    const m = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatTimeRange(TimeOfDay a, TimeOfDay b) {
    String f(TimeOfDay t) {
      final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final m = t.minute.toString().padLeft(2, '0');
      final ap = t.period == DayPeriod.am ? 'AM' : 'PM';
      return '$h:$m $ap';
    }

    return '${f(a)} - ${f(b)}';
  }

  void _goConfirm() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date first')),
      );
      return;
    }
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select appointment type')),
      );
      return;
    }

    // ตัวอย่างค่าเวลา/ระยะเวลา/ช่องทาง (แก้ได้ภายหลัง)
    const start = TimeOfDay(hour: 11, minute: 0);
    const end = TimeOfDay(hour: 13, minute: 0);
    const durationMins = 120;
    const sessionMethod = 'Video Call';
    const sessionNote = 'Online session via secure platform';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmAppointmentScreen(
          args: ConfirmAppointmentArgs(
            doctorName: widget.args.name,
            doctorTitle: widget.args.title,
            doctorRating: widget.args.rating,
            doctorReviews: widget.args.reviews,
            doctorPhotoAsset: widget.args.photoAsset,
            dateText: _formatDate(_selectedDate!),
            timeRangeText: _formatTimeRange(start, end),
            typeText: _selectedType!,
            durationText: '$durationMins minutes',
            sessionMethod: sessionMethod,
            sessionNote: sessionNote,
            // ตัวอย่างข้อมูลผู้ป่วย (จะโยงจากโปรไฟล์จริงได้ทีหลัง)
            patientName: 'George Josure',
            patientEmail: 'grorge404@gmail.com',
            patientPhone: '+66 987654321',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
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
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 10),
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
                          : const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.black38,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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

                _sectionCard(
                  title: 'About Doctor',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFB800),
                        size: 18,
                      ),
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

                _sectionCard(
                  title: 'license verification',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${args.licenseName}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'License No. ${args.licenseNo}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Expiration: ${args.licenseExpire}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
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

                const SizedBox(height: 12),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
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
                          const Icon(
                            Icons.event_rounded,
                            color: Color(0xFF00B2E3),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'Select date'
                                  : _formatDate(_selectedDate!),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _selectedDate == null
                                    ? Colors.black45
                                    : const Color(0xFF202020),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                _appointmentButton(
                  label: '1-on-1 Therapy',
                  selected: _selectedType == '1-on-1 Therapy',
                  onTap: () => setState(() => _selectedType = '1-on-1 Therapy'),
                ),
                const SizedBox(height: 10),
                _appointmentButton(
                  label: 'Group Therapy',
                  selected: _selectedType == 'Group Therapy',
                  onTap: () => setState(() => _selectedType = 'Group Therapy'),
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
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
            onPressed: (_selectedDate != null && _selectedType != null)
                ? _goConfirm
                : null,
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Helpers (อยู่ในคลาสนี้ให้เรียกใช้ได้แน่นอน) ----------------

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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1C1C),
                ),
              ),
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

  Widget _appointmentButton({
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
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
            border: Border.all(
              color: selected ? const Color(0xFF00B2E3) : Colors.transparent,
              width: selected ? 2 : 0,
            ),
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
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF00B2E3)
                      : const Color(0xFF1FD080),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}

class _HeaderArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 120);
    p.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
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

/// =======================
/// Confirm Appointment Screen
/// =======================
class ConfirmAppointmentArgs {
  final String doctorName;
  final String doctorTitle;
  final double doctorRating;
  final int doctorReviews;
  final String? doctorPhotoAsset;

  final String dateText; // e.g. "September 30, 2025"
  final String timeRangeText; // e.g. "11:00 AM - 1:00 PM"
  final String typeText; // e.g. "1-on-1 Therapy"
  final String durationText; // e.g. "120 minutes"

  final String sessionMethod; // e.g. "Video Call"
  final String sessionNote; // e.g. "Online session via secure platform"

  final String patientName;
  final String patientEmail;
  final String patientPhone;

  ConfirmAppointmentArgs({
    required this.doctorName,
    required this.doctorTitle,
    required this.doctorRating,
    required this.doctorReviews,
    required this.doctorPhotoAsset,
    required this.dateText,
    required this.timeRangeText,
    required this.typeText,
    required this.durationText,
    required this.sessionMethod,
    required this.sessionNote,
    required this.patientName,
    required this.patientEmail,
    required this.patientPhone,
  });
}

class ConfirmAppointmentScreen extends StatelessWidget {
  final ConfirmAppointmentArgs args;
  const ConfirmAppointmentScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // header ไล่เฉดฟ้าอ่อนเหมือนภาพ
            Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFBDEBFF), Color(0xFFE7FAFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                // Top AppBar-like
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Confirm Appointment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 8),

                // Doctor row card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: _cardDeco(),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        backgroundImage: args.doctorPhotoAsset != null
                            ? AssetImage(args.doctorPhotoAsset!)
                            : null,
                        child: args.doctorPhotoAsset == null
                            ? const Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.black38,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              args.doctorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              args.doctorTitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Color(0xFFFFB800),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${args.doctorRating.toStringAsFixed(1)} ( ${args.doctorReviews} Reviews )',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Appointment Details
                _sectionBlock(
                  title: 'Appointment Details',
                  children: [
                    _kv('Date', args.dateText),
                    _kv('Time', args.timeRangeText),
                    _kv('Type', args.typeText),
                    _kv('Duration', args.durationText),
                  ],
                ),

                // Session Method
                _sectionBlock(
                  title: 'Session Method',
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(Icons.videocam, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                args.sessionMethod,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                args.sessionNote,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Patient Information
                _sectionBlock(
                  title: 'Patient Information',
                  children: [
                    _twoCol(
                      'Name',
                      args.patientName,
                      'Email',
                      args.patientEmail,
                    ),
                    const SizedBox(height: 6),
                    _twoCol('Phone', args.patientPhone, '', ''),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            // ใน ConfirmAppointmentScreen (ปุ่มล่าง)
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment confirmed')),
              );

              // ✅ ไปหน้า Home และล้างสแตกทั้งหมด
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            child: const Text(
              'Confirm Appointment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }

  // --- Small UI helpers (เฉพาะ Confirm screen) ---
  BoxDecoration _cardDeco() => BoxDecoration(
    color: const Color(0xFFE6F6FF),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFFBDEBFF)),
  );

  Widget _sectionBlock({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(k, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(flex: 5, child: Text(v, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _twoCol(String k1, String v1, String k2, String v2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (k1.isNotEmpty)
                Text(k1, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (v1.isNotEmpty) Text(v1),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (k2.isNotEmpty)
                Text(k2, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (v2.isNotEmpty) Text(v2, textAlign: TextAlign.right),
            ],
          ),
        ),
      ],
    );
  }
}
