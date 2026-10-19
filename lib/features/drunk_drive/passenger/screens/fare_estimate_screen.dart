import 'package:flutter/material.dart';

import '../../models/fare_estimate.dart';
import '../../models/location_model.dart';
import '../../models/trip_reason.dart';
import '../../models/vehicle_model.dart';
import '../../services/fare_service.dart';
import '../../services/location_service.dart';
import '../../theme/drunk_drive_colors.dart';
import 'booking_confirmation_screen.dart';

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

    final distanceKm = _locationService.distanceKmBetween(
      widget.pickup,
      widget.destination,
    );
    final durationMinutes = _locationService.estimatedDurationMinutes(
      distanceKm,
    );
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
    if (_estimate == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(
          vehicle: widget.vehicle,
          pickup: widget.pickup,
          destination: widget.destination,
          reason: widget.reason,
          fareEstimate: _estimate!,
          distanceKm: _distanceKm,
          durationMinutes: _durationMinutes,
        ),
      ),
    );
  }

  String _rs(double amount) => 'Rs. ${amount.toStringAsFixed(0)}';

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
          'Estimated Fare',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(child: _buildBody(colors)),
      bottomNavigationBar: _isLoading ? null : _buildContinueBar(colors),
    );
  }

  Widget _buildBody(DrunkDrivePalette colors) {
    if (_isLoading || _estimate == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colors.accent),
            const SizedBox(height: 16),
            Text(
              'Calculating fare...',
              style: TextStyle(color: colors.textMuted),
            ),
          ],
        ),
      );
    }

    final estimate = _estimate!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Your Trip',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        _buildTripSummary(colors),
        const SizedBox(height: 22),
        Text(
          'Fare Breakdown',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.surfaceBorder),
          ),
          child: Column(
            children: [
              _fareRow('Base Fare', estimate.baseFare, colors),
              _fareRow('Distance Charge', estimate.distanceCharge, colors),
              _fareRow('Time Charge', estimate.timeCharge, colors),
              _fareRow('Service Fee', estimate.serviceFee, colors),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  color: colors.surfaceBorder,
                  height: 1,
                ),
              ),
              _fareRow(
                'Estimated Total',
                estimate.total,
                colors,
                isTotal: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: colors.textMuted, size: 17),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'This is an estimate. Your final fare may vary slightly based on actual distance and time.',
                style: TextStyle(color: colors.textMuted, fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripSummary(DrunkDrivePalette colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow(Icons.my_location_rounded, colors.success,
              widget.pickup.name, colors),
          const SizedBox(height: 12),
          _summaryRow(Icons.location_on_rounded, colors.danger,
              widget.destination.name, colors),
          const SizedBox(height: 12),
          _summaryRow(Icons.directions_car_rounded, colors.accent,
              widget.vehicle.displayName, colors),
          const SizedBox(height: 12),
          _summaryRow(Icons.info_outline_rounded, colors.textMuted,
              widget.reason.label, colors),
          const SizedBox(height: 12),
          _summaryRow(
            Icons.route_rounded,
            colors.textMuted,
            '${_distanceKm.toStringAsFixed(1)} km • $_durationMinutes min',
            colors,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    IconData icon,
    Color color,
    String text,
    DrunkDrivePalette colors,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fareRow(
    String label,
    double amount,
    DrunkDrivePalette colors, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: isTotal ? colors.textPrimary : colors.textMuted,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
                fontSize: isTotal ? 15 : 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _rs(amount),
            style: TextStyle(
              color: isTotal ? colors.accent : colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: isTotal ? 17 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueBar(DrunkDrivePalette colors) {
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
            onPressed: _onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: Colors.white,
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
