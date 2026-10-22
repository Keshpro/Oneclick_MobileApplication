
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseRecord {
  final String id;
  final String sourceModule;
  final String sourceTransactionId;
  final String description;
  final double amount;
  final String currency;
  final DateTime paidAt;

  const ExpenseRecord({
    required this.id,
    required this.sourceModule,
    required this.sourceTransactionId,
    required this.description,
    required this.amount,
    required this.currency,
    required this.paidAt,
  });

  // Convert a Firestore document into an ExpenseRecord.
  factory ExpenseRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};

    final rawAmount = data['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '') ?? 0.0;

    final rawPaidAt = data['paidAt'];

    return ExpenseRecord(
      id: snapshot.id,
      sourceModule: data['sourceModule']?.toString() ?? '',
      sourceTransactionId:
          data['sourceTransactionId']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      amount: amount,
      currency: data['currency']?.toString() ?? 'LKR',
      paidAt: rawPaidAt is Timestamp
          ? rawPaidAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  // Convert the expense into data suitable for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'sourceModule': sourceModule,
      'sourceTransactionId': sourceTransactionId,
      'description': description,
      'amount': amount,
      'currency': currency,
      'paidAt': Timestamp.fromDate(paidAt),
    };
  }
}
