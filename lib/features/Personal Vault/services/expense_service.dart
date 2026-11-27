import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense_record.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const List<String> modules = [
    'food',
    'doctor',
    'groceries',
    'quickfix',
    'drunk_drive',
  ];

  // ---------------------------------------------------
  // REAL-TIME PAYMENT HISTORY
  // ---------------------------------------------------

  Stream<List<ExpenseRecord>> watchExpenses() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return Stream.value(<ExpenseRecord>[]);
    }

    return _firestore
        .collection('payments')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          if (_auth.currentUser?.uid != uid) {
            return <ExpenseRecord>[];
          }

          final unique = <String, ExpenseRecord>{};

          for (final doc in snapshot.docs) {
            final data = doc.data();

            // Additional ownership validation.
            if (data['userId'] != uid) {
              continue;
            }

            final expense = ExpenseRecord.fromFirestore(doc);

            // Validate payment records.
            if (!modules.contains(expense.sourceModule) ||
                expense.currency != 'LKR' ||
                !expense.amount.isFinite ||
                expense.amount <= 0 ||
                expense.paidAt.millisecondsSinceEpoch <= 0) {
              continue;
            }

            final key = expense.sourceTransactionId.isEmpty
                ? expense.id
                : expense.sourceTransactionId;

            final existing = unique[key];

            // Prevent duplicate payment IDs.
            if (existing == null || expense.paidAt.isAfter(existing.paidAt)) {
              unique[key] = expense;
            }
          }

          final records = unique.values.toList();

          records.sort((a, b) => b.paidAt.compareTo(a.paidAt));

          return records;
        });
  }

  // ---------------------------------------------------
  // MONTHLY PAYMENT RECORDS
  // ---------------------------------------------------

  List<ExpenseRecord> expensesForMonth(
    List<ExpenseRecord> expenses,
    DateTime month,
  ) {
    return expenses.where((expense) {
      return expense.paidAt.year == month.year &&
          expense.paidAt.month == month.month;
    }).toList();
  }

  // ---------------------------------------------------
  // MONTHLY DEMO PAYMENT TOTAL
  // ---------------------------------------------------

  double monthlyTotal(List<ExpenseRecord> expenses, DateTime month) {
    return expensesForMonth(expenses, month)
        .where((expense) => expense.isDemoPaid)
        .fold<double>(0.0, (total, expense) => total + expense.amount);
  }

  // ---------------------------------------------------
  // MODULE-WISE TOTALS
  // ---------------------------------------------------

  Map<String, double> totalsByModule(
    List<ExpenseRecord> expenses,
    DateTime month,
  ) {
    final totals = <String, double>{for (final module in modules) module: 0.0};

    for (final expense in expensesForMonth(expenses, month)) {
      if (expense.isDemoPaid && totals.containsKey(expense.sourceModule)) {
        totals[expense.sourceModule] =
            totals[expense.sourceModule]! + expense.amount;
      }
    }

    return totals;
  }

  // ---------------------------------------------------
  // TRANSACTION STATISTICS
  // ---------------------------------------------------

  int confirmedPaymentCount(List<ExpenseRecord> expenses, DateTime month) {
    return expensesForMonth(
      expenses,
      month,
    ).where((expense) => expense.isDemoPaid).length;
  }

  int pendingCashCount(List<ExpenseRecord> expenses, DateTime month) {
    return expensesForMonth(
      expenses,
      month,
    ).where((expense) => expense.isPendingCash).length;
  }

  double pendingCashTotal(List<ExpenseRecord> expenses, DateTime month) {
    return expensesForMonth(expenses, month)
        .where((expense) => expense.isPendingCash)
        .fold<double>(0.0, (total, expense) => total + expense.amount);
  }

  double totalDemoPayments(List<ExpenseRecord> expenses) {
    return expenses
        .where((expense) => expense.isDemoPaid)
        .fold<double>(0.0, (total, expense) => total + expense.amount);
  }
}
