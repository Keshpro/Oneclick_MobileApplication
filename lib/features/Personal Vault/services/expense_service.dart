
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense_record.dart';

class ExpenseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> modules = [
    'food',
    'doctor',
    'groceries',
    'quickfix',
    'drunk_drive',
  ];

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in to view your expenses.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _expenses {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('expenses');
  }

  /// Persist a confirmed, real OneClick payment exactly once.
  ///
  /// Call this only after the payment provider/backend has confirmed payment.
  /// Do not call for pending, cash-on-delivery orders before collection,
  /// cancellations, or simulated/demo payments.
  ///
  /// The signed-in Firebase user must be the payer; do not use this method
  /// for payments made by another user. Production deployments must also
  /// enforce ownership and payment verification in Firestore security rules
  /// or a trusted backend, because client-side validation alone is not secure.
  ///
  /// Returns true if the expense was newly recorded, false if it was already
  /// present. An existing expense is never overwritten by a repeated call.
  Future<bool> recordConfirmedPayment({
    required String sourceModule,
    required String sourceTransactionId,
    required String description,
    required double amount,
    required DateTime paidAt,
  }) async {
    final module = sourceModule.trim().toLowerCase();
    final transactionId = sourceTransactionId.trim();

    if (!modules.contains(module)) {
      throw ArgumentError.value(sourceModule, 'sourceModule',
          'Must be a supported OneClick module.');
    }
    if (transactionId.isEmpty || transactionId.length > 500) {
      throw ArgumentError.value(sourceTransactionId, 'sourceTransactionId',
          'Must contain 1 to 500 characters.');
    }
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(amount, 'amount',
          'Must be a positive, finite LKR amount.');
    }
    if (paidAt.millisecondsSinceEpoch <= 0 ||
        paidAt.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      throw ArgumentError.value(paidAt, 'paidAt',
          'Must be a valid payment date, not in the future.');
    }

    // Encode the source ID so Firestore document IDs never contain '/'.
    // Prefix by module so two modules can reuse the same transaction ID.
    final id = '${module}_${base64Url.encode(utf8.encode(transactionId))}';
    final document = _expenses.doc(id);

    return _firestore.runTransaction<bool>((transaction) async {
      final existing = await transaction.get(document);
      if (existing.exists) return false;

      transaction.set(document, {
        'sourceModule': module,
        'sourceTransactionId': transactionId,
        'description': description.trim(),
        'amount': amount,
        'currency': 'LKR',
        'paidAt': Timestamp.fromDate(paidAt),
        'status': 'paid',
      });
      return true;
    });
  }

  // Listen for expenses belonging to the signed-in user.
  Stream<List<ExpenseRecord>> watchExpenses() {
    return _expenses.snapshots().map((snapshot) {
      final expenses = snapshot.docs
          .where((doc) => doc.data()['status'] == 'paid')
          .map(ExpenseRecord.fromFirestore)
          .where((expense) =>
              modules.contains(expense.sourceModule) &&
              expense.sourceTransactionId.isNotEmpty &&
              expense.amount.isFinite &&
              expense.amount > 0 &&
              expense.currency == 'LKR' &&
              expense.paidAt.millisecondsSinceEpoch > 0)
          .toList();

      expenses.sort((a, b) => b.paidAt.compareTo(a.paidAt));

      return expenses;
    });
  }

  // Expenses within a given calendar month.
  List<ExpenseRecord> expensesForMonth(
    List<ExpenseRecord> expenses,
    DateTime month,
  ) {
    return expenses.where((expense) {
      return expense.paidAt.year == month.year &&
          expense.paidAt.month == month.month;
    }).toList();
  }

  // Total paid amount for a given month.
  double monthlyTotal(
    List<ExpenseRecord> expenses,
    DateTime month,
  ) {
    return expensesForMonth(expenses, month)
        .fold<double>(0, (total, expense) => total + expense.amount);
  }

  // Spending totals grouped by OneClick module.
  Map<String, double> totalsByModule(
    List<ExpenseRecord> expenses,
    DateTime month,
  ) {
    final totals = <String, double>{
      for (final module in modules) module: 0.0,
    };

    for (final expense in expensesForMonth(expenses, month)) {
      if (totals.containsKey(expense.sourceModule)) {
        totals[expense.sourceModule] =
            totals[expense.sourceModule]! + expense.amount;
      }
    }

    return totals;
  }
}
