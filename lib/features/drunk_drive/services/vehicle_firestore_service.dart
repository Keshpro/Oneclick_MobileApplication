import '../models/vehicle_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be signed in.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _vehicles =>
      _firestore.collection('vehicles');

  // Get the signed-in passenger's vehicles.
  Future<List<Map<String, dynamic>>> getMyVehicles() async {
    final snapshot = await _vehicles
        .where('ownerId', isEqualTo: currentUserId)
        .get();

    return snapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  Future<List<VehicleModel>> getMyVehicleModels() async {
    final records = await getMyVehicles();

    return records.map((data) {
      final vehicleTypeName = data['vehicleType'] as String?;
      final transmissionName = data['transmission'] as String?;

      final vehicleType = VehicleType.values.firstWhere(
        (type) => type.name == vehicleTypeName,
        orElse: () => VehicleType.other,
      );

      final transmission = TransmissionType.values.firstWhere(
        (type) => type.name == transmissionName,
        orElse: () => TransmissionType.automatic,
      );

      return VehicleModel(
        id: data['id'] as String,
        ownerId: data['ownerId'] as String,
        registrationNumber: data['registrationNumber'] as String,
        brand: data['brand'] as String,
        model: data['model'] as String,
        colour: data['colour'] as String,
        vehicleType: vehicleType,
        transmission: transmission,
        isDefault: data['isDefault'] == true,
      );
    }).toList();
  }

  // Save a vehicle belonging to the signed-in passenger.
  Future<String> addVehicle({
    required String registrationNumber,
    required String brand,
    required String model,
    required String colour,
    required String vehicleType,
    required String transmission,
  }) async {
    final document = _vehicles.doc();

    await document.set({
      'ownerId': currentUserId,
      'registrationNumber': registrationNumber.trim().toUpperCase(),
      'brand': brand.trim(),
      'model': model.trim(),
      'colour': colour.trim(),
      'vehicleType': vehicleType,
      'transmission': transmission,
      'isDefault': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  // Update a vehicle owned by the signed-in passenger.
  Future<void> updateVehicle({
    required String vehicleId,
    required String registrationNumber,
    required String brand,
    required String model,
    required String colour,
    required String vehicleType,
    required String transmission,
  }) async {
    final document = _vehicles.doc(vehicleId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);

      if (!snapshot.exists) {
        throw StateError('Vehicle not found.');
      }

      if (snapshot.data()?['ownerId'] != currentUserId) {
        throw StateError('You cannot edit another user\'s vehicle.');
      }

      transaction.update(document, {
        'registrationNumber': registrationNumber.trim().toUpperCase(),
        'brand': brand.trim(),
        'model': model.trim(),
        'colour': colour.trim(),
        'vehicleType': vehicleType,
        'transmission': transmission,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final document = _vehicles.doc(vehicleId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);

      if (!snapshot.exists) {
        throw StateError('Vehicle not found.');
      }

      if (snapshot.data()?['ownerId'] != currentUserId) {
        throw StateError('You cannot delete another user\'s vehicle.');
      }

      transaction.delete(document);
    });
  }
  
  Future<void> setDefaultVehicle(String vehicleId) async {
    final userId = currentUserId;

    final snapshot = await _vehicles
        .where('ownerId', isEqualTo: userId)
        .get();

    final selectedVehicle = snapshot.docs.where(
      (doc) => doc.id == vehicleId,
    );

    if (selectedVehicle.isEmpty) {
      throw StateError('Vehicle not found in your account.');
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isDefault': doc.id == vehicleId,
      });
    }

    await batch.commit();
  }

}
