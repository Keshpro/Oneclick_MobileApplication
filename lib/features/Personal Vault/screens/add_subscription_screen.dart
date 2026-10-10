import 'package:flutter/material.dart';
import '../services/subscription_service.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState
    extends State<AddSubscriptionScreen> {
  static const Color bg = Color(0xFFF8F6FC);
  static const Color card = Color(0xFFF9F8FC);
  static const Color purple = Color(0xFF5049E8);
  static const Color ink = Color(0xFF303348);
  static const Color muted = Color(0xFF73758B);
  static const Color lightPurple = Color(0xFF6A63FF);

  final TextEditingController _nameController =
      TextEditingController(text: 'Netflix');

  final TextEditingController _costController =
      TextEditingController(text: '19.99');

  final SubscriptionService _subscriptionService = SubscriptionService();

  String selectedService = 'Netflix';
  String billingCycle = 'Monthly';
  String reminderTime = '3 days before';

  bool reminderEnabled = true;
  bool freeTrial = false;
  bool advancedExpanded = false;

  DateTime renewalDate = DateTime(2025, 11, 28);

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 560,
            ),
            child: Column(
              children: [
                _header(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      8,
                      24,
                      34,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        _titleSection(),

                        const SizedBox(height: 30),

                        _mainDetailsCard(),

                        const SizedBox(height: 24),

                        _reminderCard(),

                        const SizedBox(height: 24),

                        _advancedCard(),

                        const SizedBox(height: 30),

                        _saveButton(),

                        const SizedBox(height: 14),

                        _cancelButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

Widget _header() {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    decoration: BoxDecoration(
      color: bg,
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.withValues(alpha: 0.10),
        ),
      ),
    ),
    child: Row(
      children: [
        _circleButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () {
            Navigator.pop(context);
          },
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Text(
            'Add / Edit Subscription',
            style: TextStyle(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

  // ============================================================
  // TITLE
  // ============================================================

  Widget _titleSection() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 3),
          child: CircleAvatar(
            radius: 12,
            backgroundColor: purple,
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 17,
            ),
          ),
        ),

        SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Add Subscription',
                style: TextStyle(
                  color: ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 6),

              Text(
                'Track billing, renewal dates, and reminders.',
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MAIN DETAILS
  // ============================================================

  Widget _mainDetailsCard() {
    return _surface(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'SUBSCRIPTION NAME',
                  style: TextStyle(
                    color: ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),

              TextButton.icon(
                onPressed: () {
                  _message(
                    'Smart Auto-fill selected.',
                  );
                },
                icon: const Icon(
                  Icons.auto_awesome,
                  size: 15,
                ),
                label: const Text(
                  'Smart Auto-fill',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: purple,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          _inputSurface(
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.subscriptions_outlined,
                  color: muted,
                ),
                contentPadding:
                    EdgeInsets.symmetric(
                  vertical: 18,
                ),
              ),
              style: const TextStyle(
                color: ink,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 18),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _serviceChip(
                  'Netflix',
                  const Color(0xFFB93C58),
                ),
                const SizedBox(width: 8),
                _serviceChip(
                  'Spotify',
                  const Color(0xFF22B65C),
                ),
                const SizedBox(width: 8),
                _serviceChip(
                  'Apple',
                  const Color(0xFF666979),
                ),
                const SizedBox(width: 8),
                _serviceChip(
                  'YouTube',
                  const Color(0xFFFF1744),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'COST & BILLING CYCLE',
            style: TextStyle(
              color: ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _inputSurface(
                  child: TextField(
                    controller: _costController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Padding(
                        padding:
                            EdgeInsets.only(
                          left: 18,
                          right: 8,
                        ),
                        child: Text(
                          '\$',
                          style: TextStyle(
                            color: purple,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(
                        minWidth: 40,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                    ),
                    style: const TextStyle(
                      color: ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _billingCycleSelector(),
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            'NEXT RENEWAL DATE',
            style: TextStyle(
              color: ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),

          const SizedBox(height: 12),

          InkWell(
            borderRadius:
                BorderRadius.circular(24),
            onTap: _selectDate,
            child: _inputSurface(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: muted,
                      size: 20,
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        _formattedDate(
                          renewalDate,
                        ),
                        style: const TextStyle(
                          color: ink,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.edit_calendar_outlined,
                      color: muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BILLING CYCLE
  // ============================================================

  Widget _billingCycleSelector() {
    return Container(
      height: 55,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow(),
      ),
      child: Row(
        children: [
          Expanded(
            child: _cycleButton(
              'Monthly',
            ),
          ),
          Expanded(
            child: _cycleButton(
              'Yearly',
            ),
          ),
        ],
      ),
    );
  }

  Widget _cycleButton(String value) {
    final bool selected =
        billingCycle == value;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        setState(() {
          billingCycle = value;
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(22),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black
                        .withValues(
                      alpha: 0.06,
                    ),
                    blurRadius: 8,
                    offset:
                        const Offset(2, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          value,
          style: TextStyle(
            color:
                selected ? purple : muted,
            fontSize: 14,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SERVICE CHIP
  // ============================================================

  Widget _serviceChip(
    String name,
    Color dotColor,
  ) {
    final bool selected =
        selectedService == name;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        setState(() {
          selectedService = name;
          _nameController.text = name;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius:
              BorderRadius.circular(22),
          boxShadow: _softShadow(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 7),

            Text(
              name,
              style: TextStyle(
                color: selected
                    ? purple
                    : ink,
                fontSize: 13,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REMINDERS
  // ============================================================

  Widget _reminderCard() {
    return _surface(
      child: Column(
        children: [
          Row(
            children: [
              _smallIcon(
                Icons.notifications_active_outlined,
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remind before renewal',
                      style: TextStyle(
                        color: ink,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Get notified before your card is charged',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Switch(
                value: reminderEnabled,
                activeThumbColor: purple,
                onChanged: (value) {
                  setState(() {
                    reminderEnabled =
                        value;
                  });
                },
              ),
            ],
          ),

          if (reminderEnabled) ...[
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _reminderOption(
                    '3 days before',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _reminderOption(
                    '1 week before',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _reminderOption(
                    '1 day before',
                  ),
                ),
              ],
            ),
          ],

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 18,
            ),
            child: Divider(),
          ),

          Row(
            children: [
              _smallIcon(
                Icons.card_membership_outlined,
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This is a free trial',
                      style: TextStyle(
                        color: ink,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Track trial end to avoid unwanted charges',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Switch(
                value: freeTrial,
                activeThumbColor: purple,
                onChanged: (value) {
                  setState(() {
                    freeTrial = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reminderOption(
    String value,
  ) {
    final bool selected =
        reminderTime == value;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        setState(() {
          reminderTime = value;
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius:
              BorderRadius.circular(22),
          boxShadow: _softShadow(),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                selected ? purple : muted,
            fontSize: 12,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ADVANCED DETAILS
  // ============================================================

  Widget _advancedCard() {
    return _surface(
      child: Column(
        children: [
          InkWell(
            borderRadius:
                BorderRadius.circular(18),
            onTap: () {
              setState(() {
                advancedExpanded =
                    !advancedExpanded;
              });
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 4,
              ),
              child: Row(
                children: [
                  Icon(
                    advancedExpanded
                        ? Icons
                            .keyboard_arrow_up
                        : Icons
                            .keyboard_arrow_down,
                    color: muted,
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Advanced & Cancellation Details',
                          style: TextStyle(
                            color: ink,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Optional: Direct cancel URL, vault login & notes',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color: bg,
                      borderRadius:
                          BorderRadius
                              .circular(16),
                      boxShadow:
                          _softShadow(),
                    ),
                    child: const Text(
                      'Optional',
                      style: TextStyle(
                        color: purple,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (advancedExpanded) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 14),

            _advancedField(
              'Cancellation URL',
              Icons.link,
            ),

            const SizedBox(height: 12),

            _advancedField(
              'Vault Login Reference',
              Icons.key_outlined,
            ),

            const SizedBox(height: 12),

            _advancedField(
              'Additional Notes',
              Icons.notes_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _advancedField(
    String hint,
    IconData icon,
  ) {
    return _inputSurface(
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: muted,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            color: muted,
            fontSize: 13,
          ),
          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 17,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  Widget _saveButton() {
    return SizedBox(
      height: 62,
      child: ElevatedButton.icon(
        onPressed: _saveSubscription,
        icon: const Icon(
          Icons.check,
          color: Colors.white,
        ),
        label: const Text(
          'Save Subscription',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          elevation: 7,
          shadowColor: purple.withValues(
            alpha: 0.30,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _cancelButton() {
    return SizedBox(
      height: 58,
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: TextButton.styleFrom(
          foregroundColor: muted,
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SAVE FUNCTION
  // ============================================================

Future<void> _saveSubscription() async {
  final String name = _nameController.text.trim();
  final String cost = _costController.text.trim();

  if (name.isEmpty) {
    _message('Please enter a subscription name.');
    return;
  }

  if (cost.isEmpty) {
    _message('Please enter the subscription cost.');
    return;
  }

  try {
    await _subscriptionService.addSubscription(
      name: name,
      subtitle: '$selectedService • $billingCycle',
      price: 'LKR $cost',
      renewal: 'Renews ${_formattedDate(renewalDate)}',
      usage: reminderTime,
      category: 'Productivity & AI',
      status: 'Active',
      priceHiked: false,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name subscription saved.'),
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to save subscription: $e'),
      ),
    );
  }
}

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime? selected =
        await showDatePicker(
      context: context,
      initialDate: renewalDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (selected != null) {
      setState(() {
        renewalDate = selected;
      });
    }
  }

  String _formattedDate(
    DateTime date,
  ) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }

  // ============================================================
  // COMMON UI
  // ============================================================

  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(22),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: card,
        borderRadius:
            BorderRadius.circular(28),
        boxShadow: _softShadow(),
      ),
      child: child,
    );
  }

  Widget _inputSurface({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: _softShadow(),
      ),
      child: child,
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: _softShadow(),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: ink,
        ),
      ),
    );
  }

  Widget _smallIcon(
    IconData icon,
  ) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: _softShadow(),
      ),
      child: Icon(
        icon,
        color: lightPurple,
        size: 21,
      ),
    );
  }

  List<BoxShadow> _softShadow() {
    return [
      BoxShadow(
        color: Colors.white.withValues(
          alpha: 0.90,
        ),
        offset: const Offset(-4, -4),
        blurRadius: 10,
      ),
      BoxShadow(
        color: const Color(0xFFC9C6D2)
            .withValues(
          alpha: 0.35,
        ),
        offset: const Offset(4, 5),
        blurRadius: 12,
      ),
    ];
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}