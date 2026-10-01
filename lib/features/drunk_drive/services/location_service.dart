import 'dart:math';

import '../models/location_model.dart';

class LocationService {
  static const List<LocationModel> _mockLocations = [
    LocationModel(
      name: 'Colombo Fort',
      address: 'Colombo 01',
      latitude: 6.9344,
      longitude: 79.8428,
    ),
    LocationModel(
      name: 'Battaramulla',
      address: 'Battaramulla South',
      latitude: 6.8992,
      longitude: 79.9184,
    ),
    LocationModel(
      name: 'Kandy City Centre',
      address: 'Kandy',
      latitude: 7.2906,
      longitude: 80.6337,
    ),
    LocationModel(
      name: 'Galle Face Green',
      address: 'Colombo 03',
      latitude: 6.9271,
      longitude: 79.8449,
    ),
    LocationModel(
      name: 'Negombo Beach',
      address: 'Negombo',
      latitude: 7.2083,
      longitude: 79.8358,
    ),
    LocationModel(
      name: 'Peradeniya',
      address: 'Kandy District',
      latitude: 7.2599,
      longitude: 80.5977,
    ),
    LocationModel(
      name: 'Kurunegala Town',
      address: 'Kurunegala',
      latitude: 7.4863,
      longitude: 80.3647,
    ),
  ];

  List<LocationModel> getMockLocations() => List.unmodifiable(_mockLocations);

  List<LocationModel> searchLocations(String query) {
    if (query.trim().isEmpty) return getMockLocations();
    final lower = query.trim().toLowerCase();
    return _mockLocations
        .where(
          (loc) =>
              loc.name.toLowerCase().contains(lower) ||
              (loc.address?.toLowerCase().contains(lower) ?? false),
        )
        .toList();
  }

  /// Straight-line distance between two locations, in kilometres.
  /// Stands in for real routing distance until Phase 7 (Maps).
  double distanceKmBetween(LocationModel a, LocationModel b) {
    if (a.latitude == null ||
        a.longitude == null ||
        b.latitude == null ||
        b.longitude == null) {
      return 10; // fallback mock distance if coordinates are missing
    }
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(b.latitude! - a.latitude!);
    final dLon = _degToRad(b.longitude! - a.longitude!);
    final lat1 = _degToRad(a.latitude!);
    final lat2 = _degToRad(b.latitude!);

    final h =
        sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));
    return earthRadiusKm * c;
  }

  /// Rough travel time estimate assuming average city driving speed.
  int estimatedDurationMinutes(double distanceKm) {
    const averageSpeedKmh = 35;
    final minutes = (distanceKm / averageSpeedKmh) * 60;
    return minutes.round().clamp(5, 300);
  }

  double _degToRad(double deg) => deg * (pi / 180);
}
