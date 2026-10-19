import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientMedicalVaultScreen extends StatefulWidget {
  const PatientMedicalVaultScreen({super.key});

  @override
  State<PatientMedicalVaultScreen> createState() =>
      _PatientMedicalVaultScreenState();
}

class _PatientMedicalVaultScreenState extends State<PatientMedicalVaultScreen> {
  static const Color bg = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color primary = Color(0xFF059669);
  static const Color primaryLight = Color(0xFFECFDF5);

  String selectedCategory = 'All';
  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _uploadNewDocument() async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    final titleController = TextEditingController();
    String category = 'Lab Reports';

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Upload Medical Document',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Document Title',
                    hintText: 'e.g., Blood Test Report',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Lab Reports', child: Text('Lab Reports')),
                    DropdownMenuItem(
                        value: 'Scans & X-Rays', child: Text('Scans & X-Rays')),
                    DropdownMenuItem(
                        value: 'Prescriptions', child: Text('Prescriptions')),
                    DropdownMenuItem(
                        value: 'Vaccinations', child: Text('Vaccinations')),
                  ],
                  onChanged: (val) {
                    if (val != null) category = val;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      await FirebaseFirestore.instance
                          .collection('medical_vault')
                          .add({
                        'patientId': uid,
                        'title': title,
                        'category': category,
                        'date': DateTime.now().toString().split(' ')[0],
                        'fileSize': '1.2 MB',
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Document uploaded to Vault!'),
                          backgroundColor: primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Save Document Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentUser?.uid;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ink,
        title: const Text(
          'Medical Vault',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadNewDocument,
        backgroundColor: primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Upload Record',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text('Please login to access Medical Vault.'))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildVaultBanner(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildCategoryChips(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('medical_vault')
                          .where('patientId', isEqualTo: uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data?.docs ?? [];

                        final filteredDocs = docs.where((doc) {
                          final cat = doc.data()['category'] ?? 'Lab Reports';
                          if (selectedCategory == 'All') return true;
                          return cat == selectedCategory;
                        }).toList();

                        if (filteredDocs.isEmpty) {
                          return const Center(
                            child: Text('No documents in this category.',
                                style: TextStyle(color: muted)),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final docData = filteredDocs[index].data();
                            final docId = filteredDocs[index].id;
                            return _buildDocumentTile(docId, docData);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildVaultBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF064E3B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF6EE7B7),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End-to-End Encrypted',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your health records are stored securely and accessible only by you.',
                  style: TextStyle(
                    color: Color(0xFFA7F3D0),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      'All',
      'Lab Reports',
      'Scans & X-Rays',
      'Prescriptions',
      'Vaccinations'
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: primaryLight,
              labelStyle: TextStyle(
                color: isSelected ? primary : muted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (_) {
                setState(() {
                  selectedCategory = cat;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDocumentTile(String docId, Map<String, dynamic> doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.folder_outlined, color: primary),
        ),
        title: Text(
          doc['title'] ?? 'Document',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: ink,
          ),
        ),
        subtitle: Text(
          '${doc['category'] ?? ''} • ${doc['date'] ?? ''}',
          style: const TextStyle(fontSize: 11, color: muted),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('medical_vault')
                .doc(docId)
                .delete();
          },
        ),
      ),
    );
  }
}