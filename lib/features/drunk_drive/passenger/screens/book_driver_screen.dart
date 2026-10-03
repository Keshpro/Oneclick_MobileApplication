import 'package:flutter/material.dart';

import '../../models/location_model.dart';
import '../../models/trip_reason.dart';
import '../../models/vehicle_model.dart';
import '../../services/vehicle_service.dart';
import '../../theme/drunk_drive_colors.dart';
import 'add_vehicle_screen.dart';
import 'fare_estimate_screen.dart';
import 'location_picker_screen.dart';

// Book a Driver flow.
//
// This step only implements vehicle selection (spec section 8). Pickup
// location, destination, and reason are added in later steps and will
// live on this same screen, above the vehicle selector, once built.
// "Continue" is a placeholder until those fields exist.

class BookDriverScreen extends StatefulWidget {
  const BookDriverScreen({super.key});

  @override
  State<BookDriverScreen> createState() => _BookDriverScreenState();
}

class _BookDriverScreenState extends State<BookDriverScreen> {
  final VehicleService _vehicleService = VehicleService();

  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedVehicleId;
  LocationModel? _pickup;
  LocationModel? _destination;
  TripReason? _selectedReason;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final vehicles = _vehicleService.getMyVehicles();

      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
        // Pre-select the passenger's default vehicle, if they have one,
        // so they don't have to tap it manually every time.
        final defaultVehicle = _vehicleService.getDefaultVehicle();
        _selectedVehicleId ??= defaultVehicle?.id;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong.';
        _isLoading = false;
      });
    }
  }

  Future<void> _onAddVehicle() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
    );
    if (added == true) {
      await _loadVehicles();
    }
  }

  Future<void> _selectPickup() async {
    final result = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LocationPickerScreen(title: 'Pickup Location'),
      ),
    );
    if (result != null) setState(() => _pickup = result);
  }

  Future<void> _selectDestination() async {
    final result = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(title: 'Destination'),
      ),
    );
    if (result != null) setState(() => _destination = result);
  }

  void _onContinue() {
    final vehicle = _vehicleService.getVehicleById(_selectedVehicleId!);
    if (vehicle == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FareEstimateScreen(
          vehicle: vehicle,
          pickup: _pickup!,
          destination: _destination!,
          reason: _selectedReason!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DrunkDriveColors.background,
      appBar: AppBar(
        backgroundColor: DrunkDriveColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Book a Driver',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _buildContinueBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: DrunkDriveColors.accent),
            SizedBox(height: 16),
            Text(
              'Loading vehicles...',
              style: TextStyle(color: DrunkDriveColors.textMuted),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: DrunkDriveColors.danger,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: DrunkDriveColors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVehicles,
              style: ElevatedButton.styleFrom(
                backgroundColor: DrunkDriveColors.accent,
                foregroundColor: DrunkDriveColors.background,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_vehicles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.directions_car_outlined,
                color: DrunkDriveColors.textMuted,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                "You don't have a vehicle registered.",
                textAlign: TextAlign.center,
                style: TextStyle(color: DrunkDriveColors.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _onAddVehicle,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Vehicle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DrunkDriveColors.accent,
                  foregroundColor: DrunkDriveColors.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Trip Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        _LocationTile(
          icon: Icons.my_location_rounded,
          iconColor: DrunkDriveColors.success,
          label: 'Pickup Location',
          value: _pickup?.name,
          onTap: _selectPickup,
        ),
        const SizedBox(height: 10),
        _LocationTile(
          icon: Icons.location_on_rounded,
          iconColor: DrunkDriveColors.danger,
          label: 'Destination',
          value: _destination?.name,
          onTap: _selectDestination,
        ),
        const SizedBox(height: 24),
        const Text(
          'Select Vehicle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'The driver will drive this vehicle for your trip.',
          style: TextStyle(color: DrunkDriveColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 16),
        ..._vehicles.map(
          (vehicle) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SelectableVehicleCard(
              vehicle: vehicle,
              isSelected: vehicle.id == _selectedVehicleId,
              onTap: () => setState(() => _selectedVehicleId = vehicle.id),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _onAddVehicle,
          icon: const Icon(Icons.add_rounded, color: DrunkDriveColors.accent),
          label: const Text(
            'Add another vehicle',
            style: TextStyle(color: DrunkDriveColors.accent),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Reason',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'This helps us brief your driver. It is not used to make any medical or legal decision.',
          style: TextStyle(color: DrunkDriveColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: TripReason.values.map((reason) {
            return _ReasonChip(
              label: reason.label,
              isSelected: reason == _selectedReason,
              onTap: () => setState(() => _selectedReason = reason),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget? _buildContinueBar() {
    if (_isLoading || _errorMessage != null || _vehicles.isEmpty) return null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                (_selectedVehicleId == null ||
                    _pickup == null ||
                    _destination == null ||
                    _selectedReason == null)
                ? null
                : _onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: DrunkDriveColors.accent,
              foregroundColor: DrunkDriveColors.background,
              disabledBackgroundColor: DrunkDriveColors.surfaceBorder,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectableVehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableVehicleCard({
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DrunkDriveColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? DrunkDriveColors.accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected
                    ? DrunkDriveColors.accent
                    : DrunkDriveColors.textMuted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            vehicle.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: DrunkDriveColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (vehicle.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: DrunkDriveColors.success.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'DEFAULT',
                              style: TextStyle(
                                color: DrunkDriveColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.registrationNumber} • ${vehicle.colour} • ${vehicle.transmission.label}',
                      style: const TextStyle(
                        color: DrunkDriveColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _LocationTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DrunkDriveColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: DrunkDriveColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value ?? 'Select $label',
                      style: TextStyle(
                        color: value == null
                            ? DrunkDriveColors.textMuted
                            : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: DrunkDriveColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? DrunkDriveColors.accent.withValues(alpha: 0.15)
          : DrunkDriveColors.surface,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected
                  ? DrunkDriveColors.accent
                  : DrunkDriveColors.surfaceBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? DrunkDriveColors.accent
                  : DrunkDriveColors.textMuted,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
