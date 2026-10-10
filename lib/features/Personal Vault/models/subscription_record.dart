import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionRecord {
  final String id;
  final String userId;
  final String name;
  final String subtitle;
  final String price;
  final String renewal;
  final String usage;
  final String category;
  final String status;
  final bool priceHiked;
  final DateTime createdAt;

  const SubscriptionRecord({
    required this.id,
    required this.userId,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.renewal,
    required this.usage,
    required this.category,
    required this.status,
    required this.priceHiked,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'subtitle': subtitle,
      'price': price,
      'renewal': renewal,
      'usage': usage,
      'category': category,
      'status': status,
      'priceHiked': priceHiked,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SubscriptionRecord.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return SubscriptionRecord(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      subtitle: map['subtitle'] ?? '',
      price: map['price'] ?? '',
      renewal: map['renewal'] ?? '',
      usage: map['usage'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? 'Active',
      priceHiked: map['priceHiked'] ?? false,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}