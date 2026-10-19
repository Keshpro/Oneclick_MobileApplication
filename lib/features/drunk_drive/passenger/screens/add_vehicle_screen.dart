import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/vehicle_model.dart';
import '../../services/vehicle_firestore_service.dart';

class AddVehicleScreen extends StatefulWidget {
  final VehicleModel? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  bool get isEditing => vehicle != null;

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final VehicleFirestoreService _vehicleService = VehicleFirestoreService();

  final _registrationController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colourController = TextEditingController();

  VehicleType _vehicleType = VehicleType.car;
  TransmissionType _transmission = TransmissionType.automatic;
  bool _isSaving = false;
  Uint8List? _photoBytes;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _background =>
      _isDark ? const Color(0xFF101418) : Colors.white;

  Color get _surface =>
      _isDark ? const Color(0xFF1B2329) : const Color(0xFFF4F7F7);

  Color get _text =>
      _isDark ? Colors.white : const Color(0xFF17252A);

  Color get _muted =>
      _isDark ? Colors.white70 : const Color(0xFF60747A);

  Color get _border =>
      _isDark ? const Color(0xFF35444A) : const Color(0xFFE1E8E8);

  Color get _accent => Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;
    if (vehicle != null) {
      _photoBytes = vehicle.photoBytes;
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
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() {
      _photoBytes = bytes;
    });
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      if (widget.isEditing) {
        await _vehicleService.updateVehicle(
          vehicleId: widget.vehicle!.id,
          registrationNumber: _registrationController.text,
          brand: _brandController.text,
          model: _modelController.text,
          colour: _colourController.text,
          vehicleType: _vehicleType.name,
          transmission: _transmission.name,
        );
      } else {
        await _vehicleService.addVehicle(
          registrationNumber: _registrationController.text,
          brand: _brandController.text,
          model: _modelController.text,
          colour: _colourController.text,
          vehicleType: _vehicleType.name,
          transmission: _transmission.name,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save vehicle: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  InputDecoration _decoration(String label) {
    OutlineInputBorder outline(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _muted),
      floatingLabelStyle: TextStyle(color: _accent),
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      enabledBorder: outline(_border),
      focusedBorder: outline(_accent, width: 1.5),
      errorBorder: outline(Theme.of(context).colorScheme.error),
      focusedErrorBorder: outline(Theme.of(context).colorScheme.error, width: 1.5),
      border: outline(_border),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldStyle = TextStyle(color: _text);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        elevation: 0,
        title: Text(
          widget.isEditing ? 'Edit Vehicle' : 'Add Vehicle',
          style: TextStyle(color: _text, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Vehicle Details',
                style: TextStyle(
                  color: _text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter the details of the vehicle your driver will use.',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _registrationController,
                style: fieldStyle,
                textCapitalization: TextCapitalization.characters,
                decoration: _decoration('Registration Number'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                style: fieldStyle,
                decoration: _decoration('Brand'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                style: fieldStyle,
                decoration: _decoration('Model'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colourController,
                style: fieldStyle,
                decoration: _decoration('Colour'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<VehicleType>(
                initialValue: _vehicleType,
                dropdownColor: _surface,
                style: fieldStyle,
                iconEnabledColor: _muted,
                decoration: _decoration('Vehicle Type'),
                items: VehicleType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _vehicleType = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransmissionType>(
                initialValue: _transmission,
                dropdownColor: _surface,
                style: fieldStyle,
                iconEnabledColor: _muted,
                decoration: _decoration('Transmission'),
                items: TransmissionType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _transmission = value);
                },
              ),
              const SizedBox(height: 20),
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
                          color: _surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Unable to display selected photo.',
                          style: TextStyle(color: _muted),
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
                ),
                label: Text(
                  _photoBytes == null
                      ? 'Add Vehicle Photo (optional)'
                      : 'Change Vehicle Photo',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accent,
                  side: BorderSide(color: _border),
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
                    backgroundColor: _accent,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
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
