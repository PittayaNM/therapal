import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class TherapistEditScreen extends StatefulWidget {
  const TherapistEditScreen({super.key});

  @override
  State<TherapistEditScreen> createState() => _TherapistEditScreenState();
}

class _TherapistEditScreenState extends State<TherapistEditScreen> {
  final _aboutCtrl = TextEditingController();
  final _newSpecialtyCtrl = TextEditingController();
  bool _loading = true;
  String? _uid;

  // availability: list of maps {day, available, slots: [{time, types: []}]}
  List<Map<String, dynamic>> _availability = [];
  
  // Selected specialties
  final List<String> _selectedSpecialties = [];

  // Default specialties list
  final List<String> _defaultSpecialties = [
    'Couple Therapy',
    'Family Therapy',
    'Child Therapy',
    'Teen / Adolescent Therapy',
    'Trauma & PTSD',
    'Depression & Anxiety',
    'Stress Management',
    'Addiction Recovery',
    'Grief Counseling',
    'Career Counseling',
    'Self-Esteem Improvement',
    'Anger Management',
    'Mindfulness & Meditation',
    'Cognitive Behavioral Therapy (CBT)',
    'Relationship Issues',
  ];

  final _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final user = FirebaseAuth.instance.currentUser;
    _uid = user?.uid;
    // init availability with defaults
  _availability = _days
    .map((d) => {
        'day': d,
        'available': false,
        'slots': <Map<String, dynamic>>[],
      })
    .toList();

    if (_uid != null) {
      final doc = await FirebaseFirestore.instance.collection('therapists').doc(_uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _aboutCtrl.text = (data['about'] as String?) ?? '';
        
        // Load saved specialties
        final specialties = (data['specialties'] as List<dynamic>?)?.cast<String>();
        if (specialties != null) {
          _selectedSpecialties.clear();
          _selectedSpecialties.addAll(specialties);
        }
        
        final av = (data['availability'] as List<dynamic>?)?.cast<Map<String, dynamic>>();
        if (av != null) {
          // merge into our _availability by day
          for (final s in av) {
            final day = s['day'] as String?;
            if (day == null) continue;
            final idx = _availability.indexWhere((e) => e['day'] == day);
            if (idx >= 0) {
              _availability[idx]['available'] = s['available'] ?? false;
              // support legacy single-slot format
              if (s.containsKey('slots')) {
                _availability[idx]['slots'] = (s['slots'] as List<dynamic>?)
                        ?.map((e) => Map<String, dynamic>.from(e as Map))
                        .toList() ??
                    [];
              } else if (s.containsKey('time')) {
                _availability[idx]['slots'] = [
                  {
                    'time': s['time'] ?? '11:00–13:00',
                    'types': (s['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                  }
                ];
              }
            }
          }
        }
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_uid == null) return;
    setState(() => _loading = true);
    try {
      // sanitize availability: ensure slots are plain maps
      final safeAvail = _availability.map((d) {
        final slots = (d['slots'] as List<dynamic>?)
                ?.map((s) {
                  final m = Map<String, dynamic>.from(s as Map);
                  final types = (m['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                  final start = m['start'] as Map<String, dynamic>?;
                  final end = m['end'] as Map<String, dynamic>?;
                  String timeStr = (m['time'] as String?) ?? '';
                  if ((timeStr == '' || !(timeStr.contains('–'))) && start != null && end != null) {
                    final sHour = (start['hour'] as int).toString().padLeft(2, '0');
                    final sMin = (start['minute'] as int).toString().padLeft(2, '0');
                    final eHour = (end['hour'] as int).toString().padLeft(2, '0');
                    final eMin = (end['minute'] as int).toString().padLeft(2, '0');
                    timeStr = '$sHour:$sMin–$eHour:$eMin';
                  }
                  return {
                    'time': timeStr,
                    'start': start,
                    'end': end,
                    'types': types,
                    if (m.containsKey('capacity')) 'capacity': m['capacity'],
                  };
                })
                .toList() ??
            [];
        return {'day': d['day'], 'available': d['available'] ?? false, 'slots': slots};
      }).toList();

      await FirebaseFirestore.instance.collection('therapists').doc(_uid).set({
        'about': _aboutCtrl.text.trim(),
        'availability': safeAvail,
        'specialties': _selectedSpecialties,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showAddSpecialtyDialog() async {
    String? selectedSpecialty;
    
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Specialty'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Default specialties dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select from common specialties',
                      ),
                      value: selectedSpecialty,
                      items: _defaultSpecialties
                          .where((s) => !_selectedSpecialties.contains(s))
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setStateDialog(() {
                          selectedSpecialty = value;
                          _newSpecialtyCtrl.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Or add a custom specialty:'),
                    TextField(
                      controller: _newSpecialtyCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Enter custom specialty',
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedSpecialty = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    final newSpecialty = _newSpecialtyCtrl.text.trim();
                    if (newSpecialty.isNotEmpty || selectedSpecialty != null) {
                      setState(() {
                        if (newSpecialty.isNotEmpty) {
                          _selectedSpecialties.add(newSpecialty);
                        } else if (selectedSpecialty != null) {
                          _selectedSpecialties.add(selectedSpecialty!);
                        }
                      });
                      _newSpecialtyCtrl.clear();
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _aboutCtrl.dispose();
    _newSpecialtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Therapist Profile'),
        backgroundColor: const Color(0xFF00B2E3),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                TextField(
                  controller: _aboutCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Write a short description about yourself',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Specialties Section
                const Text('Specialties', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._selectedSpecialties.map((specialty) => Chip(
                            label: Text(specialty),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => setState(() => _selectedSpecialties.remove(specialty)),
                          )),
                          if (_selectedSpecialties.length < 7)
                            ActionChip(
                              label: const Text('Add Specialty'),
                              avatar: const Icon(Icons.add, size: 18),
                              onPressed: _showAddSpecialtyDialog,
                            ),
                        ],
                      ),
                      if (_selectedSpecialties.isEmpty)
                        const Text(
                          'Select up to 7 specialties',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                const Text('Availability (weekly)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                for (int i = 0; i < _availability.length; i++) _dayRow(i),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B2E3)),
                        onPressed: _save,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('Apply', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _dayRow(int idx) {
    final slot = _availability[idx];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: slot['available'] as bool,
                onChanged: (v) => setState(() => slot['available'] = v ?? false),
              ),
              Text(slot['day'] as String),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add slot',
                onPressed: () async {
                  final result = await _editSlotDialog();
                  if (result != null) {
                    setState(() {
                      final slots = slot['slots'] as List<dynamic>;
                      slots.add(result);
                      slot['available'] = true;
                    });
                  }
                },
              ),
            ],
          ),
          if (slot['available'] == true)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 6),
              child: Column(
                children: [
                  for (int si = 0; si < (slot['slots'] as List).length; si++)
                    _slotRow(idx, si),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _editSlotDialog({Map<String, dynamic>? existing}) async {
    // Use structured start/end times and a StatefulBuilder to ensure immediate UI updates
    TimeOfDay? start;
    TimeOfDay? end;
    bool oneOnOne = true;
    bool group = false;
    int capacity = 2; // default for group

    // initialize from existing
    if (existing != null) {
      final timeStr = existing['time'] as String?;
      if (timeStr != null && timeStr.contains('–')) {
        final parts = timeStr.split('–');
        try {
          final p1 = parts[0].trim();
          final p2 = parts[1].trim();
          final sParts = p1.split(':');
          final eParts = p2.split(':');
          start = TimeOfDay(hour: int.parse(sParts[0]), minute: int.parse(sParts[1]));
          end = TimeOfDay(hour: int.parse(eParts[0]), minute: int.parse(eParts[1]));
        } catch (_) {
          start = null;
          end = null;
        }
      }
      final types = (existing['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      oneOnOne = types.contains('1on1');
      group = types.contains('group');
      capacity = (existing['capacity'] as int?) ?? capacity;
    }

    final res = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setStateDialog) {
          // Use number wheel pickers for time selection
          return AlertDialog(
            title: Text(existing == null ? 'Add slot' : 'Edit slot'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Start Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            width: 120,
                            child: Row(
                              children: [
                                // Hours picker (00-23)
                                Expanded(
                                  child: CupertinoPicker(
                                    itemExtent: 32,
                                    onSelectedItemChanged: (index) => setStateDialog(() {
                                      start = TimeOfDay(hour: index, minute: start?.minute ?? 0);
                                    }),
                                    children: List<Widget>.generate(24, (index) => Center(
                                      child: Text(index.toString().padLeft(2, '0')),
                                    )),
                                    scrollController: FixedExtentScrollController(
                                      initialItem: start?.hour ?? 11,
                                    ),
                                  ),
                                ),
                                const Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                                // Minutes picker (00-59)
                                Expanded(
                                  child: CupertinoPicker(
                                    itemExtent: 32,
                                    onSelectedItemChanged: (index) => setStateDialog(() {
                                      start = TimeOfDay(hour: start?.hour ?? 0, minute: index);
                                    }),
                                    children: List<Widget>.generate(60, (index) => Center(
                                      child: Text(index.toString().padLeft(2, '0')),
                                    )),
                                    scrollController: FixedExtentScrollController(
                                      initialItem: start?.minute ?? 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('End Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            width: 120,
                            child: Row(
                              children: [
                                // Hours picker (00-23)
                                Expanded(
                                  child: CupertinoPicker(
                                    itemExtent: 32,
                                    onSelectedItemChanged: (index) => setStateDialog(() {
                                      end = TimeOfDay(hour: index, minute: end?.minute ?? 0);
                                    }),
                                    children: List<Widget>.generate(24, (index) => Center(
                                      child: Text(index.toString().padLeft(2, '0')),
                                    )),
                                    scrollController: FixedExtentScrollController(
                                      initialItem: end?.hour ?? 13,
                                    ),
                                  ),
                                ),
                                const Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                                // Minutes picker (00-59)
                                Expanded(
                                  child: CupertinoPicker(
                                    itemExtent: 32,
                                    onSelectedItemChanged: (index) => setStateDialog(() {
                                      end = TimeOfDay(hour: end?.hour ?? 0, minute: index);
                                    }),
                                    children: List<Widget>.generate(60, (index) => Center(
                                      child: Text(index.toString().padLeft(2, '0')),
                                    )),
                                    scrollController: FixedExtentScrollController(
                                      initialItem: end?.minute ?? 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('1-on-1 therapy'),
                    value: oneOnOne,
                    onChanged: (v) {
                      setStateDialog(() {
                        if (v == true) {
                          oneOnOne = true;
                          group = false; // Uncheck group when 1-on-1 is checked
                        } else {
                          oneOnOne = false;
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Group therapy'),
                    value: group,
                    onChanged: (v) {
                      setStateDialog(() {
                        if (v == true) {
                          group = true;
                          oneOnOne = false; // Uncheck 1-on-1 when group is checked
                        } else {
                          group = false;
                        }
                      });
                    },
                  ),
                  if (group) ...[
                    const SizedBox(height: 8),
                    // use Wrap to avoid overflow on small screens
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        const Text('Patients'),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: capacity > 2 ? () => setStateDialog(() => capacity--) : null,
                            ),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('$capacity', style: const TextStyle(fontWeight: FontWeight.w700))),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: capacity < 7 ? () => setStateDialog(() => capacity++) : null,
                            ),
                          ],
                        ),
                        const Text('(min 2, max 7)'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  final types = <String>[];
                  if (oneOnOne) types.add('1on1');
                  if (group) types.add('group');

                  // Initialize times if not set
                  start ??= const TimeOfDay(hour: 11, minute: 0);
                  end ??= const TimeOfDay(hour: 13, minute: 0);
                  
                  // Format the selected times
                  final sStr = '${start!.hour.toString().padLeft(2, '0')}:${start!.minute.toString().padLeft(2, '0')}';
                  final eStr = '${end!.hour.toString().padLeft(2, '0')}:${end!.minute.toString().padLeft(2, '0')}';
                  final timeStr = '$sStr–$eStr';

                  final out = {
                    'time': timeStr,
                    'start': {'hour': start!.hour, 'minute': start!.minute},
                    'end': {'hour': end!.hour, 'minute': end!.minute},
                    'types': types,
                    if (group) 'capacity': capacity,
                  };

                  Navigator.pop(ctx2, out);
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
      },
    );

    return res;
  }

  Widget _slotRow(int dayIdx, int slotIdx) {
    final day = _availability[dayIdx];
    final s = (day['slots'] as List)[slotIdx] as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(s['time'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700))),
          const SizedBox(width: 8),
          if ((s['types'] as List).contains('1on1'))
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)), child: const Text('1-on-1', style: TextStyle(fontSize: 12))),
          const SizedBox(width: 6),
          if ((s['types'] as List).contains('group')) ...[
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFFF3E6), borderRadius: BorderRadius.circular(8)), child: const Text('Group', style: TextStyle(fontSize: 12))),
            const SizedBox(width: 6),
            if (s.containsKey('capacity') && s['capacity'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEFF9F0), borderRadius: BorderRadius.circular(8)),
                child: Text('Max ${s['capacity']}', style: const TextStyle(fontSize: 12)),
              ),
          ],
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () async {
              final res = await _editSlotDialog(existing: s);
              if (res != null) setState(() => (day['slots'] as List)[slotIdx] = res);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => setState(() => (day['slots'] as List).removeAt(slotIdx)),
          ),
        ],
      ),
    );
  }
}
