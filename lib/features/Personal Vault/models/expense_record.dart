import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseRecord {
  final String id;
  final String sourceModule;
  final String sourceTransactionId;
  final String description;
  final String currency;
  final String paymentMethod;
  final String status;
  final String bookingId;
  final String environment;
  final double amount;
  final DateTime paidAt;
  final bool isRealPayment;

  const ExpenseRecord({
    required this.id,
    required this.sourceModule,
    required this.sourceTransactionId,
    required this.description,
    required this.amount,
    required this.currency,
    required this.paidAt,
    this.paymentMethod = '',
    this.status = '',
    this.bookingId = '',
    this.environment = '',
    this.isRealPayment = false,
  });

  bool get isDemoPaid => status == 'demo_paid' && !isRealPayment;

  bool get isPendingCash => status == 'pending_cash';

  String get statusLabel {
    switch (status) {
      case 'demo_paid':
        return 'Demo Paid';
      case 'pending_cash':
        return 'Pending Cash';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  String get methodLabel {
    switch (paymentMethod) {
      case 'card':
        return 'Card';
      case 'cash':
        return 'Cash';
      default:
        return paymentMethod.isEmpty ? 'Unknown' : paymentMethod;
    }
  }

  static String normalizeModule(String value) {
    final key = value.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]'), '');

    switch (key) {
      case 'grocery':
      case 'groceries':
        return 'groceries';

      case 'food':
      case 'foods':
        return 'food';

      case 'doctor':
        return 'doctor';

      case 'quickfix':
        return 'quickfix';

      case 'drinkdrive':
      case 'drinkanddrive':
      case 'drunkdrive':
      case 'drunkanddrive':
        return 'drunk_drive';

      default:
        return key;
    }
  }

  factory ExpenseRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};

    final minor = data['amountMinor'];

    final amount = minor is num
        ? minor / 100
        : double.tryParse('${data['amount'] ?? ''}') ?? 0.0;

    final rawDate = data['createdAt'];

    return ExpenseRecord(
      id: snapshot.id,

      sourceModule: normalizeModule('${data['module'] ?? ''}'),

      sourceTransactionId: '${data['paymentId'] ?? snapshot.id}',

      description: '${data['title'] ?? ''}',

      amount: amount,

      currency: '${data['currency'] ?? ''}',

      paidAt: rawDate is Timestamp
          ? rawDate.toDate().toLocal()
          : DateTime.fromMillisecondsSinceEpoch(0),

      paymentMethod: '${data['method'] ?? ''}'.toLowerCase(),

      status: '${data['status'] ?? ''}'.toLowerCase(),

      bookingId: '${data['bookingId'] ?? ''}',

      environment: '${data['environment'] ?? ''}',

      isRealPayment: data['isRealPayment'] == true,
    );
  }
}
