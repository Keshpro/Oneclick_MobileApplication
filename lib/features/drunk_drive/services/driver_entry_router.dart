import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../driver/screens/driver_home_screen.dart';
import '../passenger/screens/drunk_drive_home_screen.dart';

/// A Drunk & Drive application belongs to the Firebase Auth UID, not to
/// the general OneClick users.role field. Never grant approval in this router:
/// DriverHomeScreen independently verifies the application before access.
class DriverEntryRouter {
  const DriverEntryRouter._();

  static Future<Widget?> dashboardFor({
    required String uid,
    required String role,
  }) async {
    final normalizedRole = role.trim().toLowerCase();
    if (normalizedRole == 'admin') return null;

    final firestore = FirebaseFirestore.instance;
    final suffix = uid.length > 6 ? uid.substring(uid.length - 6) : uid;
    debugPrint(
      '[DD_ROUTE_V3] check uid=...$suffix role=$normalizedRole '
      'project=${firestore.app.options.projectId}',
    );

    // Check the actual Drunk & Drive application BEFORE considering other
    // account roles, including legacy or differently named passenger roles.
    final application = await _read(
      firestore.collection('drunkDriveDriverApplications').doc(uid),
    );
    if (application?.exists == true) {
      final status = application!.data()?['status']?.toString();
      debugPrint(
        '[DD_ROUTE_V3] application exists status=$status '
        'cached=${application.metadata.isFromCache}',
      );
      if (status == 'approved') {
        // Open the real driver dashboard directly, not a passenger screen.
        debugPrint('[DD_ROUTE_V3] destination=DriverHomeScreen');
        return const DriverHomeScreen();
      }
      // Keep pending/rejected drivers in the approval-gated driver flow.
      debugPrint('[DD_ROUTE_V3] destination=restricted driver flow');
      return const DrunkDriveHomeScreen(preferDriverMode: true);
    }

    // A missing dedicated application does not change other provider roles.
    // The shared provider registration does not itself grant trip access.
    if (!{
      'user',
      'customer',
      'passenger',
      'driver',
      'patient',
      '',
    }.contains(normalizedRole)) {
      debugPrint('[DD_ROUTE_V3] destination=existing provider route');
      return null;
    }
    final sharedDriver = normalizedRole == 'driver'
        ? true
        : (await _read(firestore.collection('drivers').doc(uid)))?.exists ==
              true;
    if (sharedDriver) {
      debugPrint('[DD_ROUTE_V3] destination=driver application flow');
      return const DrunkDriveHomeScreen(preferDriverMode: true);
    }
    debugPrint('[DD_ROUTE_V3] no readable driver application; normal route');
    return null;
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> _read(
    DocumentReference<Map<String, dynamic>> reference,
  ) async {
    try {
      final snapshot = await reference.get();
      debugPrint(
        '[DD_ROUTE_V3] ${reference.parent.id} '
        'exists=${snapshot.exists} cached=${snapshot.metadata.isFromCache}',
      );
      return snapshot;
    } on FirebaseException catch (error) {
      debugPrint('[DD_ROUTE_V3] ${reference.parent.id} error=${error.code}');
      // Rules may reject reads of missing application documents. Preserve
      // normal passenger login, but expose this reason in the debug console.
      if (error.code == 'permission-denied') return null;
      rethrow;
    }
  }
}
