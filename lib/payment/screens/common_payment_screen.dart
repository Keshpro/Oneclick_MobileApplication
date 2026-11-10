import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/payment_model.dart';

class CommonPaymentScreen extends StatefulWidget {
  final PaymentModel paymentData;

  const CommonPaymentScreen({super.key, required this.paymentData});

  @override
  State<CommonPaymentScreen> createState() => _CommonPaymentScreenState();
}

class _CommonPaymentScreenState extends State<CommonPaymentScreen> {
  bool _isProcessing = false;
  String _selectedMethod = 'Card'; // Card, ApplePay, Cash

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Save Payment to Firebase 'payments' collection
      await FirebaseFirestore.instance.collection('payments').add(
            widget.paymentData.toMap(),
          );

      // 2. Update the respective Service Status (e.g., Appointment -> Paid/Confirmed)
      if (widget.paymentData.serviceType == 'Doctor') {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(widget.paymentData.serviceId)
            .update({'paymentStatus': 'Paid', 'status': 'Approved'});
      } else if (widget.paymentData.serviceType == 'Driver') {
        await FirebaseFirestore.instance
            .collection('rides')
            .doc(widget.paymentData.serviceId)
            .update({'paymentStatus': 'Paid', 'status': 'Confirmed'});
      }

      if (!mounted) return;

      // 3. Show Success & Return
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 55),
          content: const Text(
            'Payment Successful! 🎉\nYour service has been confirmed.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return to previous screen with success
              },
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.paymentData;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Checkout & Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data.serviceType.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669), letterSpacing: 1.2)),
                      Text('LKR ${data.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(data.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text(data.subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Select Payment Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            
            // Payment Options
            _buildMethodTile('Credit / Debit Card', Icons.credit_card_rounded, 'Card'),
            const SizedBox(height: 10),
            _buildMethodTile('Mobile Wallet / Online Pay', Icons.account_balance_wallet_outlined, 'Wallet'),
            const SizedBox(height: 10),
            _buildMethodTile('Cash on Service', Icons.money_rounded, 'Cash'),

            const Spacer(),

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isProcessing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Pay LKR ${data.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(String title, IconData icon, String value) {
    bool isSelected = _selectedMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xFF059669) : const BorderSide(color: Color(0xFFE2E8F0)).color, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF059669) : const Color(0xFF64748B)),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? const Color(0xFF059669) : const Color(0xFF0F172A)))),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
          ],
        ),
      ),
    );
  }
}