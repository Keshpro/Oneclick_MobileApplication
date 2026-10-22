
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/expense_record.dart';
import '../services/expense_service.dart';
import 'expense_donut_chart.dart';

class ExpenseManagerScreen extends StatefulWidget {
  const ExpenseManagerScreen({super.key});

  @override
  State<ExpenseManagerScreen> createState() =>
      _ExpenseManagerScreenState();
}

class _ExpenseManagerScreenState extends State<ExpenseManagerScreen> {
  final ExpenseService _service = ExpenseService();
  late final Stream<List<ExpenseRecord>> _expensesStream;

  static const _purple = Color(0xFF7464E8);
  static const _ink = Color(0xFF25263A);
  static const _muted = Color(0xFF8B90A4);
  static const _background = Color(0xFFF7F8FC);

  static const _months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  static const _categories = [
    _ExpenseCategory(
      'food', 'Food', Icons.restaurant_rounded,
      Color(0xFFFFA45C), Color(0xFFFFF2E7),
    ),
    _ExpenseCategory(
      'doctor', 'Doctor', Icons.favorite_rounded,
      Color(0xFFEF7894), Color(0xFFFFEDF2),
    ),
    _ExpenseCategory(
      'groceries', 'Groceries', Icons.shopping_basket_rounded,
      Color(0xFF4CBF9C), Color(0xFFE5F8F2),
    ),
    _ExpenseCategory(
      'quickfix', 'QuickFix', Icons.handyman_rounded,
      Color(0xFF6997E8), Color(0xFFEAF1FF),
    ),
    _ExpenseCategory(
      'drunk_drive', 'Drunk Drive', Icons.directions_car_rounded,
      Color(0xFF9B80DD), Color(0xFFF2EBFF),
    ),
  ];

  DateTime _month = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  @override
  void initState() {
    super.initState();
    _expensesStream = FirebaseAuth.instance.currentUser == null
        ? Stream<List<ExpenseRecord>>.value([])
        : _service.watchExpenses();
  }

  String _money(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final digits = parts.first;
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }

    return 'LKR $buffer.${parts.last}';
  }

  String _date(DateTime value) =>
      '${value.day} ${_months[value.month - 1]} ${value.year}';

  void _moveMonth(int difference) {
    final next = DateTime(_month.year, _month.month + difference);
    final today = DateTime(DateTime.now().year, DateTime.now().month);

    if (next.isAfter(today)) return;

    setState(() => _month = next);
  }

  Widget _panel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(22),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F1F7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _header() {
    final thisMonth =
        DateTime(DateTime.now().year, DateTime.now().month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Expenses',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
            color: _ink,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Your OneClick spending, all in one place.',
          style: TextStyle(color: _muted, fontSize: 14),
        ),
        const SizedBox(height: 24),
        _panel(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () => _moveMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'SPENDING PERIOD',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: _muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_months[_month.month - 1]} ${_month.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: _month.isBefore(thisMonth)
                    ? () => _moveMonth(1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _totalCard(double total, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8778F0),
            Color(0xFF6657CF),
            Color(0xFF5144B3),
          ],
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: const [
          BoxShadow(
            color: Color(0x346657CF),
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: -75,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x26FFFFFF),
                  width: 32,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Total Spending',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _money(total),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x2AFFFFFF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '$count confirmed ${count == 1 ? 'payment' : 'payments'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: _ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: _muted,
          ),
        ),
      ],
    );
  }

  Widget _categoryBreakdown(
    Map<String, double> totals,
    double total,
  ) {
    return _panel(
      child: Column(
        children: [
          for (var index = 0;
              index < _categories.length;
              index++) ...[
            if (index > 0) const SizedBox(height: 22),
            _categoryRow(
              _categories[index],
              totals[_categories[index].id] ?? 0,
              total,
            ),
          ],
        ],
      ),
    );
  }

  Widget _categoryRow(
    _ExpenseCategory category,
    double amount,
    double total,
  ) {
    final ratio = total > 0
        ? (amount / total).clamp(0.0, 1.0)
        : 0.0;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: category.background,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            category.icon,
            color: category.color,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      category.label,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    _money(amount),
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 7,
                  color: category.color,
                  backgroundColor: category.background,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyHistory() {
    return _panel(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFF1EEFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: _purple,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Nothing spent here yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Your confirmed OneClick payments\n'
              'will appear here when payment tracking is connected.',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.55,
                color: _muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionItem(ExpenseRecord expense) {
    final category = _categories.firstWhere(
      (item) => item.id == expense.sourceModule,
      orElse: () => _categories.first,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _panel(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description.trim().isEmpty
                        ? category.label
                        : expense.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _ink,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${category.label} · ${_date(expense.paidAt)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _money(expense.amount),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expenseDashboard(List<ExpenseRecord> records) {
    final monthRecords = _service.expensesForMonth(
      records,
      _month,
    );
    final total = _service.monthlyTotal(records, _month);
    final breakdown = _service.totalsByModule(records, _month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _totalCard(total, monthRecords.length),
          const SizedBox(height: 28),

          ExpenseDonutChart(
            totals: breakdown,
          ),

          const SizedBox(height: 34),
          _sectionHeading(
            'Spending Breakdown',
            'See where your money goes',
          ),
        const SizedBox(height: 17),
        _categoryBreakdown(breakdown, total),
        const SizedBox(height: 34),
        _sectionHeading(
          'Recent Transactions',
          'Confirmed payments for this month',
        ),
        const SizedBox(height: 17),
        if (monthRecords.isEmpty)
          _emptyHistory()
        else
          for (final expense in monthRecords)
            _transactionItem(expense),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Expense Manager',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 45),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 24),
                  if (FirebaseAuth.instance.currentUser == null)
                    _panel(
                      child: const Text(
                        'Please sign in to view your expenses.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    StreamBuilder<List<ExpenseRecord>>(
                      stream: _expensesStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _panel(
                            child: const Text(
                              'Unable to load expenses. '
                              'Check your connection and '
                              'Firestore permissions.',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: _purple,
                              ),
                            ),
                          );
                        }

                        return _expenseDashboard(snapshot.data!);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _ExpenseCategory(
    this.id,
    this.label,
    this.icon,
    this.color,
    this.background,
  );
}
