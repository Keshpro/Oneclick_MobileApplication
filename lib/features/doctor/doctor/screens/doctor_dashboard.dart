
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/doctor_appointment_service.dart';
import 'doctor_patient_detail_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState
    extends State<DoctorDashboardScreen> {
  static const green = Color(0xFF059669);
  static const dark = Color(0xFF064E3B);

  int _tab = 0;
  String _filter = 'All';

  String get uid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '');
  }

  String _dateText(dynamic value) {
    final date = _date(value);
    if (date == null) return 'Date unavailable';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _cancel(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: const Text(
          'The patient will receive an in-app notification.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await DoctorAppointmentService.cancelAppointment(id);
      _message('Appointment cancelled.');
    } catch (error) {
      _message('Error: $error');
    }
  }

  Future<void> _reschedule(String id) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null || !mounted) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (!selected.isAfter(DateTime.now())) {
      _message('Select a future date and time.');
      return;
    }

    try {
      await DoctorAppointmentService.rescheduleAppointment(
        appointmentId: id,
        date: selected,
        time: time.format(context),
      );
      _message('Appointment rescheduled.');
    } catch (error) {
      _message('Error: $error');
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: green),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _income() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: DoctorAppointmentService.doctorPayments(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Income error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        final payments = snapshot.data!.docs.where((doc) {
          final data = doc.data();
          return data['module'] == 'doctor' &&
              data['method'] == 'card' &&
              data['status'] == 'demo_paid' &&
              data['environment'] == 'demo';
        }).toList();

        final amountMinor = payments.fold<int>(
          0,
          (total, doc) =>
              total +
              ((doc.data()['amountMinor'] as num?)?.toInt() ?? 0),
        );

        return Card(
          color: const Color(0xFFECFDF5),
          child: ListTile(
            leading: const Icon(
              Icons.account_balance_wallet,
              color: green,
              size: 32,
            ),
            title: const Text('Demo Card Income'),
            subtitle: Text(
              '${payments.length} simulated card payments\n'
              'Not actual bank revenue',
            ),
            trailing: Text(
              'LKR ${(amountMinor / 100).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bookingCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final status = (data['status'] ?? '').toString();
    final manageable = [
      'confirmed', 'rescheduled', 'approved'
    ].contains(status.toLowerCase());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (data['patientName'] ??
                      data['userName'] ??
                      'Patient')
                  .toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_dateText(data['appointmentDate'])} '
              '• ${data['time'] ?? ''}',
            ),
            Text('Status: $status'),
            Text(
              'Payment: ${data['paymentStatus'] ?? 'unpaid'}',
            ),
            const Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.person_search),
                  label: const Text('Patient Profile'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorPatientDetailScreen(
                          appointmentData: {
                            ...data,
                            'docId': doc.id,
                          },
                        ),
                      ),
                    );
                  },
                ),
                if (manageable)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text('Reschedule'),
                    onPressed: () => _reschedule(doc.id),
                  ),
                if (manageable)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                    onPressed: () => _cancel(doc.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _home(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final now = DateTime.now();

    final today = docs.where((doc) {
      final date = _date(doc.data()['appointmentDate']);
      return date != null &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).length;

    final confirmed = docs.where((doc) {
      return doc.data()['status'] == 'confirmed';
    }).length;

    final cancelled = docs.where((doc) {
      return doc.data()['status'] == 'cancelled';
    }).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('doctors')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Doctor profile unavailable');
            }

            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }

            final doctor = snapshot.data!.data();

            if (doctor == null) {
              return const Text('Doctor profile not found');
            }

            return Card(
              color: dark,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DOCTOR WORKSPACE',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (doctor['name'] ?? 'Doctor').toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Available for Consultations',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: doctor['isAvailable'] == true,
                      activeTrackColor: green,
                      onChanged: (value) async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('doctors')
                              .doc(uid)
                              .update({'isAvailable': value});
                        } catch (error) {
                          _message('Update failed: $error');
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _stat('Today', '$today', Icons.today),
            _stat('Confirmed', '$confirmed', Icons.check_circle),
            _stat('Cancelled', '$cancelled', Icons.cancel),
          ],
        ),
        const SizedBox(height: 16),
        _income(),
        const SizedBox(height: 20),
        const Text(
          "Today's Appointments",
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...docs.where((doc) {
          final date = _date(doc.data()['appointmentDate']);
          return date != null &&
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).map(_bookingCard),
      ],
    );
  }

  Widget _bookings(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final filtered = docs.where((doc) {
      return _filter == 'All' ||
          doc.data()['status'] == _filter.toLowerCase();
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<String>(
            initialValue: _filter,
            decoration: const InputDecoration(
              labelText: 'Filter Appointments',
              border: OutlineInputBorder(),
            ),
            items: [
              'All',
              'Confirmed',
              'Rescheduled',
              'Cancelled',
              'Awaiting_payment',
            ].map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value.replaceAll('_', ' ')),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _filter = value ?? 'All');
            },
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('No appointments found'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (_, index) =>
                      _bookingCard(filtered[index]),
                ),
        ),
      ],
    );
  }

  Widget _notifications() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: DoctorAppointmentService.notifications(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Notification error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final x = (a.data()['timestamp'] as Timestamp?)
                ?.millisecondsSinceEpoch ?? 0;
            final y = (b.data()['timestamp'] as Timestamp?)
                ?.millisecondsSinceEpoch ?? 0;
            return y.compareTo(x);
          });

        if (docs.isEmpty) {
          return const Center(
            child: Text('No notifications yet'),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, index) {
            final doc = docs[index];
            final data = doc.data();

            return ListTile(
              leading: const Icon(
                Icons.notifications,
                color: green,
              ),
              title: Text((data['title'] ?? '').toString()),
              subtitle: Text(
                (data['message'] ?? '').toString(),
              ),
              trailing: data['isRead'] == true
                  ? null
                  : const Icon(Icons.circle, size: 10),
              onTap: () async {
                try {
                  await doc.reference.update({'isRead': true});
                } catch (error) {
                  _message('Could not mark as read: $error');
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please sign in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('OneClick Doctor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => setState(() => _tab = 2),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: DoctorAppointmentService.doctorAppointments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Firestore error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final x = _date(a.data()['appointmentDate']);
              final y = _date(b.data()['appointmentDate']);
              return (x ?? DateTime(2100))
                  .compareTo(y ?? DateTime(2100));
            });

          if (_tab == 0) return _home(docs);
          if (_tab == 1) return _bookings(docs);
          return _notifications();
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          setState(() => _tab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
