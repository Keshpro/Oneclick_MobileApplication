import 'package:flutter/material.dart';
import 'document_pack_gaps_screen.dart';
import 'document_pack_home_screen.dart';
import '../services/document_pack_service.dart';
import '../models/document_pack.dart';
import '../models/vault_record.dart';
import 'document_pack_vault_picker.dart';

class DocumentPackMatchesScreen extends StatefulWidget {
  const DocumentPackMatchesScreen({
    super.key,
    required this.pack,
  });

  final DocumentPack pack;

  @override
  State<DocumentPackMatchesScreen> createState() =>
      _DocumentPackMatchesScreenState();
}

class _DocumentPackMatchesScreenState
    extends State<DocumentPackMatchesScreen> {
  late DocumentPack pack;
  bool _savingDraft = false;

  @override
  void initState() {
    super.initState();
    pack = widget.pack;
  }

static const background = Color(0xFFF5F3F2);
static const card = Color(0xFFFFFDFC);
static const purple = Color(0xFF725763);
static const ink = Color(0xFF302B31);
static const muted = Color(0xFF776F77);

// Muted semantic colors for document status.
static const green = Color(0xFF47866D);
static const orange = Color(0xFFBA8754);
static const red = Color(0xFFB96C75);

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

                  Text(
                    'CHECKLIST VALIDATION (${pack.totalRequirements} ITEMS)',
                    style: const TextStyle(
                      color: muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 18),

                  for (final requirement in pack.requirements) ...[
                    _unmatchedCard(context, requirement),
                    const SizedBox(height: 18),
                  ],

                  const SizedBox(height: 24),

                  _summary(),

                  const SizedBox(height: 24),

                  _continue(context),

                  const SizedBox(height: 20),

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
      final savedId = await DocumentPackService().savePack(pack);
      if (!mounted) return;
      setState(() => pack = pack.copyWith(savedId: savedId));
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.folder_copy_outlined,
              color: purple,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PACK CONFIGURATION',
                    style: TextStyle(
                      color: purple,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    pack.name,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.tune_rounded,
              color: muted,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Row(
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
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(text: 'Source: '),
                    TextSpan(
                      text: 'Manually entered checklist',
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
                    fontSize: 15,
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
                    fontSize: 15,
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
              color: const Color(0xFFF7F3F4),
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
                      fontSize: 12,
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

  Future<void> _selectVaultDocument(
  DocumentRequirement requirement,
) async {
  final selected = await Navigator.push<VaultRecord>(
    context,
    MaterialPageRoute(
      builder: (_) => const DocumentPackVaultPicker(),
    ),
  );

  if (!mounted || selected == null) return;

  
final confirmed = await showDialog<bool>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    backgroundColor: const Color(0xFFFFFDFC),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    title: const Text(
      'Confirm Document Match',
      style: TextStyle(
        color: Color(0xFF302B31),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    content: Text(
      'Use "${selected.title}" for "${requirement.name}"?',
      style: const TextStyle(
        color: Color(0xFF776F77),
        fontSize: 13,
        height: 1.5,
      ),
    ),
    actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext, false),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF725763),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(fontSize: 13),
        ),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(dialogContext, true),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF725763),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Confirm Match',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  ),
);


  if (!mounted || confirmed != true) return;

  setState(() {
    pack = pack.copyWith(
      requirements: [
        for (final item in pack.requirements)
          if (item.id == requirement.id)
            item.copyWith(vaultRecordId: selected.id)
          else
            item,
      ],
    );
  });
}

  Widget _unmatchedCard(
    BuildContext context,
    DocumentRequirement requirement,
  ) {
  return Container(
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
                requirement.name,
                style: const TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Not matched yet. Select a document from your Vault in the next integration step.',
          style: TextStyle(
            color: muted,
            fontSize: 12,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        _status(
          requirement.isMatched ? 'Matched' : 'Not Matched',
          requirement.isMatched ? green : orange,
        ),
        const SizedBox(height: 14),
        _wideButton(
          Icons.folder_open_outlined,
          requirement.isMatched ? 'Change Vault Document' : 'Select from Vault',
          () => _selectVaultDocument(requirement),
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
                    fontSize: 15,
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
                      fontSize: 12,
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
  final total = pack.totalRequirements;
  final matched = pack.matchedRequirements;
  final percentage = pack.completionPercentage;

  return _surface(
    child: Row(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 6,
                color: purple,
                backgroundColor: const Color(0xFFD5D7E0),
              ),
              Text(
                '${percentage.round()}%',
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
                '$matched of $total Documents Matched',
                style: const TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Select and confirm documents from your Vault to complete this pack.',
                style: TextStyle(
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

  Widget _continue(BuildContext context) {
    return _wideButton(
      Icons.arrow_forward_rounded,
      'Continue to Gap Resolution',
      () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentPackGapsScreen(pack: pack),
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
        color: const Color(0xFFECE3E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
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
                    fontSize: 11,
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
                fontSize: 12,
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
                fontSize: 13,
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
              color: const Color(0xFFECE3E8),
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
      color: active ? purple : const Color(0xFFE5DADF),
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
        color: Color(0xFFE5DADF),
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