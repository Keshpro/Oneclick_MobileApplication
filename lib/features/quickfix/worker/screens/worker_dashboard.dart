
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'worker_edit_profile_screen.dart';

class WorkerDashboard extends StatefulWidget {
  final VoidCallback? onSignedOut;
  final VoidCallback? onSwitchToUserMode;

  const WorkerDashboard({
    super.key,
    this.onSignedOut,
    this.onSwitchToUserMode,
  });

  @override
  State<WorkerDashboard> createState() =>
      _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  // ======================================================
  // THEME
  // ======================================================

  static const Color navy = Color(0xFF1E293B);
  static const Color primary = Color(0xFF087F6D);
  static const Color primarySoft = Color(0xFFE6F4F1);
  static const Color background = Color(0xFFF8FAFC);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color line = Color(0xFFE2E8F0);

  static const Color green = Color(0xFF059669);
  static const Color amber = Color(0xFFD97706);
  static const Color blue = Color(0xFF2563EB);
  static const Color red = Color(0xFFDC2626);

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  late final Stream<User?> _authStream =
      _auth.authStateChanges();

  int _tab = 0;

  String _filter = 'All';

  bool _availabilityBusy = false;
  bool _accountBusy = false;

  final Set<String> _busyIds = {};

  static const List<String> _filters = [
    'All',
    'Today',
    'Pending',
    'Approved',
    'Completed',
    'Rejected',
    'Cancelled',
  ];

  // ======================================================
  // AUTHENTICATION AND STREAMS
  // ======================================================

  String get uid => _auth.currentUser?.uid ?? '';

  String? _streamUid;

  Stream<DocumentSnapshot<Map<String, dynamic>>>?
      _profileStream;

  Stream<QuerySnapshot<Map<String, dynamic>>>?
      _bookingStream;

  Stream<QuerySnapshot<Map<String, dynamic>>>?
      _paymentStream;

  Stream<QuerySnapshot<Map<String, dynamic>>>?
      _notificationStream;

  void _bindStreams(String userId) {
    if (_streamUid == userId) return;

    _streamUid = userId;

    _profileStream = _db
        .collection('workers')
        .doc(userId)
        .snapshots();

    _bookingStream = _db
        .collection('work_appointments')
        .where('workerId', isEqualTo: userId)
        .snapshots();

    _paymentStream = _db
        .collection('payments')
        .where('workerId', isEqualTo: userId)
        .where('module', isEqualTo: 'quickfix')
        .snapshots();

    _notificationStream = _db
        .collection('quickfix_notifications')
        .where('receiverId', isEqualTo: userId)
        .snapshots();
  }

  // ======================================================
  // HELPERS
  // ======================================================

  String _text(dynamic value, [String fallback = '—']) {
    final result = value?.toString().trim() ?? '';

    return result.isEmpty ? fallback : result;
  }

  String _status(Map<String, dynamic> data) {
    return _text(data['status'], 'Unknown')
        .toLowerCase();
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
        return 'Approved';

      case 'pending':
        return 'Pending';

      case 'completed':
        return 'Completed';

      case 'rejected':
        return 'Rejected';

      case 'cancelled':
        return 'Cancelled';

      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
        return green;

      case 'completed':
        return blue;

      case 'rejected':
      case 'cancelled':
        return red;

      case 'pending':
        return amber;

      default:
        return muted;
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }

  DateTime? _appointmentDate(
    Map<String, dynamic> data,
  ) {
    return _parseDate(data['appointmentDate']) ??
        _parseDate(data['date']);
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;

    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isThisMonth(DateTime? date) {
    if (date == null) return false;

    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month;
  }

  String _dateText(DateTime? date) {
    if (date == null) return 'Date unavailable';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _dateTimeText(DateTime? date) {
    if (date == null) return 'Date unavailable';

    final time = TimeOfDay.fromDateTime(date);

    return '${_dateText(date)} at ${time.format(context)}';
  }

  int _amountMinor(Map<String, dynamic> data) {
    final value = data['amountMinor'];

    if (value is num &&
        value.isFinite &&
        value >= 0 &&
        value == value.toInt()) {
      return value.toInt();
    }

    return 0;
  }

  String _money(int minor) {
    final whole = minor ~/ 100;

    final cents =
        (minor % 100).toString().padLeft(2, '0');

    final digits = whole.toString();

    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[i]);
    }

    return 'LKR $buffer.$cents';
  }

  String _initial(String name) {
    final value = name.trim();

    return value.isEmpty
        ? 'W'
        : value.characters.first.toUpperCase();
  }

  void _message(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? red : navy,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    destructive ? red : primary,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(action),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  // ======================================================
  // AVAILABILITY MANAGEMENT
  // ======================================================

  Future<void> _updateAvailability(bool value) async {
    final userId = uid;

    if (userId.isEmpty || _availabilityBusy) return;

    setState(() => _availabilityBusy = true);

    try {
      await _db
          .collection('workers')
          .doc(userId)
          .update({
        'isAvailable': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _message(
        value
            ? 'You are now available for work.'
            : 'You are now offline.',
      );
    } catch (_) {
      _message(
        'Could not update availability.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => _availabilityBusy = false);
      }
    }
  }

  // ======================================================
  // BOOKING STATUS MANAGEMENT
  // ======================================================

  Future<void> _updateJobStatus(
    String appointmentId,
    String newStatus,
  ) async {
    final userId = uid;

    if (userId.isEmpty ||
        _busyIds.contains(appointmentId)) {
      return;
    }

    final confirmed = await _confirm(
      title: '${_statusLabel(newStatus)} appointment?',
      message: newStatus == 'Completed'
          ? 'Confirm that the requested service has been completed.'
          : 'Confirm this appointment status update.',
      action: newStatus == 'Accepted'
          ? 'Approve'
          : newStatus == 'Rejected'
              ? 'Reject'
              : 'Complete',
      destructive: newStatus == 'Rejected',
    );

    if (!confirmed ||
        !mounted ||
        uid != userId ||
        _busyIds.contains(appointmentId)) {
      return;
    }

    setState(() => _busyIds.add(appointmentId));

    try {
      final reference = _db
          .collection('work_appointments')
          .doc(appointmentId);

      await _db.runTransaction((transaction) async {
        final snapshot =
            await transaction.get(reference);

        if (!snapshot.exists) {
          throw StateError('Appointment not found.');
        }

        final data = snapshot.data()!;

        if (data['workerId'] != userId ||
            uid != userId) {
          throw StateError('Unauthorized appointment.');
        }

        final serviceType = data['serviceType'];

        if (serviceType != null &&
            serviceType != 'quickfix') {
          throw StateError('Invalid service type.');
        }

        final currentStatus = _status(data);

        final validTransition =
            (currentStatus == 'pending' &&
                (newStatus == 'Accepted' ||
                    newStatus == 'Rejected')) ||
            ((currentStatus == 'accepted' ||
                    currentStatus == 'approved') &&
                newStatus == 'Completed');

        if (!validTransition) {
          throw StateError(
            'This appointment status has already changed.',
          );
        }

        final updates = <String, dynamic>{
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (newStatus == 'Accepted') {
          updates['acceptedAt'] =
              FieldValue.serverTimestamp();
        }

        if (newStatus == 'Completed') {
          updates['completedAt'] =
              FieldValue.serverTimestamp();
        }

        if (newStatus == 'Rejected') {
          updates['rejectedAt'] =
              FieldValue.serverTimestamp();
        }

        transaction.update(reference, updates);
      });

      _message(
        'Appointment ${_statusLabel(newStatus).toLowerCase()} successfully.',
      );
    } catch (error) {
      _message(
        error is StateError
            ? error.message
            : 'Could not update appointment.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyIds.remove(appointmentId);
        });
      }
    }
  }

  // ======================================================
  // ACCOUNT MANAGEMENT
  // ======================================================

  Future<void> _switchToUserMode() async {
    if (_accountBusy ||
        _availabilityBusy ||
        _busyIds.isNotEmpty ||
        uid.isEmpty) {
      return;
    }

    final confirmed = await _confirm(
      title: 'Switch to User Mode?',
      message:
          'Continue using OneClick with your current account. '
          'Your worker profile and bookings will remain unchanged.',
      action: 'Switch Mode',
    );

    if (!confirmed || !mounted) return;

    final callback = widget.onSwitchToUserMode;

    if (callback != null) {
      callback();
      return;
    }

    try {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
      );
    } catch (_) {
      _message(
        'User Mode navigation is not configured.',
        error: true,
      );
    }
  }

  Future<void> _logout() async {
    if (_accountBusy ||
        _availabilityBusy ||
        _busyIds.isNotEmpty) {
      return;
    }

    final confirmed = await _confirm(
      title: 'Log out?',
      message:
          'You will need to sign in again to manage your worker account.',
      action: 'Log out',
      destructive: true,
    );

    if (!confirmed || !mounted) return;

    setState(() => _accountBusy = true);

    try {
      await _auth.signOut();

      if (!mounted) return;

      final callback = widget.onSignedOut;

      if (callback != null) {
        callback();
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (_) {
      _message(
        'Could not complete logout or navigation.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => _accountBusy = false);
      }
    }
  }

  Future<void> _editProfile() async {
    if (uid.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const WorkerEditProfileScreen(),
      ),
    );
  }

  void _showAccountSheet(
    Map<String, dynamic> worker,
  ) {
    final user = _auth.currentUser;

    final name = _text(
      worker['name'],
      'Worker account',
    );

    final email = _text(user?.email, '');

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              20,
            ),
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: primarySoft,
                    child: Text(
                      _initial(name),
                      style: const TextStyle(
                        color: primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(email),
                ),

                const Divider(),

                _accountTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Manage professional details',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _editProfile();
                  },
                ),

                _accountTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Income & Transactions',
                  subtitle: 'View payment history',
                  onTap: () {
                    Navigator.pop(sheetContext);

                    setState(() => _tab = 2);
                  },
                ),

                _accountTile(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Switch to User Mode',
                  subtitle: 'Continue in User Mode',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _switchToUserMode();
                  },
                ),

                _accountTile(
                  icon: Icons.logout_rounded,
                  title: 'Log Out',
                  color: red,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _logout();
                  },
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _accountTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    Color color = primary,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color == red ? red : ink,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle:
          subtitle == null ? null : Text(subtitle),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: muted,
      ),
      onTap: onTap,
    );
  }

  // ======================================================
  // COMMON UI COMPONENTS
  // ======================================================

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24,
        bottom: 12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: ink,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _loading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(
          color: primary,
        ),
      ),
    );
  }

  Widget _empty(
    IconData icon,
    String message,
  ) {
    return _card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: muted,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _error(String message) {
    return _card(
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: red),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // WORKER PROFILE HEADER
  // ======================================================

  Widget _workerHeader(
    Map<String, dynamic> worker,
  ) {
    final name = _text(
      worker['name'],
      'Worker',
    );

    final category = _text(
      worker['category'],
      'Service provider',
    );

    final details = worker['providerDetails'];

    final rate =
        (details is Map ? details['hourlyRate'] : null) ??
            worker['hourlyRate'] ??
            worker['rate'];

    final available =
        worker['isAvailable'] == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF334155),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WORKER WORKSPACE',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    Colors.white.withValues(alpha: 0.12),
                child: Text(
                  _initial(name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      rate == null
                          ? 'Hourly rate not configured'
                          : 'LKR $rate / hour',
                      style: const TextStyle(
                        color: Color(0xFFA7F3D0),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: _editProfile,
                tooltip: 'Edit profile',
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color:
                  Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: available
                        ? const Color(0xFF4ADE80)
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    available
                        ? 'Available for work'
                        : 'Currently offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Switch(
                  value: available,
                  activeTrackColor:
                      const Color(0xFF10B981),
                  onChanged: _availabilityBusy
                      ? null
                      : _updateAvailability,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,

                side: const BorderSide(
                  color: Colors.white54,
                ),

                minimumSize: const Size(0, 46),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: _accountBusy ||
                      _availabilityBusy ||
                      _busyIds.isNotEmpty
                  ? null
                  : _switchToUserMode,

              icon: const Icon(
                Icons.swap_horiz_rounded,
              ),

              label: const Text(
                'Switch to User Mode',
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,

                minimumSize: const Size(0, 46),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: _accountBusy ||
                      _availabilityBusy ||
                      _busyIds.isNotEmpty
                  ? null
                  : _logout,

              icon: const Icon(
                Icons.logout_rounded,
              ),

              label: const Text(
                'Log Out',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // APPOINTMENT STATISTICS
  // ======================================================

  Widget _statCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required String filter,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _tab = 1;
              _filter = filter;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: line),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius:
                        BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 21,
                  ),
                ),

                const SizedBox(height: 13),

                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 28,
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statistics(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        docs,
  ) {
    final pending = docs.where((doc) {
      return _status(doc.data()) == 'pending';
    }).length;

    final approved = docs.where((doc) {
      final status = _status(doc.data());

      return status == 'accepted' ||
          status == 'approved';
    }).length;

    final completed = docs.where((doc) {
      return _status(doc.data()) == 'completed';
    }).length;

    final rejected = docs.where((doc) {
      return _status(doc.data()) == 'rejected';
    }).length;

    final today = docs.where((doc) {
      final status = _status(doc.data());

      return status != 'rejected' &&
          status != 'cancelled' &&
          _isToday(_appointmentDate(doc.data()));
    }).length;

    return Column(
      children: [
        _card(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: primary,
                  size: 27,
                ),
              ),

              const SizedBox(width: 15),

              const Expanded(
                child: Text(
                  "Today's Appointments",
                  style: TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),

              Text(
                '$today',
                style: const TextStyle(
                  color: primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            _statCard(
              title: 'Pending Requests',
              count: pending,
              icon: Icons.pending_actions,
              color: amber,
              filter: 'Pending',
            ),

            const SizedBox(width: 12),

            _statCard(
              title: 'Approved Jobs',
              count: approved,
              icon: Icons.assignment_turned_in_outlined,
              color: green,
              filter: 'Approved',
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            _statCard(
              title: 'Completed Jobs',
              count: completed,
              icon: Icons.task_alt_rounded,
              color: blue,
              filter: 'Completed',
            ),

            const SizedBox(width: 12),

            _statCard(
              title: 'Rejected Jobs',
              count: rejected,
              icon: Icons.cancel_outlined,
              color: red,
              filter: 'Rejected',
            ),
          ],
        ),
      ],
    );
  }

  // ======================================================
  // INCOME MANAGEMENT
  // ======================================================

  bool _isDemoPaid(Map<String, dynamic> data) {
    return data['module'] == 'quickfix' &&
        data['environment'] == 'demo' &&
        data['method'] == 'card' &&
        data['status'] == 'demo_paid' &&
        data['currency'] == 'LKR' &&
        data['workerId'] == uid;
  }

  Widget _incomeSummary(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        docs,
  ) {
    final paid = docs.where(
      (doc) => _isDemoPaid(doc.data()),
    );

    int total = 0;
    int today = 0;
    int monthly = 0;
    int pendingCash = 0;

    for (final doc in paid) {
      final data = doc.data();

      final amount = _amountMinor(data);

      final date = _parseDate(data['createdAt']);

      total += amount;

      if (_isToday(date)) {
        today += amount;
      }

      if (_isThisMonth(date)) {
        monthly += amount;
      }
    }

    for (final doc in docs) {
      final data = doc.data();

      if (data['status'] == 'pending_cash' &&
          data['method'] == 'cash' &&
          data['environment'] == 'demo' &&
          data['currency'] == 'LKR') {
        pendingCash += _amountMinor(data);
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF087F6D),
            Color(0xFF065F52),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Total Demo Income',
                  style: TextStyle(
                    color: Color(0xFFD1FAE5),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              IconButton(
                tooltip: 'Transaction history',
                onPressed: () {
                  setState(() => _tab = 2);
                },
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _money(total),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${paid.length} simulated card payments',
            style: const TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          const Divider(color: Color(0x44FFFFFF)),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _incomeCell(
                  'Today',
                  _money(today),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _incomeCell(
                  'This Month',
                  _money(monthly),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: Colors.white,
                  size: 20,
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'Pending cash',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),

                Flexible(
                  child: Text(
                    _money(pendingCash),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Demo transactions only. Not actual revenue or bank payouts.',
            style: TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _incomeCell(
    String title,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFD1FAE5),
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 6),

        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _income({
    bool showTransactions = false,
  }) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      key: ValueKey('income-$uid'),
      stream: _paymentStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _error(
            'Unable to load income. Check payment integration and Firestore permissions.',
          );
        }

        if (!snapshot.hasData) {
          return _loading();
        }

        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final x =
                _parseDate(a.data()['createdAt']);

            final y =
                _parseDate(b.data()['createdAt']);

            return (y ?? DateTime(1970))
                .compareTo(x ?? DateTime(1970));
          });

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _incomeSummary(docs),

            if (showTransactions) ...[
              _sectionTitle('Transaction History'),

              if (docs.isEmpty)
                _empty(
                  Icons.receipt_long_outlined,
                  'No linked QuickFix payments yet.',
                )
              else
                ...docs.map(_transactionCard),
            ],
          ],
        );
      },
    );
  }

  Widget _transactionCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final status =
        _text(data['status'], 'unknown');

    final paid = _isDemoPaid(data);

    final method =
        _text(data['method'], 'Unknown');

    final date =
        _parseDate(data['createdAt']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: primarySoft,
            child: Icon(
              method == 'cash'
                  ? Icons.payments_outlined
                  : Icons.credit_card_rounded,
              color: primary,
            ),
          ),
          title: Text(
            _money(_amountMinor(data)),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          subtitle: Text(
            '$method • ${_dateText(date)}',
          ),
          trailing: _pill(
            paid
                ? 'Demo paid'
                : status.replaceAll('_', ' '),
            paid ? green : amber,
          ),
          onTap: () {
            _showTransactionDetails(doc);
          },
        ),
      ),
    );
  }

  void _showTransactionDetails(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    color: ink,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _detailRow(
                  'Payment ID',
                  _text(data['paymentId'], doc.id),
                ),

                _detailRow(
                  'Booking ID',
                  _text(data['bookingId']),
                ),

                _detailRow(
                  'Service',
                  _text(data['title'], 'QuickFix'),
                ),

                _detailRow(
                  'Amount',
                  _money(_amountMinor(data)),
                ),

                _detailRow(
                  'Method',
                  _text(data['method']),
                ),

                _detailRow(
                  'Status',
                  _text(data['status'])
                      .replaceAll('_', ' '),
                ),

                _detailRow(
                  'Date',
                  _dateTimeText(
                    _parseDate(data['createdAt']),
                  ),
                ),

                _detailRow(
                  'Environment',
                  _text(data['environment']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: SelectableText(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // APPOINTMENT CARD
  // ======================================================

  Widget _bookingCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final status = _status(data);

    final color = _statusColor(status);

    final busy = _busyIds.contains(doc.id);

    final customer = _text(
      data['customerName'] ??
          data['customerEmail'],
      'Customer',
    );

    final category = _text(
      data['category'],
      'QuickFix service',
    );

    final paymentStatus = _text(
      data['paymentStatus'],
      'Not recorded',
    );

    final canApprove = status == 'pending';

    final canComplete = status == 'accepted' ||
        status == 'approved';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primarySoft,
                  child: Text(
                    _initial(customer),
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        category,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                _pill(
                  _statusLabel(status),
                  color,
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Divider(color: line),

            const SizedBox(height: 8),

            _information(
              Icons.calendar_today_outlined,
              _dateText(_appointmentDate(data)),
            ),

            _information(
              Icons.access_time_rounded,
              _text(data['time']),
            ),

            _information(
              Icons.location_on_outlined,
              _text(
                data['address'],
                'Address unavailable',
              ),
            ),

            if (_text(data['issue'], '').isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Text(
                  'Issue: ${_text(data['issue'])}',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _pill(
                  'Payment: ${paymentStatus.replaceAll('_', ' ')}',
                  paymentStatus == 'demo_paid'
                      ? green
                      : muted,
                ),

                if (_amountMinor(data) > 0)
                  _pill(
                    _money(_amountMinor(data)),
                    primary,
                  ),
              ],
            ),

            const SizedBox(height: 14),

            if (busy)
              const LinearProgressIndicator(
                color: primary,
              ),

            if (canApprove)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: red,
                        side: const BorderSide(color: red),
                      ),
                      onPressed: busy
                          ? null
                          : () => _updateJobStatus(
                                doc.id,
                                'Rejected',
                              ),
                      child: const Text('Reject'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                      ),
                      onPressed: busy
                          ? null
                          : () => _updateJobStatus(
                                doc.id,
                                'Accepted',
                              ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),

            if (canComplete)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                  ),
                  onPressed: busy
                      ? null
                      : () => _updateJobStatus(
                            doc.id,
                            'Completed',
                          ),
                  icon: const Icon(
                    Icons.check_circle_outline,
                  ),
                  label: const Text(
                    'Mark as Completed',
                  ),
                ),
              ),

            if (status == 'completed')
              const Row(
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    color: green,
                    size: 19,
                  ),

                  SizedBox(width: 8),

                  Text(
                    'Service completed',
                    style: TextStyle(
                      color: green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _information(
    IconData icon,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: muted,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: muted,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // DASHBOARD HOME
  // ======================================================

  Widget _dashboardHome(
    Map<String, dynamic> worker,
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        docs,
  ) {
    final pending = docs.where((doc) {
      return _status(doc.data()) == 'pending';
    }).toList();

    final approved = docs.where((doc) {
      final status = _status(doc.data());

      return status == 'accepted' ||
          status == 'approved';
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        28,
      ),
      children: [
        _workerHeader(worker),

        _sectionTitle('Income Overview'),

        _income(),

        _sectionTitle('Appointment Overview'),

        _statistics(docs),

        _sectionTitle('Quick Actions'),

        Row(
          children: [
            _quickAction(
              Icons.calendar_month_outlined,
              'Bookings',
              () {
                setState(() {
                  _tab = 1;
                  _filter = 'All';
                });
              },
            ),

            _quickAction(
              Icons.wallet_outlined,
              'Income',
              () {
                setState(() => _tab = 2);
              },
            ),

            _quickAction(
              Icons.notifications_outlined,
              'Alerts',
              () {
                setState(() => _tab = 3);
              },
            ),

            _quickAction(
              Icons.person_outline,
              'Profile',
              () => _showAccountSheet(worker),
            ),
          ],
        ),

        _sectionTitle('New Job Requests'),

        if (pending.isEmpty)
          _empty(
            Icons.assignment_outlined,
            'No pending job requests.',
          )
        else
          ...pending.take(5).map(_bookingCard),

        _sectionTitle('Approved Appointments'),

        if (approved.isEmpty)
          _empty(
            Icons.event_available_outlined,
            'No approved appointments.',
          )
        else
          ...approved.take(5).map(_bookingCard),

        const SizedBox(height: 16),

        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _tab = 1;
              _filter = 'All';
            });
          },
          icon: const Icon(
            Icons.calendar_month_outlined,
          ),
          label: const Text(
            'View All Appointments',
          ),
        ),
      ],
    );
  }

  Widget _quickAction(
    IconData icon,
    String title,
    VoidCallback action,
  ) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: action,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: primary,
                  size: 24,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                title,
                style: const TextStyle(
                  color: ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // BOOKINGS TAB
  // ======================================================

  Widget _bookings(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        docs,
  ) {
    final filtered = docs.where((doc) {
      final data = doc.data();

      final status = _status(data);

      if (_filter == 'All') return true;

      if (_filter == 'Today') {
        return status != 'rejected' &&
            status != 'cancelled' &&
            _isToday(_appointmentDate(data));
      }

      if (_filter == 'Approved') {
        return status == 'accepted' ||
            status == 'approved';
      }

      return status == _filter.toLowerCase();
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            itemCount: _filters.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _filters[index];

              final selected = _filter == filter;

              return ChoiceChip(
                label: Text(filter),
                selected: selected,
                showCheckmark: false,
                selectedColor: navy,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: selected ? navy : line,
                ),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : ink,
                ),
                onSelected: (_) {
                  setState(() => _filter = filter);
                },
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            5,
            16,
            12,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${filtered.length} appointments',
              style: const TextStyle(
                color: muted,
                fontSize: 13,
              ),
            ),
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _empty(
                      Icons.event_busy_outlined,
                      'No appointments found.',
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    24,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _bookingCard(
                      filtered[index],
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ======================================================
  // NOTIFICATION MANAGEMENT
  // ======================================================

  Future<void> _markAsRead(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final userId = uid;

    if (userId.isEmpty ||
        doc.data()['receiverId'] != userId) {
      return;
    }

    try {
      await doc.reference.update({
        'isRead': true,
      });
    } catch (_) {
      _message(
        'Could not update notification.',
        error: true,
      );
    }
  }

  Widget _notificationButton() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      key: ValueKey('notification-badge-$uid'),
      stream: _notificationStream,
      builder: (context, snapshot) {
        final unread = snapshot.hasError
            ? 0
            : snapshot.data?.docs.where((doc) {
                  return doc.data()['isRead'] != true;
                }).length ??
                0;

        return IconButton(
          tooltip: 'Notifications',
          onPressed: () {
            setState(() => _tab = 3);
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_outlined,
                size: 26,
              ),

              if (unread > 0)
                Positioned(
                  top: -5,
                  right: -7,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 17,
                      minHeight: 17,
                    ),
                    decoration: const BoxDecoration(
                      color: red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _notifications() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      key: ValueKey('notifications-$uid'),
      stream: _notificationStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _error(
                'Unable to load notifications.',
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return _loading();
        }

        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final x =
                _parseDate(a.data()['createdAt']);

            final y =
                _parseDate(b.data()['createdAt']);

            return (y ?? DateTime(1970))
                .compareTo(x ?? DateTime(1970));
          });

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _empty(
                Icons.notifications_none_rounded,
                'No notifications yet.',
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];

            final data = doc.data();

            final unread = data['isRead'] != true;

            return Card(
              elevation: 0,
              color: unread
                  ? primarySoft
                  : Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: line),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    unread
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    color: primary,
                  ),
                ),
                title: Text(
                  _text(
                    data['title'],
                    'Notification',
                  ),
                  style: TextStyle(
                    fontWeight: unread
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),

                    Text(
                      _text(data['message'], ''),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _dateTimeText(
                        _parseDate(data['createdAt']),
                      ),
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                trailing: unread
                    ? const Icon(
                        Icons.circle,
                        color: primary,
                        size: 10,
                      )
                    : null,
                onTap: unread
                    ? () => _markAsRead(doc)
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  // ======================================================
  // MAIN DASHBOARD
  // ======================================================

  Widget _appointmentContent(
    Map<String, dynamic> worker,
  ) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      key: ValueKey('bookings-$uid'),
      stream: _bookingStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _error(
                'Could not load appointments.',
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return _loading();
        }

        final docs = snapshot.data!.docs
            .where((doc) {
          final data = doc.data();

          // Preserve existing QuickFix bookings that
          // were created without serviceType.
          return data['serviceType'] == 'quickfix' ||
              data['serviceType'] == null;
        }).toList()
          ..sort((a, b) {
            final x = _appointmentDate(a.data());

            final y = _appointmentDate(b.data());

            return (x ?? DateTime(2100))
                .compareTo(y ?? DateTime(2100));
          });

        if (_tab == 0) {
          return _dashboardHome(worker, docs);
        }

        return _bookings(docs);
      },
    );
  }

  Widget _body(Map<String, dynamic> worker) {
    switch (_tab) {
      case 0:
      case 1:
        return _appointmentContent(worker);

      case 2:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Income & Transactions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),

            const SizedBox(height: 16),

            _income(showTransactions: true),
          ],
        );

      case 3:
        return _notifications();

      default:
        return _appointmentContent(worker);
    }
  }

  Widget _workspace(
    Map<String, dynamic> worker,
  ) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: navy,

        title: const Text(
          'OneClick QuickFix',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          _notificationButton(),

          IconButton(
            tooltip: 'My Account',
            onPressed: () {
              _showAccountSheet(worker);
            },
            icon: const Icon(
              Icons.account_circle_outlined,
              size: 28,
            ),
          ),

          IconButton(
            tooltip: 'Log Out',

            onPressed: _accountBusy ||
                    _availabilityBusy ||
                    _busyIds.isNotEmpty
                ? null
                : _logout,

            icon: const Icon(
              Icons.logout_rounded,
              color: red,
              size: 24,
            ),
          ),

          const SizedBox(width: 5),
        ],
      ),

      body: _body(worker),

      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: primarySoft,
        selectedIndex: _tab,
        elevation: 1,

        onDestinationSelected: (index) {
          setState(() => _tab = index);
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(
              Icons.dashboard_rounded,
              color: primary,
            ),
            label: 'Dashboard',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.calendar_month_outlined,
            ),
            selectedIcon: Icon(
              Icons.calendar_month_rounded,
              color: primary,
            ),
            label: 'Bookings',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ),
            selectedIcon: Icon(
              Icons.account_balance_wallet,
              color: primary,
            ),
            label: 'Income',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.notifications_outlined,
            ),
            selectedIcon: Icon(
              Icons.notifications_rounded,
              color: primary,
            ),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState ==
            ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: background,
            body: _loading(),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          _streamUid = null;

          _profileStream = null;
          _bookingStream = null;
          _paymentStream = null;
          _notificationStream = null;

          return Scaffold(
            backgroundColor: background,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Please sign in as a worker.',
                  ),

                  const SizedBox(height: 15),

                  FilledButton(
                    onPressed: () {
                      final callback =
                          widget.onSignedOut;

                      if (callback != null) {
                        callback();
                      } else {
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ),
          );
        }

        _bindStreams(user.uid);

        return StreamBuilder<
            DocumentSnapshot<Map<String, dynamic>>>(
          key: ValueKey('worker-${user.uid}'),
          stream: _profileStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                backgroundColor: background,
                appBar: AppBar(
                  title: const Text('QuickFix'),
                  actions: [
                    IconButton(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _error(
                      'Unable to load worker profile.',
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Scaffold(
                backgroundColor: background,
                body: _loading(),
              );
            }

            final worker = snapshot.data!.data();

            if (worker == null) {
              return Scaffold(
                backgroundColor: background,
                appBar: AppBar(
                  title: const Text('QuickFix'),
                  actions: [
                    IconButton(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
                body: const Center(
                  child: Text(
                    'Worker profile not found.',
                  ),
                ),
              );
            }

            return _workspace(worker);
          },
        );
      },
    );
  }
}
