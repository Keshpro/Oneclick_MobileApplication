import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoctorScheduleManageScreen extends StatefulWidget {
  const DoctorScheduleManageScreen({super.key});

  @override
  State<DoctorScheduleManageScreen> createState() =>
      _DoctorScheduleManageScreenState();
}

class _DoctorScheduleManageScreenState
    extends State<DoctorScheduleManageScreen> {
  static const Color _green = Color(0xFF059669);
  static const Color _darkGreen = Color(0xFF064E3B);
  static const Color _background = Color(0xFFF7FAF9);
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _blue = Color(0xFF0284C7);
  static const Color _orange = Color(0xFFD97706);
  static const Color _red = Color(0xFFDC2626);

  final _feeController = TextEditingController();
  final _leaveReasonController = TextEditingController();

  DateTime? _selectedLeaveDate;
  bool _savingFee = false;
  bool _savingHoliday = false;
  String? _deletingHolidayId;

  User? get _doctor => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  @override
  void dispose() {
    _feeController.dispose();
    _leaveReasonController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  void _message(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? _red : _darkGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadDoctorData() async {
    final uid = _doctor?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .get();

      if (!mounted) return;

      final fee = snapshot.data()?['consultationFee'];

      setState(() {
        _feeController.text = fee == null ? '2500' : fee.toString();
      });
    } catch (e) {
      _message('Unable to load consultation fee.', error: true);
    }
  }

  Future<void> _updateDoctorFee() async {
    final uid = _doctor?.uid;
    if (uid == null || _savingFee) return;

    final raw = _feeController.text.trim();
    final fee = double.tryParse(raw);

    if (fee == null || !fee.isFinite || fee <= 0) {
      _message(
        'Please enter a valid consultation fee greater than zero.',
        error: true,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _savingFee = true);

    try {
      await FirebaseFirestore.instance.collection('doctors').doc(uid).update({
        'consultationFee': fee,
      });

      _message('Consultation fee updated successfully!');
    } catch (e) {
      _message('Unable to update fee: $e', error: true);
    } finally {
      if (mounted) setState(() => _savingFee = false);
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedLeaveDate ?? start,
      firstDate: start,
      lastDate: start.add(const Duration(days: 365)),
      helpText: 'Select unavailable date',
    );

    if (picked != null && mounted) {
      setState(() => _selectedLeaveDate = picked);
    }
  }

  Future<void> _markHoliday() async {
    final uid = _doctor?.uid;
    final date = _selectedLeaveDate;

    if (uid == null || date == null || _savingHoliday) return;

    final formattedDate = _formatDate(date);
    final reason = _leaveReasonController.text.trim().isEmpty
        ? 'Doctor Unavailable (On Leave)'
        : _leaveReasonController.text.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Lock this date?'),
        content: Text(
          'Mark $formattedDate as unavailable?\n\n'
          'Reason: $reason\n\n'
          'This date should be blocked for new bookings '
          'if the patient booking flow checks doctor vacations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Lock Date'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _savingHoliday = true);

    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .collection('vacations')
          .doc(formattedDate)
          .set({
            'date': formattedDate,
            'reason': reason,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      _leaveReasonController.clear();

      setState(() => _selectedLeaveDate = null);

      _message('Date marked as unavailable successfully!');
    } catch (e) {
      _message('Unable to lock date: $e', error: true);
    } finally {
      if (mounted) setState(() => _savingHoliday = false);
    }
  }

  Future<void> _deleteHoliday(String uid, String holidayId, String date) async {
    if (_deletingHolidayId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unlock date?'),
        content: Text(
          'Remove the holiday restriction for $date?\n\n'
          'Patients may be able to book this date again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep Locked'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _green),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Unlock'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deletingHolidayId = holidayId);

    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .collection('vacations')
          .doc(holidayId)
          .delete();

      _message('Holiday restriction removed.');
    } catch (e) {
      _message('Unable to unlock date: $e', error: true);
    } finally {
      if (mounted) {
        setState(() => _deletingHolidayId = null);
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
        toolbarHeight: 68,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Schedule',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            Text(
              'Doctor workspace',
              style: TextStyle(color: _muted, fontSize: 11),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: _purple,
              size: 24,
            ),
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Please sign in as a doctor.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _hero(),
                  const SizedBox(height: 25),
                  _sectionTitle(
                    'Consultation Charges',
                    'Manage your appointment pricing',
                  ),
                  const SizedBox(height: 13),
                  _feeCard(),
                  const SizedBox(height: 26),
                  _sectionTitle(
                    'Vacation & Availability',
                    'Choose dates when you are unavailable',
                  ),
                  const SizedBox(height: 13),
                  _holidayCard(),
                  const SizedBox(height: 26),
                  _sectionTitle(
                    'Locked Holiday Dates',
                    'Manage your unavailable days',
                  ),
                  const SizedBox(height: 13),
                  _holidayList(uid),
                ],
              ),
            ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkGreen, _green],
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
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Your schedule,\nyour control.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Update consultation fees and manage your '
            'unavailable dates in one place.',
            style: TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.payments_rounded, _green),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consultation Fee',
                      style: TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Amount in Sri Lankan Rupees',
                      style: TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _feeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: _inputDecoration(
              hint: 'Enter consultation fee',
              icon: Icons.currency_exchange_rounded,
              color: _green,
              prefix: 'LKR  ',
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _savingFee ? null : _updateDoctorFee,
              icon: _savingFee
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_savingFee ? 'Saving...' : 'Save Fee Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _green.withValues(alpha: 0.6),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _holidayCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.event_busy_rounded, _purple),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mark Unavailable Date',
                      style: TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Lock a date for new appointments',
                      style: TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: _savingHoliday ? null : _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: _purple,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedLeaveDate == null
                          ? 'Tap to select a date'
                          : _formatDate(_selectedLeaveDate!),
                      style: TextStyle(
                        color: _selectedLeaveDate == null ? _muted : _text,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: _muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 13),
          TextField(
            controller: _leaveReasonController,
            maxLines: 2,
            maxLength: 200,
            decoration: _inputDecoration(
              hint: 'Reason (e.g. Personal Leave)',
              icon: Icons.edit_note_rounded,
              color: _orange,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _selectedLeaveDate == null || _savingHoliday
                  ? null
                  : _markHoliday,
              icon: _savingHoliday
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.lock_clock_rounded),
              label: Text(
                _savingHoliday ? 'Locking Date...' : 'Lock Date for Bookings',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _purple.withValues(alpha: 0.45),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _holidayList(String uid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .collection('vacations')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _emptyState(
            'Unable to load holidays',
            'Check your connection and permissions.',
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: _green),
            ),
          );
        }

        final docs = snapshot.data!.docs.toList();

        docs.sort((a, b) {
          final dateA = (a.data()['date'] ?? '').toString();
          final dateB = (b.data()['date'] ?? '').toString();
          return dateA.compareTo(dateB);
        });

        if (docs.isEmpty) {
          return _emptyState(
            'No locked dates',
            'Your upcoming holidays will appear here.',
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            final date = (data['date'] ?? doc.id).toString();
            final reason = (data['reason'] ?? 'Doctor Unavailable').toString();

            return Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(14),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  _iconBox(Icons.event_busy_rounded, _purple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            color: _text,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reason,
                          style: const TextStyle(color: _muted, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Unavailable for bookings',
                          style: TextStyle(
                            color: _purple,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Unlock date',
                    onPressed: _deletingHolidayId != null
                        ? null
                        : () => _deleteHoliday(uid, doc.id, date),
                    icon: _deletingHolidayId == doc.id
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _purple,
                            ),
                          )
                        : const Icon(Icons.lock_open_rounded, color: _red),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color color,
    String? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      prefixIcon: Icon(icon, color: color),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 1.5),
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 23),
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
        Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(Icons.event_available_rounded, color: _green, size: 35),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: _text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
