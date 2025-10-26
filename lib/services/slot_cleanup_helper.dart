import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Simplified slot cleanup using Firestore FieldValue.arrayRemove
/// This is much simpler and more reliable than manual array manipulation

class SlotCleanupHelper {
  /// Remove a single patient UID from therapist's availability slot
  static Future<void> removePatientFromSlot({
    required String doctorUid,
    required String date,
    required String timeRange,
    required String patientUid,
  }) async {
    try {
      print('🔍 Removing patient $patientUid from slot');
      print('   Doctor: $doctorUid, Date: $date, Time: $timeRange');

      final therapistRef = FirebaseFirestore.instance.collection('therapists').doc(doctorUid);
      final therapistDoc = await therapistRef.get();

      if (!therapistDoc.exists) {
        print('❌ Therapist document not found');
        return;
      }

      final data = therapistDoc.data();
      if (data == null) return;

      final availability = data['availability'] as List<dynamic>?;
      if (availability == null) {
        print('❌ No availability data');
        return;
      }

      // Parse date to get day name
      final parts = date.split('-');
      if (parts.length != 3) {
        print('❌ Invalid date format: $date');
        return;
      }

      final dt = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      // Dart weekday: Mon=1, Tue=2, ..., Sun=7
      // Array: [Sun, Mon, Tue, Wed, Thu, Fri, Sat]
      const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      final dayName = dayNames[dt.weekday % 7];

      print('   Looking for: Day=$dayName, Time=$timeRange');

      // Find and update the slot
      bool found = false;
      for (var dayData in availability) {
        if (dayData['day'] == dayName) {
          final slots = dayData['slots'] as List<dynamic>?;
          if (slots != null) {
            for (var slot in slots) {
              if (slot['time'] == timeRange) {
                // Found the slot - remove patient UID
                final bookedPatients = (slot['bookedPatients'] as List<dynamic>?)?.cast<String>() ?? [];
                print('   📋 Before: $bookedPatients');
                
                // Remove the patient UID
                bookedPatients.removeWhere((uid) => uid == patientUid);
                slot['bookedPatients'] = bookedPatients;
                
                print('   ✅ After: $bookedPatients');
                found = true;
                break;
              }
            }
          }
          if (found) break;
        }
      }

      if (found) {
        // Update Firestore with modified availability
        await therapistRef.update({'availability': availability});
        print('   ✅ Firestore updated successfully');
      } else {
        print('   ⚠️ Slot not found');
      }
    } catch (e, stack) {
      print('❌ Error in removePatientFromSlot: $e');
      print('   Stack: $stack');
    }
  }

  /// Remove all patient UIDs from a session's slot (for therapist cancel/complete)
  static Future<void> removeAllPatientsFromSlot({
    required String doctorUid,
    required String date,
    required String timeRange,
  }) async {
    try {
      print('🔍 Removing ALL patients from slot');
      print('   Doctor: $doctorUid, Date: $date, Time: $timeRange');

      final therapistRef = FirebaseFirestore.instance.collection('therapists').doc(doctorUid);
      final therapistDoc = await therapistRef.get();

      if (!therapistDoc.exists) {
        print('❌ Therapist document not found');
        return;
      }

      final data = therapistDoc.data();
      if (data == null) return;

      final availability = data['availability'] as List<dynamic>?;
      if (availability == null) return;

      // Parse date
      final parts = date.split('-');
      if (parts.length != 3) return;

      final dt = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      final dayName = dayNames[dt.weekday % 7];

      print('   Looking for: Day=$dayName, Time=$timeRange');

      // Find and clear the slot
      bool found = false;
      for (var dayData in availability) {
        if (dayData['day'] == dayName) {
          final slots = dayData['slots'] as List<dynamic>?;
          if (slots != null) {
            for (var slot in slots) {
              if (slot['time'] == timeRange) {
                final bookedPatients = (slot['bookedPatients'] as List<dynamic>?)?.cast<String>() ?? [];
                print('   📋 Clearing ${bookedPatients.length} patients: $bookedPatients');
                
                // Clear all patient UIDs
                slot['bookedPatients'] = [];
                
                print('   ✅ Cleared');
                found = true;
                break;
              }
            }
          }
          if (found) break;
        }
      }

      if (found) {
        await therapistRef.update({'availability': availability});
        print('   ✅ Firestore updated successfully');
      } else {
        print('   ⚠️ Slot not found');
      }
    } catch (e, stack) {
      print('❌ Error in removeAllPatientsFromSlot: $e');
      print('   Stack: $stack');
    }
  }
}
