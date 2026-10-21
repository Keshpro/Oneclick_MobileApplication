import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

/// Location sharing is opt-in and scoped to an assigned, ongoing trip.
/// Requires Firestore rules that enforce the same authorization checks.
class DriverTripLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _positionSubscription;
  String? _bookingId;
  bool _sharing = false;
  bool _publishing = false;
  Future<void> Function(Object error)? onError;

  bool get isSharing => _sharing;

  Future<void> start(String bookingId) async {
    if (_sharing) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in before sharing location.');
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Location services are disabled.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError(
        'Location permission is required to share your position.',
      );
    }

    final reference = _firestore
        .collection('drunkDriveBookings')
        .doc(bookingId);
    final snapshot = await reference.get();
    final data = snapshot.data();
    if (data == null ||
        data['driverId'] != user.uid ||
        !_isRunning(data['status'])) {
      throw StateError(
        'Only the assigned driver of an active trip can share location.',
      );
    }

    _sharing = true;
    _bookingId = bookingId;
    try {
      final first = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _publish(first);
      if (!_sharing) return;
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 15,
            ),
          ).listen(
            (position) {
              unawaited(_publish(position));
            },
            onError: (Object error) {
              unawaited(_handleError(error));
            },
          );
    } catch (_) {
      await stop();
      rethrow;
    }
  }

  bool _isRunning(Object? status) =>
      status == 'tripStarted' || status == 'tripInProgress';

  Future<void> _publish(Position position) async {
    if (!_sharing || _publishing || _bookingId == null) return;
    _publishing = true;
    final bookingId = _bookingId!;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw StateError('Driver signed out.');
      final reference = _firestore
          .collection('drunkDriveBookings')
          .doc(bookingId);
      final accepted = await _firestore.runTransaction<bool>((
        transaction,
      ) async {
        final snapshot = await transaction.get(reference);
        final data = snapshot.data();
        if (data == null ||
            data['driverId'] != uid ||
            !_isRunning(data['status']) ||
            !_sharing) {
          return false;
        }
        transaction.update(reference, {
          'driverLocation.latitude': position.latitude,
          'driverLocation.longitude': position.longitude,
          'driverLocation.accuracyMeters': position.accuracy,
          'driverLocation.updatedAt': FieldValue.serverTimestamp(),
          'driverLocation.trackingActive': true,
        });
        return true;
      });
      if (!accepted) await stop();
    } catch (error) {
      await _handleError(error);
    } finally {
      _publishing = false;
    }
  }

  Future<void> _handleError(Object error) async {
    await stop();
    await onError?.call(error);
  }

  Future<void> stop() async {
    final bookingId = _bookingId;
    _sharing = false;
    _bookingId = null;
    final subscription = _positionSubscription;
    _positionSubscription = null;
    await subscription?.cancel();
    if (bookingId == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final reference = _firestore
        .collection('drunkDriveBookings')
        .doc(bookingId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (snapshot.data()?['driverId'] != uid) return;
      transaction.update(reference, {
        'driverLocation.trackingActive': false,
        'driverLocation.stoppedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
