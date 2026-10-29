
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_saver/file_saver.dart';

import '../models/document_pack.dart';
import '../models/vault_record.dart';
import 'supabase_storage_service.dart';
import 'vault_service.dart';

class DocumentPackZipService {
  final VaultService _vaultService = VaultService();
  final SupabaseStorageService _storageService =
      SupabaseStorageService();

  Future<void> exportPack(DocumentPack pack) async {
    if (pack.requirements.isEmpty) {
      throw StateError('This document pack has no requirements.');
    }

    if (pack.missingRequirements > 0) {
      throw StateError(
        'Match all document requirements before exporting.',
      );
    }

    final records = await _vaultService.getRecords().first;

    final recordsById = <String, VaultRecord>{
      for (final record in records) record.id: record,
    };

    final archive = Archive();

    for (var index = 0; index < pack.requirements.length; index++) {
      final requirement = pack.requirements[index];
      final record = recordsById[requirement.vaultRecordId];

      if (record == null) {
        throw StateError(
          'A linked Vault document is missing: ${requirement.name}',
        );
      }

      final path = record.filePath;

      if (path == null || path.trim().isEmpty) {
        throw StateError(
          'No storage path found for: ${requirement.name}',
        );
      }

      final bytes = await _storageService.downloadFile(
        path: path,
      );

      if (bytes.isEmpty) {
        throw StateError(
          'The selected file is empty: ${requirement.name}',
        );
      }

      final originalName =
          record.fileName?.trim().isNotEmpty == true
              ? record.fileName!.trim()
              : '${requirement.name}.pdf';

      final safeName = _safeFileName(originalName);
      final uniqueName = '${index + 1}_$safeName';

      archive.add(
        ArchiveFile.bytes(
          uniqueName,
          bytes,
        ),
      );
    }

    final zipBytes = ZipEncoder().encodeBytes(archive);

    if (zipBytes.isEmpty) {
      throw StateError('Unable to create the ZIP archive.');
    }

    final packName = _safeFileName(pack.name);

    await FileSaver.instance.saveFile(
      name: packName,
      bytes: Uint8List.fromList(zipBytes),
      fileExtension: 'zip',
      mimeType: MimeType.zip,
    );
  }

  String _safeFileName(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .trim();

    return cleaned.isEmpty ? 'document_pack' : cleaned;
  }
}
