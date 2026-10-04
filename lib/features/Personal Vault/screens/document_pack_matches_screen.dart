import 'package:flutter/material.dart';
import 'document_pack_gaps_screen.dart';

class DocumentPackMatchesScreen extends StatelessWidget {
  const DocumentPackMatchesScreen({super.key});

  static const background = Color(0xFFE9EBF2);
  static const card = Color(0xFFEEF0F6);
  static const purple = Color(0xFF6667FF);
  static const ink = Color(0xFF303344);
  static const muted = Color(0xFF707383);
  static const green = Color(0xFF00A978);
  static const orange = Color(0xFFFF9800);
  static const red = Color(0xFFFF3B62);

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
                  _header(context),
                  const SizedBox(height: 18),
                  _progress(),
                  const SizedBox(height: 28),
                  _configuration(),
                  const SizedBox(height: 28),

                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'CHECKLIST VALIDATION (4 ITEMS)',
                          style: TextStyle(
                            color: muted,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.auto_awesome,
                        color: purple,
                        size: 17,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'AI Paired',
                        style: TextStyle(
                          color: purple,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _matchedCard(
                    context,
                    icon: Icons.badge_outlined,
                    requirement: 'Valid Passport (Biometric)',
                    file: 'US_Passport_2030.pdf',
                    note: 'Extracted expiry: Aug 2030',
                  ),

                  const SizedBox(height: 18),

                  _reviewCard(context),

                  const SizedBox(height: 18),

                  _matchedCard(
                    context,
                    icon: Icons.health_and_safety_outlined,
                    requirement: 'Travel Health Insurance',
                    file: 'International_Health_Policy_2025.pdf',
                    note: 'Meets €30,000 threshold',
                  ),

                  const SizedBox(height: 18),

                  _missingCard(context),

                  const SizedBox(height: 24),

                  _summary(),

                  const SizedBox(height: 24),

                  _continue(context),

                  const SizedBox(height: 20),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pack draft saved for this demo.'),
                          ),
                        );
                      },
                      child: const Text(
                        'Save Pack Draft & Exit',
                        style: TextStyle(color: muted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        _circle(
          Icons.arrow_back_ios_new_rounded,
          () => Navigator.pop(context),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Document Pack Builder',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _circle(Icons.more_vert, () {}),
        const SizedBox(width: 10),
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: purple,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _progress() {
    return _surface(
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                '● Step 2 of 4',
                style: TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                'Review Matches',
                style: TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _step(Icons.check, 'Requisite', true),
              _line(true),
              _stepText('2', 'Matches', true),
              _line(false),
              _stepText('3', 'Gaps', false),
              _line(false),
              _stepText('4', 'Export', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _configuration() {
    return _surface(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_copy_outlined,
                color: purple,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PACK CONFIGURATION',
                      style: TextStyle(
                        color: purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Schengen Visa & Residency',
                      style: TextStyle(
                        color: ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.tune_rounded,
                color: muted,
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.attachment_rounded,
                color: purple,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: muted,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(text: 'Source: '),
                      TextSpan(
                        text: 'Uploaded Consulate Checklist.pdf',
                        style: TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _matchedCard(
    BuildContext context, {
    required IconData icon,
    required String requirement,
    required String file,
    required String note,
  }) {
    return _surface(
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  requirement,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              _status('● Matched', green),
            ],
          ),
          const SizedBox(height: 18),
          _fileBox(file, note, green),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _smallButton(
                Icons.visibility_outlined,
                'Preview',
                () => _message(context, 'Document preview will open here.'),
              ),
              const SizedBox(width: 10),
              _smallButton(
                Icons.swap_horiz_rounded,
                'Change',
                () => _message(
                  context,
                  'This will show existing Vault records.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(30),
        border: const Border(
          left: BorderSide(
            color: orange,
            width: 6,
          ),
        ),
        boxShadow: _shadow(),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.apartment_outlined,
                color: ink,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Proof of Accommodation',
                  style: TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              _status('● Needs Review', orange),
            ],
          ),
          const SizedBox(height: 18),
          _fileBox(
            'Apartment Lease Agreement 2025.pdf',
            'Suggested from Vault "Housing"',
            orange,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: orange,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lease renewal date is 2 months prior to the requested visa return date.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _smallButton(
                Icons.swap_horiz,
                'Replace',
                () => _message(
                  context,
                  'Existing Vault records will be shown here.',
                ),
              ),
              const SizedBox(width: 10),
              _smallButton(
                Icons.check_circle_outline,
                'Confirm Match',
                () => _message(
                  context,
                  'Match confirmed for this demo.',
                ),
                color: purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _missingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(30),
        border: const Border(
          left: BorderSide(
            color: red,
            width: 6,
          ),
        ),
        boxShadow: _shadow(),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                color: ink,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Bank Statement (Last 3 Months)',
                  style: TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              _status('● Missing', red),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  color: red,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No statements found in Vault matching the required 90-day window.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _wideButton(
            Icons.cloud_upload_outlined,
            '+ Upload Missing Document',
            () => _message(
              context,
              'This will connect to Add Record later.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary() {
    return _surface(
      child: const Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: .75,
                  strokeWidth: 6,
                  color: purple,
                  backgroundColor: Color(0xFFD5D7E0),
                ),
                Text(
                  '75%',
                  style: TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3 of 4 Documents Identified',
                  style: TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Review questionable matches and add missing documents.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _continue(BuildContext context) {
    return _wideButton(
      Icons.arrow_forward_rounded,
      'Continue to Gap Resolution',
      () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DocumentPackGapsScreen(),
          ),
        );
      },
    );
  }

  static Widget _status(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static Widget _fileBox(
    String title,
    String subtitle,
    Color iconColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
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
        ],
      ),
    );
  }

  static Widget _smallButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color color = ink,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F6),
          borderRadius: BorderRadius.circular(24),
          boxShadow: _shadow(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _wideButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F6),
          borderRadius: BorderRadius.circular(30),
          boxShadow: _shadow(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: purple,
              size: 20,
            ),
            const SizedBox(width: 9),
            Text(
              label,
              style: const TextStyle(
                color: purple,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _surface({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _shadow(),
      ),
      child: child,
    );
  }

  static Widget _circle(
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F6),
          shape: BoxShape.circle,
          boxShadow: _shadow(),
        ),
        child: Icon(icon, color: ink),
      ),
    );
  }

  static Widget _step(
    IconData icon,
    String label,
    bool active,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F2F7),
              boxShadow: _shadow(),
            ),
            child: Icon(
              icon,
              color: active ? purple : muted,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? purple : muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _stepText(
    String number,
    String label,
    bool active,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? purple : const Color(0xFFF1F2F7),
              boxShadow: _shadow(),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: active ? Colors.white : muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? purple : muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _line(bool active) {
    return Container(
      width: 18,
      height: 3,
      color: active ? purple : const Color(0xFFD7D9E4),
    );
  }

  static List<BoxShadow> _shadow() {
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

  static void _message(
    BuildContext context,
    String text,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}