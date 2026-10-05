import 'package:flutter/material.dart';
import 'subscriptions_screen.dart';

class AISubscriptionCheckupScreen extends StatefulWidget {
  const AISubscriptionCheckupScreen({super.key});

  @override
  State<AISubscriptionCheckupScreen> createState() =>
      _AISubscriptionCheckupScreenState();
}

class _AISubscriptionCheckupScreenState
    extends State<AISubscriptionCheckupScreen> {
  static const Color bg = Color(0xFFF9F7FF);
  static const Color surface = Color(0xFFFBF9FF);
  static const Color ink = Color(0xFF292B43);
  static const Color muted = Color(0xFF6F7185);
  static const Color purple = Color(0xFF5E5BFF);
  static const Color purple2 = Color(0xFF7C35FF);
  static const Color danger = Color(0xFFCE334B);

  bool chatGPTSelected = true;
  bool adobeSelected = true;
  bool hboSelected = false;

  int get selectedCount {
    int count = 0;

    if (chatGPTSelected) count++;
    if (adobeSelected) count++;
    if (hboSelected) count++;

    return count;
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

                  const SizedBox(height: 25),

                  _buildAuditSummary(),

                  const SizedBox(height: 30),

                  _buildRecommendationsHeader(),

                  const SizedBox(height: 17),

                  _buildChatGPTRecommendation(),

                  const SizedBox(height: 17),

                  _buildAdobeRecommendation(),

                  const SizedBox(height: 17),

                  _buildHBORecommendation(),

                  const SizedBox(height: 20),

                  _buildAnnualizedImpact(),

                  const SizedBox(height: 22),

                  _buildBottomActions(),
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
        onTap: () {
          Navigator.pop(context);
        },
      ),

      const SizedBox(width: 14),

      const Expanded(
        child: Text(
          'AI Subscription Checkup',
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
  // AUDIT SUMMARY
  // ============================================================

  Widget _buildAuditSummary() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _statusPill(
                  icon: Icons.auto_awesome,
                  text: 'Smart Audit Live · Updated 14m ago',
                  color: purple,
                ),
              ),

              const SizedBox(width: 10),

              _statusPill(
                icon: Icons.circle,
                text: '3\nActionable',
                color: purple,
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'Potential Monthly Savings',
            style: TextStyle(
              color: Color(0xFF56586F),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 5),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '\$48.98',
                style: TextStyle(
                  color: ink,
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.8,
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(
                  left: 3,
                  bottom: 5,
                ),
                child: Text(
                  '/mo',
                  style: TextStyle(
                    color: muted,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                margin: const EdgeInsets.only(bottom: 3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEAFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+\$587.76 / yr',
                  style: TextStyle(
                    color: purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Row(
            children: [
              Text(
                'Portfolio Health:',
                style: TextStyle(
                  color: Color(0xFF55576E),
                  fontSize: 12,
                ),
              ),

              Spacer(),

              Text(
                '73% Optimized',
                style: TextStyle(
                  color: purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: .73,
              minHeight: 6,
              backgroundColor: const Color(0xFFEAE9F1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                purple2,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.shield_outlined,
                color: purple,
                size: 17,
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Computed locally from your logged subscriptions & '
                  'usage ratings. Stored with zero-knowledge encryption.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10.5,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: _summaryBox(
                  label: 'Est. Savings',
                  value: '\$48.98',
                  footer: 'Monthly',
                  valueColor: purple,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _summaryBox(
                  label: 'Flagged',
                  value: '3 of 11',
                  footer: '27% Total',
                  valueColor: ink,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _summaryBox(
                  label: 'Trials Due',
                  value: '1 Expiring',
                  footer: 'In 3 days',
                  valueColor: danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryBox({
    required String label,
    required String value,
    required String footer,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 14,
      ),
      decoration: _softDecoration(radius: 24),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 9.5,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            footer,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECOMMENDATIONS HEADER
  // ============================================================

  Widget _buildRecommendationsHeader() {
    return Row(
      children: [
        const Text(
          'AI RECOMMENDATIONS',
          style: TextStyle(
            color: ink,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: .2,
          ),
        ),

        const SizedBox(width: 7),

        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFF0EEFF),
            shape: BoxShape.circle,
          ),
          child: const Text(
            '3',
            style: TextStyle(
              color: purple,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const Spacer(),

        InkWell(
          onTap: () {
            setState(() {
              chatGPTSelected = true;
              adobeSelected = true;
              hboSelected = true;
            });
          },
          child: const Text(
            'Select Recommended',
            style: TextStyle(
              color: purple,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CHATGPT RECOMMENDATION
  // ============================================================

  Widget _buildChatGPTRecommendation() {
    return _recommendationCard(
      selected: chatGPTSelected,
      onSelect: () {
        setState(() {
          chatGPTSelected = !chatGPTSelected;
        });
      },
      title: 'ChatGPT Plus & Claude Pro',
      subtitle: '\$20.00/mo each · Overlapping Tools',
      saving: 'Save +\$20.00/mo',
      description:
          'Redundant functional coverage. Your notes show regular '
          'Claude Pro usage and rare ChatGPT usage.',
      firstButtonText: 'Cancel ChatGPT',
      firstButtonIcon: Icons.cancel_outlined,
      firstButtonColor: purple,
      firstButtonAction: () {
        _message('ChatGPT cancellation selected.');
      },
      secondButtonText: 'Keep Both',
      secondButtonAction: () {
        _message('Keeping both subscriptions.');
      },
    );
  }

  // ============================================================
  // ADOBE RECOMMENDATION
  // ============================================================

  Widget _buildAdobeRecommendation() {
    return _recommendationCard(
      selected: adobeSelected,
      onSelect: () {
        setState(() {
          adobeSelected = !adobeSelected;
        });
      },
      title: 'Adobe Creative Cloud',
      subtitle: '\$54.99/mo · Rarely Used',
      saving: 'Save +\$54.99/mo',
      description:
          'Usage dropped to rarely used across the last 2 '
          'billing cycles after moving to Figma.',
      firstButtonText: 'Guided Cancellation',
      firstButtonIcon: Icons.open_in_new,
      firstButtonColor: purple,
      firstButtonAction: () {
        _message('Adobe guided cancellation selected.');
      },
      secondButtonText: 'Pause 60 Days',
      secondButtonAction: () {
        _message('Adobe pause selected.');
      },
    );
  }

  // ============================================================
  // HBO RECOMMENDATION
  // ============================================================

  Widget _buildHBORecommendation() {
    return _recommendationCard(
      selected: hboSelected,
      onSelect: () {
        setState(() {
          hboSelected = !hboSelected;
        });
      },
      title: 'HBO Max Entertainment',
      subtitle: '\$15.99/mo · Free Trial Ending',
      saving: '3 Days Left',
      savingDanger: true,
      description:
          '7-day zero-cost trial ends Nov 15. Recurring billing '
          'will trigger automatically.',
      firstButtonText: 'Cancel Trial Now',
      firstButtonIcon: Icons.notifications_off_outlined,
      firstButtonColor: danger,
      firstButtonAction: () {
        _message('HBO trial cancellation selected.');
      },
      secondButtonText: 'Keep Subscription',
      secondButtonAction: () {
        _message('HBO subscription kept.');
      },
    );
  }

  // ============================================================
  // RECOMMENDATION CARD
  // ============================================================

  Widget _recommendationCard({
    required bool selected,
    required VoidCallback onSelect,
    required String title,
    required String subtitle,
    required String saving,
    required String description,
    required String firstButtonText,
    required IconData firstButtonIcon,
    required Color firstButtonColor,
    required VoidCallback firstButtonAction,
    required String secondButtonText,
    required VoidCallback secondButtonAction,
    bool savingDanger = false,
  }) {
    return _card(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onSelect,
                borderRadius: BorderRadius.circular(30),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: selected
                        ? purple
                        : const Color(0xFFF2F1F7),
                    shape: BoxShape.circle,
                    boxShadow: _shadow(),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 17,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 7),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: savingDanger
                      ? const Color(0xFFFFE9EE)
                      : const Color(0xFFECEAFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  saving,
                  style: TextStyle(
                    color: savingDanger ? danger : purple,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Padding(
            padding: const EdgeInsets.only(left: 39),
            child: Text(
              description,
              style: const TextStyle(
                color: muted,
                fontSize: 11,
                height: 1.55,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Padding(
            padding: const EdgeInsets.only(left: 39),
            child: Row(
              children: [
                Expanded(
                  child: _recommendationButton(
                    icon: firstButtonIcon,
                    text: firstButtonText,
                    color: firstButtonColor,
                    onTap: firstButtonAction,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _recommendationButton(
                    text: secondButtonText,
                    color: ink,
                    onTap: secondButtonAction,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendationButton({
    IconData? icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 11,
        ),
        decoration: _softDecoration(radius: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
            ],

            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ANNUALIZED IMPACT
  // ============================================================

  Widget _buildAnnualizedImpact() {
    return _card(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      child: Row(
        children: [
          _circleIcon(
            Icons.trending_up,
            color: purple,
            size: 42,
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Annualized Impact',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '\$899.88 / yr',
                  style: TextStyle(
                    color: ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Max potential',
                style: TextStyle(
                  color: muted,
                  fontSize: 9,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '\$1,091.76 / yr',
                style: TextStyle(
                  color: purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM ACTIONS
  // ============================================================

  Widget _buildBottomActions() {
    return _card(
      padding: const EdgeInsets.all(17),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$selectedCount recommendations selected',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10.5,
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  _message('AI checkup report exported.');
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.download_outlined,
                      color: purple,
                      size: 16,
                    ),

                    SizedBox(width: 6),

                    Text(
                      'Export Report',
                      style: TextStyle(
                        color: purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          InkWell(
            onTap: selectedCount == 0
                ? null
                : () {
                    _showApplyDialog();
                  },
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFAFF),
                borderRadius: BorderRadius.circular(28),
                boxShadow: _shadow(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bolt,
                    color: selectedCount == 0
                        ? muted
                        : purple,
                    size: 19,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'Apply Selected Actions ($selectedCount)',
                    style: TextStyle(
                      color: selectedCount == 0
                          ? muted
                          : purple,
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
  // REUSABLE
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

  Widget _statusPill({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: _softDecoration(radius: 22),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 15,
          ),

          const SizedBox(width: 6),

          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                height: 1.2,
              ),
            ),
          ),
        ],
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

  void _showApplyDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surface,
          title: const Text(
            'Apply Selected Actions?',
            style: TextStyle(
              color: ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'You selected $selectedCount recommendation'
            '${selectedCount == 1 ? '' : 's'}.',
            style: const TextStyle(
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

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => const SubscriptionsScreen(),
    ),
    (route) => route.isFirst,
  );
},
              child: const Text(
                'Apply',
                style: TextStyle(
                  color: purple,
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