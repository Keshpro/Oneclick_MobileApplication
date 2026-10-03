import 'package:flutter/material.dart';

import 'vault_screen.dart';
import 'subscriptions_screen.dart';
import 'sharing_center_screen.dart';
import 'ask_ai_vault_screen.dart';
import 'document_pack_requirements_screen.dart';

class PersonalDashboardScreen extends StatelessWidget {
  const PersonalDashboardScreen({super.key});

  static const Color background = Color(0xFFE9EBF2);
  static const Color purple = Color(0xFF6961FF);
  static const Color ink = Color(0xFF303344);
  static const Color muted = Color(0xFF686C7C);

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
                        _showNextStep(context, 'Search');
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
                          ),

                          _action(
                            context,
                            width,
                            Icons.shield_outlined,
                            'Add Account',
                            'Store account details',
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
                        ),

                        const Divider(
                          height: 24,
                        ),

                        _record(
                          context,
                          icon: Icons.badge_outlined,
                          title: 'Passport Renewal',
                          subtitle: 'Expires in 45 days',
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
                      _showNextStep(
                        context,
                        'Favorites',
                      );
                    },
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _favorite(
                          context,
                          Icons.badge_outlined,
                          'Passport',
                        ),

                        const SizedBox(width: 12),

                        _favorite(
                          context,
                          Icons.wifi,
                          'Wi-Fi Account',
                        ),

                        const SizedBox(width: 12),

                        _favorite(
                          context,
                          Icons.directions_car,
                          'Car Records',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // =================================================
                  // BACKUPS
                  // =================================================

                  _surface(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _heading(
                          'BACKUPS',
                          trailing: 'Not connected',
                        ),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: purple.withAlpha(15),
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 44,
                                color: purple,
                              ),

                              SizedBox(height: 10),

                              Text(
                                'Backup setup coming later',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                  color: ink,
                                ),
                              ),

                              SizedBox(height: 6),

                              Text(
                                'No files have been backed up yet.',
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: muted,
                                ),
                              ),
                            ],
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
                      _showNextStep(
                        context,
                        'History',
                      );
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
  }) {
    return InkWell(
      onTap: () {
        _showNextStep(
          context,
          title,
        );
      },
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
            ),
          ),

          IconButton(
            tooltip: 'Record options',
            onPressed: () {
              _showNextStep(
                context,
                'Record options',
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
}

