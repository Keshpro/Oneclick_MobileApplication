import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorPatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const DoctorPatientDetailScreen({super.key, required this.appointmentData});

  String _value(dynamic value) {
    if (value == null) return 'Not provided';
    final text = value.toString().trim();
    return text.isEmpty ? 'Not provided' : text;
  }

  Widget _field(String label, dynamic value) {
    return ListTile(
      dense: true,
      title: Text(label, style: const TextStyle(color: Colors.grey)),
      subtitle: Text(
        _value(value),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientId =
        (appointmentData['patientId'] ?? appointmentData['userId'] ?? '')
            .toString();

    final doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final appointmentId = (appointmentData['docId'] ?? '').toString();

    if (patientId.isEmpty || doctorId.isEmpty || appointmentId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Invalid patient or appointment reference')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Profile')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .get(),
        builder: (context, appointmentSnapshot) {
          if (appointmentSnapshot.hasError) {
            return Center(
              child: Text(
                'Unable to verify appointment: '
                '${appointmentSnapshot.error}',
              ),
            );
          }

          if (!appointmentSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointment = appointmentSnapshot.data!.data();

          if (appointment == null ||
              appointment['doctorId'] != doctorId ||
              appointment['userId'] != patientId) {
            return const Center(child: Text('Access denied'));
          }

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(patientId)
                .snapshots(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Patient profile unavailable: '
                    '${profileSnapshot.error}',
                  ),
                );
              }

              if (!profileSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final profile = profileSnapshot.data!.data() ?? {};

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Color(0xFFECFDF5),
                      child: Icon(
                        Icons.person,
                        size: 42,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _value(
                      profile['name'] ??
                          profile['fullName'] ??
                          appointment['patientName'],
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Patient Information',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _field(
                          'Email',
                          profile['email'] ?? appointment['userEmail'],
                        ),
                        _field('Phone', profile['phone']),
                        _field('Date of Birth', profile['dateOfBirth']),
                        _field('Gender', profile['gender']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Column(
                      children: [
                        const ListTile(
                          title: Text(
                            'Current Appointment',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _field('Date', appointment['date']),
                        _field('Time', appointment['time']),
                        _field('Type', appointment['type']),
                        _field('Reason', appointment['reason']),
                        _field('Status', appointment['status']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Appointment History With You',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('doctorId', isEqualTo: doctorId)
                        .where('userId', isEqualTo: patientId)
                        .snapshots(),
                    builder: (context, historySnapshot) {
                      if (historySnapshot.hasError) {
                        return Text(
                          'History unavailable: '
                          '${historySnapshot.error}',
                        );
                      }

                      if (!historySnapshot.hasData) {
                        return const LinearProgressIndicator();
                      }

                      final docs = historySnapshot.data!.docs;

                      if (docs.isEmpty) {
                        return const Text('No previous appointments found.');
                      }

                      return Column(
                        children: docs.map((doc) {
                          final data = doc.data();

                          return Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.history,
                                color: Color(0xFF059669),
                              ),
                              title: Text(_value(data['date'])),
                              subtitle: Text(
                                '${_value(data['time'])} • '
                                '${_value(data['status'])}',
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
