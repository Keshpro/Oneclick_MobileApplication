import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/payment_request.dart';
import '../services/payment_service.dart';

class CheckoutScreen extends StatefulWidget {
  final PaymentRequest request;

  const CheckoutScreen({
    super.key,
    required this.request,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Palette
  static const Color primary = Color(0xFF087F6D);
  static const Color primarySoft = Color(0xFFE6F4F1);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color line = Color(0xFFE2E8F0);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFF4F7F6);
  static const Color amber = Color(0xFFB45309);
  static const Color amberSoft = Color(0xFFFFF4E5);
  static const Color danger = Color(0xFFB91C1C);

  String _selectedMethod = 'card';
  bool _processing = false;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  /// 250000 -> "2,500.00"
  String get _amount {
    final minor = widget.request.amountMinor;
    final whole = minor ~/ 100;
    final cents = (minor % 100).toString().padLeft(2, '0');
    final digits = whole.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '$buffer.$cents';
  }

  // ---------------------------------------------------------------------------
  // Logic (unchanged behaviour)
  // ---------------------------------------------------------------------------

  Future<void> _startCheckout() async {
    if (_processing) return;

    if (_selectedMethod == 'card') {
      await _showCardSheet();
    } else {
      await _completePayment('cash');
    }
  }

  Future<void> _completePayment(String method) async {
    if (_processing) return;

    setState(() => _processing = true);

    try {
      // Simulate a short payment processing period.
      await Future<void>.delayed(const Duration(seconds: 2));

      final paymentId = await PaymentService.processDemoPayment(
        request: widget.request,
        method: method,
      );

      if (!mounted) return;

      await _showResultDialog(paymentId: paymentId, method: method);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: danger,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              error is StateError
                  ? error.message
                  : "Payment didn't go through. Check your connection and "
                      'try again.',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Card entry (bottom sheet)
  // ---------------------------------------------------------------------------

  InputDecoration _decoration({
    required String label,
    String? hint,
    required IconData icon,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, size: 20, color: muted),
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      enabledBorder: border(line),
      border: border(line),
      focusedBorder: border(primary, 1.6),
      errorBorder: border(danger),
      focusedErrorBorder: border(danger, 1.6),
    );
  }

  void _fillTestDetails() {
    _nameController.text = 'Test Patient';
    _numberController.text = '4242 4242 4242 4242';
    _expiryController.text = '12/30';
    _cvvController.text = '123';
  }

  Future<void> _showCardSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: line,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Card details',
                          style: TextStyle(
                            color: ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded, color: muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: amberSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.science_outlined,
                          size: 18,
                          color: amber,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Test mode. Never enter a real card.',
                            style: TextStyle(
                              color: amber,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _fillTestDetails,
                          style: TextButton.styleFrom(
                            foregroundColor: amber,
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Fill test card',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(
                      label: 'Name on card',
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a name for the test card'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [_CardNumberFormatter()],
                    decoration: _decoration(
                      label: 'Card number',
                      hint: '4242 4242 4242 4242',
                      icon: Icons.credit_card_rounded,
                    ),
                    validator: (value) {
                      final number = (value ?? '').replaceAll(' ', '');

                      if (number != '4242424242424242') {
                        return 'Use the test card 4242 4242 4242 4242';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [_ExpiryFormatter()],
                          decoration: _decoration(
                            label: 'Expiry',
                            hint: '12/30',
                            icon: Icons.event_outlined,
                          ),
                          validator: (value) => value?.trim() == '12/30'
                              ? null
                              : 'Use test expiry 12/30',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: _decoration(
                            label: 'CVV',
                            hint: '123',
                            icon: Icons.lock_outline_rounded,
                          ),
                          validator: (value) => value?.trim() == '123'
                              ? null
                              : 'Use test CVV 123',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(sheetContext);
                        _completePayment('card');
                      }
                    },
                    style: _primaryStyle(),
                    child: Text('Pay LKR $_amount'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Result dialog
  // ---------------------------------------------------------------------------

  Widget _resultRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color.fromARGB(255, 50, 88, 141), fontSize: 13)),
          const SizedBox(width: 16),
          Flexible(child: value),
        ],
      ),
    );
  }

  Future<void> _showResultDialog({
    required String paymentId,
    required String method,
  }) async {
    final isCard = method == 'card';
    final accent = isCard ? primary : amber;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCard ? Icons.check_rounded : Icons.schedule_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isCard ? 'Payment received' : 'Cash payment selected',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isCard
                        ? 'Your booking is confirmed.'
                        : 'Your booking is saved. Pay in person to complete '
                            'it.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: line),
                    ),
                    child: Column(
                      children: [
                        _resultRow(
                          'Amount',
                          Text(
                            'LKR $_amount',
                            style: const TextStyle(
                              color: ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _resultRow(
                          'Payment ID',
                          SelectableText(
                            paymentId,
                            maxLines: 1,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Demo mode: no real money was charged.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context, true);
                    },
                    style: _primaryStyle(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Main screen
  // ---------------------------------------------------------------------------

  ButtonStyle _primaryStyle() => ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size.fromHeight(54),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFB3CECA),
        disabledForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      );

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.request.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFBFE6DF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'LKR',
                style: TextStyle(
                  color: Color(0xFFBFE6DF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _amount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0x33FFFFFF)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Booking',
                style: TextStyle(color: Color(0xFFBFE6DF), fontSize: 13),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.request.bookingId,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _methodTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selectedMethod == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? primarySoft : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _processing
              ? null
              : () => setState(() => _selectedMethod = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? primary : line,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(color: muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                    color: selected ? primary : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? primary : const Color(0xFFCBD5E1),
                      width: 1.6,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    final isCard = _selectedMethod == 'card';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _processing ? null : _startCheckout,
                style: _primaryStyle(),
                child: _processing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Processing'),
                        ],
                      )
                    : Text(
                        isCard ? 'Continue with card' : 'Confirm cash payment',
                      ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Demo mode: no real transactions are processed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: ink,
        title: const Text(
          'Checkout',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _summaryCard(),
            const SizedBox(height: 24),
            const Text(
              'Choose how to pay',
              style: TextStyle(
                color: ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _methodTile(
              value: 'card',
              title: 'Credit or debit card',
              subtitle: 'Pay now, confirmed instantly',
              icon: Icons.credit_card_rounded,
            ),
            _methodTile(
              value: 'cash',
              title: 'Cash',
              subtitle: 'Pay in person at the service',
              icon: Icons.payments_outlined,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: _selectedMethod == 'cash'
                  ? Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: amberSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: amber,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your booking is saved now, but stays unpaid '
                              'until you pay in person.',
                              style: TextStyle(
                                color: amber,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }
}

// -----------------------------------------------------------------------------
// Input formatters
// -----------------------------------------------------------------------------

/// Groups digits in fours: 4242424242424242 -> 4242 4242 4242 4242
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 16 ? digits.substring(0, 16) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(capped[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Inserts the slash after the month: 1230 -> 12/30
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 4 ? digits.substring(0, 4) : digits;

    final text = capped.length >= 3
        ? '${capped.substring(0, 2)}/${capped.substring(2)}'
        : capped;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}