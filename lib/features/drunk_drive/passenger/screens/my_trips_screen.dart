import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/booking_status.dart';
import '../../services/booking_firestore_service.dart';
import '../../theme/drunk_drive_colors.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final BookingFirestoreService _bookingService = BookingFirestoreService();

  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    try {
      final bookings = await _bookingService.getMyBookingModels();

      if (!mounted) return;

      setState(() {
        _bookings = bookings.where((booking) {
          return booking.status == BookingStatus.completed ||
              booking.status == BookingStatus.cancelledByUser ||
              booking.status == BookingStatus.cancelledByDriver;
        }).toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load trip history: $error')),
      );
    }
  }

  String _rs(double amount) => 'Rs. ${amount.toStringAsFixed(0)}';

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

  Color _historyStatusColor(BookingStatus status, DrunkDrivePalette colors) {
    switch (status) {
      case BookingStatus.completed:
        return colors.success;
      case BookingStatus.cancelledByUser:
      case BookingStatus.cancelledByDriver:
        return colors.danger;
      default:
        return colors.accent;
    }
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
          'My Trips',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(child: _buildBody(colors)),
    );
  }

  Widget _buildBody(DrunkDrivePalette colors) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.accent),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: colors.accent,
      backgroundColor: colors.surface,
      child: _bookings.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 130),
                Icon(
                  Icons.history_rounded,
                  color: colors.textMuted,
                  size: 54,
                ),
                const SizedBox(height: 16),
                Text(
                  'No past trips yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: _bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                final statusColor =
                    _historyStatusColor(booking.status, colors);

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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _historyStatusLabel(booking.status),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _rs(booking.fareEstimate.total),
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _TripLocationRow(
                        icon: Icons.my_location_rounded,
                        iconColor: colors.success,
                        text: booking.pickup.name,
                        textColor: colors.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      _TripLocationRow(
                        icon: Icons.location_on_rounded,
                        iconColor: colors.danger,
                        text: booking.destination.name,
                        textColor: colors.textPrimary,
                      ),
                      const SizedBox(height: 12),
                      Divider(color: colors.surfaceBorder, height: 1),
                      const SizedBox(height: 12),
                      Text(
                        '${booking.vehicle.displayName} • '
                        '${booking.distanceKm.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: colors.textMuted,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _formatTripDate(booking),
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 11,
                              ),
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

class _TripLocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final Color textColor;

  const _TripLocationRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 17),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
