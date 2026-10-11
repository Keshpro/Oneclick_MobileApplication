import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/doctor_model.dart'; // DoctorModel import kela ahe
import 'ai_assistant_screen.dart';
import 'book_appointment_screen.dart';
import 'my_appointments_screen.dart';

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
    {'name': 'General', 'icon': Icons.medical_services_rounded},
    {'name': 'Cardiology', 'icon': Icons.favorite_rounded},
    {'name': 'Dental', 'icon': Icons.health_and_safety_rounded},
    {'name': 'Children', 'icon': Icons.child_care_rounded},
    {'name': 'Skin', 'icon': Icons.face_retouching_natural_rounded},
  ];

  // Dummy data aapan DoctorModel madhye convert kela ahe
  final List<DoctorModel> _doctors = [
    const DoctorModel(
      id: 'doctor_001',
      name: 'Dr. Nimal Perera',
      specialty: 'General',
      specialtyLabel: 'General Physician',
      hospital: 'Central Medical Centre',
      rating: 4.8,
      reviews: 124,
      experience: 10,
      fee: 2500,
      available: true,
      nextSlot: 'Today • 3:30 PM',
    ),
    const DoctorModel(
      id: 'doctor_002',
      name: 'Dr. Amali Silva',
      specialty: 'Cardiology',
      specialtyLabel: 'Cardiologist',
      hospital: 'City Heart Centre',
      rating: 4.9,
      reviews: 98,
      experience: 12,
      fee: 3500,
      available: true,
      nextSlot: 'Today • 5:00 PM',
    ),
    const DoctorModel(
      id: 'doctor_003',
      name: 'Dr. Kasun Fernando',
      specialty: 'Skin',
      specialtyLabel: 'Dermatologist',
      hospital: 'Health Care Hospital',
      rating: 4.7,
      reviews: 76,
      experience: 8,
      fee: 3000,
      available: false,
      nextSlot: 'Tomorrow • 9:00 AM',
    ),
    const DoctorModel(
      id: 'doctor_004',
      name: 'Dr. Sachini Jayawardena',
      specialty: 'Children',
      specialtyLabel: 'Paediatrician',
      hospital: 'Children Medical Centre',
      rating: 4.9,
      reviews: 143,
      experience: 11,
      fee: 2800,
      available: true,
      nextSlot: 'Today • 6:30 PM',
    ),
  ];

  // Search aani Category pramane doctors filter karnara logic
  List<DoctorModel> get _filteredDoctors {
    return _doctors.where((doctor) {
      final query = _searchQuery.trim().toLowerCase();
      final bool matchesSearch = query.isEmpty ||
          doctor.name.toLowerCase().contains(query) ||
          doctor.specialtyLabel.toLowerCase().contains(query) ||
          doctor.hospital.toLowerCase().contains(query);

      final bool matchesSpecialty =
          _selectedSpecialty == 'All' || doctor.specialty == _selectedSpecialty;

      return matchesSearch && matchesSpecialty;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAiAssistant() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AiAssistantScreen()));
  }

  void _openMyAppointments() {
    if (_isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAppointmentsScreen()));
      return;
    }
    _showLoginRequired(
      title: 'Login required',
      description: 'Login to view and manage your appointments.',
    );
  }

  void _openBooking(DoctorModel doctor) {
    if (_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookAppointmentScreen(
            doctor: {
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
      description: 'Create an account or login to book an appointment with ${doctor.name}.',
    );
  }

  void _showLoginRequired({required String title, required String description}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 44, height: 5, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(20))),
                const SizedBox(height: 25),
                Container(
                  width: 68, height: 68,
                  decoration: const BoxDecoration(color: _lightGreen, shape: BoxShape.circle),
                  child: const Icon(Icons.lock_outline_rounded, color: _primary, size: 32),
                ),
                const SizedBox(height: 17),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(color: _text, fontSize: 21, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(description, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 14, height: 1.5)),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary, foregroundColor: Colors.white, elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Login to Continue', style: TextStyle(fontWeight: FontWeight.w700)),
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
                    child: const Text('Create New Account', style: TextStyle(color: _primary, fontWeight: FontWeight.w700)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Continue Exploring', style: TextStyle(color: _muted)),
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
          initialChildSize: 0.80, minChildSize: 0.55, maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
                children: [
                  Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(20)))),
                  const SizedBox(height: 25),
                  Center(
                    child: Container(
                      width: 90, height: 90,
                      decoration: const BoxDecoration(color: _lightGreen, shape: BoxShape.circle),
                      child: const Icon(Icons.person_rounded, color: _primary, size: 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(doctor.name, textAlign: TextAlign.center, style: const TextStyle(color: _text, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text(doctor.specialtyLabel, textAlign: TextAlign.center, style: const TextStyle(color: _primary, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  Text(doctor.hospital, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 13)),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(child: _profileStatistic(icon: Icons.star_rounded, value: '${doctor.rating}', label: 'Rating')),
                      const SizedBox(width: 10),
                      Expanded(child: _profileStatistic(icon: Icons.workspace_premium_rounded, value: '${doctor.experience}+', label: 'Years')),
                      const SizedBox(width: 10),
                      Expanded(child: _profileStatistic(icon: Icons.payments_outlined, value: '${doctor.fee}', label: 'LKR')),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text('About Doctor', style: TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    '${doctor.name} is an experienced ${doctor.specialtyLabel} currently available through the OneClick healthcare service. Browse availability and consultation information before making an appointment.',
                    style: const TextStyle(color: _muted, fontSize: 13, height: 1.6),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18), border: Border.all(color: _border)),
                    child: Row(
                      children: [
                        Container(
                          width: 45, height: 45,
                          decoration: BoxDecoration(
                            color: doctor.available ? _lightGreen : const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(Icons.calendar_month_rounded, color: doctor.available ? _primary : const Color(0xFFEA580C)),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Next available', style: TextStyle(color: _muted, fontSize: 11)),
                              const SizedBox(height: 3),
                              Text(doctor.nextSlot, style: const TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _openBooking(doctor);
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: const Text('Book Appointment', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary, foregroundColor: Colors.white, elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  Widget _profileStatistic({required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: _primary, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: _text, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: _muted, fontSize: 10)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 45, height: 45,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
                        child: const Icon(Icons.arrow_back_rounded, color: _text),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 45, height: 45,
                      decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 23),
                    ),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OneClick Health', style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w800)),
                          Text('Healthcare made easier', style: TextStyle(color: _muted, fontSize: 11)),
                        ],
                      ),
                    ),
                    if (_isLoggedIn)
                      Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 5), decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle)),
                    IconButton(tooltip: 'My Appointments', onPressed: _openMyAppointments, icon: const Icon(Icons.calendar_today_rounded, color: _text)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(23),
                  decoration: BoxDecoration(
                    color: _primaryDark, borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 22, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(30)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.health_and_safety_rounded, color: Color(0xFF6EE7B7), size: 15),
                            SizedBox(width: 6),
                            Text('ONECLICK HEALTH', style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 10, letterSpacing: 0.7, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 17),
                      const Text('Find the right doctor\nfor your care.', style: TextStyle(color: Colors.white, fontSize: 29, height: 1.12, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      const Text('Explore trusted doctors, check availability and find the care you need.', style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 13, height: 1.5)),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'Doctor, specialty or hospital...',
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            prefixIcon: const Icon(Icons.search_rounded, color: _primary),
                            suffixIcon: _searchQuery.isNotEmpty ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    icon: const Icon(Icons.close_rounded)) : null,
                            border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _quickAction(
                        icon: Icons.search_rounded, title: 'Find Doctor', subtitle: 'Browse doctors', color: _primary,
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _selectedSpecialty = 'All';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: _quickAction(
                        icon: Icons.smart_toy_outlined, title: 'AI Assistant', subtitle: 'Ask Health AI', color: _purple,
                        onTap: _openAiAssistant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text('Browse by Specialty', style: TextStyle(color: _text, fontSize: 19, fontWeight: FontWeight.w800)),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 92,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _specialties.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final specialty = _specialties[index];
                    final bool selected = _selectedSpecialty == specialty['name'];

                    return InkWell(
                      onTap: () => setState(() => _selectedSpecialty = specialty['name'].toString()),
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200), width: 85, padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selected ? _primary : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: selected ? _primary : _border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(specialty['icon'] as IconData, color: selected ? Colors.white : _primary, size: 24),
                            const SizedBox(height: 7),
                            Text(
                              specialty['name'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: selected ? Colors.white : const Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 13),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Doctors', style: TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800)),
                          SizedBox(height: 3),
                          Text('Explore doctors available on OneClick', style: TextStyle(color: _muted, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text('${_filteredDoctors.length} found', style: const TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            if (_filteredDoctors.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 45),
                  child: Column(
                    children: [
                      Icon(Icons.person_search_rounded, color: Color(0xFF94A3B8), size: 50),
                      SizedBox(height: 10),
                      Text('No doctors found', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: _filteredDoctors.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, index == 0 ? 0 : 6, 20, 8),
                    child: _doctorCard(_filteredDoctors[index]),
                  );
                },
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 15),
                child: InkWell(
                  onTap: _openAiAssistant,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFEDE9FE)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(color: _purple, borderRadius: BorderRadius.circular(18)),
                          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(child: Text('AI Health Assistant', style: TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w800))),
                                  SizedBox(width: 7),
                                  DecoratedBox(
                                    decoration: BoxDecoration(color: Color(0xFFEDE9FE), borderRadius: BorderRadius.all(Radius.circular(20))),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      child: Text('AI', style: TextStyle(color: _purple, fontSize: 9, fontWeight: FontWeight.w800)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text('Ask health questions and find the right care faster.', style: TextStyle(color: _muted, fontSize: 12, height: 1.4)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _purple),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
                child: _isLoggedIn ? _loggedInCard() : _guestCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loggedInCard() {
    final user = _currentUser;
    String displayName = 'OneClick User';
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      displayName = user.displayName!;
    } else if (user?.email != null && user!.email!.trim().isNotEmpty) {
      displayName = user.email!.split('@').first;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFD1FAE5))),
      child: Column(
        children: [
          Container(
            width: 52, height: 52, decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text('Hi, $displayName', textAlign: TextAlign.center, style: const TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text('You are signed in. You can book and manage your appointments.', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 12, height: 1.5)),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openMyAppointments, icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: const Text('My Appointments', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary, foregroundColor: Colors.white, elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guestCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: _border)),
      child: Column(
        children: [
          const Icon(Icons.account_circle_outlined, color: _primary, size: 34),
          const SizedBox(height: 10),
          const Text('Like what you see?', style: TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            'You can explore doctors and try the AI Health Assistant without an account. Create an account when you are ready to book appointments or use personalized features.',
            textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary, foregroundColor: Colors.white, elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Create Free Account', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 5),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('Already have an account? Login', style: TextStyle(color: _primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white, borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
          child: Row(
            children: [
              Container(
                width: 43, height: 43, decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 9)),
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
      color: Colors.white, borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () => _showDoctorProfile(doctor),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: _border)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70, height: 78, decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(17)),
                child: const Icon(Icons.person_rounded, color: _primary, size: 38),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(doctor.specialtyLabel, style: const TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFF94A3B8), size: 13),
                        const SizedBox(width: 3),
                        Expanded(child: Text(doctor.hospital, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 10))),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 15),
                        const SizedBox(width: 3),
                        Text('${doctor.rating}', style: const TextStyle(color: _text, fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        Text('(${doctor.reviews})', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: doctor.available ? _lightGreen : const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            doctor.available ? 'Available' : 'Next day',
                            style: TextStyle(color: doctor.available ? _primary : const Color(0xFFEA580C), fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Text(doctor.nextSlot, style: const TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.w600))),
                        const Icon(Icons.arrow_forward_rounded, color: _primary, size: 17),
                      ],
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
}