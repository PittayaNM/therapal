import 'package:flutter/material.dart';

class LivesScreen extends StatefulWidget {
  const LivesScreen({super.key});

  @override
  State<LivesScreen> createState() => _LivesScreenState();
}

class _LivesScreenState extends State<LivesScreen> {
  final List<_Chat> _messages = List.generate(
    1,
    (i) => _Chat(
      name: 'Arkom Preedakul',
      text: 'nice content!',
      avatar: 'assets/indian.jpg',
    ),
  );

  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();

  void _send() {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_Chat(
        name: 'You',
        text: t,
        avatar: 'assets/Pin.png',
      ));
    });
    _text.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar แบบ custom
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage('assets/doctor.jpg'),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Dr. Ro Diaries',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),

            // วิดีโอ/รูปตัวอย่าง
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black12,
                child: Image.asset(
                  'assets/doctor.jpg', // ใส่ภาพตัวอย่างไว้ก่อน
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // แชต + พื้นหลังไล่เฉด
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFEFF8FF), Color(0xFFE7FAFF)],
                  ),
                ),
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) {
                    final m = _messages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage(m.avatar),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  m.text,
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
                    );
                  },
                ),
              ),
            ),

            // แถวพิมพ์ข้อความ + ปุ่มหัวใจ
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  // ช่องพิมพ์ + ปุ่มส่ง
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _text,
                              decoration: const InputDecoration(
                                hintText: 'Send Message',
                                border: InputBorder.none,
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                          IconButton(
                            onPressed: _send,
                            icon: const Icon(Icons.send_rounded),
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ปุ่มหัวใจ
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('❤️  sent')),
                        );
                      },
                      icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chat {
  final String name;
  final String text;
  final String avatar;
  _Chat({required this.name, required this.text, required this.avatar});
}
