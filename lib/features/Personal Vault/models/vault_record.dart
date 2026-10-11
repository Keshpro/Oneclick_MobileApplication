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
  final String? fileName;
  final String? fileUrl;
  final DateTime createdAt;

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
    this.fileName,
    this.fileUrl,
    required this.createdAt,
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
      'createdAt': Timestamp.fromDate(createdAt),
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
      fileName: map['fileName'],
      fileUrl: map['fileUrl'],
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}