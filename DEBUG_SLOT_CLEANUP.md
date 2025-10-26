# Debug: Patient Slot Cleanup Not Working

## Problem
When patient cancels appointment, their UID is not being removed from therapist's `bookedPatients` array in Firestore.

## What to Check

### 1. Verify appointment data structure
Add this console log right before calling `_removePatientFromSlot`:

```dart
print('📋 Appointment data:');
print('  id: ${appointment['id']}');
print('  doctorUid: ${appointment['doctorUid']}');
print('  date: ${appointment['date']}');
print('  timeRange: ${appointment['timeRange']}');
print('  patientUid: ${appointment['patientUid']}');
print('  Full appointment: $appointment');
```

Add this in the Cancel button's `onPressed` handler, right after `Navigator.pop(ctx);` (around line 1217)

### 2. Check if the function is being called
The function should print these logs when called. Check your Flutter console/debug output for:
- 🔍 Function entry logs
- Day name matching
- Slot time matching
- bookedPatients array before/after

### 3. Common Issues

**Issue A: Date format mismatch**
- Appointment date format: `YYYY-MM-DD` (e.g., "2025-10-26")
- Check if date parsing is working correctly

**Issue B: Time format mismatch**
- Appointment timeRange: e.g., "9:00 AM - 10:00 AM"
- Slot time format must match exactly
- Check for extra spaces, different AM/PM formatting

**Issue C: Day calculation**
The code uses `dt.weekday % 7` which might be wrong:
- DateTime.weekday returns 1=Monday, 7=Sunday
- Array index: 0=Sunday, 6=Saturday
- **This is likely the bug!**

### 4. Fix for Day Calculation

Replace this line (around line 1028):
```dart
final dayName = dayNames[dt.weekday % 7];
```

With:
```dart
// DateTime.weekday: 1=Monday, 2=Tuesday, ..., 7=Sunday
// We need: 0=Sunday, 1=Monday, ..., 6=Saturday
final dayName = dayNames[dt.weekday == 7 ? 0 : dt.weekday];
```

### 5. Also Check Therapist's _removeAllPatientsFromSlot

The same bug exists in the therapist's function (around line 423). Apply the same fix there.

## Quick Fix Instructions

### File: appointment_screen.dart

**Location 1: Line ~1028 (in PatientApptCard._removePatientFromSlot)**
```dart
// FIND:
final dayName = dayNames[dt.weekday % 7];

// REPLACE WITH:
final dayName = dayNames[dt.weekday == 7 ? 0 : dt.weekday];
```

**Location 2: Line ~423 (in TherapistApptCard._removeAllPatientsFromSlot)**
```dart
// FIND:
final dayName = dayNames[dateTime.weekday % 7];

// REPLACE WITH:
final dayName = dayNames[dateTime.weekday == 7 ? 0 : dateTime.weekday];
```

## Why This Bug Exists

Dart's DateTime.weekday:
- Monday = 1
- Sunday = 7

Array index needs:
- Sunday = 0
- Saturday = 6

Using `% 7`:
- Monday (1) % 7 = 1 ✅ (should be 1)
- Sunday (7) % 7 = 0 ✅ (should be 0)
- Actually this works correctly!

Wait... let me recalculate. The array is:
```dart
['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
```

For a Monday appointment (weekday = 1):
- We need index 1 (Monday)
- 1 % 7 = 1 ✅

For a Sunday appointment (weekday = 7):
- We need index 0 (Sunday)
- 7 % 7 = 0 ✅

Actually the modulo operation IS correct! So the bug must be elsewhere.

## Real Debugging Steps

Add these print statements to find the real issue:

**In the cancel button handler (line ~1213):**
```dart
onPressed: () async {
  Navigator.pop(ctx);
  print('🚀 Cancel button pressed');
  print('📋 Appointment keys: ${appointment.keys.toList()}');
  print('📋 Full appointment: $appointment');
  
  try {
    // ... existing code
```

**In _removePatientFromSlot (line ~1008):**
```dart
Future<void> _removePatientFromSlot(...) async {
  print('🔍 _removePatientFromSlot called');
  print('  doctorUid: $doctorUid');
  print('  date: $date');
  print('  timeRange: $timeRange');
  print('  patientUid: $patientUid');
  
  if (doctorUid == null || date == null || timeRange == null || patientUid == null) {
    print('❌ One or more params is null - returning early');
    return;
  }
  
  // ... rest of function
```

Run the app, cancel an appointment, and check the debug console for these logs.
