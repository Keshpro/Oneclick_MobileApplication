
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppointmentRequestsScreen extends StatefulWidget {
  const AppointmentRequestsScreen({super.key});

  @override
  State<AppointmentRequestsScreen> createState() =>
      _AppointmentRequestsScreenState();
}

class _AppointmentRequestsScreenState
    extends State<AppointmentRequestsScreen> {
  static const Color _green = Color(0xFF059669);
  static const Color _darkGreen = Color(0xFF064E3B);
  static const Color _background = Color(0xFFF7FAF9);
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _blue = Color(0xFF0284C7);
  static const Color _orange = Color(0xFFD97706);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _red = Color(0xFFDC2626);

  final TextEditingController _searchController =
      TextEditingController();

  String _search = '';
  String _filter = 'All';
  String? _processingId;

  User? get _doctor => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _message(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? _red : _darkGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  bool _isPending(String status) {
    return [
      'pending',
      'upcoming',
      'requested',
    ].contains(status.toLowerCase());
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return _green;
      case 'cancelled':
        return _red;
      case 'rescheduled':
        return _purple;
      case 'upcoming':
        return _blue;
      default:
        return _orange;
    }
  }

  String _dateText(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }

    if (value == null) return 'Not scheduled';
    return value.toString();
  }

  Future<void> _updateAppointmentStatus(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String newStatus,
  ) async {
    if (_processingId != null) return;

    final data = doc.data();
    final appointmentId =
        (data['id'] ?? doc.id).toString();
    final patientEmail =
        (data['userEmail'] ?? 'Patient').toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Row(
          children: [
            Icon(
              newStatus == 'Approved'
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: newStatus == 'Approved'
                  ? _green
                  : _red,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                newStatus == 'Approved'
                    ? 'Accept booking?'
                    : 'Decline booking?',
                style: const TextStyle(fontSize: 19),
              ),
            ),
          ],
        ),
        content: Text(
          newStatus == 'Approved'
              ? 'Confirm appointment $appointmentId '
                  'for $patientEmail?'
              : 'Are you sure you want to decline '
                  'appointment $appointmentId?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Go Back'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: newStatus == 'Approved'
                  ? _green
                  : _red,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: Text(
              newStatus == 'Approved'
                  ? 'Accept'
                  : 'Decline',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _processingId = doc.id);

    try {
      final firestore = FirebaseFirestore.instance;

      // Atomic appointment update and activity log.
      // The transaction checks the current status to
      // avoid accepting an already processed request.
      await firestore.runTransaction((transaction) async {
        final latest = await transaction.get(doc.reference);

        if (!latest.exists) {
          throw StateError('Appointment no longer exists.');
        }

        final latestStatus =
            (latest.data()?['status'] ?? '')
                .toString();

        if (!_isPending(latestStatus)) {
          throw StateError(
            'This appointment has already been processed.',
          );
        }

        transaction.update(doc.reference, {
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final logRef =
            firestore.collection('activity_logs').doc();

        transaction.set(logRef, {
          'action': 'Appointment $newStatus',
          'details':
              'Appointment $appointmentId for '
              '$patientEmail was set to $newStatus.',
          'performedBy': _doctor?.email ?? 'Doctor',
          'doctorId': _doctor?.uid,
          'appointmentId': doc.id,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      _message(
        newStatus == 'Approved'
            ? 'Appointment accepted successfully!'
            : 'Appointment declined successfully.',
      );
    } catch (e) {
      _message(
        'Unable to update appointment: $e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => _processingId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _doctor?.uid;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        toolbarHeight: 66,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointments',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Doctor workspace',
              style: TextStyle(
                color: _muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: _green,
              size: 23,
            ),
          ),
        ],
      ),
      body: uid == null
          ? _emptyState(
              'Doctor account required',
              'Please sign in to manage appointments.',
            )
          : StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('doctorId', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _emptyState(
                    'Unable to load appointments',
                    '${snapshot.error}',
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _green,
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                final pending = docs.where((doc) {
                  return _isPending(
                    (doc.data()['status'] ?? '')
                        .toString(),
                  );
                }).length;

                final approved = docs.where((doc) {
                  return (doc.data()['status'] ?? '')
                          .toString()
                          .toLowerCase() ==
                      'approved';
                }).length;

                final cancelled = docs.where((doc) {
                  return (doc.data()['status'] ?? '')
                          .toString()
                          .toLowerCase() ==
                      'cancelled';
                }).length;

                final filtered = docs.where((doc) {
                  final data = doc.data();
                  final status =
                      (data['status'] ?? 'Upcoming')
                          .toString();

                  final matchesFilter = _filter == 'All' ||
                      (_filter == 'Pending'
                          ? _isPending(status)
                          : status.toLowerCase() ==
                              _filter.toLowerCase());

                  final query = _search.trim().toLowerCase();

                  final name =
                      (data['patientName'] ?? '')
                          .toString()
                          .toLowerCase();

                  final email =
                      (data['userEmail'] ?? '')
                          .toString()
                          .toLowerCase();

                  final bookingId =
                      (data['id'] ?? doc.id)
                          .toString()
                          .toLowerCase();

                  return matchesFilter &&
                      (query.isEmpty ||
                          name.contains(query) ||
                          email.contains(query) ||
                          bookingId.contains(query));
                }).toList();

                filtered.sort((a, b) {
                  final dateA =
                      _dateText(a.data()['date']);
                  final dateB =
                      _dateText(b.data()['date']);
                  return dateA.compareTo(dateB);
                });

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          18, 20, 18, 0,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _hero(pending),
                            const SizedBox(height: 24),
                            _sectionTitle(
                              'Booking Overview',
                              'Real-time appointment summary',
                            ),
                            const SizedBox(height: 13),
                            Row(
                              children: [
                                Expanded(
                                  child: _statCard(
                                    'Pending',
                                    '$pending',
                                    Icons.hourglass_top_rounded,
                                    _orange,
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: _statCard(
                                    'Approved',
                                    '$approved',
                                    Icons.verified_rounded,
                                    _green,
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: _statCard(
                                    'Declined',
                                    '$cancelled',
                                    Icons.cancel_outlined,
                                    _red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 26),
                            _sectionTitle(
                              'Patient Requests',
                              'Review and manage appointments',
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() => _search = value);
                              },
                              decoration: InputDecoration(
                                hintText:
                                    'Search patient or booking ID',
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: _green,
                                ),
                                suffixIcon: _search.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(
                                            () => _search = '',
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.close_rounded,
                                        ),
                                      )
                                    : null,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _border,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _green,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 13),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  'All',
                                  'Pending',
                                  'Approved',
                                  'Rescheduled',
                                  'Cancelled',
                                ].map((filter) {
                                  final selected =
                                      _filter == filter;

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      right: 8,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(filter),
                                      selected: selected,
                                      showCheckmark: false,
                                      selectedColor:
                                          const Color(0xFFD1FAE5),
                                      backgroundColor:
                                          Colors.white,
                                      side: BorderSide(
                                        color: selected
                                            ? _green
                                            : _border,
                                      ),
                                      labelStyle: TextStyle(
                                        color: selected
                                            ? _darkGreen
                                            : _muted,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                      onSelected: (_) {
                                        setState(
                                          () => _filter = filter,
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 17),
                            Text(
                              '${filtered.length} appointments found',
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 13),
                          ],
                        ),
                      ),
                    ),
                    if (filtered.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: _emptyState(
                            'No matching appointments',
                            'Try another search or filter.',
                          ),
                        ),
                      )
                    else
                      SliverList.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(
                              18, 0, 18, 12,
                            ),
                            child: _appointmentCard(
                              filtered[index],
                            ),
                          );
                        },
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 30),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _hero(int pending) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _darkGreen,
            _green,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Manage your\npatient bookings.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            pending == 0
                ? 'You are all caught up!'
                : '$pending appointment requests need your attention.',
            style: const TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 15,
      ),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: _text,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final patientName =
        (data['patientName'] ?? data['userEmail'] ?? 'Patient')
            .toString();

    final patientEmail =
        (data['userEmail'] ?? '').toString();

    final appointmentId =
        (data['id'] ?? doc.id).toString();

    final date = _dateText(data['date']);
    final time = (data['time'] ?? 'Not set').toString();
    final type = (data['type'] ?? 'In-person').toString();
    final status = (data['status'] ?? 'Upcoming').toString();
    final reason =
        (data['reason'] ?? '').toString().trim();

    final color = _statusColor(status);
    final pending = _isPending(status);
    final processing = _processingId == doc.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: _green,
                  size: 25,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Booking #$appointmentId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                      ),
                    ),
                    if (patientEmail.isNotEmpty &&
                        patientEmail != patientName) ...[
                      const SizedBox(height: 3),
                      Text(
                        patientEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusChip(status, color),
              _statusChip(type, _blue),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 14),
          _detailRow(
            Icons.calendar_today_rounded,
            'Date',
            date,
            _blue,
          ),
          const SizedBox(height: 10),
          _detailRow(
            Icons.access_time_rounded,
            'Time',
            time,
            _purple,
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    color: _orange,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (pending) ...[
            const SizedBox(height: 17),
            if (processing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    color: _green,
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _processingId != null
                          ? null
                          : () => _updateAppointmentStatus(
                                doc,
                                'Cancelled',
                              ),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                      ),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _red,
                        side: const BorderSide(
                          color: _red,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _processingId != null
                          ? null
                          : () => _updateAppointmentStatus(
                                doc,
                                'Approved',
                              ),
                      icon: const Icon(
                        Icons.check_rounded,
                        size: 18,
                      ),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _text,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _border),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(17),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                color: _green,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
