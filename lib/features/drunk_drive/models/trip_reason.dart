enum TripReason {
  hadAlcohol,
  tooTired,
  feelingUnwell,
  temporarilyUnable,
  other,
}

extension TripReasonLabel on TripReason {
  String get label {
    switch (this) {
      case TripReason.hadAlcohol:
        return 'Had alcohol';
      case TripReason.tooTired:
        return 'Too tired to drive';
      case TripReason.feelingUnwell:
        return 'Feeling unwell';
      case TripReason.temporarilyUnable:
        return 'Temporarily unable to drive';
      case TripReason.other:
        return 'Other';
    }
  }
}
