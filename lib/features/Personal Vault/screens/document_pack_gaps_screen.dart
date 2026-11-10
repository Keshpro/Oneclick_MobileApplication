import 'package:flutter/material.dart';
import 'document_pack_export_screen.dart';
import 'document_pack_home_screen.dart';
import '../services/document_pack_service.dart';
import '../models/document_pack.dart';

class DocumentPackGapsScreen extends StatefulWidget {
  const DocumentPackGapsScreen({
    super.key,
    required this.pack,
  });

  final DocumentPack pack;

  @override
  State<DocumentPackGapsScreen> createState() =>
      _DocumentPackGapsScreenState();
}

class _DocumentPackGapsScreenState
    extends State<DocumentPackGapsScreen> {
  static const background = Color(0xFFF5F3F2);
  static const card = Color(0xFFFFFDFC);
  static const purple = Color(0xFF725763);
  static const ink = Color(0xFF302B31);
  static const muted = Color(0xFF776F77);
  static const orange = Color(0xFFBA8754);
  static const red = Color(0xFFB96C75);
  static const green = Color(0xFF47866D);

  bool _savingDraft = false;
  bool accommodationResolved = false;
bool bankResolved = false;

bool get allResolved =>
    widget.pack.totalRequirements > 0 &&
    widget.pack.missingRequirements == 0;

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
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Review uncertain matches and provide any missing documents before creating the pack.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (widget.pack.missingRequirements == 0)
                    _allMatchedCard()
                  else
                    for (final requirement in widget.pack.requirements)
                      if (!requirement.isMatched) ...[
                        _actualGapCard(requirement.name),
                        const SizedBox(height: 20),
                      ],

                  const SizedBox(height: 24),

                  _readiness(),

                  const SizedBox(height: 24),

                  _continue(),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _savingDraft ? null : _saveDraftAndExit,
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

  Future<void> _saveDraftAndExit() async {
    if (_savingDraft) return;
    setState(() => _savingDraft = true);
    try {
      await DocumentPackService().savePack(widget.pack);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DocumentPackHomeScreen()),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save pack: $error')),
      );
    } finally {
      if (mounted) setState(() => _savingDraft = false);
    }
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
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
                'Step 3 of 4',
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

  Widget _allMatchedCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(30),
      border: const Border(
        left: BorderSide(color: green, width: 6),
      ),
      boxShadow: _shadow(),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, color: green, size: 32),
        SizedBox(height: 14),
        Text(
          'All Requirements Matched',
          style: TextStyle(
            color: ink,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Every checklist requirement has a confirmed Vault record. '
          'You can continue to review your document pack.',
          style: TextStyle(
            color: muted,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

Widget _actualGapCard(String requirementName) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(30),
      border: const Border(
        left: BorderSide(color: orange, width: 6),
      ),
      boxShadow: _shadow(),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description_outlined, color: ink),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                requirementName,
                style: const TextStyle(
                  color: ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _gapStatus(),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'No Vault document has been confirmed for this requirement.',
          style: TextStyle(
            color: muted,
            fontSize: 12,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Return to Matches'),
        ),
      ],
    ),
  );
}

Widget _gapStatus() {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F3F4),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Text(
      'Not Matched',
      style: TextStyle(
        color: orange,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
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
                resolved ? 'Resolved' : 'Needs Review',
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
                color: const Color(0xFFF7F3F4),
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
                resolved ? 'Resolved' : 'Missing',
                resolved ? green : red,
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (!resolved)
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F3F4),
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
  final total = widget.pack.totalRequirements;
  final matched = widget.pack.matchedRequirements;
  final remaining = widget.pack.missingRequirements;

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
                value: total == 0 ? 0 : matched / total,
                strokeWidth: 6,
                color: allResolved ? green : purple,
                backgroundColor: const Color(0xFFE5DADF),
              ),
              Text(
                '$matched/$total',
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
                    ? 'All Requirements Matched'
                    : '$matched of $total Requirements Matched',
                style: const TextStyle(
                  color: ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                allResolved
                    ? 'All requirements have confirmed Vault records.'
                    : '$remaining requirement(s) still need a confirmed document.',
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

  Widget _continue() {
    return Opacity(
      opacity: allResolved ? 1 : .45,
      child: InkWell(
        onTap: allResolved
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DocumentPackExportScreen(
                      pack: widget.pack,
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F3F4),
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
                  fontSize: 14,
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
        color: const Color(0xFFF7F3F4),
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
          color: const Color(0xFFF7F3F4),
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
          color: const Color(0xFFF7F3F4),
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
        color: const Color(0xFFECE3E8),
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
          color: const Color(0xFFF7F3F4),
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
                : const Color(0xFFECE3E8),
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
      color: active ? purple : const Color(0xFFE5DADF),
    );
  }

  List<BoxShadow> _shadow() {
    return const [
      BoxShadow(
        color: Color(0x16000000),
        offset: Offset(0, 4),
        blurRadius: 14,
      ),
    ];
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}
