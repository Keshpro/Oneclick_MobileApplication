import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/doctor_model.dart';
import 'ai_assistant_screen.dart';
import 'book_appointment_screen.dart';
import 'my_appointments_screen.dart';
import 'patient_medical_vault_screen.dart';
import 'patient_notifications_screen.dart';
import 'patient_prescriptions_screen.dart';
import 'patient_profile_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  static const Color _primary = Color(0xFF059669);
  static const Color _primaryDark = Color(0xFF064E3B);
  static const Color _background = Color(0xFFF7FAF9);
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _lightGreen = Color(0xFFECFDF5);
  static const Color _purple = Color(0xFF7C3AED);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialty = 'All';

  User? get _currentUser => FirebaseAuth.instance.currentUser;
  bool get _isLoggedIn => _currentUser != null;

  final List<Map<String, dynamic>> _specialties = [
    {'name': 'All', 'icon': Icons.apps_rounded},
    {'name': 'General Physician', 'icon': Icons.medical_services_rounded},
    {'name': 'Cardiologist', 'icon': Icons.favorite_rounded},
    {'name': 'Dentist', 'icon': Icons.health_and_safety_rounded},
    {'name': 'Pediatrician', 'icon': Icons.child_care_rounded},
    {'name': 'Dermatologist', 'icon': Icons.face_retouching_natural_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAiAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
    );
  }

  void _openMyAppointments() {
    if (_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyAppointmentsScreen()),
      );
      return;
    }
    _showLoginRequired(
      title: 'Login required',
      description: 'Login to view and manage your appointments.',
    );
  }

  void _openPrescriptions() {
    if (_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PatientPrescriptionsScreen(),
        ),
      );
      return;
    }
    _showLoginRequired(
      title: 'Login required',
      description: 'Login to view and manage your medical prescriptions.',
    );
  }

  void _openMedicalVault() {
    if (_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PatientMedicalVaultScreen(),
        ),
      );
      return;
    }
    _showLoginRequired(
      title: 'Login required',
      description: 'Login to view and upload your medical documents.',
    );
  }

  void _openNotifications() {
    if (_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PatientNotificationsScreen(),
        ),
      );
      return;
    }
    _showLoginRequired(
      title: 'Login required',
      description: 'Login to view your notifications.',
    );
  }

  void _openProfile() {
    if (_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PatientProfileScreen(),
        ),
      );
      return;
    }
    _showLoginRequired(
      title: 'Login required',
      description: 'Login to view your health profile and settings.',
    );
  }

  void _openBooking(DoctorModel doctor) {
    if (_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookAppointmentScreen(
            doctor: {
              'uid': doctor.id,
              'id': doctor.id,
              'name': doctor.name,
              'specialty': doctor.specialty,
              'specialtyLabel': doctor.specialtyLabel,
              'hospital': doctor.hospital,
              'rating': doctor.rating,
              'reviews': doctor.reviews,
              'experience': doctor.experience,
              'fee': doctor.fee,
              'available': doctor.available,
              'nextSlot': doctor.nextSlot,
            },
          ),
        ),
      );
      return;
    }
    _showLoginRequired(
      title: 'Ready to book?',
      description:
          'Create an account or login to book an appointment with ${doctor.name}.',
    );
  }

  void _showLoginRequired({
    required String title,
    required String description,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: _lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: _primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 17),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Login to Continue',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Create New Account',
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text(
                    'Continue Exploring',
                    style: TextStyle(color: _muted),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDoctorProfile(DoctorModel doctor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.80,
          minChildSize: 0.55,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: _lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: _primary,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    doctor.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    doctor.specialtyLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    doctor.hospital,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: _profileStatistic(
                          icon: Icons.star_rounded,
                          value: '${doctor.rating}',
                          label: 'Rating',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _profileStatistic(
                          icon: Icons.workspace_premium_rounded,
                          value: '${doctor.experience}+',
                          label: 'Years',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _profileStatistic(
                          icon: Icons.payments_outlined,
                          value: '${doctor.fee}',
                          label: 'LKR',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'About Doctor',
                    style: TextStyle(
                      color: _text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${doctor.name} is an experienced ${doctor.specialtyLabel} currently available through the OneClick healthcare service.',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _openBooking(doctor);
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: const Text(
                        'Book Appointment',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _profileStatistic({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: _primary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: _text,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: _muted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('doctors')
              .where('status', isEqualTo: 'active')
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];

            final List<DoctorModel> loadedDoctors = docs.map((doc) {
              final data = doc.data();
              final providerDetails =
                  data['providerDetails'] as Map<String, dynamic>? ?? {};

              final spec = providerDetails['specialization'] ??
                  data['specialization'] ??
                  'General Physician';

              final expYears = int.tryParse(
                    (providerDetails['experienceYears'] ?? '5').toString(),
                  ) ??
                  5;

              return DoctorModel(
                id: doc.id,
                name: data['name'] ?? 'Dr. Unknown',
                specialty: spec,
                specialtyLabel: spec,
                hospital: providerDetails['hospital'] ?? 'General Clinic',
                rating: 4.8,
                reviews: 24,
                experience: expYears,
                fee: 2500,
                available: true,
                nextSlot: 'Today • Available',
              );
            }).toList();

            final filteredDoctors = loadedDoctors.where((doctor) {
              final query = _searchQuery.trim().toLowerCase();
              final bool matchesSearch = query.isEmpty ||
                  doctor.name.toLowerCase().contains(query) ||
                  doctor.specialtyLabel.toLowerCase().contains(query) ||
                  doctor.hospital.toLowerCase().contains(query);

              final bool matchesSpecialty = _selectedSpecialty == 'All' ||
                  doctor.specialtyLabel.toLowerCase() ==
                      _selectedSpecialty.toLowerCase();

              return matchesSearch && matchesSpecialty;
            }).toList();

            return CustomScrollView(
              slivers: [
                // App Header Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _border),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: _text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(14),
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
                                style: TextStyle(
                                  color: _text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Healthcare made easier',
                                style: TextStyle(color: _muted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        // Real-time Notification Icon with Red Dot Indicator
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('notifications')
                              .where('userId',
                                  isEqualTo: _currentUser?.uid ?? '')
                              .where('isRead', isEqualTo: false)
                              .snapshots(),
                          builder: (context, notifSnapshot) {
                            final unreadDocs =
                                notifSnapshot.data?.docs.length ?? 0;
                            final hasUnread = unreadDocs > 0;

                            return Stack(
                              children: [
                                IconButton(
                                  tooltip: 'Notifications',
                                  onPressed: _openNotifications,
                                  icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: _text,
                                  ),
                                ),
                                if (hasUnread)
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Medical Vault',
                          onPressed: _openMedicalVault,
                          icon: const Icon(
                            Icons.folder_special_outlined,
                            color: _text,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Profile',
                          onPressed: _openProfile,
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            color: _text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hero Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(23),
                      decoration: BoxDecoration(
                        color: _primaryDark,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Find the right doctor\nfor your care.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) =>
                                  setState(() => _searchQuery = value),
                              decoration: InputDecoration(
                                hintText: 'Doctor, specialty or hospital...',
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: _primary,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quick Action Cards (4 Grid items)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _quickAction(
                                icon: Icons.calendar_month_rounded,
                                title: 'Appointments',
                                subtitle: 'Manage bookings',
                                color: _primary,
                                onTap: _openMyAppointments,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: _quickAction(
                                icon: Icons.medication_outlined,
                                title: 'Prescriptions',
                                subtitle: 'View E-Scripts',
                                color: _purple,
                                onTap: _openPrescriptions,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 11),
                        Row(
                          children: [
                            Expanded(
                              child: _quickAction(
                                icon: Icons.folder_special_outlined,
                                title: 'Medical Vault',
                                subtitle: 'Upload reports',
                                color: const Color(0xFF0284C7),
                                onTap: _openMedicalVault,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: _quickAction(
                                icon: Icons.smart_toy_outlined,
                                title: 'AI Assistant',
                                subtitle: 'Ask Health AI',
                                color: const Color(0xFFD97706),
                                onTap: _openAiAssistant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Specialty Selector
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
                    child: Text(
                      'Browse by Specialty',
                      style: TextStyle(
                        color: _text,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 92,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _specialties.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final specialty = _specialties[index];
                        final bool selected =
                            _selectedSpecialty == specialty['name'];

                        return InkWell(
                          onTap: () => setState(
                            () => _selectedSpecialty =
                                specialty['name'].toString(),
                          ),
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 85,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selected ? _primary : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected ? _primary : _border,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  specialty['icon'] as IconData,
                                  color: selected ? Colors.white : _primary,
                                  size: 24,
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  specialty['name'].toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF475569),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Doctor Section Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 13),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Available Doctors',
                            style: TextStyle(
                              color: _text,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${filteredDoctors.length} found',
                          style: const TextStyle(
                            color: _primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Doctor Cards
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (filteredDoctors.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No doctors found.',
                          style: TextStyle(color: _muted),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _doctorCard(filteredDoctors[index]),
                      );
                    },
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
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
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _doctorCard(DoctorModel doctor) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () => _showDoctorProfile(doctor),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: _primary,
                  size: 36,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      doctor.specialtyLabel,
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.hospital,
                      style: const TextStyle(color: _muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: _muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}