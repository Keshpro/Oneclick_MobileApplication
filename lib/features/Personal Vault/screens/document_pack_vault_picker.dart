
import 'package:flutter/material.dart';

import '../models/vault_record.dart';
import '../services/vault_service.dart';

class DocumentPackVaultPicker extends StatelessWidget {
  const DocumentPackVaultPicker({super.key});

  // Dusty mauve and ivory design palette.
  static const _purple = Color(0xFF725763);
  static const _ink = Color(0xFF302B31);
  static const _muted = Color(0xFF776F77);
  static const _background = Color(0xFFF5F3F2);
  static const _card = Color(0xFFFFFDFC);
  static const _softMauve = Color(0xFFECE3E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _ink,
        titleSpacing: 8,
        title: const Text(
          'Select Vault Document',
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
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
              child: CircularProgressIndicator(
                color: _purple,
              ),
            );
          }

          // Keep the original attachment filtering.
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
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            itemCount: records.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = records[index];

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Material(
                    color: _card,
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),

                      // Preserve the original selection behavior.
                      onTap: () => Navigator.pop(context, record),

                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFEDE6E9),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D302B31),
                              blurRadius: 14,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _softMauve,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: _purple,
                                size: 24,
                              ),
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    record.fileName ??
                                        'Attached Vault document',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: _muted,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    record.category,
                                    style: const TextStyle(
                                      color: _purple,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: _softMauve,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: _purple,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _softMauve,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: _purple,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
