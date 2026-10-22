
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
