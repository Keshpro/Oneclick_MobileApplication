
import 'package:flutter/material.dart';

import '../models/document_pack.dart';
import '../models/vault_record.dart';
import '../services/vault_service.dart';

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
  static const background = Color(0xFFE9EBF2);
  static const card = Color(0xFFEEF0F6);
  static const purple = Color(0xFF6667FF);
  static const ink = Color(0xFF303344);
  static const muted = Color(0xFF707383);
  static const green = Color(0xFF00A978);
  static const orange = Color(0xFFFF9800);

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
        title: const Text(
          'Document Pack Details',
          style: TextStyle(
            color: ink,
            fontWeight: FontWeight.w600,
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
              child: CircularProgressIndicator(color: purple),
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

          final progress =
              total == 0 ? 0.0 : availableCount / total;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 45),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SAVED DOCUMENT PACK',
                      style: TextStyle(
                        color: purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pack.name,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _surface(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 76,
                            height: 76,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 7,
                                  color: purple,
                                  backgroundColor:
                                      const Color(0xFFD5D7E0),
                                ),
                                Text(
                                  '${(progress * 100).round()}%',
                                  style: const TextStyle(
                                    color: ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$availableCount of $total documents linked',
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  availableCount == total && total > 0
                                      ? 'All requirements have linked Vault attachments.'
                                      : 'Some requirements need attention.',
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
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
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final requirement in pack.requirements) ...[
                      _requirementCard(
                        requirement,
                        recordsById[requirement.vaultRecordId],
                      ),
                      const SizedBox(height: 14),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(26),
        border: Border(
          left: BorderSide(
            color: available ? green : orange,
            width: 5,
          ),
        ),
        boxShadow: _shadow(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            available
                ? Icons.check_circle_outline
                : Icons.info_outline,
            color: available ? green : orange,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requirement.name,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
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
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  available
                      ? 'Linked Vault attachment'
                      : 'Needs attention',
                  style: TextStyle(
                    color: available ? green : orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(30),
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
            Icon(icon, size: 44, color: muted),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 14,
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
