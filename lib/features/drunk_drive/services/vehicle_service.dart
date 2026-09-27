import '../models/vehicle_model.dart';

// Mock, in-memory vehicle service.
//
// This follows the same pattern as admin_service.dart's dummyUsers list —
// it's a stand-in for a real backend. When Firebase is wired up later,
// this class's public methods stay the same; only the internals change
// to talk to Firestore instead of a local list. No screen should need to
// change when that happens.
//
// Ownership is still enforced here (see _ownershipCheck), even though
// there's only one mock user for now — this mirrors the rule in the spec
// that a user must never modify another user's vehicle, and keeps that
// rule in one place instead of scattered across screens.

class VehicleService {
  // TODO: replace with the real authenticated uid once auth is wired up.
  static const String currentUserId = 'mock-passenger-1';

  static final List<VehicleModel> _vehicles = [];

  /// All vehicles belonging to the current (mock) passenger.
  List<VehicleModel> getMyVehicles() {
    return _vehicles.where((v) => v.ownerId == currentUserId).toList();
  }

  VehicleModel? getVehicleById(String id) {
    for (final vehicle in _vehicles) {
      if (vehicle.id == id) return vehicle;
    }
    return null;
  }

  VehicleModel? getDefaultVehicle() {
    final mine = getMyVehicles();
    if (mine.isEmpty) return null;
    return mine.firstWhere(
      (v) => v.isDefault,
      orElse: () => mine.first,
    );
  }

  VehicleModel addVehicle({
    required String registrationNumber,
    required String brand,
    required String model,
    required String colour,
    required VehicleType vehicleType,
    required TransmissionType transmission,
    String? photoPath,
  }) {
    final isFirstVehicle = getMyVehicles().isEmpty;

    final vehicle = VehicleModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      ownerId: currentUserId,
      registrationNumber: registrationNumber.trim().toUpperCase(),
      brand: brand.trim(),
      model: model.trim(),
      colour: colour.trim(),
      vehicleType: vehicleType,
      transmission: transmission,
      photoPath: photoPath,
      // The first vehicle a user adds becomes their default automatically.
      isDefault: isFirstVehicle,
    );

    _vehicles.add(vehicle);
    return vehicle;
  }

  void updateVehicle(VehicleModel updated) {
    final index = _vehicles.indexWhere((v) => v.id == updated.id);
    if (index == -1) return;
    _ownershipCheck(_vehicles[index]);
    _vehicles[index] = updated;
  }

  void deleteVehicle(String id) {
    final vehicle = getVehicleById(id);
    if (vehicle == null) return;
    _ownershipCheck(vehicle);
    _vehicles.removeWhere((v) => v.id == id);
  }

  void setDefaultVehicle(String id) {
    final target = getVehicleById(id);
    if (target == null) return;
    _ownershipCheck(target);

    for (var i = 0; i < _vehicles.length; i++) {
      if (_vehicles[i].ownerId == currentUserId) {
        _vehicles[i] = _vehicles[i].copyWith(isDefault: _vehicles[i].id == id);
      }
    }
  }

  void _ownershipCheck(VehicleModel vehicle) {
    if (vehicle.ownerId != currentUserId) {
      throw StateError('Not authorized to modify this vehicle.');
    }
  }

  /// Test-only helper — do not call this from app code.
  static void debugResetForTests() => _vehicles.clear();
}