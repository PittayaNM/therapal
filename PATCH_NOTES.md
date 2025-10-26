# Slot Cleanup Implementation

## Changes Required in appointment_screen.dart

### 1. Add helper function after _initials in PatientApptCard class (around line 1005)

Add this function after the `_initials` method in PatientApptCard:

```dart
  Future<void> _removePatientFromSlot(String? doctorUid, String? date, String? timeRange, String? patientUid) async {
    if (doctorUid == null || date == null || timeRange == null || patientUid == null) return;
    
    try {
      final therapistDoc = await FirebaseFirestore.instance
          .collection('therapists')
          .doc(doctorUid)
          .get();
      
      if (!therapistDoc.exists) return;
      
      final availability = therapistDoc.data()?['availability'] as List<dynamic>?;
      if (availability == null) return;
      
      // Parse date to get day of week
      final dateParts = date.split('-');
      if (dateParts.length != 3) return;
      final dateTime = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
      final dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      final dayName = dayNames[dateTime.weekday % 7];
      
      // Find the matching day and slot
      bool updated = false;
      for (var dayData in availability) {
        if (dayData['day'] == dayName) {
          final slots = dayData['slots'] as List<dynamic>?;
          if (slots != null) {
            for (var slot in slots) {
              if (slot['time'] == timeRange) {
                // Remove this patient's UID from bookedPatients array
                final bookedPatients = (slot['bookedPatients'] as List<dynamic>?)?.cast<String>() ?? [];
                bookedPatients.remove(patientUid);
                slot['bookedPatients'] = bookedPatients;
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
      print('Error removing patient from slot: $e');
    }
  }
```

### 2. Update Patient Cancel Button (around line 1148-1168)

Replace the cancel button's `onPressed` handler:

**FIND THIS:**
```dart
TextButton(
  onPressed: () async {
    Navigator.pop(ctx);
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointment['id'] as String)
          .update({'status': 'cancelled'});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  },
  child: const Text('Yes, Cancel'),
),
```

**REPLACE WITH:**
```dart
TextButton(
  onPressed: () async {
    Navigator.pop(ctx);
    try {
      // Update appointment status
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointment['id'] as String)
          .update({'status': 'cancelled'});
      
      // Remove patient UID from therapist slot
      await _removePatientFromSlot(
        appointment['doctorUid'] as String?,
        appointment['date'] as String?,
        appointment['timeRange'] as String?,
        appointment['patientUid'] as String?,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  },
  child: const Text('Yes, Cancel'),
),
```

## Summary

1. **Therapist Cancel/Complete**: Already updated (line 374-469) - removes ALL patient UIDs from slot when session is cancelled or completed
2. **Patient Cancel**: Need to add `_removePatientFromSlot` function and update cancel button to call it - removes only that patient's UID from slot

The appointments collection will keep all records for history, but the therapist's availability slots will be cleaned up properly.
