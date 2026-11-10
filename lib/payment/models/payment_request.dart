
enum OneClickModule {
  doctor,
  food,
  groceries,
  drunkDrive,
  quickFix,
}

extension OneClickModuleName on OneClickModule {
  String get value {
    switch (this) {
      case OneClickModule.doctor:
        return 'doctor';
      case OneClickModule.food:
        return 'food';
      case OneClickModule.groceries:
        return 'groceries';
      case OneClickModule.drunkDrive:
        return 'drunk_drive';
      case OneClickModule.quickFix:
        return 'quickfix';
    }
  }

  String get displayName {
    switch (this) {
      case OneClickModule.doctor:
        return 'Doctor Appointment';
      case OneClickModule.food:
        return 'Food Order';
      case OneClickModule.groceries:
        return 'Grocery Order';
      case OneClickModule.drunkDrive:
        return 'Driver Booking';
      case OneClickModule.quickFix:
        return 'Quick Fix Service';
    }
  }
}

class PaymentRequest {
  final String orderId;
  final OneClickModule module;
  final String title;
  final String description;

  // Amount in cents: LKR 2500.00 = 250000.
  // Use integer minor units to avoid floating-point errors.
  final int amountMinor;

  final String currency;

  const PaymentRequest({
    required this.orderId,
    required this.module,
    required this.title,
    required this.description,
    required this.amountMinor,
    this.currency = 'LKR',
  }) : assert(amountMinor > 0);

  double get displayAmount => amountMinor / 100;

  String get formattedAmount {
    final whole = amountMinor ~/ 100;
    final fraction =
        (amountMinor % 100).toString().padLeft(2, '0');

    final digits = whole.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }

    return '$currency ${buffer.toString()}.$fraction';
  }
}
