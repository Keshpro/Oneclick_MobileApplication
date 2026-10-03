import 'package:flutter/material.dart';

class ExplainDocumentScreen extends StatefulWidget {
  const ExplainDocumentScreen({super.key});

  @override
  State<ExplainDocumentScreen> createState() =>
      _ExplainDocumentScreenState();
}

class _ExplainDocumentScreenState extends State<ExplainDocumentScreen> {
  static const Color background = Color(0xFFE9EBF2);
  static const Color card = Color(0xFFEEF0F6);
  static const Color purple = Color(0xFF6667FF);
  static const Color ink = Color(0xFF303344);
  static const Color muted = Color(0xFF707383);
  static const Color red = Color(0xFFFF3B3B);

  final TextEditingController _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 50),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 18),

                  _buildOriginalDocument(),

                  const SizedBox(height: 18),

                  _buildAIStatus(),

                  const SizedBox(height: 28),

                  _buildSummary(),

                  const SizedBox(height: 30),

                  _buildCriticalDates(),

                  const SizedBox(height: 30),

                  _buildFeesAndCancellation(),

                  const SizedBox(height: 30),

                  _buildReferences(),

                  const SizedBox(height: 28),

                  _buildFollowUp(),

                  const SizedBox(height: 26),

                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Row(
      children: [
        _circleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Explain This Document',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _circleButton(
          icon: Icons.more_vert,
          onTap: () {
            _showMessage('More explanation options will be connected later.');
          },
        ),
        const SizedBox(width: 10),
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: purple,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ORIGINAL DOCUMENT
  // =========================================================

  Widget _buildOriginalDocument() {
    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORIGINAL DOCUMENT',
            style: TextStyle(
              color: purple,
              fontSize: 13,
              letterSpacing: .8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF1F2F7),
                  boxShadow: _smallShadow(),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: purple,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apartment Lease Agreement',
                      style: TextStyle(
                        color: ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'PDF  •  14 Pages  •  Scanned',
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: muted,
                ),
                label: const Text(
                  'View PDF',
                  style: TextStyle(
                    color: muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // AI STATUS
  // =========================================================

  Widget _buildAIStatus() {
    return _surface(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      child: const Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: purple,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI Explanation',
              style: TextStyle(
                color: ink,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            'Generated from this document',
            style: TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SUMMARY
  // =========================================================

  Widget _buildSummary() {
    return _surface(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: purple,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Plain-Language Summary',
                  style: TextStyle(
                    color: ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Padding(
            padding: EdgeInsets.only(left: 34),
            child: Text(
              'AI-generated explanation kept separate from the original document.',
              style: TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 22),

          _summaryItem(
            icon: Icons.calendar_month_outlined,
            child: const Text.rich(
              TextSpan(
                style: TextStyle(
                  color: ink,
                  fontSize: 15,
                  height: 1.65,
                ),
                children: [
                  TextSpan(
                    text: '12-month fixed tenancy ',
                    style: TextStyle(
                      color: purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text:
                        'starting Nov 01, 2024 through Oct 31, 2025. '
                        'Standard automatic renewal applies unless written '
                        'notice is submitted.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          _summaryItem(
            icon: Icons.payments_outlined,
            child: const Text.rich(
              TextSpan(
                style: TextStyle(
                  color: ink,
                  fontSize: 15,
                  height: 1.65,
                ),
                children: [
                  TextSpan(text: 'Rent is '),
                  TextSpan(
                    text: '\$2,350.00/month',
                    style: TextStyle(
                      color: purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' due on the 1st with a ',
                  ),
                  TextSpan(
                    text: '5-day grace period',
                    style: TextStyle(
                      color: purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' before late penalties apply.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          _summaryItem(
            icon: Icons.water_drop_outlined,
            child: const Text.rich(
              TextSpan(
                style: TextStyle(
                  color: ink,
                  fontSize: 15,
                  height: 1.65,
                ),
                children: [
                  TextSpan(
                    text: 'Water and trash collection ',
                    style: TextStyle(
                      color: purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text:
                        'are included. Electricity and high-speed internet '
                        'are the tenant\'s responsibility.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F6),
        borderRadius: BorderRadius.circular(26),
        boxShadow: _smallShadow(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: purple,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(child: child),
        ],
      ),
    );
  }

  // =========================================================
  // IMPORTANT DATES
  // =========================================================

  Widget _buildCriticalDates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: purple,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Important Dates & Deadlines',
                style: TextStyle(
                  color: ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '3 Detected',
              style: TextStyle(
                color: muted,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _dateCard(
          month: 'AUG',
          day: '31',
          title: 'Notice of Non-Renewal',
          subtitle: 'Written notice deadline',
          tag: '60 Days Prior',
          action: 'Alert Set',
        ),

        const SizedBox(height: 14),

        _dateCard(
          month: 'OCT',
          day: '15',
          title: 'Inspection Window',
          subtitle: 'Oct 15–20, 2025 • Final scheduled inspection',
          tag: '',
          action: 'Pending',
        ),

        const SizedBox(height: 14),

        _dateCard(
          month: 'OCT',
          day: '31',
          title: 'Lease Expiration',
          subtitle: 'Oct 31, 2025 • Keys surrendered',
          tag: '',
          action: 'Terminal',
          danger: true,
        ),
      ],
    );
  }

  Widget _dateCard({
    required String month,
    required String day,
    required String title,
    required String subtitle,
    required String tag,
    required String action,
    bool danger = false,
  }) {
    return _surface(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F2F7),
              boxShadow: _smallShadow(),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    color: danger ? red : purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  day,
                  style: TextStyle(
                    color: danger ? red : purple,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 5,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (tag.isNotEmpty)
                      Text(
                        tag,
                        style: const TextStyle(
                          color: purple,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F7),
              borderRadius: BorderRadius.circular(20),
              boxShadow: _smallShadow(),
            ),
            child: Text(
              action,
              style: TextStyle(
                color: danger ? red : purple,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FEES / CANCELLATION
  // =========================================================

  Widget _buildFeesAndCancellation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: purple,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Fees, Conditions & Cancellation',
                style: TextStyle(
                  color: ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '3 Clauses',
              style: TextStyle(
                color: muted,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _surface(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: red,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Early Termination',
                      style: TextStyle(
                        color: ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '\$4,700 Penalty',
                    style: TextStyle(
                      color: red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F1F6),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: _smallShadow(),
                ),
                child: const Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: muted,
                      fontSize: 14,
                      height: 1.6,
                    ),
                    children: [
                      TextSpan(text: 'Requires '),
                      TextSpan(
                        text: '2 months base rent (\$4,700)',
                        style: TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ' plus a minimum of ',
                      ),
                      TextSpan(
                        text: '30 days advance written notice',
                        style: TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ' to the property manager.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Source: Page 11 • Section 18.2',
                style: TextStyle(
                  color: purple,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _feeCard(
                icon: Icons.savings_outlined,
                title: 'Security Deposit',
                value: '\$2,350',
                description:
                    'Returnable within 21 days after move-out, minus verified repair damages.',
                source: 'Section 6.1',
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _feeCard(
                icon: Icons.schedule,
                title: 'Late Surcharge',
                value: '\$75.00',
                description:
                    'Applied after 11:59 PM on the 5th calendar day of each billing cycle.',
                source: 'Section 4.3',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _feeCard({
    required IconData icon,
    required String title,
    required String value,
    required String description,
    required String source,
  }) {
    return _surface(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: purple,
            size: 21,
          ),

          const SizedBox(height: 9),

          Text(
            title,
            style: const TextStyle(
              color: purple,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              color: ink,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            description,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            source,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // REFERENCES
  // =========================================================

  Widget _buildReferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.format_quote_rounded,
              color: purple,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Original Text References',
                style: TextStyle(
                  color: ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              'Source-linked',
              style: TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _referenceCard(
          title: 'Section 18.2 — Lessee Termination Rights',
          subtitle: 'Page 11 • Lines 14–22',
          page: '11',
        ),

        const SizedBox(height: 14),

        _referenceCard(
          title: 'Section 7.4 — Subletting and Guest Restrictions',
          subtitle: 'Page 5 • Lines 03–11',
          page: '5',
        ),
      ],
    );
  }

  Widget _referenceCard({
    required String title,
    required String subtitle,
    required String page,
  }) {
    return InkWell(
      onTap: () {
        _showMessage('Opening original document at page $page.');
      },
      borderRadius: BorderRadius.circular(28),
      child: _surface(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(
              Icons.menu_book_outlined,
              color: purple,
            ),

            const SizedBox(width: 14),

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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2F7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Page $page',
                style: const TextStyle(
                  color: purple,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(width: 5),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: muted,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // FOLLOW-UP QUESTION
  // =========================================================

  Widget _buildFollowUp() {
    return _surface(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.chat_outlined,
                color: purple,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ask Follow-up Question',
                  style: TextStyle(
                    color: ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Document Scoped',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F6),
              borderRadius: BorderRadius.circular(28),
              boxShadow: _smallShadow(),
            ),
            child: TextField(
              controller: _questionController,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ask a specific question about this document...',
                hintStyle: const TextStyle(
                  color: muted,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(
                  18,
                  16,
                  8,
                  16,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(5),
                  child: InkWell(
                    onTap: _askQuestion,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: purple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _suggestionChip('Can I paint the walls?'),
              _suggestionChip('What is the guest stay limit?'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suggestionChip(String text) {
    return InkWell(
      onTap: () {
        setState(() {
          _questionController.text = text;
        });
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F7),
          borderRadius: BorderRadius.circular(22),
          boxShadow: _smallShadow(),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: ink,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _askQuestion() {
    final question = _questionController.text.trim();

    if (question.isEmpty) {
      _showMessage('Enter a question first.');
      return;
    }

    _showMessage(
      'AI follow-up answers will be connected to the document later.',
    );
  }

  // =========================================================
  // BOTTOM ACTIONS
  // =========================================================

  Widget _buildBottomActions() {
    return Column(
      children: [
        _largeButton(
          icon: Icons.bookmark_add_outlined,
          text: 'Save Explanation to Vault Notes',
          color: purple,
          onTap: () {
            _showMessage(
              'Explanation saved to Vault Notes for this demo.',
            );
          },
        ),

        const SizedBox(height: 16),

        _largeButton(
          icon: Icons.ios_share_outlined,
          text: 'Share Explanation',
          color: ink,
          onTap: () {
            _showMessage(
              'Explanation sharing will be connected later.',
            );
          },
        ),
      ],
    );
  }

  Widget _largeButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F6),
          borderRadius: BorderRadius.circular(30),
          boxShadow: _smallShadow(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 21,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // COMMON UI
  // =========================================================

  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.white70,
            offset: Offset(-5, -5),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Color(0xFFD0D2DC),
            offset: Offset(5, 5),
            blurRadius: 14,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF0F1F6),
          boxShadow: _smallShadow(),
        ),
        child: Icon(
          icon,
          color: ink,
          size: 24,
        ),
      ),
    );
  }

  List<BoxShadow> _smallShadow() {
    return const [
      BoxShadow(
        color: Colors.white70,
        offset: Offset(-3, -3),
        blurRadius: 8,
      ),
      BoxShadow(
        color: Color(0xFFD5D7E0),
        offset: Offset(4, 4),
        blurRadius: 9,
      ),
    ];
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}