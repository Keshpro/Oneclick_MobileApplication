import 'package:flutter/material.dart';

import '../models/document_pack.dart';
import '../models/vault_record.dart';

import '../services/vault_service.dart';
import '../services/document_pack_service.dart';
import '../services/document_pack_zip_service.dart';

import 'document_pack_home_screen.dart';

class DocumentPackExportScreen extends StatefulWidget {
  const DocumentPackExportScreen({
    super.key,
    required this.pack,
  });

  final DocumentPack pack;

  @override
  State<DocumentPackExportScreen> createState() =>
      _DocumentPackExportScreenState();
}

class _DocumentPackExportScreenState
    extends State<DocumentPackExportScreen> {
  late final DocumentPack pack;

  bool _isSaving = false;
  String? _savedPackId;
  bool _isExportingZip = false;

  @override
  void initState() {
    super.initState();
    pack = widget.pack;
  }

  static const background = Color(0xFFE9EBF2);
  static const card = Color(0xFFEEF0F6);
  static const purple = Color(0xFF6667FF);
  static const ink = Color(0xFF303344);
  static const muted = Color(0xFF707383);
  static const green = Color(0xFF00A978);

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
                  _readyCard(),
                  const SizedBox(height: 28),

                  const Text(
                    'Pack Contents',
                    style: TextStyle(
                      color: ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  StreamBuilder<List<VaultRecord>>(
                    stream: VaultService().getRecords(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          'Unable to load Vault documents.',
                          style: TextStyle(color: muted),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: purple),
                        );
                      }

                      final recordsById = {
                        for (final record in snapshot.data!) record.id: record,
                      };

                      return Column(
                        children: [
                          for (final requirement in pack.requirements) ...[
                            Builder(
                              builder: (context) {
                                final record = recordsById[requirement.vaultRecordId];

                                if (record == null ||
                                    ((record.fileUrl?.trim().isNotEmpty ?? false) == false &&
                                    (record.filePath?.trim().isNotEmpty ?? false) == false)) {
                                  return _document(
                                    requirement.name,
                                    'Selected Vault document unavailable',
                                    available: false,
                                  );
                                }

                                return _document(
                                  requirement.name,
                                  record.fileName ?? record.title,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  _packName(),

                  const SizedBox(height: 28),

                  const Text(
                    'Export Options',
                    style: TextStyle(
                      color: ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),
                  

                  _exportOption(
                    context,
                    icon: Icons.folder_zip_outlined,
                    title: 'Download ZIP',
                    description:
                        'Download the selected Vault documents as one ZIP file.',
                    button: 'Download ZIP',
                    onPressed: _downloadZip,
                    isLoading: _isExportingZip,
                  ),

                  const SizedBox(height: 22),

                  _saveButton(context),

                  const SizedBox(height: 15),

                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: muted,
                      ),
                      label: const Text(
                        'Back to Gap Resolution',
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
                '● Step 4 of 4',
                style: TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                'Ready to Export',
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
              _step('✓', 'Requisite', false),
              _line(),
              _step('✓', 'Matches', false),
              _line(),
              _step('✓', 'Gaps', false),
              _line(),
              _step('4', 'Export', true),
            ],
          ),
        ],
      ),
    );
  }

  
Widget _readyCard() {
  final matched = pack.matchedRequirements;
  final total = pack.totalRequirements;
  final allMatched = total > 0 && matched == total;

  return _surface(
    child: Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: allMatched
              ? const Color(0xFFE2F7F0)
              : const Color(0xFFFFF2DE),
          child: Icon(
            allMatched
                ? Icons.check_circle_outline
                : Icons.info_outline,
            color: allMatched ? green : purple,
            size: 31,
          ),
        ),
        const SizedBox(width: 17),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                allMatched
                    ? 'All $total Requirements Matched'
                    : '$matched of $total Requirements Matched',
                style: const TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                allMatched
                    ? 'Your confirmed Vault matches are ready for final review.'
                    : 'Some requirements still need matching.',
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


  Widget _document(
  String requirement,
  String file, {
  bool available = true,
}) {
    return _surface(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: available
                ? const Color(0xFFE2F7F0)
                : const Color(0xFFFFE8ED),
            child: Icon(
              available
                  ? Icons.check_rounded
                  : Icons.error_outline,
              color: available ? green : const Color(0xFFFF3B62),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requirement,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  file,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.description_outlined,
            color: purple,
          ),
        ],
      ),
    );
  }

  Widget _packName() {
    return _surface(
      child: Row(
        children: [
          Icon(
            Icons.folder_copy_outlined,
            color: purple,
            size: 28,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PACK NAME',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  pack.name,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.edit_outlined,
            color: purple,
          ),
        ],
      ),
    );
  }

  Future<void> _downloadZip() async {
  if (_isExportingZip) return;

  setState(() {
    _isExportingZip = true;
  });

  try {
    await DocumentPackZipService().exportPack(pack);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ZIP export completed successfully.'),
      ),
    );
    } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to export ZIP: $error'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isExportingZip = false;
      });
    }
  }
}

  Widget _exportOption(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String description,
  required String button,
  VoidCallback? onPressed,
  bool isLoading = false,
}) {
    return _surface(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F2F7),
                  shape: BoxShape.circle,
                  boxShadow: _shadow(),
                ),
                child: Icon(
                  icon,
                  color: purple,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          InkWell(
            onTap: isLoading
              ? null
              : onPressed ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$button is not available yet.'),
                      ),
                    );
                  },
            borderRadius: BorderRadius.circular(25),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F6),
                borderRadius: BorderRadius.circular(25),
                boxShadow: _shadow(),
              ),
              child: Text(
                isLoading ? 'Preparing ZIP...' : button,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePack() async {
  if (_isSaving || _savedPackId != null) return;

  setState(() {
    _isSaving = true;
  });

  try {
    final id = await DocumentPackService().savePack(pack);

    if (!mounted) return;

    setState(() {
      _savedPackId = id;
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const DocumentPackHomeScreen(),
      ),
      (route) => route.isFirst,
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to save document pack. Please try again.'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}

  
Widget _saveButton(BuildContext context) {
  final saved = _savedPackId != null;

  return InkWell(
    onTap: (_isSaving || saved) ? null : _savePack,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F6),
        borderRadius: BorderRadius.circular(30),
        boxShadow: _shadow(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isSaving)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: purple,
              ),
            )
          else
            Icon(
              saved
                  ? Icons.check_circle_outline
                  : Icons.bookmark_add_outlined,
              color: saved ? green : purple,
            ),
          const SizedBox(width: 9),
          Text(
            _isSaving
                ? 'Saving Pack...'
                : saved
                    ? 'Pack Saved'
                    : 'Save Pack to Vault',
            style: TextStyle(
              color: saved ? green : purple,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _step(
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
              color:
                  active ? purple : const Color(0xFFF1F2F7),
              boxShadow: _shadow(),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: active ? Colors.white : purple,
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

  Widget _line() {
    return Container(
      width: 18,
      height: 3,
      color: purple,
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
}