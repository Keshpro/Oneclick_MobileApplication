
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'pending_accounts.dart';

class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({super.key});

  @override
  State<PendingUsersScreen> createState() =>
      _PendingUsersScreenState();
}

class _PendingUsersScreenState
    extends State<PendingUsersScreen> {
  static const Color _primary = Color(0xff032744);
  static const Color _background = Color(0xFFF4F6FB);
  static const Color _text = Color(0xFF111827);

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final Set<String> _processingUsers = {};

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _pendingUsersStream;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _pendingUsersStream = _firestore
        .collection('users')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // =========================================================
  // ROLE VALIDATION
  // =========================================================

  static const Set<String> _providerRoles = {
    'provider',
    'serviceprovider',
    'doctor',
    'doctors',
    'worker',
    'workers',
    'quickfix',
    'quickfixworker',
    'driver',
    'drivers',
    'drunkdrive',
    'drunkanddrive',
    'drinkdrive',
    'drinkanddrive',
    'foodseller',
    'foodvendor',
    'fooddelivery',
    'restaurant',
    'restaurantseller',
    'groceryseller',
    'groceryvendor',
    'seller',
    'vendor',
    'admin',
  };

  static const Set<String> _customerRoles = {
    'user',
    'customer',
    'patient',
    'passenger',
    'normaluser',
    'regularuser',
  };

  String _normalizeRole(dynamic value) {
    return value
            ?.toString()
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]'), '') ??
        '';
  }

  Set<String> _getRoles(Map<String, dynamic> data) {
    final roles = <String>{};

    for (final key in [
      'role',
      'roles',
      'userRole',
      'userType',
      'accountType',
      'providerType',
      'serviceType',
    ]) {
      final value = data[key];

      if (value is Iterable) {
        for (final item in value) {
          final role = _normalizeRole(item);

          if (role.isNotEmpty) {
            roles.add(role);
          }
        }
      } else {
        final role = _normalizeRole(value);

        if (role.isNotEmpty) {
          roles.add(role);
        }
      }
    }

    return roles;
  }

  bool _isProviderAccount(Map<String, dynamic> data) {
    final roles = _getRoles(data);

    if (data['isProvider'] == true ||
        data['isServiceProvider'] == true) {
      return true;
    }

    if (roles.any(_providerRoles.contains)) {
      return true;
    }

    for (final key in [
      'grocerySellerStatus',
      'foodSellerStatus',
      'workerStatus',
      'doctorStatus',
      'driverStatus',
      'providerStatus',
    ]) {
      final status = _normalizeRole(data[key]);

      if (status == 'pending') {
        return true;
      }
    }

    return false;
  }

  bool _isRegularCustomer(Map<String, dynamic> data) {
    if (_isProviderAccount(data)) {
      return false;
    }

    final roles = _getRoles(data);

    // Unknown account types require manual verification.
    if (roles.isEmpty) {
      return false;
    }

    return roles.every(_customerRoles.contains);
  }

  // =========================================================
  // SAFE DATA HELPERS
  // =========================================================

  String _readText(
    dynamic value, [
    String fallback = '',
  ]) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }

  String _getName(Map<String, dynamic> data) {
    return _readText(
      data['name'] ??
          data['fullName'] ??
          data['displayName'],
      'Unknown Name',
    );
  }

  String _formatDate(dynamic value) {
    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }

    if (date == null) {
      return 'Not available';
    }

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // =========================================================
  // APPROVAL CONFIRMATION
  // =========================================================

  Future<void> _confirmAction({
    required String userId,
    required String name,
    required bool approve,
  }) async {
    if (_processingUsers.contains(userId)) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            approve
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            color: approve ? Colors.green : Colors.red,
            size: 42,
          ),
          title: Text(
            approve ? 'Approve User' : 'Reject User',
          ),
          content: Text(
            approve
                ? 'Are you sure you want to approve '
                    '$name\'s account?'
                : 'Are you sure you want to reject '
                    '$name\'s account?',
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
                backgroundColor:
                    approve ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                approve ? 'Approve' : 'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await _updateUserStatus(
      userId: userId,
      name: name,
      approve: approve,
    );
  }

  // =========================================================
  // FIRESTORE TRANSACTION
  // =========================================================

  Future<void> _updateUserStatus({
    required String userId,
    required String name,
    required bool approve,
  }) async {
    if (_processingUsers.contains(userId)) {
      return;
    }

    final admin = FirebaseAuth.instance.currentUser;

    if (admin == null) {
      _showMessage(
        'Session expired. Please login again.',
        Colors.red,
      );

      return;
    }

    if (admin.uid == userId) {
      _showMessage(
        'You cannot review your own account.',
        Colors.red,
      );

      return;
    }

    setState(() {
      _processingUsers.add(userId);
    });

    final newStatus = approve ? 'active' : 'rejected';

    try {
      final userRef = _firestore
          .collection('users')
          .doc(userId);

      final logRef = _firestore
          .collection('activity_logs')
          .doc();

      await _firestore.runTransaction((transaction) async {
        final userSnapshot =
            await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw StateError(
            'User account was not found.',
          );
        }

        final userData =
            userSnapshot.data() ?? <String, dynamic>{};

        final currentStatus = _normalizeRole(
          userData['status'],
        );

        if (currentStatus != 'pending') {
          throw StateError(
            'This account has already been reviewed.',
          );
        }

        // Prevent provider approval from this screen.
        if (!_isRegularCustomer(userData)) {
          throw StateError(
            'This account requires provider or manual '
            'verification.',
          );
        }

        // Check UID-based provider documents using the
        // existing provider collection structure.
        const providerCollections = [
          'doctors',
          'workers',
          'drivers',
          'food_sellers',
        ];

        for (final collection in providerCollections) {
          final providerRef = _firestore
              .collection(collection)
              .doc(userId);

          final providerSnapshot =
              await transaction.get(providerRef);

          if (providerSnapshot.exists) {
            final providerStatus = _normalizeRole(
              providerSnapshot.data()?['status'],
            );

            if (providerStatus == 'pending') {
              throw StateError(
                'This user has a pending provider '
                'application. Use Pending Accounts.',
              );
            }
          }
        }

        // Update the user after all reads are complete.
        transaction.update(userRef, {
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
          'reviewedAt': FieldValue.serverTimestamp(),
          'reviewedBy': admin.uid,
          'approvedAt': approve
              ? FieldValue.serverTimestamp()
              : null,
          'rejectedAt': approve
              ? null
              : FieldValue.serverTimestamp(),
        });

        // Save activity log in the same transaction.
        transaction.set(logRef, {
          'action':
              approve ? 'User Approved' : 'User Rejected',
          'details':
              '$name (User) status changed to $newStatus.',
          'performedBy': 'Admin',
          'performedByUid': admin.uid,
          'userId': userId,
          'collection': 'users',
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

      _showMessage(
        'Unable to update account: $error',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingUsers.remove(userId);
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
  // NAVIGATION
  // =========================================================

  void _openPendingAccounts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PendingAccounts(),
      ),
    );
  }

  // =========================================================
  // MAIN SCREEN
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          'Pending Users',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Pending Provider Accounts',
            onPressed: _openPendingAccounts,
            icon: const Icon(
              Icons.manage_accounts_outlined,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildInformationBanner(),

            _buildSearchBar(),

            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                stream: _pendingUsersStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(
                      snapshot.error.toString(),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final allDocuments = snapshot.data!.docs;

                  final regularUsers = allDocuments
                      .where(
                        (document) => _isRegularCustomer(
                          document.data(),
                        ),
                      )
                      .toList();

                  final restrictedUsers = allDocuments
                      .where(
                        (document) => !_isRegularCustomer(
                          document.data(),
                        ),
                      )
                      .toList();

                  final filteredUsers = regularUsers
                      .where((document) {
                    final data = document.data();

                    final searchableText = [
                      _getName(data),
                      _readText(data['email']),
                      _readText(
                        data['phone'] ??
                            data['phoneNumber'],
                      ),
                      _readText(data['role']),
                    ].join(' ').toLowerCase();

                    return searchableText.contains(
                      _searchQuery,
                    );
                  }).toList();

                  return Column(
                    children: [
                      _buildStatistics(
                        regularUsers.length,
                        restrictedUsers.length,
                      ),

                      Expanded(
                        child: allDocuments.isEmpty
                            ? _buildEmptyState(
                                'No pending users found.',
                              )
                            : ListView(
                                padding:
                                    const EdgeInsets.all(16),
                                children: [
                                  if (filteredUsers.isEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        vertical: 24,
                                      ),
                                      child: _buildEmptyState(
                                        'No matching regular '
                                        'user accounts.',
                                      ),
                                    ),

                                  ...filteredUsers.map(
                                    _buildUserCard,
                                  ),

                                  if (restrictedUsers
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 10),

                                    const Text(
                                      'Requires Separate Review',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold,
                                        color: _text,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    ...restrictedUsers.map(
                                      _buildRestrictedCard,
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // INFORMATION BANNER
  // =========================================================

  Widget _buildInformationBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.blue.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade700,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Regular User Approvals',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Service provider registrations must '
                  'be reviewed through Pending Accounts.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.5,
                  ),
                ),

                TextButton(
                  onPressed: _openPendingAccounts,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: _primary,
                  ),
                  child: const Text(
                    'Open Pending Accounts',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SEARCH BAR
  // =========================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search users...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: _primary,
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // LIVE STATISTICS
  // =========================================================

  Widget _buildStatistics(
    int regularCount,
    int restrictedCount,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Pending Users',
              value: regularCount,
              icon: Icons.people_outline,
              color: Colors.blue,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _buildStatCard(
              title: 'Separate Review',
              value: restrictedCount,
              icon: Icons.fact_check_outlined,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),

          const SizedBox(height: 8),

          Text(
            '$value',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: _text,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // USER CARD
  // =========================================================

  Widget _buildUserCard(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final userId = document.id;

    final name = _getName(data);

    final email = _readText(
      data['email'],
      'No email',
    );

    final phone = _readText(
      data['phone'] ?? data['phoneNumber'],
      'Not provided',
    );

    final role = _readText(
      data['role'] ??
          data['userRole'] ??
          data['userType'],
      'Customer',
    );

    final createdAt = _formatDate(
      data['createdAt'],
    );

    final isProcessing =
        _processingUsers.contains(userId);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
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
                  backgroundColor:
                      _primary.withValues(alpha: 0.10),
                  child: const Icon(
                    Icons.person_outline,
                    color: _primary,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _text,
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
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange
                        .withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 28),

            _buildInfoRow(
              Icons.phone_outlined,
              'Phone',
              phone,
            ),

            _buildInfoRow(
              Icons.badge_outlined,
              'Account Type',
              role,
            ),

            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Registered',
              createdAt,
            ),

            const SizedBox(height: 16),

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
                        side: const BorderSide(
                          color: Colors.red,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _confirmAction(
                        userId: userId,
                        name: name,
                        approve: false,
                      ),
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                      ),
                      label: const Text('Reject'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _confirmAction(
                        userId: userId,
                        name: name,
                        approve: true,
                      ),
                      icon: const Icon(
                        Icons.check,
                        size: 18,
                      ),
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
  // RESTRICTED ACCOUNT CARD
  // =========================================================

  Widget _buildRestrictedCard(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    final name = _getName(data);

    final email = _readText(
      data['email'],
      'No email',
    );

    final roles = _getRoles(data);

    final isProvider = _isProviderAccount(data);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.orange.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.shade50,
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Role: ${roles.isEmpty ? "Unknown" : roles.join(", ")}',
              style: const TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 6),

            Text(
              isProvider
                  ? 'This account requires a separate '
                      'provider or administrative review.'
                  : 'Unknown account type. Verify the '
                      'registration data before approval.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Colors.orange.shade900,
              ),
            ),

            if (isProvider) ...[
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openPendingAccounts,
                  icon: const Icon(
                    Icons.arrow_forward,
                    size: 18,
                  ),
                  label: const Text(
                    'Open Pending Accounts',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================
  // INFORMATION ROW
  // =========================================================

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: Colors.grey.shade600,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
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
              size: 65,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 14),

            const Text(
              'All caught up!',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ERROR STATE
  // =========================================================

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),

            const SizedBox(height: 14),

            const Text(
              'Unable to load users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
