import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  static const Color background = Color(0xFFF8FAFC);
  static const Color purple = Color(0xFF4F46E5);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
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
    backgroundColor: const Color(0xFFF8FAFC),
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
                    _VaultReferenceIcon(
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
                    prefixIcon: const _VaultReferenceIcon(
                      Icons.search,
                      color: muted,
                    ),
                    filled: true,
                    fillColor: Colors.white.withAlpha(235),
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
                        _VaultReferenceIcon(
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
                            child: _VaultReferenceIcon(
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
                          trailing: const _VaultReferenceIcon(
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
    final base = Theme.of(context);
    final typography = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    return Theme(
      data: base.copyWith(
        textTheme: typography,
        primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(base.primaryTextTheme),
        colorScheme: base.colorScheme.copyWith(
          primary: purple, onPrimary: Colors.white,
          secondary: const Color(0xFF0891B2),
          surface: background, onSurface: ink,
        ),
        dividerColor: const Color(0xFFEFF2F7),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) =>
            GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w800 : FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? purple : const Color(0xFF94A3B8),
            )),
          iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            size: 21,
            color: states.contains(WidgetState.selected)
                ? purple : const Color(0xFF94A3B8),
          )),
        ),
      ),
      child: Builder(builder: (themedContext) => DecoratedBox(
        decoration: const BoxDecoration(color: background),
        child: Stack(
          children: [
            Positioned.fill(child: IgnorePointer(child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.8, -1), radius: 1.4,
                  colors: [Color(0xB0E0E7FF), Color(0x00E0E7FF)],
                ),
              ),
            ))),
            Positioned.fill(child: IgnorePointer(child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1, -0.5), radius: 0.9,
                  colors: [Color(0x73F3E8FF), Color(0x00F3E8FF)],
                ),
              ),
            ))),
            Positioned.fill(child: IgnorePointer(child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, 1), radius: 1,
                  colors: [Color(0x66E0F2FE), Color(0x00E0F2FE)],
                ),
              ),
            ))),
            _buildDashboard(themedContext),
          ],
        ),
      )),
    );
  }
  Widget _buildDashboard(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 88,
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [purple, Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(
                  color: Color(0x306366F1), blurRadius: 14,
                  offset: Offset(0, 4),
                )],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(235),
                  borderRadius: BorderRadius.circular(14.5),
                ),
                child: const _VaultReferenceIcon(Icons.verified_user_outlined,
                  size: 22, color: purple),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OneClick', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    letterSpacing: -0.5, color: ink,
                  )),
                  const SizedBox(height: 4),
                  Row(children: [
                    const _VaultPulseDot(color: purple, size: 8, ping: true),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F3FF),
                        border: Border.all(color: const Color(0xFFE0E7FE)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('PERSONAL', style: TextStyle(
                        fontSize: 10, letterSpacing: 1.2,
                        fontWeight: FontWeight.w800, color: Color(0xFF4338CA))),
                    ),
                  ]),
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
            24,
            6,
            24,
            120,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // =================================================
                  // SEARCH
                  // =================================================
                  _VaultSearchSurface(
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
                        icon: const _VaultReferenceIcon(
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
                          icon: const _VaultReferenceIcon(
                            Icons.tune,
                            color: purple,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                          (constraints.maxWidth - 14) / 2;
                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
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
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 24),
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
                          'LKR 4,700',
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
                          endText: '\LKR 3,500',
                          iconColor: Colors.red,
                        ),
                        const SizedBox(height: 18),
                        _record(
                          context,
                          icon: Icons.design_services_outlined,
                          title: 'Figma Workspace',
                          subtitle: 'Renews in 6 days',
                          endText: '\LKR 1,200',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 24),
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
              _VaultReferenceIcon(
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
const SizedBox(height: 24),
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
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withAlpha(240)),
                boxShadow: const [BoxShadow(
                  color: Color(0x140F172A), blurRadius: 24,
                  offset: Offset(0, -4),
                )],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: ColoredBox(
                    color: Colors.white.withAlpha(235),
                    child: NavigationBar(
        backgroundColor: Colors.transparent,
        indicatorColor: const Color(0xFFF0F3FF),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        height: 68,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
            icon: _VaultNavGlyph(
              Icons.home_outlined,
            ),
            selectedIcon: _VaultNavGlyph(
              Icons.home,
              color: purple,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: _VaultNavGlyph(
              Icons.folder_special_outlined,
            ),
            selectedIcon: _VaultNavGlyph(
              Icons.folder_special,
              color: purple,
            ),
            label: 'Vault',
          ),
          NavigationDestination(
            icon: _VaultNavGlyph(
              Icons.credit_card_outlined,
            ),
            selectedIcon: _VaultNavGlyph(
              Icons.credit_card,
              color: purple,
            ),
            label: 'Subs',
          ),
          NavigationDestination(
            icon: _VaultNavGlyph(
              Icons.share_outlined,
            ),
            selectedIcon: _VaultNavGlyph(
              Icons.share,
              color: purple,
            ),
            label: 'Sharing',
          ),
        ],
      ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ============================================================
  // SURFACE
  // ============================================================
  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return _VaultGlassCard(padding: padding, child: child);
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
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: title == 'EXPIRING SOON'
                      ? const Color(0xFFFEF3C7) : const Color(0xFFF0F3FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(trailing, style: TextStyle(
                  color: title == 'EXPIRING SOON'
                      ? const Color(0xFFB45309) : purple,
                  fontSize: 11, fontWeight: FontWeight.w700,
                )),
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
    final Color accent = icon == Icons.shield_outlined
        ? const Color(0xFF2563EB)
        : icon == Icons.auto_awesome
            ? const Color(0xFF9333EA)
            : icon == Icons.folder_copy_outlined
                ? const Color(0xFF0891B2)
                : purple;
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
          child: _VaultGlassCard(interactive: true,
            padding: const EdgeInsets.all(16),
            child: _VaultActionContent(
              icon: icon, title: title, subtitle: subtitle, accent: accent,
            ),
          ),
        ),
      ),
    );
  }
  // ============================================================
  // ICON BADGE
  // ============================================================
  Widget _iconBadge(IconData icon, Color color) {
    return Container(
      width: 44, height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: _VaultReferenceIcon(icon, size: 22, color: color),
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
    return _VaultRowFeedback(
      builder: (context, hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: hovered ? const Color(0xB3F8FAFC) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
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
            AnimatedScale(
              scale: hovered ? 1.05 : 1,
              duration: const Duration(milliseconds: 200),
              child: _iconBadge(icon, iconColor),
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
                          FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _VaultRecordSubtitle(text: subtitle, color: subtitleColor),
                ],
              ),
            ),
            if (onTap != null && endText == null) ...[
              const SizedBox(width: 8),
              AnimatedSlide(
                offset: hovered ? const Offset(0.125, 0) : Offset.zero,
                duration: const Duration(milliseconds: 200),
                child: _VaultReferenceIcon(Icons.chevron_right, size: 16,
                  color: hovered ? muted : const Color(0xFFCBD5E1)),
              ),
            ],
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
    ) ,
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
    backgroundColor: const Color(0xFFF8FAFC),
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
      avatar: _VaultReferenceIcon(
        icon,
        size: 19,
        color: purple,
      ),
      label: Text(label),
      backgroundColor: const Color(0xFFF8FAFC),
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
    backgroundColor: const Color(0xFFF8FAFC),
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
                        icon: const _VaultReferenceIcon(
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
          icon: const _VaultReferenceIcon(
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
    backgroundColor: const Color(0xFFF8FAFC),
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
    backgroundColor: const Color(0xFFF8FAFC),
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
                    icon: const _VaultReferenceIcon(
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
                          const _VaultReferenceIcon(
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
    backgroundColor: const Color(0xFFF8FAFC),
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
                leading: const _VaultReferenceIcon(
                  Icons.open_in_new,
                  color: purple,
                ),
                title: const Text('Open'),
                onTap: () {
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const _VaultReferenceIcon(
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
                leading: const _VaultReferenceIcon(
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


class _VaultGlassScope extends InheritedWidget {
  const _VaultGlassScope({required this.hovered, required super.child});
  final bool hovered;
  static bool hoveredOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_VaultGlassScope>()?.hovered ?? false;
  @override
  bool updateShouldNotify(_VaultGlassScope oldWidget) => hovered != oldWidget.hovered;
}
class _VaultGlassCard extends StatefulWidget {
  const _VaultGlassCard({required this.child, required this.padding, this.interactive = false});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool interactive;
  @override
  State<_VaultGlassCard> createState() => _VaultGlassCardState();
}
class _VaultGlassCardState extends State<_VaultGlassCard> {
  bool _hovered = false;
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() { _hovered = false; _pressed = false; }),
      child: Listener(
        onPointerDown: (_) { if (widget.interactive) setState(() => _pressed = true); },
        onPointerUp: (_) { if (_pressed) setState(() => _pressed = false); },
        onPointerCancel: (_) { if (_pressed) setState(() => _pressed = false); },
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _hovered ? const Color(0x1F6366F1) : const Color(0x1464748B),
                  offset: Offset(0, _hovered ? 20 : 10),
                  blurRadius: _hovered ? 35 : 30, spreadRadius: _hovered ? -8 : -4,
                ),
                const BoxShadow(color: Color(0x0864748B),
                  offset: Offset(0, 4), blurRadius: 12, spreadRadius: -2),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(_hovered ? 255 : 204),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withAlpha(217)),
                  ),
                  child: _VaultGlassScope(hovered: _hovered, child: widget.child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _VaultActionContent extends StatelessWidget {
  const _VaultActionContent({required this.icon, required this.title,
    required this.subtitle, required this.accent});
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    final hovered = _VaultGlassScope.hoveredOf(context);
    final isAI = icon == Icons.auto_awesome;
    final hoverColor = icon == Icons.document_scanner_outlined
        ? const Color(0xFF6366F1) : accent;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 116),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isAI) Positioned(right: -4, top: -4,
            child: IgnorePointer(child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(width: 64, height: 64,
                decoration: const BoxDecoration(color: Color(0x1A9333EA),
                  shape: BoxShape.circle)),
            )),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedScale(
                scale: hovered ? 1.05 : 1,
                duration: const Duration(milliseconds: 300),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 44, height: 44, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hovered ? hoverColor : accent.withAlpha(15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accent.withAlpha(30)),
                  ),
                  child: _VaultReferenceIcon(icon, size: 20,
                    color: hovered ? Colors.white : accent),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  letterSpacing: -0.35, height: 1.3,
                  color: hovered ? accent : const Color(0xFF0F172A),
                ),
                child: Text(title),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.plusJakartaSans(
                fontSize: 11, fontWeight: FontWeight.w500,
                height: 1.35, color: const Color(0xFF94A3B8),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
class _VaultSearchSurface extends StatefulWidget {
  const _VaultSearchSurface({required this.child, required this.padding});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  State<_VaultSearchSurface> createState() => _VaultSearchSurfaceState();
}
class _VaultSearchSurfaceState extends State<_VaultSearchSurface> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (value) => setState(() => _focused = value),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: widget.padding,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(179),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _focused ? const Color(0x666366F1) : Colors.white.withAlpha(204),
                width: _focused ? 2 : 1,
              ),
              boxShadow: const [BoxShadow(color: Color(0x080F172A),
                offset: Offset(0, 2), blurRadius: 4)],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
class _VaultRowFeedback extends StatefulWidget {
  const _VaultRowFeedback({required this.builder});
  final Widget Function(BuildContext, bool) builder;
  @override
  State<_VaultRowFeedback> createState() => _VaultRowFeedbackState();
}
class _VaultRowFeedbackState extends State<_VaultRowFeedback> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: widget.builder(context, _hovered),
  );
}
class _VaultRecordSubtitle extends StatelessWidget {
  const _VaultRecordSubtitle({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final expiring = text.startsWith('Expires');
    final urgent = expiring && color == Colors.red;
    final textColor = urgent ? const Color(0xFFF43F5E) : color;
    final label = Text(text, style: GoogleFonts.plusJakartaSans(
      fontSize: 12, fontWeight: urgent ? FontWeight.w600 : FontWeight.w500,
      color: textColor,
    ));
    if (!expiring) return label;
    return Row(children: [
      _VaultPulseDot(color: urgent ? textColor : const Color(0xFF94A3B8),
        size: 6, animate: urgent),
      const SizedBox(width: 6), Flexible(child: label),
    ]);
  }
}
class _VaultPulseDot extends StatefulWidget {
  const _VaultPulseDot({required this.color, required this.size,
    this.ping = false, this.animate = true});
  final Color color;
  final double size;
  final bool ping;
  final bool animate;
  @override
  State<_VaultPulseDot> createState() => _VaultPulseDotState();
}
class _VaultPulseDotState extends State<_VaultPulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1400));
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.animate && !MediaQuery.disableAnimationsOf(context)) {
      _controller.repeat(reverse: !widget.ping);
    } else { _controller.stop(); }
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => SizedBox(width: widget.size, height: widget.size,
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        if (widget.ping) Transform.scale(scale: 1 + _controller.value,
          child: Opacity(opacity: (1 - _controller.value) * 0.75,
            child: Container(decoration: BoxDecoration(
              color: widget.color, shape: BoxShape.circle)))),
        Opacity(opacity: widget.ping || !widget.animate ? 1 : 1 - _controller.value * 0.5,
          child: Container(decoration: BoxDecoration(
            color: widget.color, shape: BoxShape.circle))),
      ])),
  );
}
class _VaultNavGlyph extends StatefulWidget {
  const _VaultNavGlyph(this.icon, {this.color});
  final IconData icon;
  final Color? color;
  @override
  State<_VaultNavGlyph> createState() => _VaultNavGlyphState();
}
class _VaultNavGlyphState extends State<_VaultNavGlyph> {
  bool _hovered = false;
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() { _hovered = false; _pressed = false; }),
    child: Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 200),
        child: _VaultReferenceIcon(widget.icon, size: 20,
          color: widget.color ?? (_hovered ? const Color(0xFF1E293B)
            : IconTheme.of(context).color ?? const Color(0xFF94A3B8))),
      ),
    ),
  );
}
class _VaultReferenceIcon extends StatelessWidget {
  const _VaultReferenceIcon(this.icon, {this.size, this.color});
  final IconData icon;
  final double? size;
  final Color? color;
  static final Map<IconData, String> _svg = {
    Icons.verified_user_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24">
<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
<path d="m9 12 2 2 4-4"></path>
</svg>''',
    Icons.search: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.tune: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24">
<line x1="4" x2="4" y1="21" y2="14"></line>
<line x1="4" x2="4" y1="10" y2="3"></line>
<line x1="12" x2="12" y1="21" y2="12"></line>
<line x1="12" x2="12" y1="8" y2="3"></line>
<line x1="20" x2="20" y1="21" y2="16"></line>
<line x1="20" x2="20" y1="12" y2="3"></line>
<line x1="1" x2="7" y1="14" y2="14"></line>
<line x1="9" x2="15" y1="8" y2="8"></line>
<line x1="17" x2="23" y1="16" y2="16"></line>
</svg>''',
    Icons.document_scanner_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M3 7V5a2 2 0 012-2h2m10 0h2a2 2 0 012 2v2m0 10v2a2 2 0 01-2 2h-2m-10 0H5a2 2 0 01-2-2v-2M9 10h6m-6 4h4" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.shield_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.auto_awesome: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09zM18.259 8.715L18 9.75l-.259-1.035a3.375 3.375 0 00-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 002.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 002.456 2.456L21.75 6l-1.035.259a3.375 3.375 0 00-2.456 2.456z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.folder_copy_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" stroke-linecap="round" stroke-linejoin="round"></path>
<path d="M12 11v6m3-3H9" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.laptop_mac: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="1.8" viewBox="0 0 24 24">
<path d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.chevron_right: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2.5" viewBox="0 0 24 24">
<path d="M9 5l7 7-7 7" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.badge_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="1.8" viewBox="0 0 24 24">
<path d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.image_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.more_vert: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.picture_as_pdf_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M9 12h6m2 4H7m6-12H6a2 2 0 00-2 2v14a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.home: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="#000000" viewBox="0 0 24 24">
<path d="M11.47 3.84a.75.75 0 011.06 0l8.69 8.69a.75.75 0 101.06-1.06l-8.689-8.69a2.25 2.25 0 00-3.182 0l-8.69 8.69a.75.75 0 001.061 1.06l8.69-8.69z"></path>
<path d="M12 5.432l8.159 8.159c.03.03.06.058.091.086v6.198c0 1.035-.84 1.875-1.875 1.875H15a.75.75 0 01-.75-.75v-4.5a.75.75 0 00-.75-.75h-3a.75.75 0 00-.75.75V21a.75.75 0 01-.75.75H5.625a1.875 1.875 0 01-1.875-1.875v-6.198a2.29 2.29 0 00.091-.086L12 5.43z"></path>
</svg>''',
    Icons.home_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="#000000" viewBox="0 0 24 24">
<path d="M11.47 3.84a.75.75 0 011.06 0l8.69 8.69a.75.75 0 101.06-1.06l-8.689-8.69a2.25 2.25 0 00-3.182 0l-8.69 8.69a.75.75 0 001.061 1.06l8.69-8.69z"></path>
<path d="M12 5.432l8.159 8.159c.03.03.06.058.091.086v6.198c0 1.035-.84 1.875-1.875 1.875H15a.75.75 0 01-.75-.75v-4.5a.75.75 0 00-.75-.75h-3a.75.75 0 00-.75.75V21a.75.75 0 01-.75.75H5.625a1.875 1.875 0 01-1.875-1.875v-6.198a2.29 2.29 0 00.091-.086L12 5.43z"></path>
</svg>''',
    Icons.folder_special_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
<polygon points="12 11 12.7 13.1 15 13.1 13.1 14.5 13.8 16.7 12 15.3 10.2 16.7 10.9 14.5 9 13.1 11.3 13.1 12 11"></polygon>
</svg>''',
    Icons.folder_special: r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
<polygon points="12 11 12.7 13.1 15 13.1 13.1 14.5 13.8 16.7 12 15.3 10.2 16.7 10.9 14.5 9 13.1 11.3 13.1 12 11"></polygon>
</svg>''',
    Icons.credit_card_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<rect height="14" rx="3" width="20" x="2" y="5"></rect>
<line x1="2" x2="22" y1="10" y2="10"></line>
</svg>''',
    Icons.credit_card: r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<rect height="14" rx="3" width="20" x="2" y="5"></rect>
<line x1="2" x2="22" y1="10" y2="10"></line>
</svg>''',
    Icons.share_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<circle cx="18" cy="5" r="3"></circle>
<circle cx="6" cy="12" r="3"></circle>
<circle cx="18" cy="19" r="3"></circle>
<line x1="8.59" x2="15.42" y1="13.51" y2="17.49"></line>
<line x1="15.41" x2="8.59" y1="6.51" y2="10.49"></line>
</svg>''',
    Icons.share: r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<circle cx="18" cy="5" r="3"></circle>
<circle cx="6" cy="12" r="3"></circle>
<circle cx="18" cy="19" r="3"></circle>
<line x1="8.59" x2="15.42" y1="13.51" y2="17.49"></line>
<line x1="15.41" x2="8.59" y1="6.51" y2="10.49"></line>
</svg>''',
  };
  @override
  Widget build(BuildContext context) {
    final svg = _svg[icon];
    final theme = IconTheme.of(context);
    final resolvedColor = color ?? theme.color ?? const Color(0xFF64748B);
    final resolvedSize = size ?? theme.size ?? 24;
    if (svg == null) return Icon(icon, size: resolvedSize, color: resolvedColor);
    return SvgPicture.string(svg, width: resolvedSize, height: resolvedSize,
      colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn));
  }
}
