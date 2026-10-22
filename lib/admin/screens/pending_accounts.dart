import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PendingAccounts extends StatelessWidget {
  const PendingAccounts({super.key});

  Future<void> _updateAccountStatus(
    BuildContext context,
    String collection,
    String docId,
    String newStatus,
    String name,
  ) async {
    try {
      // 1. Update account status in Provider Collection (workers, food_sellers, doctors, drivers)
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .update({
  if (collection == 'seller_applications')
    'grocerySellerStatus': newStatus
  else
    'status': newStatus,
});

      // 2. Also update account status in main 'users' collection
      final application = await FirebaseFirestore.instance
    .collection(collection)
    .doc(docId)
    .get();

String? userId;

if (collection == 'seller_applications') {
  userId = application.data()?['userId'] as String?;
} else {
  userId = docId;
}

if (userId != null && userId.isNotEmpty) {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({
    if (collection == 'seller_applications')
      'grocerySellerStatus': newStatus
    else
      'status': newStatus,
  });
}
      // 3. Add entry to activity logs collection for Admin Dashboard
      final actionTitle =
          newStatus == 'active' ? 'Account Approved' : 'Account Rejected';
      final details = '$name ($collection) was marked as $newStatus.';

      await FirebaseFirestore.instance.collection('activity_logs').add({
        'action': actionTitle,
        'details': details,
        'performedBy': 'Admin',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name marked successfully as $newStatus'),
          backgroundColor: newStatus == 'active' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6, // Existing provider tabs + Drunk & Drive
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          backgroundColor: const Color(0xff032744),
          foregroundColor: Colors.white,
          title: const Text(
            'Pending Accounts',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
            
              Tab(text: 'Workers'),
              Tab(text: 'Food Sellers'),
              Tab(text: 'Doctors'),
              Tab(text: 'Drivers'),
              Tab(text: 'Grocery Sellers'),
              Tab(text: 'Drunk & Drive'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPendingList(context, 'workers'),
            _buildPendingList(context, 'food_sellers'),
            _buildPendingList(context, 'doctors'),
            _buildPendingList(context, 'drivers'),
            _buildPendingList(context, 'seller_applications'),
            _buildDrunkDrivePendingList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingList(BuildContext context, String collectionName) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(collectionName)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading pending accounts: ${snapshot.error}'),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No pending $collectionName accounts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final docId = doc.id;

            final isGrocerySeller = collectionName == 'seller_applications';

final name = isGrocerySeller
    ? (data['shopName'] ?? 'Unknown Shop')
    : (data['name'] ?? 'Unknown Name');

final email = data['email'] ?? 'No Email';

final phone = isGrocerySeller
    ? (data['phoneNumber'] ?? 'No Phone')
    : (data['phone'] ?? 'No Phone');

final businessAddress =
    data['businessAddress'] ?? 'No Address';
            final role = data['role'] ?? collectionName;
            final category = data['category'] ?? '';
            final details =
                data['providerDetails'] as Map<String, dynamic>? ?? {};

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              const Color(0xff032744).withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xff032744),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Pending',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text('Phone: $phone', style: const TextStyle(fontSize: 13)),
                    if (isGrocerySeller) ...[
  const SizedBox(height: 4),
  Text(
    'Business Address: $businessAddress',
    style: const TextStyle(fontSize: 13),
  ),
],
                    const SizedBox(height: 4),
                    Text('Role: $role', style: const TextStyle(fontSize: 13)),
                    if (category.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Category / Skill: $category',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6FB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: details.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '${entry.key}: ${entry.value}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _updateAccountStatus(
                            context,
                            collectionName,
                            docId,
                            'rejected',
                            name,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _updateAccountStatus(
                            context,
                            collectionName,
                            docId,
                            'active',
                            name,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Approve'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  // Drunk & Drive uses a separate application collection and approval status.
  // Do not update users.status: it is shared by other OneClick modules.
  Future<void> _updateDrunkDriveStatus(
    BuildContext context,
    String applicationId,
    String name,
    String newStatus,
  ) async {
    if (newStatus != 'approved' && newStatus != 'rejected') return;

    try {
      final firestore = FirebaseFirestore.instance;
      final applicationRef = firestore
          .collection('drunkDriveDriverApplications')
          .doc(applicationId);
      final logRef = firestore.collection('activity_logs').doc();

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(applicationRef);
        if (!snapshot.exists || snapshot.data()?['status'] != 'pending') {
          throw StateError('Application is no longer pending.');
        }

        transaction.update(applicationRef, {
          'status': newStatus,
          'adminNotes': null,
        });
        transaction.set(logRef, {
          'action': newStatus == 'approved'
              ? 'Drunk & Drive Driver Approved'
              : 'Drunk & Drive Driver Rejected',
          'details': '$name (Drunk & Drive) was marked as $newStatus.',
          'performedBy': 'Admin',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name marked as $newStatus'),
          backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update driver application: $error')),
      );
    }
  }

  Widget _buildDrunkDrivePendingList(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('drunkDriveDriverApplications')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Unable to load Drunk & Drive applications: ${snapshot.error}'),
          );
        }

        final applications = snapshot.data?.docs ?? [];
        if (applications.isEmpty) {
          return const Center(child: Text('No pending Drunk & Drive applications'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final doc = applications[index];
            final data = doc.data();
            final name = (data['fullName'] as String?)?.trim().isNotEmpty == true
                ? data['fullName'] as String
                : 'Unnamed Applicant';
            final phone = data['phone'] as String? ?? 'Not provided';
            final licenceType = data['licenceType'] as String? ?? 'Not provided';
            final expiry = data['licenceExpiry'] as String? ?? 'Not provided';
            final experience = data['drivingExperienceYears'] as num? ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: 10),
                    Text('Phone: $phone'),
                    Text('Licence type: $licenceType'),
                    Text('Licence expiry: $expiry'),
                    Text('Driving experience: $experience years'),
                    Text('Manual: ${data['canDriveManual'] == true ? 'Yes' : 'No'}'),
                    Text('Automatic: ${data['canDriveAutomatic'] == true ? 'Yes' : 'No'}'),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _updateDrunkDriveStatus(
                            context, doc.id, name, 'rejected',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _updateDrunkDriveStatus(
                            context, doc.id, name, 'approved',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approve'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

}