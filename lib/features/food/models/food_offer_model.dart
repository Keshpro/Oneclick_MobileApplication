
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodOfferModel {
  final String? id;
  final String foodName;
  final String category;
  final String originalPrice;
  final String saverPrice;
  final String quantity;
  final String availableFrom;
  final String availableUntil;
  final String description;
  final String allergens;
  final DateTime? expiresAt;
  String status;

  FoodOfferModel({
    this.id,
    required this.foodName,
    required this.category,
    required this.originalPrice,
    required this.saverPrice,
    required this.quantity,
    required this.availableFrom,
    required this.availableUntil,
    required this.description,
    required this.allergens,
    this.expiresAt,
    this.status = 'ACTIVE',
  });

  factory FoodOfferModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    final expiry = data['expiresAt'];

    return FoodOfferModel(
      id: document.id,
      foodName: data['foodName']?.toString() ?? '',
      category: data['category']?.toString() ?? 'Other',
      originalPrice: data['originalPrice']?.toString() ?? '0',
      saverPrice: data['saverPrice']?.toString() ?? '0',
      quantity: data['quantity']?.toString() ?? '0',
      availableFrom: data['availableFrom']?.toString() ?? '',
      availableUntil: data['availableUntil']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      allergens: data['allergens']?.toString() ?? '',
      expiresAt: expiry is Timestamp
          ? expiry.toDate()
          : expiry is DateTime
              ? expiry
              : null,
      status: data['status']?.toString() ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'foodName': foodName,
      'category': category,
      'originalPrice': originalPrice,
      'saverPrice': saverPrice,
      'quantity': quantity,
      'availableFrom': availableFrom,
      'availableUntil': availableUntil,
      'description': description,
      'allergens': allergens,
      'expiresAt': expiresAt == null
          ? null
          : Timestamp.fromDate(expiresAt!),
      'status': status,
    };
  }
}
