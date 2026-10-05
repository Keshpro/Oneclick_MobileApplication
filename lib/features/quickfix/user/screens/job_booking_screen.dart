import 'package:flutter/material.dart';

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

  void _submitBooking() {
    if (_selectedDate == null || _selectedTime == null || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields (Date, Time, and Address)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final workerName = widget.worker['name'] ?? 'Worker';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking request sent to $workerName!'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.of(context).pop(); 
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
    final workerRate = widget.worker['rate']?.toString() ?? 'N/A';
    
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
              color: Colors.black.withOpacity(0.05),
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
              onPressed: _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff032744),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Confirm & Send Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    backgroundColor: const Color(0xff032744).withOpacity(0.1),
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
                    workerRate,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff032744)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
            const Text('When do you need the service?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
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
                                  : "${_selectedDate!.toLocal()}".split(' ')[0],
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
            const SizedBox(height: 15),
            
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image picker will open here')),
                );
              },
              icon: const Icon(Icons.add_a_photo, size: 18),
              label: const Text('Add Photos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff032744),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}