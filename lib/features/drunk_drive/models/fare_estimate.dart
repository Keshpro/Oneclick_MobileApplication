class FareEstimate {
  final double baseFare;
  final double distanceCharge;
  final double timeCharge;
  final double serviceFee;

  const FareEstimate({
    required this.baseFare,
    required this.distanceCharge,
    required this.timeCharge,
    required this.serviceFee,
  });

  double get total => baseFare + distanceCharge + timeCharge + serviceFee;
}