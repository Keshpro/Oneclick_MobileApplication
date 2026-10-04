import 'package:flutter/material.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  const SubscriptionDetailsScreen({super.key});

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
  static const Color purple2 = Color(0xFF7C35FF);
  static const Color danger = Color(0xFFCE334B);

  bool renewalReminders = true;
  bool passphraseVisible = false;

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

                  _buildBillingAndUsage(),

                  const SizedBox(height: 28),

                  _buildVaultAndLegal(),

                  const SizedBox(height: 28),

                  _buildCancellationProtocol(),

                  const SizedBox(height: 28),

                  _buildCancellationEvidence(),

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

        _circleButton(
          icon: Icons.share_outlined,
          onTap: () => _message('Share subscription details'),
        ),

        const SizedBox(width: 10),

        _circleButton(
          icon: Icons.more_vert,
          onTap: () => _message('More options'),
        ),
      ],
    );
  }

  // ============================================================
  // SUBSCRIPTION SUMMARY
  // ============================================================

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

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adobe Creative Cloud',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'All Apps Individual',
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              _badge(
                '●  Renews in 11d',
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$54.99',
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
                              '/ month',
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
                        '\$659.88 estimated annual spend',
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
                  icon: Icons.open_in_new,
                  text: 'Cancel URL',
                  color: purple,
                  onTap: () => _message(
                    'Cancellation portal will open here.',
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _actionButton(
                  icon: Icons.check_circle_outline,
                  text: 'Mark Ended',
                  color: ink,
                  onTap: () => _message(
                    'Subscription marked as ended.',
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _actionButton(
                  icon: Icons.edit_outlined,
                  text: 'Edit',
                  color: ink,
                  onTap: () => _message(
                    'Edit subscription selected.',
                  ),
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

  Widget _buildBillingAndUsage() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: purple,
                size: 22,
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'BILLING & USAGE',
                  style: TextStyle(
                    color: Color(0xFF55576E),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .3,
                  ),
                ),
              ),

              _badge(
                'Auto-Renew On',
                purple,
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: _softDecoration(radius: 25),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.trending_up,
                  color: purple2,
                  size: 20,
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                        height: 1.45,
                      ),
                      children: [
                        TextSpan(
                          text: 'Price Increase: ',
                          style: TextStyle(
                            color: ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Adjusted +\$5.00/mo on Sep 2025 (Previously \$49.99/mo).',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _infoBox(
                  icon: Icons.calendar_today_outlined,
                  label: 'Next Bill',
                  title: 'Nov 24, 2025',
                  subtitle: 'In 11 days',
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _infoBox(
                  icon: Icons.credit_card_outlined,
                  label: 'Payment',
                  title: 'Chase Sapphire',
                  subtitle: '•••• 4291',
                  trailing: Icons.swap_horiz,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 15,
            ),
            decoration: _softDecoration(radius: 28),
            child: Row(
              children: [
                _circleIcon(
                  Icons.donut_large,
                  color: purple2,
                  size: 42,
                ),

                const SizedBox(width: 13),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$18.33 / session',
                        style: TextStyle(
                          color: ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '3 opens / mo · Above avg (\$6.40)',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                _badge(
                  'MODERATE',
                  muted,
                ),
              ],
            ),
          ),

          const SizedBox(height: 23),

          Row(
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
                      'Alerts 7 days & 24h prior',
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
                onChanged: (value) {
                  setState(() {
                    renewalReminders = value;
                  });
                },
              ),
            ],
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
                'ENCRYPTED',
                muted,
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(17),
            decoration: _softDecoration(radius: 26),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Primary Account ID',
                            style: TextStyle(
                              color: muted,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'alex.miller@design.studio',
                            style: TextStyle(
                              color: ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _smallButton(
                      icon: Icons.key_outlined,
                      text: 'Copy',
                      onTap: () => _message(
                        'Account ID copied.',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    setState(() {
                      passphraseVisible = !passphraseVisible;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    decoration: _softDecoration(radius: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          passphraseVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: muted,
                          size: 19,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          passphraseVisible
                              ? 'VaultPass#2025'
                              : 'Reveal Passphrase',
                          style: const TextStyle(
                            color: ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: 16),

                        const Icon(
                          Icons.shield_outlined,
                          color: muted,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: _softDecoration(radius: 25),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: danger,
                      size: 23,
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'adobe_annual_terms_2024.pdf',
                            style: TextStyle(
                              color: ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Signed Nov 2024 · 1.4 MB',
                            style: TextStyle(
                              color: muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _circleButton(
                      icon: Icons.download_outlined,
                      size: 42,
                      onTap: () => _message(
                        'Terms document download selected.',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () => _message(
                    'AI terms explanation selected.',
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    decoration: _softDecoration(radius: 25),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          color: purple2,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Explain Terms with AI',
                          style: TextStyle(
                            color: purple2,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  'CANCELLATION PROTOCOL',
                  style: TextStyle(
                    color: Color(0xFF55576E),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .3,
                  ),
                ),
              ),

              Text(
                '3 Steps',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: _softDecoration(radius: 27),
            child: const Column(
              children: [
                _CancellationStep(
                  number: '1',
                  children: [
                    TextSpan(
                      text: 'Navigate to ',
                    ),
                    TextSpan(
                      text: 'account.adobe.com/plans',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' and log in.',
                    ),
                  ],
                ),

                SizedBox(height: 17),

                _CancellationStep(
                  number: '2',
                  children: [
                    TextSpan(
                      text: 'Choose ',
                    ),
                    TextSpan(
                      text: 'Manage Plan',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ', then click ',
                    ),
                    TextSpan(
                      text: 'Cancel your plan.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 17),

                _CancellationStep(
                  number: '3',
                  children: [
                    TextSpan(
                      text:
                          'Review fee penalty warning on step 3. Decline retention discounts.',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => _message(
              'Opening direct cancellation portal.',
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              decoration: _softDecoration(radius: 28),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Open Direct Cancellation Portal',
                    style: TextStyle(
                      color: purple,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(width: 9),

                  Icon(
                    Icons.north_east,
                    color: purple,
                    size: 17,
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
  // CANCELLATION EVIDENCE
  // ============================================================

  Widget _buildCancellationEvidence() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Cancellation Evidence',
                  style: TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              _badge(
                'Pending',
                muted,
              ),
            ],
          ),

          const SizedBox(height: 17),

          InkWell(
            borderRadius: BorderRadius.circular(27),
            onTap: () => _message(
              'Upload proof of cancellation selected.',
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 16,
              ),
              decoration: _softDecoration(radius: 27),
              child: Column(
                children: [
                  _circleIcon(
                    Icons.cloud_upload_outlined,
                    color: purple,
                    size: 46,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Upload Proof of Cancellation',
                    style: TextStyle(
                      color: ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Attach confirmation email snapshot or PDF',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
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

  Widget _infoBox({
    required IconData icon,
    required String label,
    required String title,
    required String subtitle,
    IconData? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _softDecoration(radius: 27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: muted,
                size: 16,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ),

              if (trailing != null)
                Icon(
                  trailing,
                  color: muted,
                  size: 17,
                ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
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

  Widget _smallButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 10,
        ),
        decoration: _softDecoration(radius: 22),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: purple,
              size: 17,
            ),

            const SizedBox(width: 6),

            Text(
              text,
              style: const TextStyle(
                color: purple,
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
        color: Colors.white.withOpacity(.9),
        offset: const Offset(-4, -4),
        blurRadius: 10,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(.065),
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
                color: Colors.black.withOpacity(.05),
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