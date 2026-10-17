import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:file_saver/file_saver.dart';

import '../models/subscription_record.dart';
import '../models/vault_record.dart';
import 'subscription_service.dart';
import 'supabase_storage_service.dart';
import 'vault_service.dart';

class EncryptedVaultExportService {
  final VaultService _vaultService = VaultService();

  final SubscriptionService _subscriptionService =
      SubscriptionService();

  final SupabaseStorageService _storageService =
      SupabaseStorageService();

  final AesGcm _aesGcm = AesGcm.with256bits();

  final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 210000,
    bits: 256,
  );

  Future<void> exportEncryptedVault({
    required String password,
  }) async {
    final cleanPassword = password.trim();

    if (cleanPassword.length < 8) {
      throw Exception(
        'Password must contain at least 8 characters.',
      );
    }

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
      String? encryptedArchiveFilePath;

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

          final archivePath =
              'files/${record.id}_$safeName';

          archive.add(
            ArchiveFile.bytes(
              archivePath,
              bytes,
            ),
          );

          encryptedArchiveFilePath = archivePath;
        } catch (_) {
          encryptedArchiveFilePath = null;
        }
      }

      recordData.add(
        _vaultRecordToJson(
          record,
          archiveFilePath:
              encryptedArchiveFilePath,
        ),
      );
    }

    final manifest = <String, dynamic>{
      'exportVersion': 1,
      'format': 'oneclick-encrypted-vault',
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

    final salt = _secureRandomBytes(16);

    final nonce = _secureRandomBytes(12);

    final passwordKey = SecretKey(
      utf8.encode(cleanPassword),
    );

    final derivedKey =
        await _pbkdf2.deriveKey(
      secretKey: passwordKey,
      nonce: salt,
    );

    final secretBox =
        await _aesGcm.encrypt(
      zipBytes,
      secretKey: derivedKey,
      nonce: nonce,
    );

    final envelope = <String, dynamic>{
      'format': 'oneclick',
      'version': 1,
      'encryption': 'AES-256-GCM',
      'keyDerivation': 'PBKDF2-HMAC-SHA256',
      'iterations': 210000,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'cipherText':
          base64Encode(secretBox.cipherText),
    };

    final encryptedBytes = Uint8List.fromList(
      utf8.encode(
        jsonEncode(envelope),
      ),
    );

    final timestamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');

    await FileSaver.instance.saveFile(
      name:
          'oneclick_encrypted_vault_$timestamp',
      bytes: encryptedBytes,
      fileExtension: 'oneclick',
      mimeType: MimeType.other,
      customMimeType:
          'application/octet-stream',
    );
  }

  List<int> _secureRandomBytes(int length) {
    final random = Random.secure();

    return List<int>.generate(
      length,
      (_) => random.nextInt(256),
    );
  }

  Map<String, dynamic> _vaultRecordToJson(
    VaultRecord record, {
    required String? archiveFilePath,
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
      'archiveFilePath': archiveFilePath,
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
    return {
      'biometricEnabled': false,
      'pushNotifications': true,
      'emailNotifications': false,
      'expiryWarnings': [
        '30 days',
        '14 days',
        '7 days',
      ],
      'renewalWarning': '3 days prior',
    };
  }

  String _safeFileName(String fileName) {
    return fileName.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '_',
    );
  }
}