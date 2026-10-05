import 'package:flutter/material.dart';
import 'document_pack_export_screen.dart';

class DocumentPackGapsScreen extends StatefulWidget {
  const DocumentPackGapsScreen({super.key});

  @override
  State<DocumentPackGapsScreen> createState() =>
      _DocumentPackGapsScreenState();
}

class _DocumentPackGapsScreenState
    extends State<DocumentPackGapsScreen> {
  static const background = Color(0xFFE9EBF2);
  static const card = Color(0xFFEEF0F6);
  static const purple = Color(0xFF6667FF);
  static const ink = Color(0xFF303344);
  static const muted = Color(0xFF707383);
  static const orange = Color(0xFFFF9800);
  static const red = Color(0xFFFF3B62);
  static const green = Color(0xFF00A978);

  bool accommodationResolved = false;
  bool bankResolved = false;

  bool get allResolved =>
      accommodationResolved && bankResolved;

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
                  _header(),
                  const SizedBox(height: 18),
                  _progress(),
                  const SizedBox(height: 28),

                  const Text(
                    'Resolve Remaining Gaps',
                    style: TextStyle(
                      color: ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Review uncertain matches and provide any missing documents before creating the pack.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _accommodationGap(),

                  const SizedBox(height: 20),

                  _bankGap(),

                  const SizedBox(height: 24),

                  _readiness(),

                  const SizedBox(height: 24),

                  _continue(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
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
                '● Step 3 of 4',
                style: TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                'Resolve Gaps',
                style: TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              _completedStep('✓', 'Requisite'),
              _line(true),
              _completedStep('✓', 'Matches'),
              _line(true),
              _activeStep('3', 'Gaps'),
              _line(false),
              _inactiveStep('4', 'Export'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _accommodationGap() {
    final resolved = accommodationResolved;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(30),
        border: Border(
          left: BorderSide(
            color: resolved ? green : orange,
            width: 6,
          ),
        ),
        boxShadow: _shadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _status(
                resolved ? '● Resolved' : '● Needs Review',
                resolved ? green : orange,
              ),
            ],
          ),

          const SizedBox(height: 20),

          _document(
            'Apartment Lease Agreement 2025.pdf',
            'Current Vault match',
          ),

          const SizedBox(height: 16),

          if (!resolved)
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
                    Icons.warning_amber_rounded,
                    color: orange,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'The lease renewal date may not cover the requested visa return date.',
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

          if (!resolved) const SizedBox(height: 18),

          if (!resolved)
            Row(
              children: [
                Expanded(
                  child: _button(
                    Icons.swap_horiz,
                    'Choose Different',
                    () {
                      _message(
                        'This will display existing Vault records.',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _button(
                    Icons.check_circle_outline,
                    'Confirm',
                    () {
                      setState(() {
                        accommodationResolved = true;
                      });
                    },
                    color: purple,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _bankGap() {
    final resolved = bankResolved;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(30),
        border: Border(
          left: BorderSide(
            color: resolved ? green : red,
            width: 6,
          ),
        ),
        boxShadow: _shadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _status(
                resolved ? '● Resolved' : '● Missing',
                resolved ? green : red,
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (!resolved)
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
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No Vault document currently satisfies the required 90-day statement period.',
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

          if (resolved)
            _document(
              'Bank_Statement_Jan_2025.pdf',
              'Added to Vault',
            ),

          const SizedBox(height: 18),

          if (!resolved) ...[
            _wideButton(
              Icons.search,
              'Search Vault Again',
              () {
                _message(
                  'This will search the user\'s current Vault records.',
                );
              },
            ),

            const SizedBox(height: 12),

            _wideButton(
              Icons.add_rounded,
              'Add Missing Document',
              () {
                // Demo behaviour.
                //
                // Later this button will open AddRecordScreen.
                // When that record is saved, return here and
                // refresh the shared Vault data source.

                setState(() {
                  bankResolved = true;
                });

                _message(
                  'Demo bank statement added. Later this will use Add Record.',
                );
              },
              color: purple,
            ),
          ],
        ],
      ),
    );
  }

  Widget _readiness() {
    final resolvedCount =
        2 +
        (accommodationResolved ? 1 : 0) +
        (bankResolved ? 1 : 0);

    return _surface(
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: resolvedCount / 4,
                  strokeWidth: 6,
                  color: allResolved ? green : purple,
                  backgroundColor: const Color(0xFFD5D7E0),
                ),
                Text(
                  '$resolvedCount/4',
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allResolved
                      ? 'All Requirements Satisfied'
                      : '$resolvedCount of 4 Requirements Ready',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  allResolved
                      ? 'Your document pack is ready for final review.'
                      : '${4 - resolvedCount} item(s) still require attention.',
                  style: const TextStyle(
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

  Widget _continue() {
    return Opacity(
      opacity: allResolved ? 1 : .45,
      child: InkWell(
        onTap: allResolved
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const DocumentPackExportScreen(),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F1F6),
            borderRadius: BorderRadius.circular(30),
            boxShadow: _shadow(),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue to Export',
                style: TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              SizedBox(width: 9),
              Icon(
                Icons.arrow_forward_rounded,
                color: purple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _document(
    String title,
    String subtitle,
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
          const Icon(
            Icons.description_outlined,
            color: purple,
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
        ],
      ),
    );
  }

  Widget _button(
    IconData icon,
    String text,
    VoidCallback onTap, {
    Color color = ink,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F6),
          borderRadius: BorderRadius.circular(25),
          boxShadow: _shadow(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wideButton(
    IconData icon,
    String text,
    VoidCallback onTap, {
    Color color = purple,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(27),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F6),
          borderRadius: BorderRadius.circular(27),
          boxShadow: _shadow(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _status(String text, Color color) {
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
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _surface({required Widget child}) {
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

  Widget _circle(
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

  Widget _completedStep(
    String number,
    String label,
  ) {
    return Expanded(
      child: _step(number, label, true, false),
    );
  }

  Widget _activeStep(
    String number,
    String label,
  ) {
    return Expanded(
      child: _step(number, label, true, true),
    );
  }

  Widget _inactiveStep(
    String number,
    String label,
  ) {
    return Expanded(
      child: _step(number, label, false, false),
    );
  }

  Widget _step(
    String number,
    String label,
    bool completed,
    bool active,
  ) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? purple
                : const Color(0xFFF1F2F7),
            boxShadow: _shadow(),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : completed
                      ? purple
                      : muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: active || completed ? purple : muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _line(bool active) {
    return Container(
      width: 18,
      height: 3,
      color: active ? purple : const Color(0xFFD7D9E4),
    );
  }

  List<BoxShadow> _shadow() {
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

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}