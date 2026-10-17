import 'package:cloud_firestore/cloud_firestore.dart';

class VaultRecord {
  final String id;
  final String userId;
  final String title;
  final String recordType;
  final String category;
  final String notes;
  final List<String> tags;
  final DateTime renewalDate;
  final bool expiryNotification;
  final bool isFavorite;
  final String? fileName;
  final String? fileUrl;
  final String? filePath;
  final DateTime createdAt;
  final DateTime? lastOpenedAt;
  final String? merchant;
  final DateTime? purchaseDate;
  final String? amount;

  const VaultRecord({
    required this.id,
    required this.userId,
    required this.title,
    required this.recordType,
    required this.category,
    required this.notes,
    required this.tags,
    required this.renewalDate,
    required this.expiryNotification,
    this.isFavorite = false,
    this.fileName,
    this.fileUrl,
    this.filePath,
    required this.createdAt,
    this.lastOpenedAt,
    this.merchant,
    this.purchaseDate,
    this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'recordType': recordType,
      'category': category,
      'notes': notes,
      'tags': tags,
      'renewalDate': Timestamp.fromDate(renewalDate),
      'expiryNotification': expiryNotification,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'filePath': filePath,
      'createdAt': Timestamp.fromDate(createdAt),
      'isFavorite': isFavorite,
      'lastOpenedAt':
      lastOpenedAt != null ? Timestamp.fromDate(lastOpenedAt!) : null,
      'merchant': merchant,
      'purchaseDate':
          purchaseDate != null ? Timestamp.fromDate(purchaseDate!) : null,
      'amount': amount,
    };
  }

  factory VaultRecord.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return VaultRecord(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      recordType: map['recordType'] ?? '',
      category: map['category'] ?? '',
      notes: map['notes'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      renewalDate:
          (map['renewalDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiryNotification: map['expiryNotification'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
      fileName: map['fileName'],
      fileUrl: map['fileUrl'],
      filePath: map['filePath'],
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastOpenedAt:
          (map['lastOpenedAt'] as Timestamp?)?.toDate(),
      merchant: map['merchant'],
      purchaseDate:
          (map['purchaseDate'] as Timestamp?)?.toDate(),
      amount: map['amount'],
    );
  }
}