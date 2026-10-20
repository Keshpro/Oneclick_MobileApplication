
import 'package:flutter/material.dart';

import '../models/vault_record.dart';
import '../services/vault_service.dart';

class DocumentPackVaultPicker extends StatelessWidget {
  const DocumentPackVaultPicker({super.key});

  static const _purple = Color(0xFF6667FF);
  static const _ink = Color(0xFF303344);
  static const _muted = Color(0xFF707383);
  static const _background = Color(0xFFE9EBF2);
  static const _card = Color(0xFFEEF0F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        title: const Text(
          'Select Vault Document',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<VaultRecord>>(
        stream: VaultService().getRecords(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _centerMessage(
              Icons.error_outline,
              'Unable to load Vault documents.',
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _purple),
            );
          }

          final records = snapshot.data!
              .where(
                (record) =>
                    (record.fileUrl?.trim().isNotEmpty ?? false) ||
                    (record.filePath?.trim().isNotEmpty ?? false),
              )
              .toList();

          if (records.isEmpty) {
            return _centerMessage(
              Icons.folder_open_outlined,
              'No documents with attached files were found in your Vault.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: records.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = records[index];

              return Material(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pop(context, record),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          color: _purple,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.title,
                                style: const TextStyle(
                                  color: _ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                record.fileName ??
                                    'Attached Vault document',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                record.category,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: _purple,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _centerMessage(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _muted, size: 42),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
