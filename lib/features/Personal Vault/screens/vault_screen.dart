import 'package:flutter/material.dart';

import 'add_record_screen.dart';
import 'record_details_screen.dart';
import 'subscriptions_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  static const background = Color(0xFFE9EBF2);
  static const purple = Color(0xFF6961FF);
  static const ink = Color(0xFF303344);
  static const muted = Color(0xFF686C7C);

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
              Icon(item.icon, color: purple, size: 36),
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
    final visible = _visibleItems;
    final pinned = _items.where((item) => item.favorite).toList();
    final folders = _items.map((item) => item.folder).toSet().toList();
    final tags = _items.expand((item) => item.tags).toSet().toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OneClick',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '● VAULT',
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _comingSoon('Notifications'),
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => _comingSoon('Profile'),
            icon: const Icon(Icons.account_circle, color: purple),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'My Vault',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: ink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _label('Demo'),
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
                        child: _surface(
                          padding: EdgeInsets.zero,
                          child: TextField(
                            onChanged: (value) {
                              setState(() => _query = value);
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search items, tags, folders...',
                              prefixIcon: Icon(Icons.search, color: muted),
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
                          icon: const Icon(Icons.swap_vert, color: purple),
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
                            selectedColor: const Color(0xFFDCD9FF),
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
                        avatar: const Icon(
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
        backgroundColor: background,
        foregroundColor: purple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRecordScreen(),
          ),
         );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: background,
        indicatorColor: const Color(0xFFDCD9FF),
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
          } else if (index == 1) {

          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionsScreen(),
              ),
            );
            } else if (index == 3) {
              _comingSoon('Sharing');
            }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_special_outlined),
            label: 'Vault',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card),
            label: 'Subs',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_outlined),
            label: 'Sharing',
          ),
        ],
      ),
    );
  }

  Widget _recordCard(_VaultItem item) {
    return _surface(
      child: Column(
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
                      style: const TextStyle(
                        color: ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _label(item.type),
                    const SizedBox(height: 10),
                    Text(
                      item.details,
                      style: const TextStyle(color: muted),
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
                onPressed: () => _comingSoon('Share record'),
                icon: const Icon(Icons.ios_share, color: muted),
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
                icon: const Icon(
                  Icons.chevron_right,
                  color: purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pinnedCard(_VaultItem item) {
    return SizedBox(
      width: 165,
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
        child: _surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.icon, color: purple),
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
                  fontWeight: FontWeight.w600,
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
      icon: Icon(
        item.favorite ? Icons.star : Icons.star_border,
        color: item.favorite ? Colors.orange : muted,
      ),
    );
  }

  Widget _badge(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: purple, size: 28),
    );
  }

  Widget _label(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE0DEFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: purple, fontSize: 12),
      ),
    );
  }

  Widget _heading(String title, {String? trailing}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: muted,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (trailing != null)
          Text(trailing, style: const TextStyle(color: muted)),
      ],
    );
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
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.white70,
            offset: Offset(-5, -5),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Color(0xFFD0D2DC),
            offset: Offset(5, 5),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
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