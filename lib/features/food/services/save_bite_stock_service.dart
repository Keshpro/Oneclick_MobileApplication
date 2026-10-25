import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/food_product.dart';

class SaveBiteStockService {
  SaveBiteStockService._();

  static final SaveBiteStockService instance = SaveBiteStockService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> validateAndReserveStock(List<dynamic> cartItems) async {
    final Map<String, int> requested = {};
    final Map<String, FoodProduct> products = {};

    for (final item in cartItems) {
      final product = item.product as FoodProduct;

      // Hardcoded demo offers don't use Firestore stock.
      final path = product.firestoreOfferPath;
      if (product.type != FoodProductType.saveBite || path == null) {
        continue;
      }

      requested.update(
        path,
        (value) => value + (item.quantity as int),
        ifAbsent: () => item.quantity as int,
      );

      products[path] = product;
    }

    if (requested.isEmpty) return;

    final refs = <String, DocumentReference<Map<String, dynamic>>>{};

    for (final path in requested.keys) {
      refs[path] = _firestore.doc(path);
    }

    await _firestore.runTransaction((transaction) async {
      final offerSnapshots = <String, DocumentSnapshot<Map<String, dynamic>>>{};

      // Read all offer documents first.
      for (final path in requested.keys) {
        offerSnapshots[path] = await transaction.get(refs[path]!);
      }

      final sellerRefs = <String, DocumentReference<Map<String, dynamic>>>{};
      final sellerSnapshots =
          <String, DocumentSnapshot<Map<String, dynamic>>>{};

      // Read seller documents before making any writes.
      for (final path in requested.keys) {
        final sellerRef = refs[path]!.parent.parent!;

        sellerRefs[path] = sellerRef;

        if (!sellerSnapshots.containsKey(sellerRef.path)) {
          sellerSnapshots[sellerRef.path] = await transaction.get(sellerRef);
        }
      }

      for (final path in requested.keys) {
        final offerSnapshot = offerSnapshots[path]!;
        final product = products[path]!;

        if (!offerSnapshot.exists) {
          throw Exception('${product.name} is no longer available.');
        }

        final data = offerSnapshot.data()!;
        final quantity = int.tryParse('${data['quantity']}') ?? 0;
        final status = '${data['status'] ?? 'ACTIVE'}'.toUpperCase();
        final sellerSnapshot = sellerSnapshots[sellerRefs[path]!.path]!;
        final sellerData = sellerSnapshot.data();

        if (!sellerSnapshot.exists ||
            sellerData == null ||
            '${sellerData['role']}'.toLowerCase() != 'foodseller' ||
            '${sellerData['status']}'.toLowerCase() != 'active' ||
            status != 'ACTIVE') {
          throw Exception('${product.name} is no longer available.');
        }

        if (quantity < requested[path]!) {
          throw Exception(
            'Not enough portions of ${product.name} remain. '
            'Available: $quantity; requested: ${requested[path]}.',
          );
        }
      }

      // Update stock only after all validation reads have completed.
      for (final path in requested.keys) {
        final data = offerSnapshots[path]!.data()!;
        final quantity = int.parse('${data['quantity']}');

        transaction.update(refs[path]!, {
          'quantity': '${quantity - requested[path]!}',
        });
      }
    });
  }
}
