import 'package:flutter/material.dart';
import '../services/subscription_service.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  final String subscriptionId;
  final String name;
  final String subtitle;
  final String price;
  final String status;
  final String billingCycle;
  final DateTime? renewalDate;
  final VoidCallback onEdit;

  const SubscriptionDetailsScreen({
    super.key,
    required this.subscriptionId,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.status,
    required this.billingCycle,
    required this.renewalDate,
    required this.onEdit,
  });

  @override
  State<SubscriptionDetailsScreen> createState() =>
      _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState
    extends State<SubscriptionDetailsScreen> {
  static const Color bg = Color(0xFFF9F7FF);
  static const Color surface = Color(0xFFFBF9FF);
  static const Color ink = Color(0xFF292B43);
  static const Color muted = Color(0xFF6F7185);
  static const Color purple = Color(0xFF5E5BFF);
  static const Color danger = Color(0xFFCE334B);

  bool renewalReminders = true;
  bool _loadingRenewalReminders = true;
  bool _savingRenewalReminders = false;

  @override
  void initState() {
    super.initState();
    _loadRenewalReminders();
  }


Future<void> _loadRenewalReminders() async {
  try {
    final records = await _subscriptionService
        .getSubscriptions()
        .first;

    for (final record in records) {
      if (record.id == widget.subscriptionId) {
        if (!mounted) return;

        setState(() {
          renewalReminders = record.renewalReminders;
          _loadingRenewalReminders = false;
        });
        return;
      }
    }

    if (!mounted) return;

    setState(() {
      _loadingRenewalReminders = false;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      _loadingRenewalReminders = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not load reminder settings: $error',
        ),
      ),
    );
  }
}

Future<void> _updateRenewalReminders(bool enabled) async {
  if (_loadingRenewalReminders || _savingRenewalReminders) return;

  final previousValue = renewalReminders;

  setState(() {
    renewalReminders = enabled;
    _savingRenewalReminders = true;
  });

  try {
    await _subscriptionService.updateRenewalReminders(
      subscriptionId: widget.subscriptionId,
      enabled: enabled,
    );

    if (!mounted) return;

    setState(() {
      _savingRenewalReminders = false;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      renewalReminders = previousValue;
      _savingRenewalReminders = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not save reminder setting: $error'),
      ),
    );
  }
}

  final SubscriptionService _subscriptionService =
    SubscriptionService();

  bool _markingEnded = false;

  Future<void> _markSubscriptionEnded() async {
  if (_markingEnded) {
    return;
  }

  setState(() {
    _markingEnded = true;
  });

  try {
    await _subscriptionService.cancelSubscription(
      widget.subscriptionId,
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.name} marked as cancelled.',
        ),
      ),
    );
  } catch (error) {
    if (!mounted) {
      return;
    }

    setState(() {
      _markingEnded = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not update subscription: $error',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 45),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 26),

                  _buildSubscriptionSummary(),

                  const SizedBox(height: 28),

                  _buildRenewalReminders(),

                  const SizedBox(height: 28),

                  _buildVaultAndLegal(),

                  const SizedBox(height: 28),

                  _buildCancellationProtocol(),

                  const SizedBox(height: 28),

                  _buildDangerZone(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        _circleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),

        const SizedBox(width: 15),

        const Expanded(
          child: Text(
            'Subscription Details',
            style: TextStyle(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUBSCRIPTION SUMMARY
  // ============================================================

String _renewalLabel() {
  final date = widget.renewalDate;

  if (date == null) {
    return 'No renewal date';
  }

  final today = DateTime.now();
  final todayOnly = DateTime(
    today.year,
    today.month,
    today.day,
  );

  final renewalOnly = DateTime(
    date.year,
    date.month,
    date.day,
  );

  final days = renewalOnly
      .difference(todayOnly)
      .inDays;

  if (days < 0) {
    return 'Renewal passed';
  }

  if (days == 0) {
    return 'Renews today';
  }

  if (days == 1) {
    return 'Renews tomorrow';
  }

  return 'Renews in $days days';
}

double _detailsPriceAmount() {
  return double.tryParse(
        widget.price.replaceAll(
          RegExp(r'[^0-9.]'),
          '',
        ),
      ) ??
      0;
}

String _detailsCurrency() {
  final normalized =
      widget.price.trim().toUpperCase();

  return normalized.startsWith('USD') ||
          normalized.startsWith(r'$')
      ? 'USD'
      : 'LKR';
}

String _formatAmount(double amount) {
  final parts =
      amount.toStringAsFixed(2).split('.');

  final whole = parts[0];
  final decimal = parts[1];

  final buffer = StringBuffer();

  for (int i = 0; i < whole.length; i++) {
    if (i > 0 &&
        (whole.length - i) % 3 == 0) {
      buffer.write(',');
    }

    buffer.write(whole[i]);
  }

  return '${buffer.toString()}.$decimal';
}

String _annualSpendLabel() {
  final amount = _detailsPriceAmount();

  final annualAmount =
      widget.billingCycle
              .toLowerCase()
              .contains('annual')
          ? amount
          : amount * 12;

  return '${_detailsCurrency()} '
      '${_formatAmount(annualAmount)} '
      'estimated annual spend';
}

  Widget _buildSubscriptionSummary() {
    return _card(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              _circleIcon(
                Icons.layers,
                color: purple,
                size: 55,
              ),

              const SizedBox(width: 15),

              const SizedBox(width: 15),

Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        widget.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        widget.subtitle,
        style: const TextStyle(
          color: muted,
          fontSize: 13,
        ),
      ),
    ],
  ),
),

_badge(
  widget.renewalDate == null
      ? widget.status
      : '${widget.status} • ${_renewalLabel()}',
  purple,
),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _softDecoration(radius: 28),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.price,
                            style: TextStyle(
                              color: ink,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                              bottom: 5,
                            ),
                            child: Text(
                              widget.billingCycle
                                      .toLowerCase()
                                      .contains('annual')
                                  ? '/ year'
                                  : '/ month',
                              style: TextStyle(
                                color: muted,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3),
                      Text(
                        _annualSpendLabel(),
                        style: TextStyle(
                          color: muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                _circleIcon(
                  Icons.calendar_month_outlined,
                  color: purple,
                  size: 45,
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.check_circle_outline,
                  text: _markingEnded
                      ? 'Updating...'
                      : 'Mark Ended',
                  color: ink,
                  onTap: _markingEnded
                      ? () {}
                      : _markSubscriptionEnded,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _actionButton(
                  icon: Icons.edit_outlined,
                  text: 'Edit',
                  color: ink,
                  onTap: () {
                    Navigator.pop(context);

                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) {
                        widget.onEdit();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BILLING & USAGE
  // ============================================================

  
Widget _buildRenewalReminders() {
  return _card(
    child: Row(
      children: [
        _circleIcon(
          Icons.notifications_active_outlined,
          color: muted,
          size: 42,
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Renewal Reminders',
                style: TextStyle(
                  color: ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Reminder preference',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: renewalReminders,
          activeThumbColor: purple,
          onChanged: _loadingRenewalReminders ||
                  _savingRenewalReminders
              ? null
              : _updateRenewalReminders,
        ),
      ],
    ),
  );
}

  // ============================================================
  // VAULT & LEGAL
  // ============================================================

  Widget _buildVaultAndLegal() {
  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lock_outline,
              color: purple,
              size: 22,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'VAULT & LEGAL',
                style: TextStyle(
                  color: Color(0xFF55576E),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .4,
                ),
              ),
            ),
            _badge(
              'SECURE',
              muted,
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: _softDecoration(
            radius: 26,
          ),
          child: const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.shield_outlined,
                color: purple,
                size: 22,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No account credentials, passwords, or legal documents are linked to this subscription.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  // ============================================================
  // CANCELLATION PROTOCOL
  // ============================================================

  Widget _buildCancellationProtocol() {
  return _card(
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.help_outline,
              color: purple,
              size: 21,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'CANCELLATION GUIDE',
                style: TextStyle(
                  color: Color(0xFF55576E),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: _softDecoration(
            radius: 27,
          ),
          child: const Column(
            children: [
              _CancellationStep(
                number: '1',
                children: [
                  TextSpan(
                    text:
                        'Open the subscription provider\'s official app or website.',
                  ),
                ],
              ),
              SizedBox(height: 17),
              _CancellationStep(
                number: '2',
                children: [
                  TextSpan(
                    text:
                        'Open your plan, billing, or subscription settings.',
                  ),
                ],
              ),
              SizedBox(height: 17),
              _CancellationStep(
                number: '3',
                children: [
                  TextSpan(
                    text:
                        'Cancel the plan with the provider, then mark it as cancelled in OneClick.',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'OneClick tracks your subscription status but does not cancel external provider accounts directly.',
          style: TextStyle(
            color: muted,
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ],
    ),
  );
}

  // ============================================================
  // CANCELLATION EVIDENCE
  // ============================================================

  // ============================================================
  // DANGER ZONE
  // ============================================================

  Widget _buildDangerZone() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: danger,
                size: 23,
              ),

              SizedBox(width: 10),

              Text(
                'DANGER ZONE',
                style: TextStyle(
                  color: danger,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'Permanently detach this recurring tracker, associated '
            'spend analytics, and historical snapshots from OneClick.',
            style: TextStyle(
              color: muted,
              fontSize: 13,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: _showDeleteDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              decoration: _softDecoration(radius: 28),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: danger,
                    size: 19,
                  ),

                  SizedBox(width: 9),

                  Text(
                    'Delete Subscription Record',
                    style: TextStyle(
                      color: danger,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REUSABLE UI
  // ============================================================

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(22),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _shadow(),
      ),
      child: child,
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 8,
        ),
        decoration: _softDecoration(radius: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 17,
            ),

            const SizedBox(width: 6),

            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 46,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFAFF),
          shape: BoxShape.circle,
          boxShadow: _shadow(),
        ),
        child: Icon(
          icon,
          color: muted,
          size: size * .45,
        ),
      ),
    );
  }

  Widget _circleIcon(
    IconData icon, {
    required Color color,
    double size = 50,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAFF),
        shape: BoxShape.circle,
        boxShadow: _shadow(),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * .48,
      ),
    );
  }

  Widget _badge(
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4FC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  BoxDecoration _softDecoration({
    double radius = 25,
  }) {
    return BoxDecoration(
      color: const Color(0xFFFBFAFF),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: _shadow(),
    );
  }

  List<BoxShadow> _shadow() {
    return [
      BoxShadow(
        color: Colors.white.withValues(alpha: .9),
        offset: const Offset(-4, -4),
        blurRadius: 10,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: .065),
        offset: const Offset(5, 7),
        blurRadius: 15,
      ),
    ];
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surface,
          title: const Text(
            'Delete Subscription Record?',
            style: TextStyle(
              color: ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'This will remove this subscription record from OneClick.',
            style: TextStyle(
              color: muted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: muted,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _message(
                  'Subscription record deletion selected.',
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ================================================================
// CANCELLATION STEP
// ================================================================

class _CancellationStep extends StatelessWidget {
  final String number;
  final List<InlineSpan> children;

  const _CancellationStep({
    required this.number,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    const Color ink = Color(0xFF292B43);
    const Color purple = Color(0xFF5E5BFF);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFFBFAFF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 8,
                offset: const Offset(3, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: purple,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                color: ink,
                fontSize: 13,
                height: 1.45,
              ),
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}