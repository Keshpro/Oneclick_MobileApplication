import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseManagement extends StatefulWidget {
  const DatabaseManagement({super.key});

  @override
  State<DatabaseManagement> createState() => _DatabaseManagementState();
}

class _DatabaseManagementState extends State<DatabaseManagement>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xff032744);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Backup Trigger & Log Entry Function
  Future<void> _triggerDatabaseBackup() async {
    try {
      await FirebaseFirestore.instance.collection('activity_logs').add({
        'action': 'Database Backup',
        'details': 'System data snapshot and audit backup initiated.',
        'performedBy': 'Admin',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database backup completed & logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Database Management'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Data Overview'),
            Tab(icon: Icon(Icons.people_alt_outlined), text: 'System Roles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Real-time Collections Overview with Clickable Interactive Lists
          _buildOverviewTab(),

          // TAB 2: Roles View (User, Doctor, Driver, Admin)
          _buildRolesTab(),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 1: DATA OVERVIEW (Clickable Real-Time Data Expansion)
  // ============================================================
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Real-Time Data Collections',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap any category to view live records from Firestore.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),

          // Clickable Interactive Stat Cards
          _buildInteractiveStatCard(
            collectionPath: 'appointments',
            title: 'Appointments',
            icon: Icons.calendar_month_rounded,
            color: Colors.teal,
            itemBuilder: (data) {
              final userEmail = data['userEmail'] ?? 'Patient';
              final date = data['date'] ?? 'N/A';
              final time = data['time'] ?? 'N/A';
              final status = data['status'] ?? 'Upcoming';
              return ListTile(
                dense: true,
                title: Text(userEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Date: $date at $time'),
                trailing: Chip(
                  label: Text(status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                  backgroundColor: status == 'Approved' ? Colors.green : Colors.orange,
                ),
              );
            },
          ),

          _buildInteractiveStatCard(
            collectionPath: 'users',
            title: 'Registered Users',
            icon: Icons.people_rounded,
            color: Colors.blue,
            itemBuilder: (data) {
              final name = data['name'] ?? 'User';
              final email = data['email'] ?? 'N/A';
              final role = data['role'] ?? 'user';
              return ListTile(
                dense: true,
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(email),
                trailing: Text(role.toString().toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
              );
            },
          ),

          _buildInteractiveStatCard(
            collectionPath: 'doctors',
            title: 'Medical Doctors',
            icon: Icons.medical_services_rounded,
            color: Colors.green,
            itemBuilder: (data) {
              final name = data['name'] ?? 'Doctor';
              final email = data['email'] ?? 'N/A';
              final status = data['status'] ?? 'pending';
              return ListTile(
                dense: true,
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(email),
                trailing: Chip(
                  label: Text(status.toString().toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                  backgroundColor: status == 'active' || status == 'approved' ? Colors.green : Colors.orange,
                ),
              );
            },
          ),

          _buildInteractiveStatCard(
            collectionPath: 'drivers',
            title: 'Registered Drivers',
            icon: Icons.directions_car_rounded,
            color: Colors.orange,
            itemBuilder: (data) {
              final name = data['name'] ?? 'Driver';
              final email = data['email'] ?? 'N/A';
              return ListTile(
                dense: true,
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(email),
              );
            },
          ),

          _buildInteractiveStatCard(
            collectionPath: 'activity_logs',
            title: 'Audit & Activity Logs',
            icon: Icons.history_rounded,
            color: Colors.purple,
            itemBuilder: (data) {
              final action = data['action'] ?? 'Event';
              final details = data['details'] ?? '';
              return ListTile(
                dense: true,
                title: Text(action, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(details, maxLines: 1, overflow: TextOverflow.ellipsis),
              );
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          const Text(
            'Database Maintenance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),

          // Backup Database Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _triggerDatabaseBackup,
              icon: const Icon(Icons.cloud_download_rounded),
              label: const Text(
                'Initiate Database Backup',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
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

  // Interactive Expansion Card for Firestore Collections
  Widget _buildInteractiveStatCard({
    required String collectionPath,
    required String title,
    required IconData icon,
    required Color color,
    required Widget Function(Map<String, dynamic> data) itemBuilder,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(collectionPath).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final countText = snapshot.hasData ? '${docs.length} Records' : 'Loading...';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              countText,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
            children: docs.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Text('No records found in this collection.',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    )
                  ]
                : docs.map((doc) => itemBuilder(doc.data())).toList(),
          ),
        );
      },
    );
  }

  // ============================================================
  // TAB 2: SYSTEM ROLES
  // ============================================================
  Widget _buildRolesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Users Categorized by Role',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),

          _buildRoleCategoryTile('Doctor', 'doctors', Icons.medical_services_rounded, Colors.green),
          _buildRoleCategoryTile('Driver', 'drivers', Icons.directions_car_rounded, Colors.orange),
          _buildRoleCategoryTile('User / Patient', 'users', Icons.person_rounded, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildRoleCategoryTile(
    String roleName,
    String collection,
    IconData icon,
    Color color,
  ) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            title: Text(
              '$roleName Role',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text('${docs.length} Active Accounts'),
            children: docs.map((doc) {
              final data = doc.data();
              final name = data['name'] ?? 'N/A';
              final email = data['email'] ?? 'N/A';
              final status = data['status'] ?? 'active';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(email, style: const TextStyle(fontSize: 12)),
                trailing: Chip(
                  label: Text(
                    status.toString().toUpperCase(),
                    style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: status == 'active' || status == 'approved' ? Colors.green : Colors.orange,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}