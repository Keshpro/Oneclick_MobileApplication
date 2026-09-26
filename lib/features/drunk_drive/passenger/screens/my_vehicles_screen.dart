import 'package:flutter/material.dart';

import '../../models/vehicle_model.dart';
import '../../services/vehicle_service.dart';
import '../../theme/drunk_drive_colors.dart';
import 'add_vehicle_screen.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  final VehicleService _vehicleService = VehicleService();

  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;
  String? _errorMessage;

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
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Vehicle added')));
    }
  }

  void _onEditVehicle(VehicleModel vehicle) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit Vehicle — coming soon')));
  }

  Future<void> _onSetDefault(VehicleModel vehicle) async {
    _vehicleService.setDefaultVehicle(vehicle.id);
    await _loadVehicles();
  }

  Future<void> _onDeleteVehicle(VehicleModel vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: DrunkDriveColors.surface,
        title: const Text(
          'Remove vehicle?',
          style: TextStyle(color: DrunkDriveColors.textPrimary),
        ),
        content: Text(
          'This will remove ${vehicle.displayName} (${vehicle.registrationNumber}) from your account.',
          style: const TextStyle(color: DrunkDriveColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: DrunkDriveColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _vehicleService.deleteVehicle(vehicle.id);
    await _loadVehicles();

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Vehicle removed')));
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
          'My Vehicles',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: DrunkDriveColors.accent),
            onPressed: _onAddVehicle,
            tooltip: 'Add Vehicle',
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
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
              "You don't have any vehicles yet.",
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
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVehicles,
      color: DrunkDriveColors.accent,
      backgroundColor: DrunkDriveColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _vehicles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          return _VehicleCard(
            vehicle: vehicle,
            onTap: () => _onEditVehicle(vehicle),
            onSetDefault: () => _onSetDefault(vehicle),
            onDelete: () => _onDeleteVehicle(vehicle),
          );
        },
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _VehicleCard({
    required this.vehicle,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DrunkDriveColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: DrunkDriveColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: DrunkDriveColors.accent,
                ),
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
                      vehicle.registrationNumber,
                      style: const TextStyle(
                        color: DrunkDriveColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vehicle.colour} • ${vehicle.transmission.label}',
                      style: const TextStyle(
                        color: DrunkDriveColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: DrunkDriveColors.surface,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: DrunkDriveColors.textMuted,
                ),
                onSelected: (value) {
                  if (value == 'default') onSetDefault();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  if (!vehicle.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Text(
                        'Set as default',
                        style: TextStyle(color: DrunkDriveColors.textPrimary),
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Remove',
                      style: TextStyle(color: DrunkDriveColors.danger),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
