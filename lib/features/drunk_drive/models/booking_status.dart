enum BookingStatus {
  requested,
  searchingDriver,
  driverAssigned,
  driverAccepted,
  driverArriving,
  driverArrived,
  verification,
  tripStarted,
  tripInProgress,
  tripCompleted,
  payment,
  completed,
  cancelledByUser,
  cancelledByDriver,
  driverNotFound,
  paymentFailed,
  incidentReported,
}

extension BookingStatusLabel on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.requested:
        return 'Requested';
      case BookingStatus.searchingDriver:
        return 'Searching for Driver';
      case BookingStatus.driverAssigned:
        return 'Driver Assigned';
      case BookingStatus.driverAccepted:
        return 'Driver Accepted';
      case BookingStatus.driverArriving:
        return 'Driver Arriving';
      case BookingStatus.driverArrived:
        return 'Driver Arrived';
      case BookingStatus.verification:
        return 'Verification';
      case BookingStatus.tripStarted:
        return 'Trip Started';
      case BookingStatus.tripInProgress:
        return 'Trip in Progress';
      case BookingStatus.tripCompleted:
        return 'Trip Completed';
      case BookingStatus.payment:
        return 'Payment';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelledByUser:
        return 'Cancelled by You';
      case BookingStatus.cancelledByDriver:
        return 'Cancelled by Driver';
      case BookingStatus.driverNotFound:
        return 'No Driver Found';
      case BookingStatus.paymentFailed:
        return 'Payment Failed';
      case BookingStatus.incidentReported:
        return 'Incident Reported';
    }
  }
}