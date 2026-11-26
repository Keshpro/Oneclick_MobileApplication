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
  int _generation = 0;
  Timer? _heartbeat;
  Future<void> Function(Object error)? onError;

  bool get isSharing => _sharing;

  Future<void> start(String bookingId) async {
    if (_sharing) return;
    final generation = ++_generation;
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

    if (generation != _generation) return;
    _sharing = true;
    _bookingId = bookingId;
    try {
      final first = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15),
        ),
      );
      if (generation != _generation || !_sharing) return;
      await _publish(first);
      if (!_sharing || generation != _generation) return;
      _heartbeat = Timer.periodic(const Duration(seconds: 45), (_) async {
        if (!_sharing || generation != _generation || _publishing) return;
        try {
          final fresh = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)));
          if (!_sharing || generation != _generation) return;
          await _publish(fresh);
        } catch (_) {
          // A failed GPS read must not re-publish an old coordinate as fresh.
        }
      });
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 15,
            ),
          ).listen(
            (position) {
              if (generation != _generation) return;
              unawaited(_publish(position));
            },
            onError: (Object error) {
              unawaited(_handleError(error));
            },
          );
    } catch (_) {
      try { await stop(); } catch (_) {}
      rethrow;
    }
  }

  bool _isRunning(Object? status) =>
      status == 'driverArriving' || status == 'tripStarted' || status == 'tripInProgress';

  Future<void> _publish(Position position) async {
    if (!_sharing || _publishing || _bookingId == null) return;
    _publishing = true;
    final bookingId = _bookingId!;
    final generation = _generation;
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
            !_sharing || generation != _generation || _bookingId != bookingId) {
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
      if (!accepted && generation == _generation) await stop();
    } catch (error) {
      if (generation == _generation) await _handleError(error);
    } finally {
      _publishing = false;
    }
  }

  Future<void> _handleError(Object error) async {
    try { await stop(); } catch (_) {}
    await onError?.call(error);
  }

  Future<void> stop() async {
    final bookingId = _bookingId;
    _generation++;
    _heartbeat?.cancel();
    _heartbeat = null;
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
