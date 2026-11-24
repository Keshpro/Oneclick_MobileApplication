
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

class _ExpenseManagerScreenState
    extends State<ExpenseManagerScreen> {

  final _authStream =
      FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Unable to verify your account.',
              ),
            ),
          );
        }

        return _ExpenseDashboardView(
          key: ValueKey(snapshot.data?.uid),
        );
      },
    );
  }
}

class _ExpenseDashboardView extends StatefulWidget {
  const _ExpenseDashboardView({super.key});

  @override
  State<_ExpenseDashboardView> createState() =>
      _ExpenseDashboardViewState();
}

class _ExpenseDashboardViewState
    extends State<_ExpenseDashboardView> {

  final ExpenseService _service = ExpenseService();

  late final Stream<List<ExpenseRecord>>
      _expensesStream;

  static const _purple = Color(0xFF7464E8);
  static const _ink = Color(0xFF25263A);
  static const _muted = Color(0xFF8B90A4);
  static const _background = Color(0xFFF7F8FC);

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _categories = [
    _ExpenseCategory(
      'food',
      'Food',
      Icons.restaurant_rounded,
      Color(0xFFFFA45C),
      Color(0xFFFFF2E7),
    ),
    _ExpenseCategory(
      'doctor',
      'Doctor',
      Icons.favorite_rounded,
      Color(0xFFEF7894),
      Color(0xFFFFEDF2),
    ),
    _ExpenseCategory(
      'groceries',
      'Groceries',
      Icons.shopping_basket_rounded,
      Color(0xFF4CBF9C),
      Color(0xFFE5F8F2),
    ),
    _ExpenseCategory(
      'quickfix',
      'QuickFix',
      Icons.handyman_rounded,
      Color(0xFF6997E8),
      Color(0xFFEAF1FF),
    ),
    _ExpenseCategory(
      'drunk_drive',
      'Drink & Drive',
      Icons.directions_car_rounded,
      Color(0xFF9B80DD),
      Color(0xFFF2EBFF),
    ),
  ];

  DateTime _month = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  @override
  void initState() {
    super.initState();

    _expensesStream = _service.watchExpenses();
  }

  // ---------------------------------------------------
  // FORMATTING
  // ---------------------------------------------------

  String _money(double value) {
    final parts =
        value.toStringAsFixed(2).split('.');

    final digits = parts.first;
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 &&
          (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[i]);
    }

    return 'LKR $buffer.${parts.last}';
  }

  String _date(DateTime value) {
    return '${value.day} '
        '${_months[value.month - 1]} '
        '${value.year}';
  }

  String _dateTime(DateTime value) {
    final hour =
        value.hour.toString().padLeft(2, '0');

    final minute =
        value.minute.toString().padLeft(2, '0');

    return '${_date(value)} · $hour:$minute';
  }

  void _moveMonth(int difference) {
    final next = DateTime(
      _month.year,
      _month.month + difference,
    );

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
    );

    if (next.isAfter(today)) return;

    setState(() {
      _month = next;
    });
  }

  _ExpenseCategory _getCategory(String module) {
    return _categories.firstWhere(
      (item) => item.id == module,
      orElse: () => const _ExpenseCategory(
        'other',
        'Other',
        Icons.receipt_long_rounded,
        Color(0xFF7464E8),
        Color(0xFFF1EEFF),
      ),
    );
  }

  Color _statusColor(ExpenseRecord expense) {
    if (expense.isDemoPaid ||
        expense.status == 'paid') {
      return const Color(0xFF168765);
    }

    if (expense.isPendingCash) {
      return const Color(0xFFB7791F);
    }

    if (expense.status == 'failed' ||
        expense.status == 'cancelled') {
      return Colors.red;
    }

    return _muted;
  }

  // ---------------------------------------------------
  // COMMON PANEL
  // ---------------------------------------------------

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
        border: Border.all(
          color: const Color(0xFFF0F1F7),
        ),
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

  // ---------------------------------------------------
  // HEADER & MONTH SELECTOR
  // ---------------------------------------------------

  Widget _header() {
    final thisMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month,
    );

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
          style: TextStyle(
            color: _muted,
            fontSize: 14,
          ),
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
                icon: const Icon(
                  Icons.chevron_left_rounded,
                ),
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
                      '${_months[_month.month - 1]} '
                      '${_month.year}',
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
                icon: const Icon(
                  Icons.chevron_right_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------
  // TOTAL PAYMENT CARD
  // ---------------------------------------------------

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
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: 19,
                  ),

                  SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      'Total Demo Payments',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: Text(
                  '$count confirmed '
                  '${count == 1 ? 'payment' : 'payments'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Demo transactions only. '
                'No real money charged.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // TRANSACTION STATISTICS
  // ---------------------------------------------------

  Widget _statItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),

        const SizedBox(height: 10),

        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _muted,
          ),
        ),
      ],
    );
  }

  Widget _statistics(
    List<ExpenseRecord> records,
  ) {
    final monthlyRecords =
        _service.expensesForMonth(records, _month);

    final confirmed =
        _service.confirmedPaymentCount(
      records,
      _month,
    );

    final pending =
        _service.pendingCashCount(
      records,
      _month,
    );

    final pendingTotal =
        _service.pendingCashTotal(
      records,
      _month,
    );

    return _panel(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Statistics',
            style: TextStyle(
              fontSize: 16,
              color: _ink,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _statItem(
                  label: 'Transactions',
                  value: '${monthlyRecords.length}',
                  icon: Icons.receipt_long_rounded,
                  color: _purple,
                ),
              ),

              Expanded(
                child: _statItem(
                  label: 'Demo Paid',
                  value: '$confirmed',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF168765),
                ),
              ),

              Expanded(
                child: _statItem(
                  label: 'Pending Cash',
                  value: '$pending',
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFFB7791F),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Divider(
            color: Color(0xFFF0F1F7),
          ),

          const SizedBox(height: 10),

          _detailRow(
            'Pending cash amount',
            _money(pendingTotal),
          ),

          _detailRow(
            'All-time demo payments',
            _money(
              _service.totalDemoPayments(records),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // SECTION HEADING
  // ---------------------------------------------------

  Widget _sectionHeading(
    String title,
    String subtitle,
  ) {
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

  // ---------------------------------------------------
  // CATEGORY BREAKDOWN
  // ---------------------------------------------------

  Widget _categoryBreakdown(
    Map<String, double> totals,
    double total,
  ) {
    return _panel(
      child: Column(
        children: [
          for (
            var index = 0;
            index < _categories.length;
            index++
          ) ...[
            if (index > 0)
              const SizedBox(height: 22),

            _categoryRow(
              _categories[index],
              totals[_categories[index].id] ?? 0.0,
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
        ? (amount / total)
            .clamp(0.0, 1.0)
            .toDouble()
        : 0.0;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: category.background,
            borderRadius:
                BorderRadius.circular(15),
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
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

                  const SizedBox(width: 8),

                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _money(amount),
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 7,
                  color: category.color,
                  backgroundColor:
                      category.background,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------
  // EMPTY PAYMENT HISTORY
  // ---------------------------------------------------

  Widget _emptyHistory() {
    return _panel(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
        ),
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
              'No transactions yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),

            const SizedBox(height: 9),

            const Text(
              'Your OneClick payments will '
              'automatically appear here.',
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

  // ---------------------------------------------------
  // PAYMENT STATUS
  // ---------------------------------------------------

  Widget _statusBadge(ExpenseRecord expense) {
    final color = _statusColor(expense);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        expense.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // TRANSACTION DETAILS
  // ---------------------------------------------------

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            flex: 3,
            child: SelectableText(
              value.isEmpty ? 'Not available' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentDetails(
    ExpenseRecord expense,
  ) async {
    final category =
        _getCategory(expense.sourceModule);

    final ownerUid =
        FirebaseAuth.instance.currentUser?.uid;

    if (ownerUid == null) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return StreamBuilder<User?>(
          stream:
              FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.data?.uid != ownerUid ||
                FirebaseAuth.instance.currentUser?.uid
                    != ownerUid) {
              return const SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'Payment details unavailable.',
                  ),
                ),
              );
            }

            return StreamBuilder<List<ExpenseRecord>>(
              stream: _service.watchExpenses(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const SizedBox(
                    height: 160,
                    child: Center(
                      child: Text(
                        'Unable to load payment details.',
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 160,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                ExpenseRecord? currentPayment;

                for (final item in snapshot.data!) {
                  if (item.id == expense.id ||
                      item.sourceTransactionId ==
                          expense.sourceTransactionId) {
                    currentPayment = item;
                    break;
                  }
                }

                if (currentPayment == null) {
                  return const SizedBox(
                    height: 160,
                    child: Center(
                      child: Text(
                        'Payment record unavailable.',
                      ),
                    ),
                  );
                }

                final payment = currentPayment;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    30,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E4EC),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: category.background,
                          borderRadius:
                              BorderRadius.circular(24),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 34,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        payment.description.isEmpty
                            ? category.label
                            : payment.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _money(payment.amount),
                          style: const TextStyle(
                            color: _purple,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _statusBadge(payment),

                      const SizedBox(height: 24),

                      _panel(
                        padding:
                            const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _detailRow(
                              'Payment ID',
                              payment.sourceTransactionId,
                            ),

                            const Divider(),

                            _detailRow(
                              'Booking ID',
                              payment.bookingId,
                            ),

                            const Divider(),

                            _detailRow(
                              'Service',
                              category.label,
                            ),

                            const Divider(),

                            _detailRow(
                              'Date & Time',
                              _dateTime(payment.paidAt),
                            ),

                            const Divider(),

                            _detailRow(
                              'Payment Method',
                              payment.methodLabel,
                            ),

                            const Divider(),

                            _detailRow(
                              'Status',
                              payment.statusLabel,
                            ),

                            const Divider(),

                            _detailRow(
                              'Currency',
                              payment.currency,
                            ),

                            const Divider(),

                            _detailRow(
                              'Environment',
                              payment.environment,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      if (!payment.isRealPayment)
                        const Text(
                          'This is a demo transaction. '
                          'No real money was charged.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _muted,
                            fontSize: 12,
                          ),
                        ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------
  // TRANSACTION ITEM
  // ---------------------------------------------------

  Widget _transactionItem(
    ExpenseRecord expense,
  ) {
    final category =
        _getCategory(expense.sourceModule);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            _showPaymentDetails(expense);
          },
          child: _panel(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: category.background,
                    borderRadius:
                        BorderRadius.circular(15),
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                        '${category.label} · '
                        '${_date(expense.paidAt)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _muted,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Icon(
                            expense.paymentMethod == 'cash'
                                ? Icons.payments_outlined
                                : Icons.credit_card_rounded,
                            size: 13,
                            color: _muted,
                          ),

                          const SizedBox(width: 5),

                          Flexible(
                            child: Text(
                              expense.methodLabel,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(expense.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: _ink,
                      ),
                    ),

                    const SizedBox(height: 7),

                    _statusBadge(expense),
                  ],
                ),

                const SizedBox(width: 4),

                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: _muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // EXPENSE DASHBOARD
  // ---------------------------------------------------

  Widget _expenseDashboard(
    List<ExpenseRecord> records,
  ) {
    final monthRecords =
        _service.expensesForMonth(
      records,
      _month,
    );

    final total =
        _service.monthlyTotal(records, _month);

    final breakdown =
        _service.totalsByModule(records, _month);

    final confirmed =
        _service.confirmedPaymentCount(
      records,
      _month,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _totalCard(total, confirmed),

        const SizedBox(height: 24),

        _statistics(records),

        const SizedBox(height: 28),

        ExpenseDonutChart(
          totals: breakdown,
        ),

        const SizedBox(height: 34),

        _sectionHeading(
          'Spending Breakdown',
          'See where your demo payments go',
        ),

        const SizedBox(height: 17),

        _categoryBreakdown(
          breakdown,
          total,
        ),

        const SizedBox(height: 34),

        _sectionHeading(
          'Transaction History',
          'Your OneClick payments for this month',
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

  // ---------------------------------------------------
  // MAIN SCREEN
  // ---------------------------------------------------

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
          padding: const EdgeInsets.fromLTRB(
            18,
            20,
            18,
            45,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 760,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _header(),

                  const SizedBox(height: 24),

                  if (FirebaseAuth.instance.currentUser ==
                      null)
                    _panel(
                      child: const Text(
                        'Please sign in to view '
                        'your expenses.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    StreamBuilder<List<ExpenseRecord>>(
                      stream: _expensesStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _panel(
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red,
                                  size: 32,
                                ),

                                SizedBox(height: 12),

                                Text(
                                  'Unable to load payments.',
                                  style: TextStyle(
                                    color: _ink,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),

                                SizedBox(height: 8),

                                Text(
                                  'Check your internet '
                                  'connection and Firestore '
                                  'permissions.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child:
                                  CircularProgressIndicator(
                                color: _purple,
                              ),
                            ),
                          );
                        }

                        return _expenseDashboard(
                          snapshot.data!,
                        );
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

// -----------------------------------------------------
// EXPENSE CATEGORY MODEL
// -----------------------------------------------------

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
