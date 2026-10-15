import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_saver/file_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subscription_record.dart';
import '../models/vault_record.dart';
import 'subscription_service.dart';
import 'supabase_storage_service.dart';
import 'vault_service.dart';

class VaultBackupService {
  final VaultService _vaultService = VaultService();
  final SubscriptionService _subscriptionService =
      SubscriptionService();
  final SupabaseStorageService _storageService =
      SupabaseStorageService();

  Future<void> createBackup() async {
    final records =
        await _vaultService.getRecords().first;

    final subscriptions =
        await _subscriptionService
            .getSubscriptions()
            .first;

    final preferences =
        await _getVaultPreferences();

    final archive = Archive();

    final recordData = <Map<String, dynamic>>[];

    for (final record in records) {
      String? backupFilePath;

      final storagePath = record.filePath;

      if (storagePath != null &&
          storagePath.trim().isNotEmpty) {
        try {
          final bytes =
              await _storageService.downloadFile(
            path: storagePath,
          );

          final originalName =
              record.fileName?.trim().isNotEmpty == true
                  ? record.fileName!.trim()
                  : 'vault_file';

          final safeName =
              _safeFileName(originalName);

          final archiveName =
              'files/${record.id}_$safeName';

          archive.add(
            ArchiveFile.bytes(
              archiveName,
              bytes,
            ),
          );

          backupFilePath = archiveName;
        } catch (_) {
          backupFilePath = null;
        }
      }

      recordData.add(
        _vaultRecordToJson(
          record,
          backupFilePath: backupFilePath,
        ),
      );
    }

    final manifest = <String, dynamic>{
      'backupVersion': 1,
      'createdAt':
          DateTime.now().toUtc().toIso8601String(),
      'vaultRecords': recordData,
      'subscriptions': subscriptions
          .map(_subscriptionToJson)
          .toList(),
      'preferences': preferences,
    };

    final manifestText =
        const JsonEncoder.withIndent('  ')
            .convert(manifest);

    archive.add(
      ArchiveFile.string(
        'manifest.json',
        manifestText,
      ),
    );

    final zipBytes =
        ZipEncoder().encodeBytes(archive);

    final timestamp =
        DateTime.now()
            .toUtc()
            .toIso8601String()
            .replaceAll(':', '-')
            .replaceAll('.', '-');

    await FileSaver.instance.saveFile(
      name: 'personal_vault_backup_$timestamp',
      bytes: Uint8List.fromList(zipBytes),
      fileExtension: 'zip',
      mimeType: MimeType.other,
      customMimeType: 'application/zip',
    );
  }

  Map<String, dynamic> _vaultRecordToJson(
    VaultRecord record, {
    required String? backupFilePath,
  }) {
    return {
      'id': record.id,
      'userId': record.userId,
      'title': record.title,
      'recordType': record.recordType,
      'category': record.category,
      'notes': record.notes,
      'tags': record.tags,
      'renewalDate':
          record.renewalDate.toIso8601String(),
      'expiryNotification':
          record.expiryNotification,
      'isFavorite': record.isFavorite,
      'fileName': record.fileName,
      'originalFilePath': record.filePath,
      'backupFilePath': backupFilePath,
      'createdAt':
          record.createdAt.toIso8601String(),
      'lastOpenedAt':
          record.lastOpenedAt?.toIso8601String(),
      'merchant': record.merchant,
      'purchaseDate':
          record.purchaseDate?.toIso8601String(),
      'amount': record.amount,
    };
  }

  Map<String, dynamic> _subscriptionToJson(
    SubscriptionRecord subscription,
  ) {
    return {
      'id': subscription.id,
      'userId': subscription.userId,
      'name': subscription.name,
      'subtitle': subscription.subtitle,
      'price': subscription.price,
      'renewal': subscription.renewal,
      'usage': subscription.usage,
      'category': subscription.category,
      'status': subscription.status,
      'priceHiked': subscription.priceHiked,
      'createdAt':
          subscription.createdAt.toIso8601String(),
    };
  }

  Future<Map<String, dynamic>>
      _getVaultPreferences() async {
    final prefs =
        await SharedPreferences.getInstance();

    return {
      'biometricEnabled':
          prefs.getBool(
                'vault_biometric_enabled',
              ) ??
              false,
      'pushNotifications':
          prefs.getBool(
                'vault_push_notifications',
              ) ??
              true,
      'emailNotifications':
          prefs.getBool(
                'vault_email_notifications',
              ) ??
              false,
      'expiryWarnings':
          prefs.getStringList(
                'vault_expiry_warnings',
              ) ??
              [
                '30 days',
                '14 days',
                '7 days',
              ],
      'renewalWarning':
          prefs.getString(
                'vault_renewal_warning',
              ) ??
              '3 days prior',
    };
  }

  String _safeFileName(String fileName) {
    return fileName.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '_',
    );
  }
}