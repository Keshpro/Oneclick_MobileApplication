import 'package:flutter/material.dart';

import '../../models/vehicle_model.dart';
import '../../services/vehicle_service.dart';
import '../../theme/drunk_drive_colors.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final VehicleService _vehicleService = VehicleService();

  final _registrationController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colourController = TextEditingController();

  VehicleType _vehicleType = VehicleType.car;
  TransmissionType _transmission = TransmissionType.automatic;

  bool _isSaving = false;

  @override
  void dispose() {
    _registrationController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colourController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 300));

    _vehicleService.addVehicle(
      registrationNumber: _registrationController.text,
      brand: _brandController.text,
      model: _modelController.text,
      colour: _colourController.text,
      vehicleType: _vehicleType,
      transmission: _transmission,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.pop(context, true);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: DrunkDriveColors.textMuted),
      filled: true,
      fillColor: DrunkDriveColors.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DrunkDriveColors.surfaceBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DrunkDriveColors.accent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DrunkDriveColors.danger),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
          'Add Vehicle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _registrationController,
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.characters,
                decoration: _decoration('Registration Number'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Brand'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Model'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colourController,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Colour'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<VehicleType>(
                initialValue: _vehicleType,
                dropdownColor: DrunkDriveColors.surface,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Vehicle Type'),
                items: VehicleType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _vehicleType = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransmissionType>(
                initialValue: _transmission,
                dropdownColor: DrunkDriveColors.surface,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Transmission'),
                items: TransmissionType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _transmission = value);
                },
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo upload — coming soon')),
                  );
                },
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: DrunkDriveColors.textMuted,
                ),
                label: const Text(
                  'Add Vehicle Photo (optional)',
                  style: TextStyle(color: DrunkDriveColors.textMuted),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: DrunkDriveColors.surfaceBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DrunkDriveColors.accent,
                    foregroundColor: DrunkDriveColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: DrunkDriveColors.background,
                          ),
                        )
                      : const Text(
                          'Save Vehicle',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
