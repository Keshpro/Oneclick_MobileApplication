import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'add_record_screen.dart';
import 'record_details_screen.dart';
import 'subscriptions_screen.dart';
import 'vault_settings_screen.dart';
import 'dashboard.dart';
import 'sharing_center_screen.dart';
import 'share_record_screen.dart';
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});
  @override
  State<VaultScreen> createState() => _VaultScreenState();
}
class _VaultScreenState extends State<VaultScreen> {
  static const background = Color(0xFFF8FAFC);
  static const purple = Color(0xFF4F46E5);
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  String _query = '';
  String _filter = 'All';
  String? _folder;
  String? _tag;
  bool _ascending = true;
  final List<_VaultItem> _items = [
    _VaultItem(
      title: 'US Passport',
      type: 'Document',
      details: 'Sample passport • Exp: 2030',
      folder: 'Personal ID',
      tags: ['travel'],
      icon: Icons.badge_outlined,
      favorite: true,
    ),
    _VaultItem(
      title: 'Wi-Fi & Router',
      type: 'Account',
      details: 'Netgear 6E • Sample account',
      folder: 'Home & Lease',
      tags: ['home'],
      icon: Icons.wifi,
      favorite: true,
    ),
    _VaultItem(
      title: 'Apartment Lease Agreement',
      type: 'Document',
      details: 'PDF • 2.4 MB • Sample document',
      folder: 'Home & Lease',
      tags: ['renewals', 'urgent'],
      icon: Icons.description_outlined,
      favorite: true,
    ),
    _VaultItem(
      title: 'GitHub Personal Access',
      type: 'Account',
      details: 'user@example.com • Sample account',
      folder: 'Digital Accounts',
      tags: ['work'],
      icon: Icons.key,
    ),
    _VaultItem(
      title: 'Sony WH-1000XM5',
      type: 'Receipt & Warranty',
      details: 'Sample receipt • Warranty information',
      folder: 'Receipts',
      tags: ['warranty'],
      icon: Icons.verified_outlined,
    ),
    _VaultItem(
      title: 'Automobile Insurance Card',
      type: 'Document',
      details: 'Sample insurance document',
      folder: 'Personal ID',
      tags: ['renewals'],
      icon: Icons.directions_car_outlined,
    ),
    _VaultItem(
      title: 'Vanguard Retirement',
      type: 'Account',
      details: 'me@example.com • Sample account',
      folder: 'Digital Accounts',
      tags: ['work'],
      icon: Icons.account_balance_outlined,
    ),
  ];
  List<_VaultItem> get _visibleItems {
    final query = _query.trim().toLowerCase();
    final results = _items.where((item) {
      final matchesQuery = [
        item.title,
        item.details,
        item.folder,
        ...item.tags,
      ].join(' ').toLowerCase().contains(query);
      final matchesFilter = _filter == 'All' ||
          (_filter == 'Documents' && item.type != 'Account') ||
          (_filter == 'Accounts' && item.type == 'Account') ||
          (_filter == 'Favorites' && item.favorite);
      return matchesQuery &&
          matchesFilter &&
          (_folder == null || item.folder == _folder) &&
          (_tag == null || item.tags.contains(_tag));
    }).toList();
    results.sort((a, b) {
      final result = a.title.compareTo(b.title);
      return _ascending ? result : -result;
    });
    return results;
  }
  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature will be connected next.')),
    );
  }
  void _shareRecord(_VaultItem item) {
  final shareItem = ShareRecordItem(
    title: item.title,
    subtitle: '${item.type} • ${item.details}',
    icon: item.icon,
  );
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.25),
    builder: (context) {
      return ShareRecordSheet(
        selectedRecord: shareItem,
      );
    },
  );
}
  void _showDetails(_VaultItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VaultReferenceIcon(item.icon, color: purple, size: 36),
              const SizedBox(height: 16),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(item.details),
              const SizedBox(height: 8),
              Text('Folder: ${item.folder}'),
              const SizedBox(height: 8),
              Text(item.tags.map((tag) => '#$tag').join('  ')),
              const SizedBox(height: 20),
              const Text(
                'Demo record only. No file or credentials are stored.',
                style: TextStyle(color: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
        chipTheme: base.chipTheme.copyWith(
          backgroundColor: Colors.white.withAlpha(220),
          selectedColor: const Color(0xFFE0E7FE),
          checkmarkColor: purple,
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.w600, color: ink),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            _buildVault(themedContext),
          ],
        ),
      )),
    );
  }
  Widget _buildVault(BuildContext context) {
    final visible = _visibleItems;
    final pinned = _items.where((item) => item.favorite).toList();
    final folders = _items.map((item) => item.folder).toSet().toList();
    final tags = _items.expand((item) => item.tags).toSet().toList();
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: true,
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
              actions: [
  Padding(
    padding: const EdgeInsets.only(right: 24),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        tooltip: 'Vault Settings',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VaultSettingsScreen(),
            ),
          );
        },
        icon: const _VaultReferenceIcon(
          Icons.settings_outlined,
          color: purple,
        ),
      ),
    ),
  ),
],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 140),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'My Vault',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: ink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _label(''),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_items.length} sample records',
                    style: const TextStyle(color: muted),
                  ),
                  const SizedBox(height: 24),
                  // Search and alphabetical sorting.
                  Row(
                    children: [
                      Expanded(
                        child: _VaultSearchSurface(
                          padding: EdgeInsets.zero,
                          child: TextField(
                            onChanged: (value) {
                              setState(() => _query = value);
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search items, tags, folders...',
                              prefixIcon: _VaultReferenceIcon(Icons.search, color: muted),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _surface(
                        padding: const EdgeInsets.all(4),
                        child: IconButton(
                          tooltip: _ascending
                              ? 'Sort Z to A'
                              : 'Sort A to Z',
                          onPressed: () {
                            setState(() => _ascending = !_ascending);
                          },
                          icon: const _VaultReferenceIcon(Icons.swap_vert, color: purple),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _horizontal(
                    ['All', 'Documents', 'Accounts', 'Favorites']
                        .map(
                          (filter) => ChoiceChip(
                            label: Text(filter),
                            selected: _filter == filter,
                            selectedColor: const Color(0xFFE0E7FE),
                            onSelected: (_) {
                              setState(() => _filter = filter);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  _heading('FOLDERS & TAGS'),
                  const SizedBox(height: 12),
                  _horizontal(
                    folders.map((folder) {
                      final count = _items
                          .where((item) => item.folder == folder)
                          .length;
                      return FilterChip(
                        avatar: const _VaultReferenceIcon(
                          Icons.folder_outlined,
                          size: 18,
                        ),
                        label: Text('$folder  $count'),
                        selected: _folder == folder,
                        onSelected: (selected) {
                          setState(() {
                            _folder = selected ? folder : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  _horizontal(
                    tags.map((tag) {
                      return FilterChip(
                        label: Text('#$tag'),
                        selected: _tag == tag,
                        onSelected: (selected) {
                          setState(() => _tag = selected ? tag : null);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  _heading(
                    'PINNED QUICK ACCESS',
                    trailing: '${pinned.length} items',
                  ),
                  const SizedBox(height: 14),
                  if (pinned.isEmpty)
                    const Text(
                      'Tap a star on a record to pin it here.',
                      style: TextStyle(color: muted),
                    )
                  else
                    _horizontal(
                      pinned.map(_pinnedCard).toList(),
                    ),
                  const SizedBox(height: 28),
                  _heading(
                    'Vault Records',
                    trailing: '${visible.length} shown',
                  ),
                  const SizedBox(height: 16),
                  if (visible.isEmpty)
                    _surface(
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No records match your filters.'),
                        ),
                      ),
                    )
                  else
                    ...visible.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _recordCard(item),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: purple,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRecordScreen(),
          ),
         );
        },
        icon: const _VaultReferenceIcon(Icons.add),
        label: const Text('Add Record'),
      ),
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
        selectedIndex: 1,
        onDestinationSelected: (index) {
  if (index == 1) {
    return;
  }
  if (index == 0) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PersonalDashboardScreen(),
      ),
    );
  }
  if (index == 2) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SubscriptionsScreen(),
      ),
    );
  }
  if (index == 3) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SharingCenterScreen(),
      ),
    );
  }
},
        destinations: const [
          NavigationDestination(
            icon: _VaultNavGlyph(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: _VaultNavGlyph(Icons.folder_special_outlined),
            label: 'Vault',
          ),
          NavigationDestination(
            icon: _VaultNavGlyph(Icons.credit_card),
            label: 'Subs',
          ),
          NavigationDestination(
            icon: _VaultNavGlyph(Icons.share_outlined),
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
  Widget _recordCard(_VaultItem item) {
    return _surface(
      child: Builder(builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _badge(item.icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: _VaultGlassScope.hoveredOf(context)
                            ? _recordAccent(item.icon) : ink,
                        fontSize: 14, letterSpacing: -0.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _label(item.type),
                    const SizedBox(height: 10),
                    Text(
                      item.details,
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _star(item),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Sample record',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ),
              IconButton(
                tooltip: 'Share',
                onPressed: () {
                  _shareRecord(item);
                },
                icon: const _VaultReferenceIcon(
                  Icons.ios_share,
                  color: muted,
                ),
              ),
              IconButton(
                tooltip: 'View details',
                onPressed: () {
                  if (item.title == 'Apartment Lease Agreement') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecordDetailsScreen(),
                      ),
                    );
                  } else {
                     _showDetails(item);
                  }
                },
                icon: const _VaultReferenceIcon(
                  Icons.chevron_right,
                  color: purple,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
  Widget _pinnedCard(_VaultItem item) {
    return SizedBox(
      width: 172,
      child: GestureDetector(
        onTap: () {
          if (item.title == 'Apartment Lease Agreement') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecordDetailsScreen(),
              ),
            );
            } else {
              _showDetails(item);
              }
            },
        child: _VaultGlassCard(interactive: true, padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _badge(item.icon),
                  const Spacer(),
                  _star(item),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.type,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _star(_VaultItem item) {
    return IconButton(
      tooltip: item.favorite ? 'Unpin record' : 'Pin record',
      onPressed: () {
        setState(() => item.favorite = !item.favorite);
      },
      icon: _VaultReferenceIcon(
        item.favorite ? Icons.star : Icons.star_border,
        color: item.favorite ? Colors.orange : muted,
      ),
    );
  }
  Widget _badge(IconData icon) {
    final accent = _recordAccent(icon);
    return Builder(builder: (context) {
      final hovered = _VaultGlassScope.hoveredOf(context);
      return AnimatedScale(
        scale: hovered ? 1.05 : 1,
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 44, height: 44, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hovered ? accent : accent.withAlpha(18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withAlpha(30)),
          ),
          child: _VaultReferenceIcon(icon, size: 22,
            color: hovered ? Colors.white : accent),
        ),
      );
    });
  }
  Color _recordAccent(IconData icon) {
    if (icon == Icons.wifi || icon == Icons.key) return const Color(0xFF2563EB);
    if (icon == Icons.description_outlined) return const Color(0xFF059669);
    if (icon == Icons.verified_outlined) return const Color(0xFFD97706);
    if (icon == Icons.directions_car_outlined) return const Color(0xFF0891B2);
    if (icon == Icons.account_balance_outlined) return const Color(0xFF9333EA);
    return purple;
  }
  Widget _label(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        border: Border.all(color: const Color(0xFFE0E7FE)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(
        color: Color(0xFF4338CA), fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
  Widget _heading(String title, {String? trailing}) {
    return Row(children: [
      Expanded(child: Text(title.toUpperCase(), style: const TextStyle(
        color: Color(0xFF94A3B8), fontSize: 12,
        fontWeight: FontWeight.w800, letterSpacing: 1.6))),
      if (trailing != null) Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: const Color(0xFFF0F3FF),
          borderRadius: BorderRadius.circular(20)),
        child: Text(trailing, style: const TextStyle(
          color: purple, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    ]);
  }
  Widget _horizontal(List<Widget> children) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: children
            .map(
              (child) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: child,
              ),
            )
            .toList(),
      ),
    );
  }
  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return _VaultGlassCard(padding: padding, child: child);
  }
}
class _VaultItem {
  final String title;
  final String type;
  final String details;
  final String folder;
  final List<String> tags;
  final IconData icon;
  bool favorite;
  _VaultItem({
    required this.title,
    required this.type,
    required this.details,
    required this.folder,
    required this.tags,
    required this.icon,
    this.favorite = false,
  });
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
  static const String _documentSvg = r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''';
  static const String _shareSvg = r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<circle cx="18" cy="5" r="3"></circle>
<circle cx="6" cy="12" r="3"></circle>
<circle cx="18" cy="19" r="3"></circle>
<line x1="8.59" x2="15.42" y1="13.51" y2="17.49"></line>
<line x1="15.41" x2="8.59" y1="6.51" y2="10.49"></line>
</svg>''';
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
    Icons.description_outlined: _documentSvg,
    Icons.ios_share: _shareSvg,
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
