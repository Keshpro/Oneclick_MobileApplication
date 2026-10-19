import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/booking_status.dart';
import '../../services/booking_firestore_service.dart';
import '../../theme/drunk_drive_colors.dart';

class DriverTripHistoryScreen extends StatefulWidget {
  const DriverTripHistoryScreen({super.key});

  @override
  State<DriverTripHistoryScreen> createState() =>
      _DriverTripHistoryScreenState();
}

class _DriverTripHistoryScreenState extends State<DriverTripHistoryScreen> {
  final BookingFirestoreService _firestoreService = BookingFirestoreService();

  List<BookingModel> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final trips = await _firestoreService.getCompletedDriverTrips();

      if (!mounted) return;

      setState(() {
        _trips = trips;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load driver trip history: $error')),
      );
    }
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelledByDriver:
        return 'Cancelled by You';
      case BookingStatus.cancelledByUser:
        return 'Cancelled by Customer';
      default:
        return status.label;
    }
  }

  Color _statusColor(BookingStatus status, DrunkDrivePalette colors) {
    switch (status) {
      case BookingStatus.completed:
        return colors.success;
      case BookingStatus.cancelledByDriver:
      case BookingStatus.cancelledByUser:
        return colors.danger;
      default:
        return colors.textMuted;
    }
  }

  String _formatDate(BookingModel booking) {
    final date = booking.completedAt ?? booking.createdAt;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year • $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final colors = DrunkDrivePalette.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          'Trip History',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrips,
        color: colors.accent,
        backgroundColor: colors.surface,
        child: _trips.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 180),
                  Icon(
                    Icons.history_rounded,
                    size: 56,
                    color: colors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No driver trips yet.',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: _trips.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final booking = _trips[index];
                  return _TripHistoryCard(
                    booking: booking,
                    statusLabel: _statusLabel(booking.status),
                    statusColor: _statusColor(booking.status, colors),
                    dateText: _formatDate(booking),
                  );
                },
              ),
      ),
    );
  }
}

class _TripHistoryCard extends StatelessWidget {
  final BookingModel booking;
  final String statusLabel;
  final Color statusColor;
  final String dateText;

  const _TripHistoryCard({
    required this.booking,
    required this.statusLabel,
    required this.statusColor,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DrunkDrivePalette.of(context);
    final isCompleted = booking.status == BookingStatus.completed;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isCompleted)
                Text(
                  'Rs. ${booking.fareEstimate.total.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: colors.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.trip_origin_rounded, text: booking.pickup.name),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.location_on_rounded,
            text: booking.destination.name,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.directions_car_rounded,
            text:
                '${booking.vehicle.displayName} (${booking.vehicle.registrationNumber})',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.route_rounded,
            text:
                '${booking.distanceKm.toStringAsFixed(1)} km • ${booking.durationMinutes} min',
          ),
          const SizedBox(height: 14),
          Divider(color: colors.surfaceBorder, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: colors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  dateText,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = DrunkDrivePalette.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.accent, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
