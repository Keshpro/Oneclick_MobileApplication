import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/vehicle_model.dart';
import '../../services/vehicle_service.dart';
import '../../theme/drunk_drive_colors.dart';

class AddVehicleScreen extends StatefulWidget {
  final VehicleModel? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  bool get isEditing => vehicle != null;

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
  Uint8List? _photoBytes;
  String? _photoName;
  @override
  void initState() {
    super.initState();

    final vehicle = widget.vehicle;

    if (vehicle != null) {
      _photoBytes = vehicle.photoBytes;
      _photoName = vehicle.photoName;
      _registrationController.text = vehicle.registrationNumber;
      _brandController.text = vehicle.brand;
      _modelController.text = vehicle.model;
      _colourController.text = vehicle.colour;
      _vehicleType = vehicle.vehicleType;
      _transmission = vehicle.transmission;
    }
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colourController.dispose();
    super.dispose();
  }

  Future<void> _pickVehiclePhoto() async {
    final file = await FilePicker.pickFile(type: FileType.image);

    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      _photoBytes = bytes;
      _photoName = file.name;
    });
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 300));

    if (widget.isEditing) {
      final current = widget.vehicle!;

      final updated = current.copyWith(
        registrationNumber: _registrationController.text.trim().toUpperCase(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        colour: _colourController.text.trim(),
        vehicleType: _vehicleType,
        transmission: _transmission,
        photoBytes: _photoBytes,
        photoName: _photoName,
      );

      _vehicleService.updateVehicle(updated);
    } else {
      _vehicleService.addVehicle(
        registrationNumber: _registrationController.text,
        brand: _brandController.text,
        model: _modelController.text,
        colour: _colourController.text,
        vehicleType: _vehicleType,
        transmission: _transmission,
        photoBytes: _photoBytes,
        photoName: _photoName,
      );
    }

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
        title: Text(
          widget.isEditing ? 'Edit Vehicle' : 'Add Vehicle',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
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

              if (_photoBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    _photoBytes!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: DrunkDriveColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Unable to display selected photo.',
                          style: TextStyle(color: DrunkDriveColors.textMuted),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              OutlinedButton.icon(
                onPressed: _pickVehiclePhoto,
                icon: Icon(
                  _photoBytes == null
                      ? Icons.add_a_photo_outlined
                      : Icons.edit_outlined,
                  color: DrunkDriveColors.textMuted,
                ),
                label: Text(
                  _photoBytes == null
                      ? 'Add Vehicle Photo (optional)'
                      : 'Change Vehicle Photo',
                  style: const TextStyle(color: DrunkDriveColors.textMuted),
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
