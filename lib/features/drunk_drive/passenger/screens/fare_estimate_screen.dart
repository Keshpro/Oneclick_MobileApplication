import 'package:flutter/material.dart';

import '../../models/fare_estimate.dart';
import '../../models/location_model.dart';
import '../../models/trip_reason.dart';
import '../../models/vehicle_model.dart';
import '../../services/fare_service.dart';
import '../../services/location_service.dart';
import '../../theme/drunk_drive_colors.dart';

class FareEstimateScreen extends StatefulWidget {
  final VehicleModel vehicle;
  final LocationModel pickup;
  final LocationModel destination;
  final TripReason reason;

  const FareEstimateScreen({
    super.key,
    required this.vehicle,
    required this.pickup,
    required this.destination,
    required this.reason,
  });

  @override
  State<FareEstimateScreen> createState() => _FareEstimateScreenState();
}

class _FareEstimateScreenState extends State<FareEstimateScreen> {
  final LocationService _locationService = LocationService();
  final FareService _fareService = FareService();

  bool _isLoading = true;
  double _distanceKm = 0;
  int _durationMinutes = 0;
  FareEstimate? _estimate;

  @override
  void initState() {
    super.initState();
    _calculateFare();
  }

  Future<void> _calculateFare() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final distanceKm = _locationService.distanceKmBetween(widget.pickup, widget.destination);
    final durationMinutes = _locationService.estimatedDurationMinutes(distanceKm);
    final estimate = _fareService.estimateFare(
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
    );

    if (!mounted) return;
    setState(() {
      _distanceKm = distanceKm;
      _durationMinutes = durationMinutes;
      _estimate = estimate;
      _isLoading = false;
    });
  }

  void _onContinue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking confirmation — coming in the next step')),
    );
  }

  String _rs(double amount) => 'Rs. ${amount.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DrunkDriveColors.background,
      appBar: AppBar(
        backgroundColor: DrunkDriveColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Estimated Fare',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _isLoading ? null : _buildContinueBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading || _estimate == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: DrunkDriveColors.accent),
            SizedBox(height: 16),
            Text('Calculating fare...', style: TextStyle(color: DrunkDriveColors.textMuted)),
          ],
        ),
      );
    }

    final estimate = _estimate!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTripSummary(),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: DrunkDriveColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              _fareRow('Base Fare', estimate.baseFare),
              _fareRow('Distance Charge', estimate.distanceCharge),
              _fareRow('Time Charge', estimate.timeCharge),
              _fareRow('Service Fee', estimate.serviceFee),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: DrunkDriveColors.surfaceBorder, height: 1),
              ),
              _fareRow('Estimated Total', estimate.total, isTotal: true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'This is an estimate. Your final fare may vary slightly based on actual distance and time.',
          style: TextStyle(color: DrunkDriveColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTripSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DrunkDriveColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow(Icons.my_location_rounded, DrunkDriveColors.success, widget.pickup.name),
          const SizedBox(height: 10),
          _summaryRow(Icons.location_on_rounded, DrunkDriveColors.danger, widget.destination.name),
          const SizedBox(height: 10),
          _summaryRow(Icons.directions_car_rounded, DrunkDriveColors.accent, widget.vehicle.displayName),
          const SizedBox(height: 10),
          _summaryRow(Icons.info_outline_rounded, DrunkDriveColors.textMuted, widget.reason.label),
          const SizedBox(height: 10),
          _summaryRow(
            Icons.route_rounded,
            DrunkDriveColors.textMuted,
            '${_distanceKm.toStringAsFixed(1)} km • $_durationMinutes min',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _fareRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : DrunkDriveColors.textMuted,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              fontSize: isTotal ? 15 : 13,
            ),
          ),
          Text(
            _rs(amount),
            style: TextStyle(
              color: isTotal ? DrunkDriveColors.accent : Colors.white,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              fontSize: isTotal ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: DrunkDriveColors.accent,
              foregroundColor: DrunkDriveColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}