import 'package:flutter/material.dart';

import '../models/document_pack.dart';
import '../models/vault_record.dart';
import '../services/vault_service.dart';
import 'document_pack_matches_screen.dart';

class SavedDocumentPackDetailsScreen extends StatefulWidget {
  const SavedDocumentPackDetailsScreen({
    super.key,
    required this.pack,
  });

  final DocumentPack pack;

  @override
  State<SavedDocumentPackDetailsScreen> createState() =>
      _SavedDocumentPackDetailsScreenState();
}

class _SavedDocumentPackDetailsScreenState
    extends State<SavedDocumentPackDetailsScreen> {
  static const background = Color(0xFFF5F3F2);
  static const card = Color(0xFFFFFDFC);
  static const mauve = Color(0xFF725763);
  static const softMauve = Color(0xFFECE3E8);
  static const ink = Color(0xFF302B31);
  static const muted = Color(0xFF776F77);
  static const green = Color(0xFF47866D);
  static const orange = Color(0xFFBA8754);

  late final Stream<List<VaultRecord>> _recordsStream;

  @override
  void initState() {
    super.initState();
    _recordsStream = VaultService().getRecords();
  }

  @override
  Widget build(BuildContext context) {
    final pack = widget.pack;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ink,
        titleSpacing: 0,
        title: const Text(
          'Document Pack Details',
          style: TextStyle(
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<List<VaultRecord>>(
        stream: _recordsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _message(
              Icons.error_outline,
              'Unable to load linked Vault documents.',
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: mauve),
            );
          }

          final recordsById = {
            for (final record in snapshot.data!) record.id: record,
          };

          final total = pack.totalRequirements;

          bool hasAttachment(VaultRecord record) {
            return (record.fileUrl?.trim().isNotEmpty ?? false) ||
                (record.filePath?.trim().isNotEmpty ?? false);
          }

          final availableCount = pack.requirements.where((requirement) {
            final record = recordsById[requirement.vaultRecordId];

            return requirement.isMatched &&
                record != null &&
                hasAttachment(record);
          }).length;

          final progress = total == 0 ? 0.0 : availableCount / total;
          final allAvailable = availableCount == total && total > 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 45),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _surface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SAVED DOCUMENT PACK',
                            style: TextStyle(
                              color: mauve,
                              fontSize: 11,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pack.name,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Icon(
                                allAvailable
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.info_outline_rounded,
                                color: allAvailable ? green : orange,
                                size: 19,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$availableCount of $total documents linked',
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${(progress * 100).round()}%',
                                style: const TextStyle(
                                  color: mauve,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 7,
                              backgroundColor: softMauve,
                              color: mauve,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            allAvailable
                                ? 'All requirements have linked Vault attachments.'
                                : 'Some requirements need attention.',
                            style: const TextStyle(
                              color: muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Document Checklist',
                      style: TextStyle(
                        color: ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final requirement in pack.requirements) ...[
                      _requirementCard(
                        requirement,
                        recordsById[requirement.vaultRecordId],
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (!allAvailable) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DocumentPackMatchesScreen(pack: pack),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: mauve,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Resume Matching'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _requirementCard(
    DocumentRequirement requirement,
    VaultRecord? record,
  ) {
    final hasFile = record != null &&
        ((record.fileUrl?.trim().isNotEmpty ?? false) ||
            (record.filePath?.trim().isNotEmpty ?? false));

    final available = requirement.isMatched && hasFile;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDE6E9)),
        boxShadow: _shadow(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: softMauve,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: mauve,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requirement.name,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  available
                      ? (record.fileName?.trim().isNotEmpty ?? false)
                          ? record.fileName!
                          : record.title
                      : requirement.isMatched
                          ? 'Linked Vault document unavailable'
                          : 'No document matched yet',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Icon(
                      available
                          ? Icons.check_circle_outline_rounded
                          : Icons.info_outline_rounded,
                      color: available ? green : orange,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        available
                            ? 'Linked Vault attachment'
                            : 'Needs attention',
                        style: TextStyle(
                          color: available ? green : orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _surface({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDE6E9)),
        boxShadow: _shadow(),
      ),
      child: child,
    );
  }

  Widget _message(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: muted),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<BoxShadow> _shadow() {
    return const [
      BoxShadow(
        color: Color(0x12000000),
        offset: Offset(0, 5),
        blurRadius: 18,
      ),
    ];
  }
}
