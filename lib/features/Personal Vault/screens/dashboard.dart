import 'package:flutter/material.dart';

import 'vault_screen.dart';
import 'subscriptions_screen.dart';
import 'sharing_center_screen.dart';
import 'ask_ai_vault_screen.dart';
import 'document_pack_requirements_screen.dart';
import 'scan_upload_screen.dart';
import 'add_account_screen.dart';
import 'vault_settings_screen.dart';

class PersonalDashboardScreen extends StatefulWidget {
  const PersonalDashboardScreen({super.key});

  @override
  State<PersonalDashboardScreen> createState() =>
      _PersonalDashboardScreenState();
}

class _PersonalDashboardScreenState
    extends State<PersonalDashboardScreen> {

  static const Color background = Color(0xFFE9EBF2);
  static const Color purple = Color(0xFF6961FF);
  static const Color ink = Color(0xFF303344);
  static const Color muted = Color(0xFF686C7C);

final Map<String, bool> _favorites = {
  'Passport': true,
  'Wi-Fi Account': true,
  'Car Records': true,
  'Health Insurance': false,
  'Apartment Lease': false,
  'Google Account': false,
};
  // ============================================================
  // PLACEHOLDER MESSAGE
  // ============================================================

  void _showNextStep(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature screen will be connected next.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
void _showSearchPanel(BuildContext context) {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> items = [
    {
      'title': 'Passport',
      'type': 'Document',
      'icon': Icons.badge_outlined,
    },
    {
      'title': 'Apartment Lease Agreement',
      'type': 'Document',
      'icon': Icons.picture_as_pdf_outlined,
    },
    {
      'title': 'Health Insurance Card',
      'type': 'Document',
      'icon': Icons.health_and_safety_outlined,
    },
    {
      'title': 'Google Account',
      'type': 'Account Access',
      'icon': Icons.account_circle_outlined,
    },
    {
      'title': 'Netflix Premium',
      'type': 'Subscription',
      'icon': Icons.movie_outlined,
    },
    {
      'title': 'Figma Workspace',
      'type': 'Subscription',
      'icon': Icons.design_services_outlined,
    },
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(26),
      ),
    ),
    builder: (context) {
      List<Map<String, dynamic>> filteredItems = items;
      String selectedFilter = 'All';

      return StatefulBuilder(
        builder: (context, setModalState) {
          void applyFilters() {
  setModalState(() {
    final query =
        searchController.text.trim().toLowerCase();

    filteredItems = items.where((item) {
      final title =
          item['title'].toString().toLowerCase();

      final type =
          item['type'].toString().toLowerCase();

      final matchesSearch =
          title.contains(query) ||
          type.contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          type == selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  });
}

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Small top handle
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: muted.withAlpha(70),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                const Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: purple,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Search Personal Vault',
                      style: TextStyle(
                        color: ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: searchController,
                  autofocus: true,
                  onChanged: (_) {
                    applyFilters();
                    },
                  decoration: InputDecoration(
                    hintText: 'Search documents, accounts...',
                    hintStyle: const TextStyle(
                      color: muted,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: muted,
                    ),
                    filled: true,
                    fillColor: Colors.white.withAlpha(80),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),

                const SizedBox(height: 14),

SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      'All',
      'Document',
      'Account Access',
      'Subscription',
    ].map((filter) {
      final selected =
          selectedFilter == filter;

      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(filter),
          selected: selected,
          selectedColor: purple.withAlpha(35),
          backgroundColor: Colors.white,
          side: BorderSide.none,
          labelStyle: TextStyle(
            color: selected ? purple : muted,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w500,
          ),
          onSelected: (_) {
            selectedFilter = filter;
            applyFilters();
          },
        ),
      );
    }).toList(),
  ),
),

                const SizedBox(height: 16),

                if (searchController.text.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    child: Text(
                      'Start typing to search your Personal Vault',
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                      ),
                    ),
                  )
                else if (filteredItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          color: muted,
                          size: 35,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No matching records found',
                          style: TextStyle(
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 280,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: purple.withAlpha(18),
                              borderRadius:
                                  BorderRadius.circular(13),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: purple,
                              size: 21,
                            ),
                          ),
                          title: Text(
                            item['title'].toString(),
                            style: const TextStyle(
                              color: ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            item['type'].toString(),
                            style: const TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: muted,
                          ),
                          onTap: () {
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${item['title']} selected',
                                ),
                              ),
                            );
                          },
                        );
                      },
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

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 20,

        title: Row(
          children: [
            const Icon(
              Icons.verified_user_outlined,
              color: purple,
            ),

            const SizedBox(width: 12),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OneClick',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '● PERSONAL',
                    style: TextStyle(
                      fontSize: 11,
                      color: purple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // =================================================
                  // SEARCH
                  // =================================================

                  _surface(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    child: TextField(
                      readOnly: true,
                      onTap: () {
                        _showSearchPanel(context);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,

                        icon: const Icon(
                          Icons.search,
                          color: muted,
                        ),

                        hintText: 'Search your personal space',

                        hintStyle: const TextStyle(
                          color: muted,
                          fontSize: 13,
                        ),

                        suffixIcon: IconButton(
                          tooltip: 'Filter records',
                          onPressed: () {
                            _showNextStep(
                              context,
                              'Filters',
                            );
                          },
                          icon: const Icon(
                            Icons.tune,
                            color: purple,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // =================================================
                  // INSTANT ACTIONS
                  // =================================================

                  _heading('INSTANT ACTIONS'),

                  LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      final double width =
                          (constraints.maxWidth - 16) / 2;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _action(
                            context,
                            width,
                            Icons.document_scanner_outlined,
                            'Scan & Upload',
                            'Auto-tagging OCR',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ScanUploadScreen(),
                                ),
                              );
                            },
                          ),


                          _action(
                            context,
                            width,
                            Icons.shield_outlined,
                            'Add Account Access',
                            'Save login & recovery details',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddAccountScreen(),
                                ),
                              );
                            },
                          ),

                          _action(
                            context,
                            width,
                            Icons.auto_awesome,
                            'Ask Vault AI',
                            'Ask about your documents',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const AskAIVaultScreen(),
                                ),
                              );
                            },
                          ),

                          _action(
                            context,
                            width,
                            Icons.folder_copy_outlined,
                            'Build Document Pack',
                            'Match Vault files to a checklist',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const DocumentPackRequirementsScreen(),
                                ),
                              );
                            },
                         ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 26),

                  // =================================================
                  // EXPIRING SOON
                  // =================================================

                  _heading(
                    'EXPIRING SOON',
                    trailing: '2 items',
                  ),

                  _surface(
                    child: Column(
                      children: [
                        _record(
  context,
  icon: Icons.laptop_mac,
  title: 'MacBook Pro M2 Warranty',
  subtitle: 'Expires in 14 days',
  subtitleColor: Colors.red,
  onTap: () {
    _showExpiringDetails(
      context,
      icon: Icons.laptop_mac,
      title: 'MacBook Pro M2 Warranty',
      status: 'Expires in 14 days',
      details: 'Warranty document for MacBook Pro M2.',
    );
  },
),

                        const Divider(
                          height: 24,
                        ),

                        _record(
  context,
  icon: Icons.badge_outlined,
  title: 'Passport Renewal',
  subtitle: 'Expires in 45 days',
  onTap: () {
    _showExpiringDetails(
      context,
      icon: Icons.badge_outlined,
      title: 'Passport Renewal',
      status: 'Expires in 45 days',
      details: 'Passport renewal reminder and document information.',
    );
  },
),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // =================================================
                  // UPCOMING RENEWALS
                  // =================================================

                  _heading(
                    'UPCOMING RENEWALS',
                    trailing: 'View all',

                    // Opens Subscription Screen
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SubscriptionsScreen(),
                        ),
                      );
                    },
                  ),

                  _surface(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Due in the next 7 days',
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'USD 27.99',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: ink,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          '2 renewals · Sample amounts',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _record(
                          context,
                          icon: Icons.movie_outlined,
                          title: 'Netflix Premium',
                          subtitle: 'Renews in 3 days',
                          endText: '\$15.99',
                          iconColor: Colors.red,
                        ),

                        const SizedBox(height: 18),

                        _record(
                          context,
                          icon: Icons.design_services_outlined,
                          title: 'Figma Workspace',
                          subtitle: 'Renews in 6 days',
                          endText: '\$12.00',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // =================================================
                  // FAVORITES
                  // =================================================

                  _heading(
                    'FAVORITES',
                    trailing: 'Manage',
                    onTap: () {
                      _showManageFavorites(context);
                    },
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
  if (_favorites['Passport'] == true) ...[
    _favorite(
      context,
      Icons.badge_outlined,
      'Passport',
    ),
    const SizedBox(width: 12),
  ],

  if (_favorites['Wi-Fi Account'] == true) ...[
    _favorite(
      context,
      Icons.wifi,
      'Wi-Fi Account',
    ),
    const SizedBox(width: 12),
  ],

  if (_favorites['Car Records'] == true) ...[
    _favorite(
      context,
      Icons.directions_car,
      'Car Records',
    ),
    const SizedBox(width: 12),
  ],

  if (_favorites['Health Insurance'] == true) ...[
    _favorite(
      context,
      Icons.health_and_safety_outlined,
      'Health Insurance',
    ),
    const SizedBox(width: 12),
  ],

  if (_favorites['Apartment Lease'] == true) ...[
    _favorite(
      context,
      Icons.home_outlined,
      'Apartment Lease',
    ),
    const SizedBox(width: 12),
  ],

  if (_favorites['Google Account'] == true)
    _favorite(
      context,
      Icons.account_circle_outlined,
      'Google Account',
    ),
],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // =================================================
                  // BACKUPS
                  // =================================================

                  // =================================================
// BACKUPS
// =================================================

_surface(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        'BACKUPS',
        trailing: 'Manage',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const VaultSettingsScreen(),
            ),
          );
        },
      ),

      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const VaultSettingsScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: purple.withAlpha(15),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.cloud_sync_outlined,
                size: 44,
                color: purple,
              ),

              SizedBox(height: 10),

              Text(
                'Vault Backup',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ink,
                ),
              ),

              SizedBox(height: 6),

              Text(
                'Create or restore a secure backup of your Personal Vault.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Tap to manage backups',
                style: TextStyle(
                  fontSize: 12,
                  color: purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 26),


// =================================================
// RECENTLY OPENED
// =================================================

                   _heading(
  'RECENTLY OPENED',
  trailing: 'History',
  onTap: () {
    _showRecentHistory(context);
  },
),

                  _recent(
                    context,
                    Icons.picture_as_pdf_outlined,
                    'Apartment Lease Agreement',
                    'PDF · 2.4 MB · 2 hours ago',
                    Colors.red,
                  ),

                  const SizedBox(height: 14),

                  _recent(
                    context,
                    Icons.image_outlined,
                    'Health Insurance Card',
                    'Image · Yesterday',
                    purple,
                  ),

                  const SizedBox(height: 14),

                  _recent(
                    context,
                    Icons.password,
                    'Shopping Account',
                    'Account · 3 days ago',
                    purple,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: NavigationBar(
        backgroundColor: background,
        indicatorColor: purple.withAlpha(20),
        selectedIndex: 0,

        onDestinationSelected: (index) {
          // HOME
          if (index == 0) {
            return;
          }

          // VAULT
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const VaultScreen(),
              ),
            );

            return;
          }

          // SUBSCRIPTIONS
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const SubscriptionsScreen(),
              ),
            );

            return;
          }

          // SHARING
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SharingCenterScreen(),
              ),
            );
            return;
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
              color: purple,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.folder_special_outlined,
            ),
            selectedIcon: Icon(
              Icons.folder_special,
              color: purple,
            ),
            label: 'Vault',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.credit_card_outlined,
            ),
            selectedIcon: Icon(
              Icons.credit_card,
              color: purple,
            ),
            label: 'Subs',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.share_outlined,
            ),
            selectedIcon: Icon(
              Icons.share,
              color: purple,
            ),
            label: 'Sharing',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SURFACE
  // ============================================================

  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(18),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlpha(210),
            offset: const Offset(-5, -5),
            blurRadius: 12,
          ),

          BoxShadow(
            color: const Color(
              0xFFB9BEC9,
            ).withAlpha(110),
            offset: const Offset(5, 5),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // HEADING
  // ============================================================

  Widget _heading(
    String title, {
    String? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: muted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),

          if (trailing != null)
            if (onTap != null)
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  foregroundColor: purple,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  minimumSize:
                      const Size(48, 40),
                ),
                child: Text(
                  trailing,
                ),
              )
            else
              Text(
                trailing,
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _action(
    BuildContext context,
    double width,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
    }) {
    return SizedBox(
      width: width,
      child: Semantics(
        button: true,
        label: title,
        child: GestureDetector(
          onTap: onTap ??
    () {
      _showNextStep(
        context,
        title,
      );
    },
          child: _surface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _iconBadge(
                  icon,
                  purple,
                ),

                const SizedBox(height: 14),

                Text(
                  title,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ICON BADGE
  // ============================================================

  Widget _iconBadge(
    IconData icon,
    Color color,
  ) {
    return _surface(
      padding: const EdgeInsets.all(10),
      child: Icon(
        icon,
        size: 23,
        color: color,
      ),
    );
  }

  // ============================================================
  // RECORD
  // ============================================================

Widget _record(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  Color subtitleColor = muted,
  Color iconColor = purple,
  String? endText,
  VoidCallback? onTap,
}) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 4,
        ),
        child: Row(
          children: [
            _iconBadge(
              icon,
              iconColor,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                      color: ink,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),

            if (endText != null) ...[
              const SizedBox(width: 8),

              Text(
                endText,
                style: const TextStyle(
                  color: ink,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  void _showExpiringDetails(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String status,
  required String details,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBadge(
                icon,
                purple,
              ),

              const SizedBox(height: 18),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                status,
                style: const TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                details,
                style: const TextStyle(
                  color: muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // ============================================================
  // FAVORITE
  // ============================================================

  Widget _favorite(
    BuildContext context,
    IconData icon,
    String label,
  ) {
    return ActionChip(
      onPressed: () {
        _showNextStep(
          context,
          label,
        );
      },
      avatar: Icon(
        icon,
        size: 19,
        color: purple,
      ),
      label: Text(label),
      backgroundColor: background,
      side: BorderSide.none,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
    );
  }
void _showManageFavorites(BuildContext context) {
  final Map<String, bool> tempFavorites =
      Map<String, bool>.from(_favorites);

  showModalBottomSheet(
    context: context,
    backgroundColor: background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                22,
                24,
                24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Manage Favorites',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: muted,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Choose the records you want quick access to.',
                    style: TextStyle(
                      fontSize: 13,
                      color: muted,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ...tempFavorites.entries.map(
                    (entry) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: purple,
                        controlAffinity:
                            ListTileControlAffinity.trailing,
                        title: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w600,
                            color: ink,
                          ),
                        ),
                        value: entry.value,
                        onChanged: (value) {
                          setModalState(() {
                            tempFavorites[entry.key] =
                                value ?? false;
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _favorites
                            ..clear()
                            ..addAll(tempFavorites);
                        });

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Favorites updated',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Save Favorites',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
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
    },
  );
}

// ============================================================
// RECENT
// ============================================================

Widget _recent(
  BuildContext context,
  IconData icon,
  String title,
  String subtitle,
  Color color,
) {
  return _surface(
    child: Row(
      children: [
        Expanded(
          child: _record(
            context,
            icon: icon,
            title: title,
            subtitle: subtitle,
            iconColor: color,

            // Opens this recently viewed item
            onTap: () {
              _showRecentDetails(
                context,
                icon: icon,
                title: title,
                subtitle: subtitle,
                color: color,
              );
            },
          ),
        ),

        IconButton(
          tooltip: 'Record options',
          onPressed: () {
            _showRecentOptions(
              context,
              title,
            );
          },
          icon: const Icon(
            Icons.more_vert,
            color: muted,
          ),
        ),
      ],
    ),
  );
}
void _showRecentDetails(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBadge(
                icon,
                color,
              ),

              const SizedBox(height: 18),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: muted,
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Recently opened from your Personal Vault.',
                style: TextStyle(
                  fontSize: 14,
                  color: muted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
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
void _showRecentHistory(BuildContext context) {
  final recentItems = [
    {
      'icon': Icons.picture_as_pdf_outlined,
      'title': 'Apartment Lease Agreement',
      'subtitle': 'PDF · 2.4 MB · 2 hours ago',
      'color': Colors.red,
    },
    {
      'icon': Icons.image_outlined,
      'title': 'Health Insurance Card',
      'subtitle': 'Image · Yesterday',
      'color': purple,
    },
    {
      'icon': Icons.password,
      'title': 'Shopping Account',
      'subtitle': 'Account · 3 days ago',
      'color': purple,
    },
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            22,
            24,
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recently Opened',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: muted,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              const Text(
                'Your recently opened Vault records.',
                style: TextStyle(
                  fontSize: 13,
                  color: muted,
                ),
              ),

              const SizedBox(height: 20),

              ...recentItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.pop(sheetContext);

                      _showRecentDetails(
                        context,
                        icon: item['icon'] as IconData,
                        title: item['title'] as String,
                        subtitle: item['subtitle'] as String,
                        color: item['color'] as Color,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _iconBadge(
                            item['icon'] as IconData,
                            item['color'] as Color,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: ink,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  item['subtitle'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: muted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right,
                            color: muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
void _showRecentOptions(
  BuildContext context,
  String title,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.open_in_new,
                  color: purple,
                ),
                title: const Text('Open'),
                onTap: () {
                  Navigator.pop(sheetContext);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.star_border,
                  color: purple,
                ),
                title: const Text('Add to Favorites'),
                onTap: () {
                  Navigator.pop(sheetContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$title added to Favorites',
                      ),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.history_toggle_off,
                  color: muted,
                ),
                title: const Text(
                  'Remove from Recent',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$title removed from recent history',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
    }
