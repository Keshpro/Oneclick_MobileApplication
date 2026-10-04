import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'user_management.dart';

// ==================================================================
// PENDING ACCOUNTS (placeholder)
// ==================================================================

class PendingAccounts extends StatelessWidget {
  const PendingAccounts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pending Accounts'),
      ),
      body: const Center(child: Text('Pending Accounts')),
    );
  }
}

class FoodAdminSellerApplicationsScreen extends StatelessWidget {
  const FoodAdminSellerApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Seller Applications')),
      body: const Center(child: Text('Food Seller Applications')),
    );
  }
}

// ==================================================================
// THEME TOKENS
// ==================================================================

class _C {
  static const bg = Color(0xFFF4F6FB);
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1E40AF);
  static const text = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const danger = Color(0xFFDC2626);
}

// ==================================================================
// ADMIN DASHBOARD
// ==================================================================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedCategory = 0;

  final List<_AuditCategory> _categories = const [
    _AuditCategory(
      name: 'Doctor',
      icon: Icons.medical_services_outlined,
      description: 'Audit doctors, patients and activities related to the medical service.',
      stats: [
        _AuditStat(
          title: 'Doctors',
          value: '145',
          icon: Icons.medical_services,
        ),
        _AuditStat(
          title: 'Patients',
          value: '628',
          icon: Icons.personal_injury,
        ),
        _AuditStat(title: 'Pending', value: '12', icon: Icons.pending_actions),
        _AuditStat(title: 'Activities', value: '1,240', icon: Icons.history),
      ],
    ),
    _AuditCategory(
      name: 'Drunk Drive',
      icon: Icons.directions_car_outlined,
      description: 'Audit drivers, passengers, trips and related activities.',
      stats: [
        _AuditStat(title: 'Drivers', value: '320', icon: Icons.drive_eta),
        _AuditStat(title: 'Passengers', value: '456', icon: Icons.people),
        _AuditStat(title: 'Pending', value: '8', icon: Icons.pending_actions),
        _AuditStat(title: 'Trips', value: '2,340', icon: Icons.route),
      ],
    ),
    _AuditCategory(
      name: 'Category 3',
      icon: Icons.category_outlined,
      description: 'Audit users, activities and data related to Category 3.',
      stats: [
        _AuditStat(title: 'Users', value: '120', icon: Icons.people),
        _AuditStat(title: 'Active', value: '98', icon: Icons.person),
        _AuditStat(title: 'Pending', value: '5', icon: Icons.pending_actions),
        _AuditStat(title: 'Activities', value: '540', icon: Icons.history),
      ],
    ),
    _AuditCategory(
      name: 'Category 4',
      icon: Icons.grid_view_outlined,
      description: 'Audit users, activities and data related to Category 4.',
      stats: [
        _AuditStat(title: 'Users', value: '98', icon: Icons.people),
        _AuditStat(title: 'Active', value: '76', icon: Icons.person),
        _AuditStat(title: 'Pending', value: '3', icon: Icons.pending_actions),
        _AuditStat(title: 'Activities', value: '320', icon: Icons.history),
      ],
    ),
  ];

  // ================================================================
  // LOGOUT
  // ================================================================

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _C.danger.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout_rounded, color: _C.danger, size: 28),
        ),
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to log out of the admin panel?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _C.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;

    // Go back to the root route. If you use an auth-state wrapper
    // (StreamBuilder on authStateChanges) it will show the login screen.
    // Otherwise replace this with:
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (_) => const LoginScreen()),
    //   (route) => false,
    // );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: _C.text),
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
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications opened'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: _C.danger),
            tooltip: 'Logout',
            onPressed: _confirmLogout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _sectionTitle('Application Overview'),
              const SizedBox(height: 14),
              _buildStatisticsGrid(),
              const SizedBox(height: 24),
              _sectionTitle('Quick Actions'),
              const SizedBox(height: 14),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _sectionTitle('Category Audit'),
              const SizedBox(height: 4),
              const Text(
                'Select a category to audit and monitor its activities.',
                style: TextStyle(fontSize: 13, color: _C.muted),
              ),
              const SizedBox(height: 14),
              _buildCategoryAudit(),
              const SizedBox(height: 24),
              _buildRecentActivities(),
              const SizedBox(height: 20),
              _buildImportantNotifications(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _C.text,
      ),
    );
  }

  // ================================================================
  // DRAWER
  // ================================================================

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_C.primary, _C.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 32,
                    color: _C.primary,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Application Administrator',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _drawerItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  selected: true,
                  onTap: () => Navigator.pop(context),
                ),
                _drawerItem(
                  icon: Icons.pending_actions,
                  title: 'Pending Accounts',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PendingAccounts(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.storefront_rounded,
                  title: 'Food Seller Applications',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const FoodAdminSellerApplicationsScreen(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.people_alt_rounded,
                  title: 'User Management',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserManagementScreen(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.fact_check_outlined,
                  title: 'Category Audit',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Open category audit
                  },
                ),
                _drawerItem(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Notifications
                  },
                ),
                const Divider(height: 30, indent: 20, endIndent: 20),
                _drawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Settings
                  },
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
                icon: Icons.logout_rounded,
                title: 'Logout',
                iconColor: _C.danger,
                textColor: _C.danger,
                tint: _C.danger.withValues(alpha: 0.08),
                onTap: () {
                  Navigator.pop(context);
                  _confirmLogout();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    Color? iconColor,
    Color? textColor,
    Color? tint,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: tint ?? (selected ? _C.primary.withValues(alpha: 0.10) : null),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? (selected ? _C.primary : _C.muted),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? (selected ? _C.primary : _C.text),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ================================================================
  // WELCOME
  // ================================================================

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.primary, _C.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Monitor users, accounts and activities across the application.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.insights_rounded,
            size: 54,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STATISTICS
  // ================================================================

  Widget _buildStatisticsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 700
            ? 4
            : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: const [
            _StatCard(
              title: 'Total Users',
              value: '1,248',
              icon: Icons.people,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Active Users',
              value: '982',
              icon: Icons.person,
              color: Colors.green,
            ),
            _StatCard(
              title: 'New Users',
              value: '86',
              icon: Icons.person_add,
              color: Colors.purple,
              subtitle: 'This month',
            ),
            _StatCard(
              title: 'Pending Accounts',
              value: '24',
              icon: Icons.pending_actions,
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }

  // ================================================================
  // QUICK ACTIONS
  // ================================================================

  Widget _buildQuickActions() {
    return Column(
      children: [
        _actionTile(
          icon: Icons.storefront_rounded,
          color: Colors.green,
          title: 'Food Seller Applications',
          subtitle: 'Review and approve food seller applications',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FoodAdminSellerApplicationsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _actionTile(
          icon: Icons.manage_accounts,
          color: Colors.indigo,
          title: 'User Management',
          subtitle: 'View, update, or remove users (CRUD)',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserManagementScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _C.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: _C.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 15, color: _C.muted),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // CATEGORY AUDIT
  // ================================================================

  Widget _buildCategoryAudit() {
    final current = _categories[_selectedCategory];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_categories.length, (i) {
                final c = _categories[i];
                final selected = i == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(
                      c.icon,
                      size: 18,
                      color: selected ? Colors.white : _C.muted,
                    ),
                    label: Text(c.name),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: _C.primary,
                    backgroundColor: _C.bg,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : _C.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = i),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _auditContent(current),
          ),
        ],
      ),
    );
  }

  Widget _auditContent(_AuditCategory c) {
    return Column(
      key: ValueKey(c.name),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${c.name} Category',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _C.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          c.description,
          style: const TextStyle(fontSize: 12, color: _C.muted, height: 1.4),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
          ),
          itemCount: c.stats.length,
          itemBuilder: (context, index) {
            final s = c.stats[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(s.icon, size: 20, color: _C.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          s.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: _C.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () {
              // TODO: Navigate to ${c.name} Audit Screen
            },
            icon: const Icon(Icons.fact_check_outlined, size: 18),
            label: const Text('Open Audit'),
            style: FilledButton.styleFrom(
              backgroundColor: _C.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // RECENT ACTIVITIES
  // ================================================================

  Widget _buildRecentActivities() {
    return _sectionCard(
      title: 'Recent Activities',
      icon: Icons.history,
      child: Column(
        children: [
          _listItem(
            icon: Icons.person_add,
            color: Colors.green,
            title: 'New user registered',
            description: 'John Doe created a new account',
            time: '5 minutes ago',
          ),
          _listItem(
            icon: Icons.check_circle,
            color: Colors.blue,
            title: 'Account approved',
            description: 'Dr. Sarah Wilson was approved',
            time: '25 minutes ago',
          ),
          _listItem(
            icon: Icons.edit,
            color: Colors.orange,
            title: 'User information updated',
            description: 'User #1024 profile was updated',
            time: '2 hours ago',
          ),
          _listItem(
            icon: Icons.login,
            color: Colors.purple,
            title: 'Admin login',
            description: 'Administrator logged into the system',
            time: '3 hours ago',
            showDivider: false,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: View all activities
              },
              child: const Text('View All Activities'),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // IMPORTANT NOTIFICATIONS
  // ================================================================

  Widget _buildImportantNotifications() {
    return _sectionCard(
      title: 'Important Notifications',
      icon: Icons.notifications_active_outlined,
      child: Column(
        children: [
          _listItem(
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            title: 'Pending approvals',
            description: '24 accounts are waiting for approval.',
          ),
          _listItem(
            icon: Icons.security,
            color: Colors.blue,
            title: 'Security notice',
            description: 'Review recent administrator activities.',
          ),
          _listItem(
            icon: Icons.system_update,
            color: Colors.green,
            title: 'System update',
            description: 'Application data was successfully synchronized.',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SHARED WIDGETS
  // ================================================================

  Widget _listItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    String? time,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _C.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: _C.muted),
                    ),
                    if (time != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: _C.border),
      ],
    );
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 21, color: _C.primary),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: _C.border),
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
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

// ==================================================================
// STAT CARD
// ==================================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _C.text,
                ),
              ),
              Text(
                subtitle == null ? title : '$title · $subtitle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _C.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// MODELS
// ==================================================================

class _AuditCategory {
  final String name;
  final IconData icon;
  final String description;
  final List<_AuditStat> stats;

  const _AuditCategory({
    required this.name,
    required this.icon,
    required this.description,
    required this.stats,
  });
}

class _AuditStat {
  final String title;
  final String value;
  final IconData icon;

  const _AuditStat({
    required this.title,
    required this.value,
    required this.icon,
  });
}
