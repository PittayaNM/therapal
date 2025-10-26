# HOW TO FIX: Patient UID Not Removed from Slot

## The Issue
When a patient cancels their appointment, the UID should be removed from the therapist's `bookedPatients` array in the availability slot, but it's not working.

## Root Cause Analysis

The function `_removePatientFromSlot` in `PatientApptCard` is likely being called, but something is preventing the update from succeeding. Common causes:

1. **Null parameters** - One of doctorUid/date/timeRange/patientUid is null
2. **Format mismatch** - The time format doesn't match exactly
3. **Day calculation error** - Wrong day name
4. **Silent failure** - Error is caught but not shown to user

## SOLUTION: Add Debug Logging

### Step 1: Add logging to the cancel button

In `appointment_screen.dart`, find the patient cancel button (around line 1213), and add logging:

```dart
TextButton(
  onPressed: () async {
    Navigator.pop(ctx);
    
    // ADD THIS LOGGING:
    print('🚀 CANCEL BUTTON PRESSED');
    print('📋 Appointment ID: ${appointment['id']}');
    print('📋 Doctor UID: ${appointment['doctorUid']}');
    print('📋 Patient UID: ${appointment['patientUid']}');
    print('📋 Date: ${appointment['date']}');
    print('📋 Time Range: ${appointment['timeRange']}');
    
    try {
      // 1) Update appointment status
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointment['id'] as String)
          .update({'status': 'cancelled'});
      
      print('✅ Appointment status updated');

      // 2) Remove this patient from the therapist slot
      await _removePatientFromSlot(
        appointment['doctorUid'] as String?,
        appointment['date'] as String?,
        appointment['timeRange'] as String?,
        appointment['patientUid'] as String?,
      );
      
      print('✅ Slot cleanup completed');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment cancelled')),
        );
      }
    } catch (e) {
      print('❌ ERROR: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  },
  child: const Text('Yes, Cancel'),
),
```

### Step 2: Add logging to _removePatientFromSlot

Find the `_removePatientFromSlot` function (around line 1008) and add comprehensive logging:

```dart
Future<void> _removePatientFromSlot(
  String? doctorUid,
  String? date,
  String? timeRange,
  String? patientUid,
) async {
  print('🔍 _removePatientFromSlot CALLED');
  print('  doctorUid: $doctorUid (null: ${doctorUid == null})');
  print('  date: $date (null: ${date == null})');
  print('  timeRange: $timeRange (null: ${timeRange == null})');
  print('  patientUid: $patientUid (null: ${patientUid == null})');

  if (doctorUid == null || date == null || timeRange == null || patientUid == null) {
    print('❌ EARLY RETURN: One or more parameters is null');
    return;
  }

  try {
    final therapistRef = FirebaseFirestore.instance.collection('therapists').doc(doctorUid);
    final therapistDoc = await therapistRef.get();
    print('  📄 Therapist doc exists: ${therapistDoc.exists}');
    
    if (!therapistDoc.exists) {
      print('❌ Therapist document not found');
      return;
    }

    final availability = (therapistDoc.data()?['availability'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    print('  📅 Availability days: ${availability?.length}');
    
    if (availability == null) {
      print('❌ No availability data');
      return;
    }

    // Parse date to determine weekday name
    final parts = date.split('-');
    if (parts.length != 3) {
      print('❌ Invalid date format');
      return;
    }
    
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final dayName = dayNames[dt.weekday % 7];
    print('  📆 Parsed date: $dt -> weekday ${dt.weekday} -> $dayName');

    bool updated = false;
    for (final dayData in availability) {
      print('  🔄 Checking day: ${dayData['day']}');
      
      if (dayData['day'] == dayName) {
        print('    ✅ DAY MATCHED!');
        final slots = (dayData['slots'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        print('    Slots in this day: ${slots?.length}');
        
        if (slots == null) continue;
        
        for (final slot in slots) {
          print('    ⏰ Checking slot: "${slot['time']}" vs "$timeRange"');
          
          if (slot['time'] == timeRange) {
            print('      ✅ TIME MATCHED!');
            final booked = (slot['bookedPatients'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
            print('      📋 bookedPatients BEFORE: $booked');
            print('      🗑️ Removing: $patientUid');
            
            booked.removeWhere((id) => id == patientUid);
            print('      📋 bookedPatients AFTER: $booked');
            
            slot['bookedPatients'] = booked;
            dayData['slots'] = slots;
            updated = true;
            break;
          }
        }
        if (updated) break;
      }
    }

    print('  🎯 Update flag: $updated');
    
    if (updated) {
      print('  💾 Updating Firestore...');
      await therapistRef.update({'availability': availability});
      print('  ✅ FIRESTORE UPDATE SUCCESSFUL');
    } else {
      print('  ⚠️ NO MATCHING SLOT FOUND - No update performed');
    }
  } catch (e, stack) {
    print('❌ EXCEPTION in _removePatientFromSlot: $e');
    print('   Stack trace: $stack');
  }
}
```

### Step 3: Test It

1. Save the file
2. Hot restart the app (not just hot reload)
3. Go to a patient's appointment
4. Press Cancel
5. Watch the debug console

You should see output like:
```
🚀 CANCEL BUTTON PRESSED
📋 Appointment ID: abc123
📋 Doctor UID: xyz789
...
🔍 _removePatientFromSlot CALLED
  doctorUid: xyz789 (null: false)
...
```

### Step 4: Diagnose from Logs

**If you see "EARLY RETURN: One or more parameters is null"**
- Check which parameter is null
- The appointment map might not have that field

**If you see "NO MATCHING SLOT FOUND"**
- Check the time format - it must match EXACTLY
- Check if the day calculation is correct
- Verify the therapist actually has that slot in their availability

**If you see "FIRESTORE UPDATE SUCCESSFUL"**
- The code is working!
- Check Firestore console to verify the update happened
- There might be a caching issue - try restarting the app

## Quick Alternative: Manual Firebase Console Check

1. Open Firebase Console
2. Go to Firestore Database
3. Navigate to: `therapists/{doctorUid}/availability`
4. Find the day and slot
5. Check the `bookedPatients` array
6. Manually remove the patient UID to test if it's a code issue or permissions issue

## Permissions Check

Make sure your Firestore security rules allow patients to update therapist documents:

```javascript
match /therapists/{therapistId} {
  allow read: if true;
  allow write: if request.auth != null; // Patients need write access to update slots
}
```

If this is the issue, you'll see a "permission-denied" error in the logs.
