
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oneclick/features/auth/screens/home_screen.dart';
import 'doctor_schedule_screen.dart';
import '../../../auth/screens/login_screen.dart';
import 'appointment_requests_screen.dart';
import 'doctor_profile_manage_screen.dart';
import 'doctor_schedule_manage_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  static const Color _green = Color(0xFF059669);
  static const Color _darkGreen = Color(0xFF064E3B);
  static const Color _background = Color(0xFFF7FAF9);
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _blue = Color(0xFF0284C7);
  static const Color _orange = Color(0xFFD97706);

  int _selectedIndex = 0;
  String _filter = 'All';
  String _search = '';
  bool _updatingAvailability = false;
  bool _rescheduling = false;

  late final TextEditingController _searchController;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

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
        backgroundColor:
            error ? const Color(0xFFDC2626) : _darkGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _open(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _setAvailability(bool value) async {
    final uid = _uid;

    if (uid == null || _updatingAvailability) return;

    setState(() => _updatingAvailability = true);

    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .update({'isAvailable': value});

      _message(
        value
            ? 'You are available for consultations'
            : 'You are now offline',
      );
    } catch (e) {
      _message(
        'Could not update availability: $e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => _updatingAvailability = false);
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Log out?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your doctor account?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      _message('Logout failed: $e', error: true);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod;

    final minute = time.minute.toString().padLeft(2, '0');

    final period = time.period == DayPeriod.am
        ? 'AM'
        : 'PM';

    return '$hour:$minute $period';
  }

  DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();

    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  bool _isToday(dynamic value) {
    final date = _parseDate(value);
    if (date == null) return false;

    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _reschedule(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    if (_rescheduling) return;

    final data = doc.data();
    final now = DateTime.now();

    final existingDate = _parseDate(data['date']);

    final initialDate = existingDate != null &&
            !existingDate.isBefore(
              DateTime(now.year, now.month, now.day),
            )
        ? existingDate
        : now;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select new appointment date',
    );

    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select new appointment time',
    );

    if (selectedTime == null || !mounted) return;

    final appointmentDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (!appointmentDateTime.isAfter(DateTime.now())) {
      _message(
        'Please select a future date and time.',
        error: true,
      );
      return;
    }

    final formattedDate = _formatDate(selectedDate);
    final formattedTime = _formatTime(selectedTime);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Confirm Reschedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update this appointment to:',
            ),
            const SizedBox(height: 16),
            _dialogInfo(
              Icons.calendar_today_rounded,
              formattedDate,
            ),
            const SizedBox(height: 10),
            _dialogInfo(
              Icons.access_time_rounded,
              formattedTime,
            ),
            const SizedBox(height: 14),
            const Text(
              'The patient will receive an in-app notification.',
              style: TextStyle(
                color: _muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _green,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _rescheduling = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      batch.update(doc.reference, {
        'date': formattedDate,
        'time': formattedTime,
        'status': 'Rescheduled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final patientUid =
          (data['userId'] ?? '').toString();

      if (patientUid.isNotEmpty) {
        final notificationRef =
            firestore.collection('notifications').doc();

        batch.set(notificationRef, {
          'userId': patientUid,
          'userEmail':
              (data['userEmail'] ?? '').toString(),
          'title': 'Appointment Rescheduled',
          'message':
              'Your doctor rescheduled your appointment '
              'to $formattedDate at $formattedTime.',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      _message(
        'Appointment rescheduled successfully!',
      );
    } catch (e) {
      _message(
        'Rescheduling failed: $e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => _rescheduling = false);
      }
    }
  }

  Widget _dialogInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: _green, size: 20),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _onNavigationSelected(int index) {
    if (index == 2) {
      _open(const DoctorScheduleScreen());
      return;
    }

    if (index == 3) {
      _open(const DoctorProfileManageScreen());
      return;
    }

    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in as a doctor.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _background,

      // MAIN APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OneClick Health',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _text,
                      fontSize: 18,
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
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Appointments',
            onPressed: () {
              setState(() => _selectedIndex = 1);
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: _green,
              size: 25,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // MAIN BODY
      body: Column(
        children: [
          // ALWAYS VISIBLE ACCOUNT ACTIONS
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              14, 5, 14, 15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _topAction(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Customer Mode',
                    color: _orange,
                    onTap: () =>
                        _open(const HomeScreen()),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _topAction(
                    icon: Icons.manage_accounts_rounded,
                    title: 'Manage Account',
                    color: _blue,
                    onTap: () => _open(
                      const DoctorProfileManageScreen(),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _topAction(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    color: const Color(0xFFDC2626),
                    onTap: _logout,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<
                DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .doc(uid)
                  .snapshots(),
              builder: (context, doctorSnapshot) {
                if (doctorSnapshot.hasError) {
                  return _errorState(
                    'Unable to load doctor profile.',
                  );
                }

                if (!doctorSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final doctor =
                    doctorSnapshot.data?.data() ??
                        <String, dynamic>{};

                final provider =
                    doctor['providerDetails'] is Map
                        ? Map<String, dynamic>.from(
                            doctor['providerDetails'] as Map,
                          )
                        : <String, dynamic>{};

                final name =
                    (doctor['name'] ?? 'Doctor').toString();

                final specialty =
                    (provider['specialization'] ??
                            'General Physician')
                        .toString();

                final online =
                    doctor['isAvailable'] == true;

                final fee =
                    doctor['consultationFee'] is num
                        ? (doctor['consultationFee'] as num)
                            .toDouble()
                        : 2500.0;

                return StreamBuilder<
                    QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('appointments')
                      .where('doctorId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _errorState(
                        'Unable to load appointments.',
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    final approved = docs.where((doc) {
                      final status = (doc.data()['status'] ??
                              '')
                          .toString()
                          .toLowerCase();

                      return status == 'approved';
                    }).length;

                    final pending = docs.where((doc) {
                      final status = (doc.data()['status'] ??
                              '')
                          .toString()
                          .toLowerCase();

                      return [
                        'pending',
                        'upcoming',
                        'requested',
                      ].contains(status);
                    }).length;

                    final today = docs.where((doc) {
                      return _isToday(doc.data()['date']);
                    }).length;

                    final visible = docs.where((doc) {
                      final data = doc.data();

                      final status =
                          (data['status'] ?? 'Upcoming')
                              .toString();

                      final matchesStatus =
                          _filter == 'All' ||
                              status.toLowerCase() ==
                                  _filter.toLowerCase();

                      final query = _search
                          .trim()
                          .toLowerCase();

                      final patientName =
                          (data['patientName'] ?? '')
                              .toString()
                              .toLowerCase();

                      final email =
                          (data['userEmail'] ?? '')
                              .toString()
                              .toLowerCase();

                      final matchesSearch =
                          query.isEmpty ||
                              patientName.contains(query) ||
                              email.contains(query);

                      return matchesStatus && matchesSearch;
                    }).toList();

                    visible.sort((a, b) {
                      final dateA = _parseDate(
                        a.data()['date'],
                      );
                      final dateB = _parseDate(
                        b.data()['date'],
                      );

                      if (dateA == null && dateB == null) {
                        return 0;
                      }
                      if (dateA == null) return 1;
                      if (dateB == null) return -1;

                      return dateA.compareTo(dateB);
                    });

                    return IndexedStack(
                      index: _selectedIndex,
                      children: [
                        _home(
                          name: name,
                          specialty: specialty,
                          online: online,
                          fee: fee,
                          docs: docs,
                          today: today,
                          pending: pending,
                          approved: approved,
                        ),
                        _appointments(visible),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // FIXED BOTTOM NAVIGATION
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFD1FAE5),
          labelTextStyle:
              WidgetStateProperty.resolveWith<TextStyle>(
            (states) {
              final selected =
                  states.contains(WidgetState.selected);

              return TextStyle(
                color: selected
                    ? _darkGreen
                    : const Color(0xFF475569),
                fontSize: 12,
                fontWeight: selected
                    ? FontWeight.w800
                    : FontWeight.w600,
              );
            },
          ),
          iconTheme:
              WidgetStateProperty.resolveWith<IconThemeData>(
            (states) {
              final selected =
                  states.contains(WidgetState.selected);

              return IconThemeData(
                color: selected
                    ? _green
                    : const Color(0xFF64748B),
                size: 25,
              );
            },
          ),
        ),
        child: NavigationBar(
          height: 76,
          elevation: 2,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          indicatorColor: const Color(0xFFD1FAE5),
          selectedIndex: _selectedIndex,
          labelBehavior:
              NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: _onNavigationSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon:
                  Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon:
                  Icon(Icons.calendar_month_rounded),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon:
                  Icon(Icons.event_note_rounded),
              label: 'Schedule',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon:
                  Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // TOP ACTION BUTTONS
  Widget _topAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 7),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HOME DASHBOARD
  Widget _home({
    required String name,
    required String specialty,
    required bool online,
    required double fee,
    required List<
            QueryDocumentSnapshot<Map<String, dynamic>>>
        docs,
    required int today,
    required int pending,
    required int approved,
  }) {
    final todayDocs = docs.where((doc) {
      return _isToday(doc.data()['date']);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
      children: [
        // WELCOME CARD
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF064E3B),
                Color(0xFF059669),
              ],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WELCOME BACK, DOCTOR',
                style: TextStyle(
                  color: Color(0xFFA7F3D0),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.16,
                      ),
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
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
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialty,
                          style: const TextStyle(
                            color: Color(0xFFD1FAE5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: online
                          ? const Color(0xFF86EFAC)
                          : Colors.white54,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        online
                            ? 'Available for consultations'
                            : 'Currently offline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: online,
                      activeTrackColor:
                          const Color(0xFF34D399),
                      onChanged: _updatingAvailability
                          ? null
                          : _setAvailability,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

        _heading(
          'Overview',
          'Your practice at a glance',
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _stat(
                title: 'Today',
                value: '$today',
                icon: Icons.today_rounded,
                color: _blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _stat(
                title: 'Pending',
                value: '$pending',
                icon: Icons.hourglass_top_rounded,
                color: _orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _stat(
                title: 'Approved',
                value: '$approved',
                icon: Icons.verified_rounded,
                color: _green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),

        Container(
          padding: const EdgeInsets.all(17),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              _iconBox(
                Icons.account_balance_wallet_rounded,
                _green,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated booking value',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LKR ${(approved * fee).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: _darkGreen,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Approved bookings × current fee',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                      ),
                    ),
                    const Text(
                      'Not confirmed payment revenue',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 27),

        _heading(
          'Quick Access',
          'Everything you need, one tap away',
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _action(
                title: 'Appointments',
                subtitle: 'Manage bookings',
                icon: Icons.calendar_month_rounded,
                color: _green,
                onTap: () => _open(
                  const AppointmentRequestsScreen(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _action(
                title: 'My Schedule',
                subtitle: 'Fees & holidays',
                icon: Icons.event_available_rounded,
                color: _purple,
                onTap: () => _open(
                  const DoctorScheduleManageScreen(),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _action(
                title: 'Manage Account',
                subtitle: 'Update profile',
                icon: Icons.manage_accounts_rounded,
                color: _blue,
                onTap: () => _open(
                  const DoctorProfileManageScreen(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _action(
                title: 'Customer Mode',
                subtitle: 'Switch workspace',
                icon: Icons.swap_horiz_rounded,
                color: _orange,
                onTap: () =>
                    _open(const HomeScreen()),
              ),
            ),
          ],
        ),

        const SizedBox(height: 27),

        Row(
          children: [
            const Expanded(
              child: Text(
                "Today's Appointments",
                style: TextStyle(
                  color: _text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _selectedIndex = 1);
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: _green,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        if (todayDocs.isEmpty)
          _empty(
            'No appointments scheduled for today',
          )
        else
          ...todayDocs
              .take(4)
              .map(_appointmentCard),
      ],
    );
  }

  // BOOKINGS PAGE
  Widget _appointments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        docs,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            18, 20, 18, 14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heading(
                'Patient Appointments',
                'Search and manage bookings',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _search = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search patient name or email',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: _green,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: _border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: _green,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'All',
                    'Pending',
                    'Approved',
                    'Rescheduled',
                    'Cancelled',
                  ].map((item) {
                    final selected = _filter == item;

                    return Padding(
                      padding:
                          const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(item),
                        selected: selected,
                        selectedColor:
                            const Color(0xFFD1FAE5),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: selected
                              ? _green
                              : _border,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? _darkGreen
                              : _muted,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) {
                          setState(() => _filter = item);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: docs.isEmpty
              ? _empty('No matching appointments')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return _appointmentCard(docs[index]);
                  },
                ),
        ),
      ],
    );
  }

  // APPOINTMENT CARD
  Widget _appointmentCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final name = (data['patientName'] ??
            data['userEmail'] ??
            'Patient')
        .toString();

    final status =
        (data['status'] ?? 'Upcoming').toString();

    final rawDate = data['date'];
    final parsedDate = _parseDate(rawDate);

    final date = parsedDate != null
        ? _formatDate(parsedDate)
        : (rawDate ?? 'Date not set').toString();

    final time =
        (data['time'] ?? 'Time not set').toString();

    final type =
        (data['type'] ?? 'In-person').toString();

    final lower = status.toLowerCase();

    final Color statusColor;

    if (lower == 'approved') {
      statusColor = _green;
    } else if (lower == 'cancelled') {
      statusColor = const Color(0xFFDC2626);
    } else if (lower == 'rescheduled') {
      statusColor = _purple;
    } else {
      statusColor = _orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(
                Icons.person_rounded,
                _blue,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              _meta(
                Icons.calendar_today_outlined,
                date,
              ),
              _meta(
                Icons.access_time_rounded,
                time,
              ),
              _meta(
                Icons.medical_information_outlined,
                type,
              ),
            ],
          ),
          if (lower != 'cancelled') ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _rescheduling
                    ? null
                    : () => _reschedule(doc),
                icon: const Icon(
                  Icons.edit_calendar_rounded,
                  size: 18,
                ),
                label: const Text('Reschedule'),
                style: TextButton.styleFrom(
                  foregroundColor: _purple,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: _muted,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // OVERVIEW STAT CARD
  Widget _stat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 16,
      ),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(
              color: _text,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
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

  // QUICK ACTION CARD
  Widget _action({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBox(icon, color),
              const SizedBox(height: 15),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: color,
        size: 23,
      ),
    );
  }

  Widget _heading(String title, String subtitle) {
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
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: _border),
    );
  }

  Widget _empty(String message) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 35,
        ),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                color: _green,
                size: 32,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
