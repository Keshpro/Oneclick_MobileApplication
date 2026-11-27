import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';
import 'booking_policy.dart';

/// Device GPS quality and straight-line pickup radius (not road distance).
class GpsPolicy {
  GpsPolicy._();

  static const double maxDriverAccuracyMeters = 500;
  static const double maxPickupAccuracyMeters = 100;
  static const maxPositionAge = Duration(minutes: 2);

  static bool validCoordinates(double? latitude, double? longitude) =>
      latitude != null &&
      longitude != null &&
      latitude.isFinite &&
      longitude.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  static bool isFresh(Position position) {
    final age = DateTime.now().difference(position.timestamp);
    return age >= const Duration(seconds: -30) && age <= maxPositionAge;
  }

  static bool usable(
    Position? position, {
    double maxAccuracy = maxDriverAccuracyMeters,
  }) =>
      position != null &&
      validCoordinates(position.latitude, position.longitude) &&
      position.accuracy.isFinite &&
      position.accuracy >= 0 &&
      position.accuracy <= maxAccuracy &&
      isFresh(position);

  static double? pickupDistanceMeters(Position? driver, LocationModel pickup) {
    if (!usable(driver) ||
        !validCoordinates(pickup.latitude, pickup.longitude)) {
      return null;
    }
    return Geolocator.distanceBetween(
      driver!.latitude,
      driver.longitude,
      pickup.latitude!,
      pickup.longitude!,
    );
  }

  static bool withinPickupRadius(Position? driver, LocationModel pickup) {
    final distance = pickupDistanceMeters(driver, pickup);
    return distance != null && distance <= BookingPolicy.nearbyRadiusKm * 1000;
  }

  static Future<Position> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Location is disabled. Turn on GPS and try again.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError(
        'Allow location access in device settings and try again.',
      );
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
    if (!validCoordinates(position.latitude, position.longitude) ||
        !isFresh(position)) {
      throw StateError(
        'The device returned an old or invalid location. Refresh GPS.',
      );
    }
    return position;
  }
}
