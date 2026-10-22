import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionRecord {
  final String id;
  final String userId;
  final String name;
  final String subtitle;

  // Old display fields kept for backward compatibility.
  final String price;
  final String renewal;
  final String usage;

  final String category;
  final String status;
  final bool priceHiked;
  final DateTime createdAt;

  // Structured fields used by the real subscription calculations.
  final double? amount;
  final String currency;
  final String billingCycle;
  final DateTime? renewalDate;
  final DateTime? cancelledAt;
  final DateTime? renewalActionHandledFor;
  final bool renewalReminders;

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
    this.amount,
    this.currency = 'LKR',
    this.billingCycle = 'Monthly',
    this.renewalDate,
    this.cancelledAt,
    this.renewalActionHandledFor,
    this.renewalReminders = true,
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
      'renewalReminders': renewalReminders,

      // New structured fields.
      'amount': amount,
      'currency': currency,
      'billingCycle': billingCycle,
      'renewalDate':
          renewalDate == null
              ? null
              : Timestamp.fromDate(renewalDate!),
      'cancelledAt':
          cancelledAt == null
              ? null
              : Timestamp.fromDate(cancelledAt!),
      'renewalActionHandledFor':
          renewalActionHandledFor == null
              ? null
              : Timestamp.fromDate(
                  renewalActionHandledFor!,),
    };
  }

  factory SubscriptionRecord.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final String oldPrice =
        map['price']?.toString() ?? '';

    final double? storedAmount =
        map['amount'] is num
            ? (map['amount'] as num).toDouble()
            : null;

    final double? fallbackAmount =
        double.tryParse(
          oldPrice.replaceAll(
            RegExp(r'[^0-9.]'),
            '',
          ),
        );

    final String storedCurrency =
        map['currency']?.toString() ?? '';

    final String fallbackCurrency =
        oldPrice.trim().toUpperCase().startsWith('USD') ||
                oldPrice.trim().startsWith(r'$')
            ? 'USD'
            : 'LKR';

    final String subtitle =
        map['subtitle']?.toString() ?? '';

    final String storedBillingCycle =
        map['billingCycle']?.toString() ?? '';

    final String fallbackBillingCycle =
        subtitle.toLowerCase().contains('annual')
            ? 'Annual'
            : 'Monthly';

    return SubscriptionRecord(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      subtitle: subtitle,
      price: oldPrice,
      renewal: map['renewal'] ?? '',
      usage: map['usage'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? 'Active',
      priceHiked: map['priceHiked'] ?? false,
      createdAt:
          (map['createdAt'] as Timestamp?)
                  ?.toDate() ??
              DateTime.now(),

      // New fields with fallbacks for old Firestore records.
      amount: storedAmount ?? fallbackAmount,
      currency:
          storedCurrency.isEmpty
              ? fallbackCurrency
              : storedCurrency,
      billingCycle:
          storedBillingCycle.isEmpty
              ? fallbackBillingCycle
              : storedBillingCycle,
      renewalDate:
          (map['renewalDate'] as Timestamp?)
              ?.toDate(),
      cancelledAt:
          (map['cancelledAt'] as Timestamp?)
              ?.toDate(),
      renewalActionHandledFor:
          (map['renewalActionHandledFor']
                  as Timestamp?)
              ?.toDate(),
      renewalReminders: map['renewalReminders'] is bool
          ? map['renewalReminders'] as bool
          : true,
    );
  }
}