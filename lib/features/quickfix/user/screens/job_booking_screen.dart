import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'booking_success_screen.dart';

class JobBookingScreen extends StatefulWidget {
  final Map<String, dynamic> worker;

  const JobBookingScreen({super.key, required this.worker});

  @override
  State<JobBookingScreen> createState() => _JobBookingScreenState();
}

class _JobBookingScreenState extends State<JobBookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff032744),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff032744),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedDate == null || _selectedTime == null || _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields (Date, Time, and Address)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final workerId = widget.worker['id'] ?? widget.worker['uid'] ?? '';
      final workerName = widget.worker['name'] ?? 'Worker';
      final category = widget.worker['category'] ?? 'General Repair';

      final formattedDate =
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      final formattedTime = _selectedTime!.format(context);

      // Save Booking Request in 'work_appointments' Firestore Collection
      await FirebaseFirestore.instance.collection('work_appointments').add({
        'workerId': workerId,
        'workerName': workerName,
        'category': category,
        'customerId': currentUser?.uid ?? '',
        'customerEmail': currentUser?.email ?? 'Customer',
        'address': _addressController.text.trim(),
        'issue': _descriptionController.text.trim(),
        'date': formattedDate,
        'time': formattedTime,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Navigate to BookingSuccessScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(worker: widget.worker),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workerName = widget.worker['name']?.toString() ?? 'Worker';
    final providerDetails = widget.worker['providerDetails'] as Map<String, dynamic>? ?? {};
    final workerRate = providerDetails['hourlyRate'] ?? widget.worker['hourlyRate'] ?? widget.worker['rate'] ?? '1500';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff032744),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Confirm & Send Request',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Worker Card Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xff032744).withValues(alpha: 0.1),
                    child: Text(
                      workerName.isNotEmpty ? workerName.substring(0, 1).toUpperCase() : 'W',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff032744)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Booking for', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        Text(workerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  Text(
                    'LKR $workerRate/hr',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff032744)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
            const Text('When do you need the service?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            // Date & Time Selectors
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xff032744), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedDate == null 
                                  ? 'Select Date *' 
                                  : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                color: _selectedDate == null ? Colors.grey.shade600 : Colors.black,
                                fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xff032744), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedTime == null 
                                  ? 'Select Time *' 
                                  : _selectedTime!.format(context),
                              style: TextStyle(
                                color: _selectedTime == null ? Colors.grey.shade600 : Colors.black,
                                fontWeight: _selectedTime == null ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),
            
            // Address Input Field
            const Text('Service Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter your full address *',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 25),
            
            // Issue Description Input Field
            const Text('Describe the issue (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'E.g., The AC is not cooling properly and making a strange noise...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}