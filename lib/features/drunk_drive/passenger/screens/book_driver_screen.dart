import 'package:flutter/material.dart';

import '../../models/location_model.dart';
import '../../models/trip_reason.dart';
import '../../models/vehicle_model.dart';
import '../../services/vehicle_firestore_service.dart';
import '../../theme/drunk_drive_colors.dart';
import 'add_vehicle_screen.dart';
import 'fare_estimate_screen.dart';
import 'location_picker_screen.dart';

/// Customer booking form. Vehicle data continues to come from Firestore.
class BookDriverScreen extends StatefulWidget {
  const BookDriverScreen({super.key});

  @override
  State<BookDriverScreen> createState() => _BookDriverScreenState();
}

class _BookDriverScreenState extends State<BookDriverScreen> {
  final VehicleFirestoreService _vehicleService = VehicleFirestoreService();
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
      final vehicles = await _vehicleService.getMyVehicleModels();
      if (!mounted) return;

      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
        final previousSelection = vehicles.where(
          (vehicle) => vehicle.id == _selectedVehicleId,
        );
        final defaultVehicles = vehicles.where((vehicle) => vehicle.isDefault);
        if (previousSelection.isNotEmpty) {
          _selectedVehicleId = previousSelection.first.id;
        } else if (defaultVehicles.isNotEmpty) {
          _selectedVehicleId = defaultVehicles.first.id;
        } else if (vehicles.isNotEmpty) {
          _selectedVehicleId = vehicles.first.id;
        } else {
          _selectedVehicleId = null;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load vehicles: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _onAddVehicle() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
    );
    if (!mounted) return;
    if (added == true) await _loadVehicles();
  }

  Future<void> _selectPickup() async {
    final result = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LocationPickerScreen(title: 'Pickup Location'),
      ),
    );
    if (!mounted) return;
    if (result != null) setState(() => _pickup = result);
  }

  Future<void> _selectDestination() async {
    final result = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(title: 'Destination'),
      ),
    );
    if (!mounted) return;
    if (result != null) setState(() => _destination = result);
  }

  void _onContinue() {
    if (_selectedVehicleId == null ||
        _pickup == null ||
        _destination == null ||
        _selectedReason == null) {
      return;
    }
    final matchingVehicles = _vehicles.where(
      (vehicle) => vehicle.id == _selectedVehicleId,
    );
    if (matchingVehicles.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FareEstimateScreen(
          vehicle: matchingVehicles.first,
          pickup: _pickup!,
          destination: _destination!,
          reason: _selectedReason!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = DrunkDrivePalette.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Book a Driver',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(child: _buildBody(colors)),
      bottomNavigationBar: _buildContinueBar(colors),
    );
  }

  Widget _buildBody(DrunkDrivePalette colors) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colors.accent),
            const SizedBox(height: 16),
            Text('Loading vehicles...', style: TextStyle(color: colors.textMuted)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: colors.danger, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadVehicles,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.surface,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
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
              Icon(Icons.directions_car_outlined,
                  color: colors.textMuted, size: 48),
              const SizedBox(height: 16),
              Text(
                "You don't have a vehicle registered.",
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _onAddVehicle,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Vehicle'),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.surface,
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
        _SectionTitle(title: 'Trip Details', colors: colors),
        const SizedBox(height: 12),
        _LocationTile(
          icon: Icons.my_location_rounded,
          iconColor: colors.success,
          label: 'Pickup Location',
          value: _pickup?.name,
          onTap: _selectPickup,
        ),
        const SizedBox(height: 10),
        _LocationTile(
          icon: Icons.location_on_rounded,
          iconColor: colors.danger,
          label: 'Destination',
          value: _destination?.name,
          onTap: _selectDestination,
        ),
        const SizedBox(height: 24),
        _SectionTitle(title: 'Select Vehicle', colors: colors),
        const SizedBox(height: 4),
        Text(
          'The driver will drive this vehicle for your trip.',
          style: TextStyle(color: colors.textMuted, fontSize: 12),
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
          icon: Icon(Icons.add_rounded, color: colors.accent),
          label: Text(
            'Add another vehicle',
            style: TextStyle(color: colors.accent),
          ),
        ),
        const SizedBox(height: 24),
        _SectionTitle(title: 'Reason', colors: colors),
        const SizedBox(height: 4),
        Text(
          'This helps us brief your driver. It is not used to make any medical or legal decision.',
          style: TextStyle(color: colors.textMuted, fontSize: 12),
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

  Widget? _buildContinueBar(DrunkDrivePalette colors) {
    if (_isLoading || _errorMessage != null || _vehicles.isEmpty) return null;

    final enabled = _selectedVehicleId != null &&
        _pickup != null &&
        _destination != null &&
        _selectedReason != null;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.surfaceBorder)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: enabled ? _onContinue : null,
            style: FilledButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.surface,
              disabledBackgroundColor: colors.surfaceBorder,
              disabledForegroundColor: colors.textMuted,
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final DrunkDrivePalette colors;

  const _SectionTitle({required this.title, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: colors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 16,
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
    final colors = DrunkDrivePalette.of(context);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? colors.accent : colors.surfaceBorder,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? colors.accent : colors.textMuted,
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
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (vehicle.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: TextStyle(
                                color: colors.success,
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
                      style: TextStyle(color: colors.textMuted, fontSize: 12),
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
    final colors = DrunkDrivePalette.of(context);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.surfaceBorder),
          ),
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
                      style: TextStyle(color: colors.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value ?? 'Select $label',
                      style: TextStyle(
                        color: value == null
                            ? colors.textMuted
                            : colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.textMuted),
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
    final colors = DrunkDrivePalette.of(context);
    return Material(
      color: isSelected
          ? colors.accent.withValues(alpha: 0.12)
          : colors.surface,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? colors.accent : colors.surfaceBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colors.accent : colors.textMuted,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
