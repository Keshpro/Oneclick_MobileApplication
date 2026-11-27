import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PendingAccounts extends StatefulWidget {
  const PendingAccounts({super.key});

  @override
  State<PendingAccounts> createState() => _PendingAccountsState();
}

class _PendingAccountsState extends State<PendingAccounts> {
  static const Color _primary = Color(0xff032744);
  static const Color _background = Color(0xFFF4F6FB);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Set<String> _processingAccounts = {};

  // =========================================================
  // PROVIDER CONFIGURATION
  // =========================================================

  static const List<Map<String, String>> _providers = [
    {'title': 'Workers', 'collection': 'workers'},
    {'title': 'Food Sellers', 'collection': 'food_sellers'},
    {'title': 'Doctors', 'collection': 'doctors'},
    {'title': 'Grocery Sellers', 'collection': 'seller_applications'},
    {'title': 'Drunk & Drive', 'collection': 'drunkDriveDriverApplications'},
  ];

  // =========================================================
  // SAFE DATA HELPERS
  // =========================================================

  String _readText(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;

    if (value is Timestamp) {
      final date = value.toDate();

      return '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }

    final text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }

  String _getName(Map<String, dynamic> data) {
    return _readText(
      data['shopName'] ??
          data['fullName'] ??
          data['name'] ??
          data['businessName'],
      'Unknown Applicant',
    );
  }

  String _getProviderName(String collection) {
    switch (collection) {
      case 'workers':
        return 'QuickFix Worker';

      case 'food_sellers':
        return 'Food Seller';

      case 'doctors':
        return 'Doctor';

      case 'seller_applications':
        return 'Grocery Seller';

      case 'drivers':
      case 'drunkDriveDriverApplications':
        return 'Drunk & Drive';

      default:
        return 'Service Provider';
    }
  }

  // =========================================================
  // APPROVAL / REJECTION CONFIRMATION
  // =========================================================

  Future<void> _confirmAction({
    required String collection,
    required String documentId,
    required String name,
    required bool approve,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(approve ? 'Approve Account' : 'Reject Account'),
          content: Text(
            approve
                ? 'Are you sure you want to approve $name?'
                : 'Are you sure you want to reject $name?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: approve ? Colors.green : Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(approve ? 'Approve' : 'Reject'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await _updateAccountStatus(
      collection: collection,
      documentId: documentId,
      name: name,
      approve: approve,
    );
  }

  // =========================================================
  // FIRESTORE TRANSACTION
  // =========================================================

  Future<void> _updateAccountStatus({
    required String collection,
    required String documentId,
    required String name,
    required bool approve,
  }) async {
    final processingKey = '$collection/$documentId';

    if (_processingAccounts.contains(processingKey)) {
      return;
    }

    final admin = FirebaseAuth.instance.currentUser;

    if (admin == null) {
      _showMessage('Admin session expired. Please login again.', Colors.red);

      return;
    }

    setState(() {
      _processingAccounts.add(processingKey);
    });

    final isDrunkDrive = collection == 'drunkDriveDriverApplications';

    final isGrocerySeller = collection == 'seller_applications';

    // Preserve existing status conventions.
    final String newStatus = approve
        ? (isDrunkDrive ? 'approved' : 'active')
        : 'rejected';

    try {
      final providerRef = _firestore.collection(collection).doc(documentId);

      final logRef = _firestore.collection('activity_logs').doc();

      await _firestore.runTransaction((transaction) async {
        // Read provider application.
        final providerSnapshot = await transaction.get(providerRef);

        if (!providerSnapshot.exists) {
          throw StateError('Provider application was not found.');
        }

        final providerData = providerSnapshot.data() ?? <String, dynamic>{};

        final currentStatus = _readText(providerData['status']).toLowerCase();

        if (currentStatus != 'pending') {
          throw StateError('This application has already been processed.');
        }

        // Read linked user account before making writes.
        DocumentReference<Map<String, dynamic>>? userRef;

        if (!isDrunkDrive) {
          String userId;

          if (isGrocerySeller) {
            userId = _readText(providerData['userId']);
          } else {
            userId = documentId;
          }

          if (userId.isEmpty) {
            throw StateError('Linked user ID was not found.');
          }

          userRef = _firestore.collection('users').doc(userId);

          final userSnapshot = await transaction.get(userRef);

          if (!userSnapshot.exists) {
            throw StateError('Linked user account was not found.');
          }
        }

        // Update provider application.
        final Map<String, dynamic> providerUpdates = {
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
          'reviewedAt': FieldValue.serverTimestamp(),
          'reviewedBy': admin.uid,
          'approvedAt': approve ? FieldValue.serverTimestamp() : null,
          'rejectedAt': approve ? null : FieldValue.serverTimestamp(),
        };

        if (isGrocerySeller) {
          providerUpdates['grocerySellerStatus'] = newStatus;
        }

        if (isDrunkDrive) {
          providerUpdates['adminNotes'] = null;
        }

        transaction.update(providerRef, providerUpdates);

        // Drunk & Drive uses its own application status.
        // Do not change the user's global account status.
        if (userRef != null) {
          final Map<String, dynamic> userUpdates = {
            'updatedAt': FieldValue.serverTimestamp(),
          };

          if (isGrocerySeller) {
            userUpdates['grocerySellerStatus'] = newStatus;
          } else {
            userUpdates['status'] = newStatus;

            userUpdates['approvedAt'] = approve
                ? FieldValue.serverTimestamp()
                : null;
          }

          transaction.update(userRef, userUpdates);
        }

        // Save an activity log in the same transaction.
        transaction.set(logRef, {
          'action': approve ? 'Account Approved' : 'Account Rejected',
          'details':
              '$name (${_getProviderName(collection)}) '
              'was marked as $newStatus.',
          'performedBy': 'Admin',
          'performedByUid': admin.uid,
          'providerId': documentId,
          'collection': collection,
          'providerType': _getProviderName(collection),
          'status': newStatus,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;

      _showMessage(
        approve
            ? '$name approved successfully.'
            : '$name rejected successfully.',
        approve ? Colors.green : Colors.red,
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(
        'Firebase error: ${error.message ?? error.code}',
        Colors.red,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage('Unable to update account: $error', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _processingAccounts.remove(processingKey);
        });
      }
    }
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

  void _showMessage(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // =========================================================
  // MAIN SCREEN
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _providers.length,
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Pending Accounts',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            dividerColor: Colors.transparent,
            tabs: _providers.map((provider) {
              return Tab(text: provider['title']);
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: _providers.map((provider) {
            final collection = provider['collection']!;

            if (collection == 'drunkDriveDriverApplications') {
              return _buildCombinedDriverList();
            }

            return _buildPendingList(collection);
          }).toList(),
        ),
      ),
    );
  }

  // =========================================================
  // STANDARD PROVIDER LIST
  // =========================================================

  Widget _buildPendingList(String collection) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection(collection)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data!.docs;

        if (documents.isEmpty) {
          return _buildEmptyState(
            'No pending ${_getProviderName(collection)} '
            'accounts.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final document = documents[index];

            return _buildProviderCard(
              collection: collection,
              document: document,
            );
          },
        );
      },
    );
  }

  // =========================================================
  // COMBINED DRIVER LIST
  // =========================================================

  Widget _buildCombinedDriverList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.directions_car_rounded, color: _primary, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drunk & Drive Applications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Review all driver registration requests.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildDriverSection(
          collection: 'drunkDriveDriverApplications',
          title: 'Driver Applications',
        ),

        const SizedBox(height: 20),

        _buildDriverSection(
          collection: 'drivers',
          title: 'Previous Driver Registrations',
        ),
      ],
    );
  }

  Widget _buildDriverSection({
    required String collection,
    required String title,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection(collection)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (snapshot.hasData)
                  Chip(label: Text('${snapshot.data!.docs.length}')),
              ],
            ),

            const SizedBox(height: 10),

            if (snapshot.hasError)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Unable to load applications: '
                  '${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (!snapshot.hasData)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (snapshot.data!.docs.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('No pending applications.')),
                ),
              )
            else
              ...snapshot.data!.docs.map((document) {
                return _buildProviderCard(
                  collection: collection,
                  document: document,
                );
              }),
          ],
        );
      },
    );
  }

  // =========================================================
  // PROVIDER ACCOUNT CARD
  // =========================================================

  Widget _buildProviderCard({
    required String collection,
    required QueryDocumentSnapshot<Map<String, dynamic>> document,
  }) {
    final data = document.data();

    final name = _getName(data);

    final email = _readText(data['email'], 'Not provided');

    final phone = _readText(
      data['phone'] ?? data['phoneNumber'] ?? data['contactNumber'],
      'Not provided',
    );

    final address = _readText(data['businessAddress'] ?? data['address']);

    final category = _readText(
      data['category'] ?? data['specialization'] ?? data['skill'],
    );

    final processingKey = '$collection/${document.id}';

    final isProcessing = _processingAccounts.contains(processingKey);

    final isDriver =
        collection == 'drivers' || collection == 'drunkDriveDriverApplications';

    final rawDetails = data['providerDetails'];

    final Map<String, dynamic> details = rawDetails is Map
        ? rawDetails.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: _primary.withValues(alpha: 0.10),
                  child: Icon(_getProviderIcon(collection), color: _primary),
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
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
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

            const Divider(height: 28),

            _buildInfoRow(
              Icons.person_outline,
              'Provider',
              _getProviderName(collection),
            ),

            _buildInfoRow(Icons.phone_outlined, 'Phone', phone),

            if (address.isNotEmpty)
              _buildInfoRow(Icons.location_on_outlined, 'Address', address),

            if (category.isNotEmpty)
              _buildInfoRow(
                Icons.category_outlined,
                'Category / Skill',
                category,
              ),

            if (data['createdAt'] != null)
              _buildInfoRow(
                Icons.calendar_today_outlined,
                'Registered',
                _readText(data['createdAt']),
              ),

            if (isDriver) ...[
              const SizedBox(height: 8),

              _buildOptionalInfo('Licence Type', data['licenceType']),

              _buildOptionalInfo('Licence Number', data['licenceNumber']),

              _buildOptionalInfo('Licence Expiry', data['licenceExpiry']),

              if (data['drivingExperienceYears'] != null)
                _buildInfoRow(
                  Icons.history,
                  'Experience',
                  '${data['drivingExperienceYears']} years',
                ),

              if (data['canDriveManual'] != null)
                _buildInfoRow(
                  Icons.directions_car_outlined,
                  'Manual',
                  data['canDriveManual'] == true ? 'Yes' : 'No',
                ),

              if (data['canDriveAutomatic'] != null)
                _buildInfoRow(
                  Icons.directions_car_outlined,
                  'Automatic',
                  data['canDriveAutomatic'] == true ? 'Yes' : 'No',
                ),
            ],

            if (details.isNotEmpty) ...[
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Provider Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    ...details.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '${entry.key}: '
                          '${_readText(entry.value)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF374151),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            if (isProcessing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _confirmAction(
                        collection: collection,
                        documentId: document.id,
                        name: name,
                        approve: false,
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _confirmAction(
                        collection: collection,
                        documentId: document.id,
                        name: name,
                        approve: true,
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PROVIDER ICONS
  // =========================================================

  IconData _getProviderIcon(String collection) {
    switch (collection) {
      case 'workers':
        return Icons.construction_rounded;

      case 'food_sellers':
        return Icons.restaurant_rounded;

      case 'doctors':
        return Icons.medical_services_rounded;

      case 'seller_applications':
        return Icons.storefront_rounded;

      case 'drivers':
      case 'drunkDriveDriverApplications':
        return Icons.directions_car_rounded;

      default:
        return Icons.person_outline;
    }
  }

  // =========================================================
  // INFORMATION ROW
  // =========================================================

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: Colors.grey.shade600),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalInfo(String label, dynamic value) {
    final text = _readText(value);

    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildInfoRow(Icons.badge_outlined, label, text);
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 72,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            const Text(
              'All caught up!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ERROR STATE
  // =========================================================

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),

            const SizedBox(height: 16),

            const Text(
              'Unable to load accounts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
