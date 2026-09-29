import '../models/fare_estimate.dart';

class FarePricingConfig {
  FarePricingConfig._();

  static const double baseFare = 300; // Rs.
  static const double perKmRate = 60; // Rs. per km
  static const double perMinuteRate = 15; // Rs. per minute
  static const double serviceFee = 100; // Rs. flat
}

class FareService {
  FareEstimate estimateFare({
    required double distanceKm,
    required int durationMinutes,
  }) {
    return FareEstimate(
      baseFare: FarePricingConfig.baseFare,
      distanceCharge: distanceKm * FarePricingConfig.perKmRate,
      timeCharge: durationMinutes * FarePricingConfig.perMinuteRate,
      serviceFee: FarePricingConfig.serviceFee,
    );
  }
}
