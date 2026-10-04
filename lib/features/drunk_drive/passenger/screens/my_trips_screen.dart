import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/booking_status.dart';
import '../../services/booking_service.dart';
import '../../theme/drunk_drive_colors.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final BookingService _bookingService = BookingService();

  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    if (!mounted) return;

    setState(() {
      _bookings = _bookingService.getMyBookings().where((booking) {
        return booking.status == BookingStatus.completed ||
            booking.status == BookingStatus.cancelledByUser ||
            booking.status == BookingStatus.cancelledByDriver;
      }).toList();

      _isLoading = false;
    });
  }

  String _rs(double amount) {
    return 'Rs. ${amount.toStringAsFixed(0)}';
  }

  String _formatTripDate(BookingModel booking) {
    final date = booking.completedAt ?? booking.createdAt;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year • $hour:$minute $period';
  }

  String _historyStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return 'Completed';

      case BookingStatus.cancelledByUser:
        return 'Cancelled by You';

      case BookingStatus.cancelledByDriver:
        return 'Cancelled by Driver';

      default:
        return status.label;
    }
  }

  Color _historyStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return DrunkDriveColors.success;

      case BookingStatus.cancelledByUser:
      case BookingStatus.cancelledByDriver:
        return DrunkDriveColors.danger;

      default:
        return DrunkDriveColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DrunkDriveColors.background,
      appBar: AppBar(
        backgroundColor: DrunkDriveColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'My Trips',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: DrunkDriveColors.accent,
        ),
      );
    }

    if (_bookings.isEmpty) {
      return const Center(
        child: Text(
          'No past trips yet.',
          style: TextStyle(
            color: DrunkDriveColors.textMuted,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: DrunkDriveColors.accent,
      backgroundColor: DrunkDriveColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _bookings.length,
        separatorBuilder: (_, _) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          final statusColor = _historyStatusColor(
            booking.status,
          );

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DrunkDriveColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and fare
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        _historyStatusLabel(
                          booking.status,
                        ),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      _rs(
                        booking.fareEstimate.total,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Pickup
                Row(
                  children: [
                    const Icon(
                      Icons.my_location_rounded,
                      color: DrunkDriveColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.pickup.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Destination
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: DrunkDriveColors.danger,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.destination.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Vehicle and distance
                Text(
                  '${booking.vehicle.displayName} • '
                  '${booking.distanceKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    color: DrunkDriveColors.textMuted,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 6),

                // Trip date/time
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: DrunkDriveColors.textMuted,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTripDate(booking),
                      style: const TextStyle(
                        color: DrunkDriveColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}