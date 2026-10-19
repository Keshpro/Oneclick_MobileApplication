
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'worker_edit_profile_screen.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() =>
      _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  static const Color _primaryNavy = Color(0xFF1E293B);
  static const Color _bgCanvas = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  User? get _currentUser =>
      FirebaseAuth.instance.currentUser;

  bool _updatingAvailability = false;

  // ================================
  // UPDATE ONLINE / OFFLINE STATUS
  // ================================

  Future<void> _updateAvailability(
    String uid,
    bool value,
  ) async {
    setState(() => _updatingAvailability = true);

    try {
      await _firestore
          .collection('workers')
          .doc(uid)
          .update({
        'isAvailable': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update availability: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingAvailability = false);
      }
    }
  }

  // ================================
  // UPDATE JOB STATUS
  // ================================

  Future<void> _updateJobStatus(
    String appointmentId,
    String newStatus,
  ) async {
    try {
      await _firestore
          .collection('work_appointments')
          .doc(appointmentId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Job status updated to $newStatus',
          ),
          backgroundColor:
              newStatus == 'Accepted' ||
                      newStatus == 'Completed'
                  ? Colors.green
                  : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update status: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================================
  // OPEN EDIT PROFILE SCREEN
  // ================================

  void _openEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const WorkerEditProfileScreen(),
      ),
    );
  }

  // ================================
  // MAIN DASHBOARD
  // ================================

  @override
  Widget build(BuildContext context) {
    final uid = _currentUser?.uid;

    return Scaffold(
      backgroundColor: _bgCanvas,

      appBar: AppBar(
        title: const Text(
          'Worker Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,

        actions: [
          if (uid != null)
            StreamBuilder<
                DocumentSnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('workers')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final worker = snapshot.data?.data();
                final isOnline =
                    worker?['isAvailable'] == true;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isOnline ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isOnline
                            ? const Color(0xFF4ADE80)
                            : Colors.grey,
                      ),
                    ),
                    Switch(
                      value: isOnline,
                      activeColor:
                          const Color(0xFF4ADE80),
                      onChanged:
                          _updatingAvailability ||
                                  !snapshot.hasData ||
                                  !snapshot.data!.exists
                              ? null
                              : (value) =>
                                  _updateAvailability(
                                    uid,
                                    value,
                                  ),
                    ),
                    const SizedBox(width: 8),
                  ],
                );
              },
            ),
        ],
      ),

      body: uid == null
          ? const Center(
              child: Text(
                'Please log in as a worker.',
              ),
            )
          : CustomScrollView(
              physics:
                  const BouncingScrollPhysics(),
              slivers: [
                // WORKER PROFILE HEADER
                SliverToBoxAdapter(
                  child: _buildWorkerProfileHeader(
                    uid,
                  ),
                ),

                // METRICS
                SliverToBoxAdapter(
                  child: _buildMetricsSummary(uid),
                ),

                // SECTION TITLE
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    10,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Job Requests & Appointments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                  ),
                ),

                // REAL-TIME APPOINTMENTS
                _buildAppointmentsList(uid),
              ],
            ),
    );
  }

  // ================================
  // WORKER PROFILE HEADER
  // ================================

  Widget _buildWorkerProfileHeader(
    String uid,
  ) {
    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('workers')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};

        final name =
            (data['name'] ?? 'Professional Worker')
                .toString();

        final category =
            (data['category'] ?? 'Quick Fix Provider')
                .toString();

        final providerDetails =
            Map<String, dynamic>.from(
          data['providerDetails'] is Map
              ? data['providerDetails'] as Map
              : {},
        );

        final rate =
            providerDetails['hourlyRate'] ??
                data['hourlyRate'] ??
                '1500';

        return Container(
          color: _primaryNavy,
          padding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            24,
          ),
          child: Row(
            children: [
              // PROFILE AVATAR
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    Colors.white.withOpacity(0.12),
                child: Text(
                  name.isNotEmpty
                      ? name[0].toUpperCase()
                      : 'W',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // WORKER DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '$category • LKR $rate/hr',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // NEW EDIT PROFILE BUTTON
              IconButton(
                tooltip: 'Edit Profile',
                onPressed: _openEditProfile,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================================
  // METRICS SUMMARY
  // ================================

  Widget _buildMetricsSummary(
    String uid,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _metricCard(
              title: 'Pending Jobs',
              stream: _firestore
                  .collection('work_appointments')
                  .where(
                    'workerId',
                    isEqualTo: uid,
                  )
                  .where(
                    'status',
                    isEqualTo: 'Pending',
                  )
                  .snapshots(),
              icon: Icons.hourglass_top_rounded,
              color: const Color(0xFFF59E0B),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _metricCard(
              title: 'Completed',
              stream: _firestore
                  .collection('work_appointments')
                  .where(
                    'workerId',
                    isEqualTo: uid,
                  )
                  .where(
                    'status',
                    isEqualTo: 'Completed',
                  )
                  .snapshots(),
              icon:
                  Icons.check_circle_outline_rounded,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // METRIC CARD
  // ================================

  Widget _metricCard({
    required String title,
    required Stream<
            QuerySnapshot<Map<String, dynamic>>>
        stream,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                StreamBuilder<
                    QuerySnapshot<
                        Map<String, dynamic>>>(
                  stream: stream,
                  builder: (context, snapshot) {
                    final count =
                        snapshot.data?.docs.length ?? 0;

                    return Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    );
                  },
                ),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // APPOINTMENTS LIST
  // ================================

  Widget _buildAppointmentsList(
    String uid,
  ) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('work_appointments')
          .where(
            'workerId',
            isEqualTo: uid,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to load appointments: '
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final docs =
            snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 40,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons
                        .assignment_turned_in_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'No assigned appointments yet.',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            30,
          ),
          sliver: SliverList(
            delegate:
                SliverChildBuilderDelegate(
              (context, index) {
                final doc = docs[index];
                final booking = doc.data();

                final customerEmail =
                    (booking['customerEmail'] ??
                            'Customer')
                        .toString();

                final address =
                    (booking['address'] ??
                            'No address provided')
                        .toString();

                final issue =
                    (booking['issue'] ??
                            'Maintenance Request')
                        .toString();

                final date =
                    (booking['date'] ?? 'N/A')
                        .toString();

                final time =
                    (booking['time'] ?? 'N/A')
                        .toString();

                final status =
                    (booking['status'] ?? 'Pending')
                        .toString();

                Color statusColor =
                    const Color(0xFFF59E0B);

                if (status == 'Accepted') {
                  statusColor =
                      const Color(0xFF10B981);
                }

                if (status == 'Completed') {
                  statusColor =
                      const Color(0xFF2563EB);
                }

                if (status == 'Rejected') {
                  statusColor =
                      const Color(0xFFEF4444);
                }

                return Card(
                  elevation: 0,
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                    side: const BorderSide(
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // CUSTOMER & STATUS
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customerEmail,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 15,
                                  color: _textDark,
                                ),
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: statusColor
                                    .withOpacity(0.1),
                                borderRadius:
                                    BorderRadius
                                        .circular(10),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ADDRESS
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: _textMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                address,
                                style:
                                    const TextStyle(
                                  fontSize: 12.5,
                                  color: _textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // DATE & TIME
                        Row(
                          children: [
                            const Icon(
                              Icons.event_outlined,
                              size: 16,
                              color: _textMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '$date at $time',
                                style:
                                    const TextStyle(
                                  fontSize: 12.5,
                                  color: _textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ISSUE
                        if (issue.isNotEmpty) ...[
                          const SizedBox(height: 8),

                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(10),
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(0xFFF1F5F9),
                              borderRadius:
                                  BorderRadius
                                      .circular(10),
                            ),
                            child: Text(
                              'Issue: $issue',
                              style:
                                  const TextStyle(
                                fontSize: 12,
                                color:
                                    Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // PENDING JOB ACTIONS
                        if (status == 'Pending') ...[
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      _updateJobStatus(
                                    doc.id,
                                    'Rejected',
                                  ),
                                  style:
                                      OutlinedButton
                                          .styleFrom(
                                    foregroundColor:
                                        Colors.red,
                                    side:
                                        const BorderSide(
                                      color: Colors.red,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(10),
                                    ),
                                  ),
                                  child:
                                      const Text('Decline'),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _updateJobStatus(
                                    doc.id,
                                    'Accepted',
                                  ),
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    backgroundColor:
                                        const Color(
                                            0xFF10B981),
                                    foregroundColor:
                                        Colors.white,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Accept Job',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]

                        // ACCEPTED JOB ACTION
                        else if (status == 'Accepted') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _updateJobStatus(
                                doc.id,
                                'Completed',
                              ),
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    _primaryNavy,
                                foregroundColor:
                                    Colors.white,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(10),
                                ),
                              ),
                              child: const Text(
                                'Mark as Completed',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
              childCount: docs.length,
            ),
          ),
        );
      },
    );
  }
}
