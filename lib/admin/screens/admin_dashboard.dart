
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'activity_logs.dart';
import 'database_management.dart';
import 'doctor_audit.dart';
import 'drunk_drive_audit.dart';
import 'food_delivery_audit.dart';
import 'grocery_audit.dart';
import 'logout.dart';
import 'notification.dart';
import 'pending_accounts.dart';
import 'pending_users_screen.dart';
import 'settings.dart';
import 'user_management_screen.dart';

// ===========================================================
// DASHBOARD THEME
// ===========================================================

class _C {
  static const bg = Color(0xFFF4F6FB);
  static const primary = Color(0xff032744);
  static const primaryDark = Color(0xff021b30);
  static const text = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const danger = Color(0xFFDC2626);
}

// ===========================================================
// ADMIN DASHBOARD
// ===========================================================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState
    extends State<AdminDashboard> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  int _selectedCategory = 0;

  // =========================================================
  // FIRESTORE COLLECTION CONFIGURATION
  // =========================================================

  static const List<String> _providerCollections = [
    'doctors',
    'workers',
    'food_sellers',
    'seller_applications',
    'drivers',
    'drunkDriveDriverApplications',
  ];

  final Map<
      String,
      Stream<QuerySnapshot<Map<String, dynamic>>>>
      _providerStreams = {};

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _usersStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _activityStream;

  // =========================================================
  // SERVICE CATEGORIES
  // =========================================================

  final List<_AuditCategory> _categories = const [
    _AuditCategory(
      name: 'Doctor',
      icon: Icons.medical_services_outlined,
      color: Colors.blue,
      description:
          'Monitor doctor accounts and medical service '
          'provider registrations.',
      collections: ['doctors'],
      providerLabel: 'Doctors',
    ),
    _AuditCategory(
      name: 'Drunk & Drive',
      icon: Icons.directions_car_outlined,
      color: Colors.indigo,
      description:
          'Manage driver accounts and driver applications '
          'from both registration systems.',
      collections: [
        'drivers',
        'drunkDriveDriverApplications',
      ],
      providerLabel: 'Driver Records',
    ),
    _AuditCategory(
      name: 'Food Delivery',
      icon: Icons.fastfood_outlined,
      color: Colors.deepOrange,
      description:
          'Monitor food sellers and restaurant '
          'registration requests.',
      collections: ['food_sellers'],
      providerLabel: 'Food Sellers',
    ),
    _AuditCategory(
      name: 'Grocery',
      icon: Icons.shopping_cart_outlined,
      color: Colors.green,
      description:
          'Monitor grocery seller applications and '
          'approval statuses.',
      collections: ['seller_applications'],
      providerLabel: 'Grocery Applications',
    ),
    _AuditCategory(
      name: 'QuickFix',
      icon: Icons.construction_rounded,
      color: Colors.purple,
      description:
          'Monitor workers and service provider '
          'registration requests.',
      collections: ['workers'],
      providerLabel: 'Workers',
    ),
  ];

  // =========================================================
  // INITIALIZATION
  // =========================================================

  @override
  void initState() {
    super.initState();

    _usersStream = _firestore
        .collection('users')
        .snapshots();

    _activityStream = _firestore
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots();

    for (final collection in _providerCollections) {
      _providerStreams[collection] = _firestore
          .collection(collection)
          .snapshots();
    }
  }

  // =========================================================
  // DATA HELPERS
  // =========================================================

  String _readText(
    dynamic value, [
    String fallback = '',
  ]) {
    if (value == null) return fallback;

    final result = value.toString().trim();

    return result.isEmpty ? fallback : result;
  }

  String _normalizeStatus(dynamic value) {
    return _readText(value).toLowerCase();
  }

  bool _isApproved(dynamic value) {
    final status = _normalizeStatus(value);

    return status == 'active' ||
        status == 'approved';
  }

  bool _isPending(dynamic value) {
    return _normalizeStatus(value) == 'pending';
  }

  bool _isRejected(dynamic value) {
    return _normalizeStatus(value) == 'rejected';
  }

  // =========================================================
  // NAVIGATION
  // =========================================================

  void _openScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  void _openPendingAccounts() {
    _openScreen(const PendingAccounts());
  }

  void _openPendingUsers() {
    _openScreen(const PendingUsersScreen());
  }

  void _openNotifications() {
    _openScreen(const NotificationScreen());
  }

  void _openActivityLogs() {
    _openScreen(const ActivityLogs());
  }

  void _openUserManagement() {
    _openScreen(
      const UserManagementScreen(
        title: 'User Management',
      ),
    );
  }

  void _openDatabaseManagement() {
    _openScreen(const DatabaseManagement());
  }

  void _openSettings() {
    _openScreen(const SettingsScreen());
  }

  void _openLogout() {
    _openScreen(const LogoutScreen());
  }

  void _openCategoryAudit(
    _AuditCategory category,
  ) {
    switch (category.name) {
      case 'Doctor':
        _openScreen(const DoctorAudit());
        break;

      case 'Drunk & Drive':
        _openScreen(const DrunkDriveAudit());
        break;

      case 'Food Delivery':
        _openScreen(const FoodDeliveryAudit());
        break;

      case 'Grocery':
        _openScreen(const GroceryAudit());
        break;

      case 'QuickFix':
        // Existing QuickFix audit screen was not supplied.
        // Open provider management instead.
        _openPendingAccounts();
        break;
    }
  }

  // =========================================================
  // MAIN DASHBOARD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: _C.text,
        ),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: _C.text,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: _openNotifications,
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _openLogout,
            icon: const Icon(
              Icons.logout_rounded,
              color: _C.danger,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),

      drawer: _buildDrawer(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1500,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),

                  const SizedBox(height: 26),

                  _sectionTitle(
                    'Application Overview',
                  ),

                  const SizedBox(height: 14),

                  _buildLiveDashboard(),

                  const SizedBox(height: 26),

                  _sectionTitle('Quick Actions'),

                  const SizedBox(height: 14),

                  _buildQuickActions(),

                  const SizedBox(height: 26),

                  _sectionTitle('Category Audit'),

                  const SizedBox(height: 6),

                  const Text(
                    'Monitor service providers and '
                    'registration activities.',
                    style: TextStyle(
                      color: _C.muted,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildCategoryAudit(),

                  const SizedBox(height: 26),

                  _buildRecentActivities(),

                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _C.text,
        fontWeight: FontWeight.w800,
        fontSize: 19,
      ),
    );
  }

  // =========================================================
  // ADMIN DRAWER
  // =========================================================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              20,
              60,
              20,
              26,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _C.primary,
                  _C.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 35,
                    color: _C.primary,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  'OneClick Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Administration Panel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              children: [
                _drawerItem(
                  title: 'Dashboard',
                  icon: Icons.dashboard_rounded,
                  selected: true,
                  onTap: () {},
                ),

                _drawerItem(
                  title: 'Pending Accounts',
                  icon: Icons.pending_actions,
                  onTap: _openPendingAccounts,
                ),

                _drawerItem(
                  title: 'Pending Users',
                  icon: Icons.person_add_alt_1_outlined,
                  onTap: _openPendingUsers,
                ),

                _drawerItem(
                  title: 'User Management',
                  icon: Icons.people_alt_rounded,
                  onTap: _openUserManagement,
                ),

                _drawerItem(
                  title: 'Database Management',
                  icon: Icons.storage_rounded,
                  onTap: _openDatabaseManagement,
                ),

                _drawerItem(
                  title: 'Activity Logs',
                  icon: Icons.history_rounded,
                  onTap: _openActivityLogs,
                ),

                _drawerItem(
                  title: 'Notifications',
                  icon: Icons.notifications_none,
                  onTap: _openNotifications,
                ),

                const Divider(
                  height: 30,
                  indent: 20,
                  endIndent: 20,
                ),

                _drawerItem(
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                  onTap: _openSettings,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _drawerItem(
                title: 'Logout',
                icon: Icons.logout_rounded,
                danger: true,
                onTap: _openLogout,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool selected = false,
    bool danger = false,
  }) {
    final color = danger
        ? _C.danger
        : selected
            ? _C.primary
            : _C.muted;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: selected || danger
            ? color.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            color: danger ? _C.danger : _C.text,
            fontWeight: selected
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  // =========================================================
  // WELCOME CARD
  // =========================================================

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _C.primary,
            _C.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withValues(
              alpha: 0.20,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 9),

                Text(
                  'Manage OneClick users, service '
                  'providers and account approvals '
                  'from one dashboard.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),

                SizedBox(height: 15),

                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 9,
                      color: Colors.greenAccent,
                    ),

                    SizedBox(width: 7),

                    Flexible(
                      child: Text(
                        'Real-time dashboard',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Icon(
            Icons.admin_panel_settings_outlined,
            color: Colors.white.withValues(
              alpha: 0.25,
            ),
            size: 68,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // COMBINED REAL-TIME PROVIDER STREAMS
  // =========================================================

  Widget _buildProviderData({
    required List<String> collections,
    required Widget Function(
      Map<
          String,
          List<
              QueryDocumentSnapshot<
                  Map<String, dynamic>>>>,
    ) builder,
    int index = 0,
    Map<
        String,
        List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>>>?
        accumulated,
  }) {
    final currentData = accumulated ??
        <
            String,
            List<
                QueryDocumentSnapshot<
                    Map<String, dynamic>>>>{};

    if (index >= collections.length) {
      return builder(currentData);
    }

    final collection = collections[index];

    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      key: ValueKey('provider-$collection'),
      stream: _providerStreams[collection],
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorCard(
            'Unable to load $collection.',
            snapshot.error.toString(),
          );
        }

        if (!snapshot.hasData) {
          return _buildLoadingCard(
            'Loading service providers...',
          );
        }

        final nextData = {
          ...currentData,
          collection: snapshot.data!.docs,
        };

        return _buildProviderData(
          collections: collections,
          builder: builder,
          index: index + 1,
          accumulated: nextData,
        );
      },
    );
  }

  // =========================================================
  // REAL-TIME DASHBOARD STATISTICS
  // =========================================================

  Widget _buildLiveDashboard() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _usersStream,
      builder: (context, usersSnapshot) {
        if (usersSnapshot.hasError) {
          return _buildErrorCard(
            'Unable to load users.',
            usersSnapshot.error.toString(),
          );
        }

        if (!usersSnapshot.hasData) {
          return _buildLoadingCard(
            'Loading dashboard statistics...',
          );
        }

        final users = usersSnapshot.data!.docs;

        return _buildProviderData(
          collections: _providerCollections,
          builder: (providerData) {
            final statistics = _DashboardStatistics();

            statistics.totalUsers = users.length;

            statistics.activeUsers = users.where(
              (document) => _isApproved(
                document.data()['status'],
              ),
            ).length;

            statistics.pendingUsers = users.where(
              (document) => _isPending(
                document.data()['status'],
              ),
            ).length;

            statistics.rejectedUsers = users.where(
              (document) => _isRejected(
                document.data()['status'],
              ),
            ).length;

            for (final entry in providerData.entries) {
              final docs = entry.value;

              final total = docs.length;

              final pending = docs.where(
                (doc) => _isPending(
                  doc.data()['status'],
                ),
              ).length;

              final approved = docs.where(
                (doc) => _isApproved(
                  doc.data()['status'],
                ),
              ).length;

              final rejected = docs.where(
                (doc) => _isRejected(
                  doc.data()['status'],
                ),
              ).length;

              statistics.totalProviderRecords += total;

              statistics.pendingProviders += pending;

              statistics.approvedProviderRecords +=
                  approved;

              statistics.rejectedProviderRecords +=
                  rejected;

              statistics.pendingByCollection[
                  entry.key] = pending;
            }

            return Column(
              children: [
                _buildStatisticsGrid(statistics),

                const SizedBox(height: 22),

                _buildPendingBreakdown(statistics),

                const SizedBox(height: 22),

                _buildImportantNotifications(
                  statistics,
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================
  // STATISTICS GRID
  // =========================================================

  Widget _buildStatisticsGrid(
    _DashboardStatistics stats,
  ) {
    final items = [
      _StatItem(
        title: 'Total Users',
        value: '${stats.totalUsers}',
        icon: Icons.people_alt_outlined,
        color: Colors.blue,
      ),
      _StatItem(
        title: 'Active Users',
        value: '${stats.activeUsers}',
        icon: Icons.verified_user_outlined,
        color: Colors.green,
      ),
      _StatItem(
        title: 'Provider Records',
        value: '${stats.totalProviderRecords}',
        icon: Icons.badge_outlined,
        color: Colors.indigo,
      ),
      _StatItem(
        title: 'Approved Providers',
        value: '${stats.approvedProviderRecords}',
        icon: Icons.verified_outlined,
        color: Colors.teal,
      ),
      _StatItem(
        title: 'Pending Accounts',
        value: '${stats.pendingProviders}',
        icon: Icons.pending_actions,
        color: Colors.orange,
      ),
      _StatItem(
        title: 'Pending User Records',
        value: '${stats.pendingUsers}',
        icon: Icons.person_add_alt_1,
        color: Colors.deepPurple,
      ),
      _StatItem(
        title: 'Rejected Providers',
        value: '${stats.rejectedProviderRecords}',
        icon: Icons.person_off_outlined,
        color: Colors.red,
      ),
      _StatItem(
        title: 'Rejected Users',
        value: '${stats.rejectedUsers}',
        icon: Icons.cancel_outlined,
        color: Colors.redAccent,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 1000
                ? 4
                : constraints.maxWidth >= 650
                    ? 3
                    : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 140,
          ),
          itemBuilder: (context, index) {
            return _StatCard(
              item: items[index],
            );
          },
        );
      },
    );
  }

  // =========================================================
  // PENDING APPLICATION BREAKDOWN
  // =========================================================

  Widget _buildPendingBreakdown(
    _DashboardStatistics stats,
  ) {
    final doctors =
        stats.pendingByCollection['doctors'] ?? 0;

    final workers =
        stats.pendingByCollection['workers'] ?? 0;

    final food =
        stats.pendingByCollection['food_sellers'] ?? 0;

    final grocery =
        stats.pendingByCollection[
                'seller_applications'] ??
            0;

    final drivers =
        (stats.pendingByCollection['drivers'] ?? 0) +
            (stats.pendingByCollection[
                    'drunkDriveDriverApplications'] ??
                0);

    return _sectionCard(
      title: 'Pending Provider Requests',
      icon: Icons.pending_actions_rounded,
      child: Column(
        children: [
          _buildPendingRow(
            title: 'Doctors',
            count: doctors,
            icon: Icons.medical_services_outlined,
            color: Colors.blue,
          ),

          _buildPendingRow(
            title: 'Drunk & Drive',
            count: drivers,
            icon: Icons.directions_car_outlined,
            color: Colors.indigo,
          ),

          _buildPendingRow(
            title: 'Food Sellers',
            count: food,
            icon: Icons.restaurant_outlined,
            color: Colors.deepOrange,
          ),

          _buildPendingRow(
            title: 'Grocery Sellers',
            count: grocery,
            icon: Icons.storefront_outlined,
            color: Colors.green,
          ),

          _buildPendingRow(
            title: 'QuickFix Workers',
            count: workers,
            icon: Icons.construction_rounded,
            color: Colors.purple,
          ),

          const Divider(height: 28),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Pending Applications',
                  style: TextStyle(
                    color: _C.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),

              Text(
                '${stats.pendingProviders}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w800,
                  fontSize: 23,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              onPressed: _openPendingAccounts,
              icon: const Icon(
                Icons.fact_check_outlined,
              ),
              label: const Text(
                'Review Pending Accounts',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRow({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 21,
              color: color,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _C.text,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),

          Container(
            constraints: const BoxConstraints(
              minWidth: 42,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: count > 0
                  ? Colors.orange.withValues(
                      alpha: 0.10,
                    )
                  : Colors.green.withValues(
                      alpha: 0.10,
                    ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: count > 0
                    ? Colors.orange.shade800
                    : Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // IMPORTANT NOTIFICATIONS
  // =========================================================

  Widget _buildImportantNotifications(
    _DashboardStatistics stats,
  ) {
    return _sectionCard(
      title: 'Important Notifications',
      icon: Icons.notifications_active_outlined,
      child: Column(
        children: [
          if (stats.pendingProviders > 0)
            _notificationTile(
              title: 'Provider approvals required',
              description:
                  '${stats.pendingProviders} provider '
                  'applications are waiting for review.',
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
              onTap: _openPendingAccounts,
            )
          else
            _notificationTile(
              title: 'No pending provider requests',
              description:
                  'All provider applications have '
                  'been reviewed or are not pending.',
              icon: Icons.check_circle_outline,
              color: Colors.green,
              onTap: _openPendingAccounts,
            ),

          if (stats.pendingUsers > 0) ...[
            const Divider(height: 20),

            _notificationTile(
              title: 'Pending user accounts',
              description:
                  '${stats.pendingUsers} user records '
                  'have pending status. Provider-linked '
                  'accounts may also be included.',
              icon: Icons.person_add_alt_1_outlined,
              color: Colors.blue,
              onTap: _openPendingUsers,
            ),
          ],
        ],
      ),
    );
  }

  Widget _notificationTile({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            color.withValues(alpha: 0.10),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: _C.text,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          description,
          style: const TextStyle(
            color: _C.muted,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
      ),
      onTap: onTap,
    );
  }

  // =========================================================
  // QUICK ACTIONS
  // =========================================================

  Widget _buildQuickActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final actions = [
          _actionTile(
            title: 'Pending Accounts',
            subtitle: 'Approve service providers',
            icon: Icons.pending_actions,
            color: Colors.orange,
            onTap: _openPendingAccounts,
          ),

          _actionTile(
            title: 'Pending Users',
            subtitle: 'Review user registrations',
            icon: Icons.person_add_alt_1,
            color: Colors.blue,
            onTap: _openPendingUsers,
          ),

          _actionTile(
            title: 'User Management',
            subtitle: 'Manage existing accounts',
            icon: Icons.manage_accounts,
            color: Colors.indigo,
            onTap: _openUserManagement,
          ),

          _actionTile(
            title: 'Database Management',
            subtitle: 'Manage application data',
            icon: Icons.storage_rounded,
            color: Colors.green,
            onTap: _openDatabaseManagement,
          ),

          _actionTile(
            title: 'Activity Logs',
            subtitle: 'Monitor administrative actions',
            icon: Icons.history_rounded,
            color: Colors.purple,
            onTap: _openActivityLogs,
          ),

          _actionTile(
            title: 'Notifications',
            subtitle: 'View important updates',
            icon: Icons.notifications_none,
            color: Colors.teal,
            onTap: _openNotifications,
          ),
        ];

        if (constraints.maxWidth >= 750) {
          return GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 100,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            children: actions,
          );
        }

        return Column(
          children: actions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: action,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _actionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _C.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.text,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _C.muted,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: _C.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CATEGORY AUDIT
  // =========================================================

  Widget _buildCategoryAudit() {
    final current =
        _categories[_selectedCategory];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                _categories.length,
                (index) {
                  final category =
                      _categories[index];

                  final selected =
                      index == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(
                      right: 8,
                    ),
                    child: ChoiceChip(
                      avatar: Icon(
                        category.icon,
                        size: 18,
                        color: selected
                            ? Colors.white
                            : category.color,
                      ),
                      label: Text(category.name),
                      selected: selected,
                      selectedColor: _C.primary,
                      backgroundColor: _C.bg,
                      showCheckmark: false,
                      side: BorderSide.none,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : _C.text,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildAuditContent(current),
        ],
      ),
    );
  }

  Widget _buildAuditContent(
    _AuditCategory category,
  ) {
    return _buildProviderData(
      collections: category.collections,
      builder: (providerData) {
        int total = 0;
        int approved = 0;
        int pending = 0;
        int rejected = 0;

        for (final documents
            in providerData.values) {
          total += documents.length;

          for (final document in documents) {
            final status =
                document.data()['status'];

            if (_isApproved(status)) {
              approved++;
            } else if (_isPending(status)) {
              pending++;
            } else if (_isRejected(status)) {
              rejected++;
            }
          }
        }

        final items = [
          _StatItem(
            title: category.providerLabel,
            value: '$total',
            icon: category.icon,
            color: category.color,
          ),
          _StatItem(
            title: 'Approved',
            value: '$approved',
            icon: Icons.verified_outlined,
            color: Colors.green,
          ),
          _StatItem(
            title: 'Pending',
            value: '$pending',
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
          _StatItem(
            title: 'Rejected',
            value: '$rejected',
            icon: Icons.cancel_outlined,
            color: Colors.red,
          ),
        ];

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    '${category.name} Category',
                    style: const TextStyle(
                      color: _C.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              category.description,
              style: const TextStyle(
                fontSize: 13,
                color: _C.muted,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 105,
              ),
              itemBuilder: (context, index) {
                final item = items[index];

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _C.bg,
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: item.color,
                        size: 22,
                      ),

                      const SizedBox(height: 7),

                      Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _C.text,
                        ),
                      ),

                      Text(
                        item.title,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _C.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _C.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _openCategoryAudit(category);
                },
                icon: const Icon(
                  Icons.fact_check_outlined,
                ),
                label: Text(
                  category.name == 'QuickFix'
                      ? 'Manage Provider Requests'
                      : 'Open Audit',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // REAL-TIME ACTIVITY LOGS
  // =========================================================

  Widget _buildRecentActivities() {
    return _sectionCard(
      title: 'Recent Activities',
      icon: Icons.history_rounded,
      child: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _activityStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Unable to load activity logs.\n'
                '${snapshot.error}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return _buildLoadingCard(
              'Loading recent activities...',
            );
          }

          final logs = snapshot.data!.docs;

          if (logs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      color: Colors.grey,
                      size: 40,
                    ),

                    SizedBox(height: 12),

                    Text(
                      'No activity records available.',
                      style: TextStyle(
                        color: _C.muted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              ...logs.map((document) {
                return _buildActivityTile(
                  document.data(),
                );
              }),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _openActivityLogs,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'View All Activities',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActivityTile(
    Map<String, dynamic> data,
  ) {
    final action = _readText(
      data['action'],
      'Activity',
    );

    final details = _readText(
      data['details'] ?? data['description'],
      'No additional details.',
    );

    final performedBy = _readText(
      data['performedBy'],
      'Unknown',
    );

    final date = _formatTimestamp(
      data['timestamp'],
    );

    final normalizedAction = action.toLowerCase();

    Color color = Colors.blue;
    IconData icon = Icons.history_rounded;

    if (normalizedAction.contains('reject')) {
      color = Colors.red;
      icon = Icons.cancel_outlined;
    } else if (
        normalizedAction.contains('approv')) {
      color = Colors.green;
      icon = Icons.check_circle_outline;
    } else if (
        normalizedAction.contains('register')) {
      color = Colors.indigo;
      icon = Icons.person_add_alt_1;
    } else if (
        normalizedAction.contains('delete')) {
      color = Colors.red;
      icon = Icons.delete_outline;
    } else if (
        normalizedAction.contains('update')) {
      color = Colors.orange;
      icon = Icons.update_rounded;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 23,
                  color: color,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      action,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.text,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      details,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _C.muted,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'By $performedBy',
                      style: const TextStyle(
                        color: _C.muted,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      date,
                      style: const TextStyle(
                        color: _C.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(
          height: 1,
          color: _C.border,
        ),
      ],
    );
  }

  // =========================================================
  // TIMESTAMP FORMATTER
  // =========================================================

  String _formatTimestamp(dynamic value) {
    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate().toLocal();
    } else if (value is DateTime) {
      date = value.toLocal();
    } else if (value is String) {
      date = DateTime.tryParse(value)?.toLocal();
    }

    if (date == null) {
      return 'Date unavailable';
    }

    final difference =
        DateTime.now().difference(date);

    if (!difference.isNegative) {
      if (difference.inMinutes < 1) {
        return 'Just now';
      }

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      }

      if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      }

      if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      }
    }

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  // =========================================================
  // REUSABLE SECTION CARD
  // =========================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: _C.primary,
                size: 23,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _C.text,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Divider(
            height: 1,
            color: _C.border,
          ),

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _C.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: 0.025,
          ),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // =========================================================
  // LOADING STATE
  // =========================================================

  Widget _buildLoadingCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: _C.primary,
          ),

          const SizedBox(height: 16),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _C.muted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ERROR STATE
  // =========================================================

  Widget _buildErrorCard(
    String title,
    String message,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.shade100,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: Colors.red,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _C.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// STATISTICS MODEL
// ===========================================================

class _DashboardStatistics {
  int totalUsers = 0;
  int activeUsers = 0;
  int pendingUsers = 0;
  int rejectedUsers = 0;

  int totalProviderRecords = 0;
  int pendingProviders = 0;
  int approvedProviderRecords = 0;
  int rejectedProviderRecords = 0;

  final Map<String, int> pendingByCollection = {};
}

// ===========================================================
// STAT ITEM MODEL
// ===========================================================

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

// ===========================================================
// STAT CARD
// ===========================================================

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _C.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: item.color.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              item.icon,
              size: 23,
              color: item.color,
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _C.text,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _C.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// AUDIT CATEGORY MODEL
// ===========================================================

class _AuditCategory {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> collections;
  final String providerLabel;

  const _AuditCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.collections,
    required this.providerLabel,
  });
}
