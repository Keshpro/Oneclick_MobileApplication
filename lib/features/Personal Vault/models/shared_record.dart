import 'package:cloud_firestore/cloud_firestore.dart';

class SharedRecord {
  final String id;
  final String ownerId;
  final String recordTitle;
  final String recipientName;
  final String recipientEmail;
  final String permission;
  final String status;
  final DateTime? expiryDate;
  final DateTime createdAt;

  const SharedRecord({
    required this.id,
    required this.ownerId,
    required this.recordTitle,
    required this.recipientName,
    required this.recipientEmail,
    required this.permission,
    required this.status,
    required this.expiryDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'recordTitle': recordTitle,
      'recipientName': recipientName,
      'recipientEmail': recipientEmail,
      'permission': permission,
      'status': status,
      'expiryDate':
          expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SharedRecord.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return SharedRecord(
      id: id,
      ownerId: map['ownerId'] ?? '',
      recordTitle: map['recordTitle'] ?? '',
      recipientName: map['recipientName'] ?? '',
      recipientEmail: map['recipientEmail'] ?? '',
      permission: map['permission'] ?? 'View only',
      status: map['status'] ?? 'Active',
      expiryDate: (map['expiryDate'] as Timestamp?)?.toDate(),
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}