import 'package:flutter/material.dart';

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
      body: const Center(
        child: Text('Pending Accounts'),
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> categories = [
    'Doctor',
    'Drunk Drive',
    'Category 3',
    'Category 4',
  ];

  final List<IconData> categoryIcons = [
    Icons.medical_services_outlined,
    Icons.directions_car_outlined,
    Icons.category_outlined,
    Icons.grid_view_outlined,
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              // TODO: Open notifications
            },
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
          ),

          const SizedBox(width: 12),
        ],
      ),

      // ============================================================
      // DRAWER
      // ============================================================
      drawer: _buildDrawer(context),

      // ============================================================
      // BODY
      // ============================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================================
              // WELCOME SECTION
              // ======================================================
              _buildWelcomeSection(),

              const SizedBox(height: 25),

              // ======================================================
              // APPLICATION OVERVIEW
              // ======================================================
              const Text(
                'Application Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              _buildStatisticsGrid(),

              const SizedBox(height: 30),

              // ======================================================
              // AUDIT CATEGORIES
              // ======================================================
              const Text(
                'Category Audit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Select a category to audit and monitor its activities.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 16),

              _buildCategoryTabs(),

              const SizedBox(height: 30),

              // ======================================================
              // RECENT ACTIVITIES
              // ======================================================
              _buildRecentActivities(),

              const SizedBox(height: 25),

              // ======================================================
              // IMPORTANT NOTIFICATIONS
              // ======================================================
              _buildImportantNotifications(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // DRAWER
  // ================================================================

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // ----------------------------------------------------------
          // DRAWER HEADER
          // ----------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 55,
              bottom: 25,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(color: Colors.blue),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 32,
                    color: Colors.blue,
                  ),
                ),

                SizedBox(height: 15),

                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
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

          // ----------------------------------------------------------
          // MENU
          // ----------------------------------------------------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _drawerItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  selected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
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
                  icon: Icons.people,
                  title: 'User Management',
                  onTap: () {
                    Navigator.pop(context);

                    // TODO:
                    // Navigate to User Management
                  },
                ),

                _drawerItem(
                  icon: Icons.fact_check_outlined,
                  title: 'Category Audit',
                  onTap: () {
                    Navigator.pop(context);

                    // TODO:
                    // Open category audit
                  },
                ),

                _drawerItem(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.pop(context);

                    // TODO:
                    // Navigate to Notifications
                  },
                ),

                const Divider(height: 30, indent: 20, endIndent: 20),

                _drawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);

                    // TODO:
                    // Navigate to Settings
                  },
                ),
              ],
            ),
          ),

          // ----------------------------------------------------------
          // LOGOUT
          // ----------------------------------------------------------
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _drawerItem(
                icon: Icons.logout,
                title: 'Logout',
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  // TODO:
                  // FirebaseAuth.instance.signOut();

                  Navigator.pop(context);
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
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? Colors.blue.withOpacity(0.10) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? (selected ? Colors.blue : Colors.grey.shade700),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? (selected ? Colors.blue : Colors.black87),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ================================================================
  // WELCOME SECTION
  // ================================================================

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, Admin 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Monitor users, accounts and activities across the application.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
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
        int crossAxisCount;

        if (constraints.maxWidth >= 1100) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 700) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.35,
          children: [
            _statCard(
              title: 'Total Users',
              value: '1,248',
              icon: Icons.people,
              iconColor: Colors.blue,
            ),

            _statCard(
              title: 'Active Users',
              value: '982',
              icon: Icons.person,
              iconColor: Colors.green,
            ),

            _statCard(
              title: 'New Users',
              value: '86',
              icon: Icons.person_add,
              iconColor: Colors.purple,
              subtitle: 'This month',
            ),

            _statCard(
              title: 'Pending Accounts',
              value: '24',
              icon: Icons.pending_actions,
              iconColor: Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),

            const Spacer(),

            Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================================================================
  // CATEGORY AUDIT TABS
  // ================================================================

  Widget _buildCategoryTabs() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // ----------------------------------------------------------
          // TAB BAR
          // ----------------------------------------------------------
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,

              isScrollable: true,

              tabAlignment: TabAlignment.start,

              padding: const EdgeInsets.symmetric(horizontal: 8),

              labelColor: Colors.blue,

              unselectedLabelColor: Colors.grey.shade600,

              indicatorColor: Colors.blue,

              indicatorWeight: 3,

              dividerColor: Colors.transparent,

              tabs: List.generate(categories.length, (index) {
                return Tab(
                  icon: Icon(categoryIcons[index], size: 20),
                  text: categories[index],
                );
              }),
            ),
          ),

          // ----------------------------------------------------------
          // TAB CONTENT
          // ----------------------------------------------------------
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDoctorAudit(),

                _buildDrunkDriveAudit(),

                _buildCategory3Audit(),

                _buildCategory4Audit(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // DOCTOR AUDIT
  // ================================================================

  Widget _buildDoctorAudit() {
    return _auditContent(
      icon: Icons.medical_services_outlined,
      title: 'Doctor Category',
      description: 'Audit doctors, patients and activities related to the medical service.',
      statistics: const [
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
      onAuditPressed: () {
        // TODO:
        // Navigate to Doctor Audit Screen
      },
    );
  }

  // ================================================================
  // DRUNK DRIVE AUDIT
  // ================================================================

  Widget _buildDrunkDriveAudit() {
    return _auditContent(
      icon: Icons.directions_car_outlined,
      title: 'Drunk Drive Category',
      description: 'Audit drivers, passengers, trips and related activities.',
      statistics: const [
        _AuditStat(title: 'Drivers', value: '320', icon: Icons.drive_eta),
        _AuditStat(title: 'Passengers', value: '456', icon: Icons.people),
        _AuditStat(title: 'Pending', value: '8', icon: Icons.pending_actions),
        _AuditStat(title: 'Trips', value: '2,340', icon: Icons.route),
      ],
      onAuditPressed: () {
        // TODO:
        // Navigate to Drunk Drive Audit Screen
      },
    );
  }

  // ================================================================
  // CATEGORY 3 AUDIT
  // ================================================================

  Widget _buildCategory3Audit() {
    return _auditContent(
      icon: Icons.category_outlined,
      title: 'Category 3',
      description: 'Audit users, activities and data related to Category 3.',
      statistics: const [
        _AuditStat(title: 'Users', value: '120', icon: Icons.people),
        _AuditStat(title: 'Active', value: '98', icon: Icons.person),
        _AuditStat(title: 'Pending', value: '5', icon: Icons.pending_actions),
        _AuditStat(title: 'Activities', value: '540', icon: Icons.history),
      ],
      onAuditPressed: () {
        // TODO:
        // Navigate to Category 3 Audit Screen
      },
    );
  }

  // ================================================================
  // CATEGORY 4 AUDIT
  // ================================================================

  Widget _buildCategory4Audit() {
    return _auditContent(
      icon: Icons.grid_view_outlined,
      title: 'Category 4',
      description: 'Audit users, activities and data related to Category 4.',
      statistics: const [
        _AuditStat(title: 'Users', value: '98', icon: Icons.people),
        _AuditStat(title: 'Active', value: '76', icon: Icons.person),
        _AuditStat(title: 'Pending', value: '3', icon: Icons.pending_actions),
        _AuditStat(title: 'Activities', value: '320', icon: Icons.history),
      ],
      onAuditPressed: () {
        // TODO:
        // Navigate to Category 4 Audit Screen
      },
    );
  }

  // ================================================================
  // COMMON AUDIT CONTENT
  // ================================================================

  Widget _auditContent({
    required IconData icon,
    required String title,
    required String description,
    required List<_AuditStat> statistics,
    required VoidCallback onAuditPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.blue, size: 25),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.4,
              ),
              itemCount: statistics.length,
              itemBuilder: (context, index) {
                final stat = statistics[index];

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(stat.icon, size: 18, color: Colors.blue),

                      const SizedBox(width: 7),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              stat.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              stat.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onAuditPressed,
              icon: const Icon(Icons.fact_check_outlined, size: 18),
              label: const Text('Open Audit'),
            ),
          ),
        ],
      ),
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
          _activityItem(
            icon: Icons.person_add,
            iconColor: Colors.green,
            title: 'New user registered',
            description: 'John Doe created a new account',
            time: '5 minutes ago',
          ),

          _activityItem(
            icon: Icons.check_circle,
            iconColor: Colors.blue,
            title: 'Account approved',
            description: 'Dr. Sarah Wilson was approved',
            time: '25 minutes ago',
          ),

          _activityItem(
            icon: Icons.edit,
            iconColor: Colors.orange,
            title: 'User information updated',
            description: 'User #1024 profile was updated',
            time: '2 hours ago',
          ),

          _activityItem(
            icon: Icons.login,
            iconColor: Colors.purple,
            title: 'Admin login',
            description: 'Administrator logged into the system',
            time: '3 hours ago',
            showDivider: false,
          ),

          const SizedBox(height: 10),

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

  Widget _activityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String time,
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
                  color: iconColor.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
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
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (showDivider) Divider(height: 1, color: Colors.grey.shade200),
      ],
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
          _notificationItem(
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.orange,
            title: 'Pending approvals',
            description: '24 accounts are waiting for approval.',
          ),

          _notificationItem(
            icon: Icons.security,
            iconColor: Colors.blue,
            title: 'Security notice',
            description: 'Review recent administrator activities.',
          ),

          _notificationItem(
            icon: Icons.system_update,
            iconColor: Colors.green,
            title: 'System update',
            description: 'Application data was successfully synchronized.',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _notificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (showDivider) Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  // ================================================================
  // COMMON SECTION CARD
  // ================================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 21, color: Colors.blue),

                const SizedBox(width: 9),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Divider(color: Colors.grey.shade200),

            child,
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// AUDIT STAT MODEL
// ==================================================================

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
