import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Read-only admin view of Drunk & Drive Firestore records.
/// Card payments marked "simulated" are not actual receipts.
class DrunkDriveAudit extends StatefulWidget {
  const DrunkDriveAudit({super.key});

  @override
  State<DrunkDriveAudit> createState() => _DrunkDriveAuditState();
}

class _DrunkDriveAuditState extends State<DrunkDriveAudit> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _drivers;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _bookings;

  @override
  void initState() {
    super.initState();
    final db = FirebaseFirestore.instance;
    _drivers = db.collection('drunkDriveDriverApplications').snapshots();
    _bookings = db.collection('drunkDriveBookings').snapshots();
  }

  static String _text(Object? value, [String fallback = 'Not recorded']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static String _date(Object? value) {
    if (value is Timestamp) {
      final date = value.toDate().toLocal();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.year}-$month-$day $hour:$minute';
    }
    return 'Not recorded';
  }

  static double? _amount(Map<String, dynamic> booking) {
    final savedAmount = booking['amountDue'];
    if (savedAmount is num) return savedAmount.toDouble();
    // Older bookings may have no amountDue; sum the recorded estimate.
    final estimate = booking['fareEstimate'];
    if (estimate is! Map) return null;
    const parts = ['baseFare', 'distanceCharge', 'timeCharge', 'serviceFee'];
    if (parts.any((key) => estimate[key] is! num)) return null;
    return parts.fold<double>(0, (total, key) => total + (estimate[key] as num).toDouble());
  }

  static Widget _metric(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF1F7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );

  static Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Text('$label: $value'),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Drunk Drive Audit'),
          backgroundColor: const Color(0xff032744),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [Tab(text: 'Drivers'), Tab(text: 'Trips & Payments')],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _drivers,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Unable to load drivers: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final aTime = a.data()['submittedAt'];
                    final bTime = b.data()['submittedAt'];
                    final aValue = aTime is Timestamp ? aTime.millisecondsSinceEpoch : 0;
                    final bValue = bTime is Timestamp ? bTime.millisecondsSinceEpoch : 0;
                    return bValue.compareTo(aValue);
                  });
                final approved = docs.where((d) => d.data()['status'] == 'approved').length;
                final pending = docs.where((d) => d.data()['status'] == 'pending').length;
                final online = docs.where((d) =>
                    d.data()['status'] == 'approved' && d.data()['isOnline'] == true).length;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _metric('Applications', '${docs.length}'),
                      _metric('Approved', '$approved'),
                      _metric('Pending', '$pending'),
                      _metric('Approved online', '$online'),
                    ]),
                    const SizedBox(height: 12),
                    if (docs.isEmpty) const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No Drunk & Drive driver applications recorded.'),
                    ),
                    for (final doc in docs)
                      Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Builder(builder: (context) {
                            final data = doc.data();
                            final status = _text(data['status'], 'unknown');
                            final availability = status != 'approved'
                                ? 'Not available (not approved)'
                                : data['isOnline'] == true ? 'Online' : 'Offline';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_text(data['fullName'], 'Unnamed Driver'),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                _line('Application status', status),
                                _line('Availability', availability),
                                _line('Phone', _text(data['phone'])),
                                _line('Licence type', _text(data['licenceType'])),
                                _line('Experience (years)', _text(data['drivingExperienceYears'])),
                                _line('Submitted', _date(data['submittedAt'])),
                              ],
                            );
                          }),
                        ),
                      ),
                  ],
                );
              },
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _bookings,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Unable to load trips: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final aTime = a.data()['createdAt'];
                    final bTime = b.data()['createdAt'];
                    final aValue = aTime is Timestamp ? aTime.millisecondsSinceEpoch : 0;
                    final bValue = bTime is Timestamp ? bTime.millisecondsSinceEpoch : 0;
                    return bValue.compareTo(aValue);
                  });
                final completed = docs.where((d) => d.data()['status'] == 'completed').length;
                final cancelled = docs.where((d) =>
                    ['cancelledByUser', 'cancelledByDriver'].contains(d.data()['status'])).length;
                final confirmedCash = docs.where((d) => d.data()['paymentStatus'] == 'paid' &&
                    d.data()['paymentMethod'] == 'cash').toList();
                final simulated = docs.where((d) => d.data()['paymentStatus'] == 'simulated').length;
                final confirmedAmount = confirmedCash.fold<double>(0, (total, d) =>
                    total + (_amount(d.data()) ?? 0));
                final unknownPaidAmount = confirmedCash.where((d) => _amount(d.data()) == null).length;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _metric('Total bookings', '${docs.length}'),
                      _metric('Completed', '$completed'),
                      _metric('Cancelled', '$cancelled'),
                      _metric('Cash confirmed', '${confirmedCash.length}'),
                      _metric('Simulated cards', '$simulated'),
                    ]),
                    const SizedBox(height: 12),
                    Text('Confirmed cash amount recorded: ${confirmedAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (unknownPaidAmount > 0)
                      Text('$unknownPaidAmount confirmed cash booking(s) have no recorded amount.'),
                    const Text('Card simulations are NOT actual payments. Amounts are shown in the app’s fare units.',
                        style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 12),
                    if (docs.isEmpty) const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No Drunk & Drive bookings recorded.'),
                    ),
                    for (final doc in docs)
                      Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Builder(builder: (context) {
                            final data = doc.data();
                            final pickup = data['pickup'];
                            final destination = data['destination'];
                            final pickupName = pickup is Map ? _text(pickup['name']) : 'Not recorded';
                            final destinationName = destination is Map
                                ? _text(destination['name']) : 'Not recorded';
                            final amount = _amount(data);
                            final method = _text(data['paymentMethod'], 'Not selected');
                            final status = _text(data['paymentStatus'], 'unpaid');
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$pickupName → $destinationName',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                _line('Booking ID', doc.id),
                                _line('Trip status', _text(data['status'])),
                                _line('Driver assigned',
                                    data['driverId'] == null ? 'No' : 'Yes'),
                                _line('Amount due / estimated',
                                    amount == null ? 'Not recorded' : amount.toStringAsFixed(2)),
                                _line('Payment status', status),
                                _line('Payment method', method),
                                if (status == 'simulated')
                                  const Text('Simulation only — no real card payment.',
                                      style: TextStyle(color: Colors.deepOrange)),
                                _line('Created', _date(data['createdAt'])),
                                if (data['completedAt'] != null)
                                  _line('Completed', _date(data['completedAt'])),
                                if (data['paidAt'] != null)
                                  _line('Cash confirmed at', _date(data['paidAt'])),
                              ],
                            );
                          }),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
