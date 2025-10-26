import 'package:cloud_firestore/cloud_firestore.dart';

/// Test script to verify slot cleanup is working
/// 
/// Run this after making changes to debug why patient UIDs aren't being removed
class SlotCleanupTest {
  static Future<void> testRemovePatient() async {
    print('=== SLOT CLEANUP TEST ===\n');
    
    // Test data - replace with real values from your Firestore
    const testDoctorUid = 'REPLACE_WITH_REAL_DOCTOR_UID';
    const testDate = '2025-10-26'; // Format: YYYY-MM-DD
    const testTimeRange = '9:00 AM - 10:00 AM'; // Must match exactly
    const testPatientUid = 'REPLACE_WITH_REAL_PATIENT_UID';
    
    print('Test Parameters:');
    print('  Doctor UID: $testDoctorUid');
    print('  Date: $testDate');
    print('  Time Range: $testTimeRange');
    print('  Patient UID: $testPatientUid');
    print('');
    
    try {
      // Step 1: Fetch therapist document
      print('Step 1: Fetching therapist document...');
      final therapistRef = FirebaseFirestore.instance
          .collection('therapists')
          .doc(testDoctorUid);
      final therapistDoc = await therapistRef.get();
      
      if (!therapistDoc.exists) {
        print('❌ ERROR: Therapist document does not exist!');
        return;
      }
      print('✅ Therapist document found');
      
      // Step 2: Get availability
      print('\nStep 2: Reading availability...');
      final data = therapistDoc.data();
      if (data == null) {
        print('❌ ERROR: Therapist document has no data!');
        return;
      }
      
      final availability = data['availability'] as List<dynamic>?;
      if (availability == null) {
        print('❌ ERROR: No availability array found!');
        return;
      }
      print('✅ Found ${availability.length} days in availability');
      
      // Step 3: Parse date and find day
      print('\nStep 3: Parsing date...');
      final parts = testDate.split('-');
      if (parts.length != 3) {
        print('❌ ERROR: Invalid date format! Use YYYY-MM-DD');
        return;
      }
      
      final dt = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      print('  Parsed: $dt');
      print('  Weekday number: ${dt.weekday}');
      
      const dayNames = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday'
      ];
      
      final dayName = dayNames[dt.weekday % 7];
      print('  Day name: $dayName');
      
      // Step 4: Find the day in availability
      print('\nStep 4: Finding day in availability...');
      Map<String, dynamic>? targetDay;
      for (var day in availability) {
        print('  Checking: ${day['day']}');
        if (day['day'] == dayName) {
          targetDay = day as Map<String, dynamic>;
          print('  ✅ Found matching day!');
          break;
        }
      }
      
      if (targetDay == null) {
        print('❌ ERROR: Day "$dayName" not found in availability!');
        print('Available days:');
        for (var day in availability) {
          print('  - ${day['day']}');
        }
        return;
      }
      
      // Step 5: Find the slot
      print('\nStep 5: Finding time slot...');
      final slots = targetDay['slots'] as List<dynamic>?;
      if (slots == null) {
        print('❌ ERROR: No slots array in this day!');
        return;
      }
      print('  Found ${slots.length} slots');
      
      Map<String, dynamic>? targetSlot;
      int slotIndex = -1;
      for (int i = 0; i < slots.length; i++) {
        final slot = slots[i] as Map<String, dynamic>;
        print('  Checking slot $i: "${slot['time']}"');
        if (slot['time'] == testTimeRange) {
          targetSlot = slot;
          slotIndex = i;
          print('  ✅ Found matching slot at index $i!');
          break;
        }
      }
      
      if (targetSlot == null) {
        print('❌ ERROR: Time range "$testTimeRange" not found!');
        print('Available times:');
        for (var slot in slots) {
          print('  - "${slot['time']}"');
        }
        return;
      }
      
      // Step 6: Check bookedPatients
      print('\nStep 6: Checking bookedPatients...');
      final bookedPatients = (targetSlot['bookedPatients'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [];
      print('  Current bookedPatients: $bookedPatients');
      
      if (!bookedPatients.contains(testPatientUid)) {
        print('⚠️ WARNING: Patient UID "$testPatientUid" is NOT in the list!');
        print('  Maybe it was already removed?');
        return;
      }
      print('  ✅ Patient UID found in list');
      
      // Step 7: Remove the patient
      print('\nStep 7: Removing patient UID...');
      bookedPatients.removeWhere((uid) => uid == testPatientUid);
      print('  After removal: $bookedPatients');
      
      // Update the slot
      targetSlot['bookedPatients'] = bookedPatients;
      
      // Step 8: Write back to Firestore
      print('\nStep 8: Updating Firestore...');
      await therapistRef.update({'availability': availability});
      print('  ✅ SUCCESS! Firestore updated');
      
      // Step 9: Verify
      print('\nStep 9: Verifying update...');
      final verifyDoc = await therapistRef.get();
      final verifyAvail = verifyDoc.data()?['availability'] as List<dynamic>?;
      if (verifyAvail != null) {
        for (var day in verifyAvail) {
          if (day['day'] == dayName) {
            final verifySlots = day['slots'] as List<dynamic>?;
            if (verifySlots != null) {
              for (var slot in verifySlots) {
                if (slot['time'] == testTimeRange) {
                  final verifyBooked = (slot['bookedPatients'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ?? [];
                  print('  Verified bookedPatients: $verifyBooked');
                  
                  if (verifyBooked.contains(testPatientUid)) {
                    print('  ❌ FAILED: Patient UID still in list!');
                  } else {
                    print('  ✅ VERIFIED: Patient UID successfully removed!');
                  }
                  break;
                }
              }
            }
            break;
          }
        }
      }
      
      print('\n=== TEST COMPLETE ===');
      
    } catch (e, stack) {
      print('\n❌ EXCEPTION: $e');
      print('Stack trace:');
      print(stack);
    }
  }
}
