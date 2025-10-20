// import 'dart:async';
// import 'package:flutter/material.dart';
// // ถ้าจะใช้ Jitsi ให้เปิดคอมเมนต์ 2 บรรทัดนี้
// // import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

// class VideoCallPage extends StatefulWidget {
//   final String doctorName;
//   final String roomName;
//   final String doctorImage; // asset path พื้นหลัง

//   const VideoCallPage({
//     super.key,
//     required this.doctorName,
//     required this.roomName,
//     required this.doctorImage,
//   });

//   @override
//   State<VideoCallPage> createState() => _VideoCallPageState();
// }

// class _VideoCallPageState extends State<VideoCallPage> {
//   bool micOn = true;
//   bool camOn = true;
//   Duration callDuration = Duration.zero;
//   Timer? _ticker;

//   // ถ้าใช้ Jitsi ให้ประกาศ
//   // final _jitsi = JitsiMeet();

//   @override
//   void initState() {
//     super.initState();
//     // นับเวลาสาย
//     _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
//       setState(() => callDuration += const Duration(seconds: 1));
//     });

//     // ถ้าต้องการเข้าห้อง Jitsi อัตโนมัติ เปิดคอมเมนต์
//     // _joinJitsi();
//   }

//   @override
//   void dispose() {
//     _ticker?.cancel();
//     // ถ้าใช้ Jitsi
//     // _jitsi.hangUp();
//     super.dispose();
//   }

//   String _mmss(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   // ใช้เมื่อจะเข้า Jitsi จริง
//   // Future<void> _joinJitsi() async {
//   //   final opts = JitsiMeetingOptions(
//   //     room: widget.roomName,
//   //     serverURL: "https://meet.jit.si",
//   //     userDisplayName: widget.doctorName, // หรือชื่อผู้ใช้ก็ได้
//   //     configOverrides: {
//   //       "startWithAudioMuted": !micOn,
//   //       "startWithVideoMuted": !camOn,
//   //       "prejoinPageEnabled": true,
//   //     },
//   //     featureFlags: {"welcomepage.enabled": false},
//   //   );
//   //   await _jitsi.join(opts);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         bottom: false,
//         child: Stack(
//           children: [
//             // พื้นหลังเป็นภาพหมอเต็มจอ
//             Positioned.fill(
//               child: Image.asset(
//                 widget.doctorImage,
//                 fit: BoxFit.cover,
//               ),
//             ),

//             // ชื่อหมอ + เวลา
//             Positioned(
//               left: 16,
//               top: 12,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.doctorName,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     "${_mmss(callDuration)} min",
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // กล่อง PiP (วิดีโอเรา) มุมขวาบน
//             Positioned(
//               right: 16,
//               top: 56,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Container(
//                   width: 120,
//                   height: 160,
//                   color: Colors.black12,
//                   child: Image.asset(
//                     'assets/Pin.png', // ใส่ภาพผู้ใช้ชั่วคราว
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),

//             // แถบควบคุมด้านล่างโปร่งแสง
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.35),
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _CircleButton(
//                         icon: micOn ? Icons.mic : Icons.mic_off,
//                         onTap: () => setState(() => micOn = !micOn),
//                       ),
//                       _CircleButton(
//                         icon: camOn ? Icons.videocam : Icons.videocam_off,
//                         onTap: () => setState(() => camOn = !camOn),
//                       ),
//                       // ปุ่มเปิด Jitsi (จริง) — เอาไว้ทดสอบเข้าห้อง
//                       // _CircleButton(
//                       //   icon: Icons.arrow_upward,
//                       //   onTap: _joinJitsi,
//                       // ),
//                       _CircleButton(
//                         icon: Icons.call_end,
//                         bg: const Color(0xFFE53935),
//                         iconColor: Colors.white,
//                         onTap: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _CircleButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   final Color bg;
//   final Color iconColor;

//   const _CircleButton({
//     required this.icon,
//     required this.onTap,
//     this.bg = const Color(0xFFEDEEF2),
//     this.iconColor = Colors.black87,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkResponse(
//       onTap: onTap,
//       radius: 36,
//       child: Container(
//         width: 54,
//         height: 54,
//         decoration: BoxDecoration(
//           color: bg,
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, size: 24, color: iconColor),
//       ),
//     );
//   }
// }
