import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'share_record_screen.dart';
import 'dashboard.dart';
import 'vault_screen.dart';
import 'subscriptions_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shared_record.dart';
import '../services/sharing_service.dart';


class SharingCenterScreen extends StatefulWidget {
  const SharingCenterScreen({super.key});
  @override
  State<SharingCenterScreen> createState() => _SharingCenterScreenState();
}
class _SharingCenterScreenState extends State<SharingCenterScreen> {
  static const Color bg = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color purple = Color(0xFF4F46E5);
  static const Color purple2 = Color(0xFF9333EA);
  static const Color danger = Color(0xFFF43F5E);

  final SharingService _sharingService = SharingService();
  
  List<SharedRecord> sharedRecords = [];

  List<SharedRecord> receivedRecords = [];

  bool sharedByMe = true;

@override
void initState() {
  super.initState();

  if (FirebaseAuth.instance.currentUser != null) {
    _loadSharedRecords();
    _loadReceivedRecords();
  }
}

void _loadSharedRecords() {
  _sharingService.getSharedRecords().listen((records) {
    if (!mounted) return;

    setState(() {
      sharedRecords = records;
    });
  });
}
void _loadReceivedRecords() {
  _sharingService.getReceivedRecords().listen((records) {
    if (!mounted) return;

    setState(() {
      receivedRecords = records;
    });
  });
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
          surface: bg, onSurface: ink,
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
        decoration: const BoxDecoration(color: bg),
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
            _buildSharing(themedContext),
          ],
        ),
      )),
    );
  }
  Widget _buildSharing(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 130),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHero(),
                        const SizedBox(height: 30),
                        _buildTabs(),
                        const SizedBox(height: 30),
                        if (sharedByMe) ...[
                        _buildRevocationNotice(),
                        const SizedBox(height: 28),

                        if (sharedRecords.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Text(
                                'No shared records yet.',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else
                          ...sharedRecords.map(
                            (record) => Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: _buildSharedRecordCard(record),
                            ),
                          ),

                        const SizedBox(height: 10),
                        _buildShareNewRecord(),
                      ] else ...[
                        _buildReceivedSection(),
                      ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
          bottomNavigationBar: _buildBottomNavigation(),
    );
  }
  // ============================================================
  // TOP BAR
  // ============================================================
Widget _buildTopBar() {
  void _showSharingSearch() {
  final controller = TextEditingController();
  final searchItems = [
    'Apartment Lease Agreement',
    'Home Purchase Tax Bundle',
    'Wi-Fi & Router Admin',
    'Family Health Insurance Group',
    'Rental Car Protection Receipt',
  ];
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final query = controller.text.toLowerCase();
          final results = searchItems.where((item) {
            return item.toLowerCase().contains(query);
          }).toList();
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .70,
              ),
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Sharing',
                    style: TextStyle(
                      color: ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    onChanged: (_) {
                      setModalState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Search shared records...',
                      prefixIcon: const _VaultReferenceIcon(
                        Icons.search_rounded,
                        color: purple,
                      ),
                      filled: true,
                      fillColor: surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    query.isEmpty
                        ? 'SUGGESTED'
                        : 'SEARCH RESULTS',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: results.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No matching sharing records found.',
                                style: TextStyle(
                                  color: muted,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: results.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = results[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const _VaultReferenceIcon(
                                  Icons.description_outlined,
                                  color: purple,
                                ),
                                title: Text(
                                  item,
                                  style: const TextStyle(
                                    color: ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: const _VaultReferenceIcon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: muted,
                                  size: 15,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Found: $item',
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
            ),
          );
        },
      );
    },
  );
}
  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
    child: Row(
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
                      _topCircle(Icons.search_rounded, onTap: _showSharingSearch),
],
        ),
  );
}
  Widget _smallLogo() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FF),
        shape: BoxShape.circle,
        boxShadow: _shadow(),
      ),
      child: const _VaultReferenceIcon(
        Icons.touch_app_outlined,
        color: purple,
        size: 20,
      ),
    );
  }
  // ============================================================
  // HERO
  // ============================================================
  Widget _buildHero() {
    return _card(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _circleIcon(
                Icons.share_outlined,
                color: purple,
                size: 44,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Sharing Center',
                  style: TextStyle(
                    color: ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.5,
                  ),
                ),
              ),
              _pill(
                icon: Icons.circle,
                text: '5 Active',
                color: purple,
              ),
            ],
          ),
          const SizedBox(height: 28),
          _pill(
            icon: Icons.verified_user_outlined,
            text: 'End-to-End Encrypted',
            color: purple,
          ),
          const SizedBox(height: 12),
          _pill(
            icon: Icons.key_outlined,
            text: 'Zero-Knowledge Relay',
            color: muted,
          ),
        ],
      ),
    );
  }
  // ============================================================
  // TABS
  // ============================================================
  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: _softDecoration(radius: 16),
      child: Row(
        children: [
          Expanded(
            child: _tab(
              selected: sharedByMe,
              icon: Icons.outbox_outlined,
              text: 'Shared by Me',
              count: '3',
              onTap: () {
                setState(() {
                  sharedByMe = true;
                });
              },
            ),
          ),
          Expanded(
            child: _tab(
              selected: !sharedByMe,
              icon: Icons.inbox_outlined,
              text: 'Shared with Me',
              count: '2',
              onTap: () {
                setState(() {
                  sharedByMe = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _tab({
    required bool selected,
    required IconData icon,
    required String text,
    required String count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF0F3FF)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: selected ? _shadow() : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _VaultReferenceIcon(
              icon,
              color: selected ? purple : muted,
              size: 21,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? purple : muted,
                  fontSize: 15,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Container(
              width: 25,
              height: 25,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: selected ? ink : muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ============================================================
  // REVOCATION NOTICE
  // ============================================================
  Widget _buildRevocationNotice() {
    return _card(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _circleIcon(
            Icons.history_rounded,
            color: purple2,
            size: 44,
          ),
          const SizedBox(width: 17),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instant Key Revocation',
                  style: TextStyle(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Revoking access terminates recipient decryption '
                  'keys immediately across our enclave relays. Note: '
                  'locally exported copies cannot be deleted remotely.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedRecordCard(SharedRecord record) {
  final recipientName = record.recipientName.trim();

  final initials = recipientName.isNotEmpty
      ? recipientName[0].toUpperCase()
      : '?';

  final expiryText = record.expiryDate == null
      ? 'Never expires'
      : 'Expires ${record.expiryDate!.day}/${record.expiryDate!.month}/${record.expiryDate!.year}';

  final isRevoked = record.status == 'Revoked';

  return _card(
    padding: const EdgeInsets.all(22),
    child: Column(
      children: [
        Row(
          children: [
            _circleIcon(
              Icons.description_outlined,
              color: purple,
              size: 44,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.recordTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Shared record',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            _pill(
              icon: record.permission == 'View and download'
                  ? Icons.cloud_download_outlined
                  : Icons.visibility_outlined,
              text: record.permission,
              color: purple2,
            ),
          ],
        ),

        const SizedBox(height: 23),

        _recipient(
          initials: initials,
          name: record.recipientName,
          email: record.recipientEmail,
          rightTitle: 'Status',
          rightValue: record.status,
          rightValueColor: isRevoked ? danger : purple,
          verified: !isRevoked,
        ),

        const SizedBox(height: 21),

        Row(
          children: [
            Expanded(
              child: _infoPill(
                record.expiryDate == null
                    ? Icons.all_inclusive
                    : Icons.schedule,
                expiryText,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoPill(
                Icons.shield_outlined,
                record.permission,
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: isRevoked
                    ? Icons.check_circle_outline
                    : Icons.block,
                text: isRevoked
                    ? 'Access Revoked'
                    : 'Revoke Access',
                color: isRevoked ? muted : danger,
                onTap: () {
                  if (!isRevoked) {
                    _confirmRevoke(record);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  // ============================================================
  // APARTMENT LEASE
  // ============================================================
  Widget _buildApartmentLease() {
    return _card(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              _circleIcon(
                Icons.description_outlined,
                color: purple,
                size: 44,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apartment Lease Agreement',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Single PDF document • 4.2 MB',
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _pill(
                icon: Icons.visibility_outlined,
                text: 'View only',
                color: purple2,
              ),
            ],
          ),
          const SizedBox(height: 23),
          _recipient(
            initials: 'MV',
            name: 'Marcus Vance',
            email: 'm.vance@studio.o',
            rightTitle: 'Key Fingerprint',
            rightValue: '#9F02···A1',
            verified: true,
          ),
          const SizedBox(height: 21),
          Row(
            children: [
              Expanded(
                child: _infoPill(
                  Icons.schedule,
                  'Expires in 6d (Nov 15)',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoPill(
                  Icons.history,
                  'Accessed 2h ago • 3x',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _actionButton(
                  icon: Icons.block,
                  text: 'Revoke Access',
                  color: danger,
                  onTap: () {
                    _message('This mock card is no longer active.');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.tune,
                  text: 'Edit Link',
                  color: ink,
                  onTap: () {
                    _message('Edit sharing link');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // ============================================================
  // HOME PURCHASE
  // ============================================================
  Widget _buildHomePurchase() {
    return _card(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              _circleIcon(
                Icons.folder_zip_outlined,
                color: purple2,
                size: 44,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home Purchase Tax Bundle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Encrypted bundle • 6 attachments',
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _pill(
                icon: Icons.cloud_download_outlined,
                text: 'View & Download',
                color: purple,
              ),
            ],
          ),
          const SizedBox(height: 23),
          _recipient(
            initials: 'ER',
            name: 'Elena Rostova (Notary)',
            email: 'e.rostova@legaladvisors.ch',
            rightTitle: 'Vault Seal',
            rightValue: 'Active',
            rightValueColor: purple,
            verified: true,
          ),
          const SizedBox(height: 21),
          Row(
            children: [
              Expanded(
                child: _infoPill(
                  Icons.all_inclusive,
                  'Never expires',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoPill(
                  Icons.download_done_outlined,
                  'Downloaded once (Nov 9)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _actionButton(
                  icon: Icons.link_off,
                  text: 'Revoke Access',
                  color: danger,
                  onTap: () {
                    _message('This mock card is no longer active.');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.receipt_long_outlined,
                  text: 'Audit Log',
                  color: ink,
                  onTap: () {
                    _message('Opening audit log');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // ============================================================
  // WIFI ADMIN
  // ============================================================
  Widget _buildWifiAdmin() {
    return _card(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              _circleIcon(
                Icons.key_outlined,
                color: purple,
                size: 50,
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wi-Fi & Router Admin',
                      style: TextStyle(
                        color: ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Encrypted Secret payload',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _pill(
                icon: Icons.shield_outlined,
                text: 'View secret',
                color: muted,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: _softDecoration(radius: 16),
            child: Row(
              children: [
                _initialCircle('SM'),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sarah Miller (Sister)',
                        style: TextStyle(
                          color: ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'sarah.m@gmail.com',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _simpleBadge('Invited'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _infoPill(
                  Icons.hourglass_bottom,
                  'Expires in 24 hours',
                  iconColor: danger,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoPill(
                  Icons.mark_email_unread_outlined,
                  'Pending acceptance',
                  iconColor: purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _actionButton(
                  icon: Icons.cancel_outlined,
                  text: 'Cancel Invite',
                  color: muted,
                  onTap: () {
                    _message('Invitation cancelled');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.send_outlined,
                  text: 'Resend',
                  color: purple,
                  onTap: () {
                    _message('Invitation resent');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // ============================================================
  // SHARED WITH ME
  // ============================================================
Widget _buildReceivedSection() {
  return _card(
    padding: const EdgeInsets.all(22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _VaultReferenceIcon(
              Icons.folder_shared_outlined,
              color: purple,
              size: 22,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Shared with Me',
                style: TextStyle(
                  color: ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${receivedRecords.length} Received',
              style: TextStyle(
                color: purple.withValues(alpha: .9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        const Text(
          'Records shared with your OneClick account.',
          style: TextStyle(
            color: muted,
            fontSize: 12,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 21),

        if (receivedRecords.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Text(
                'No records have been shared with you yet.',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ),
          )
        else
          ...receivedRecords.map((record) {
            final expiryText = record.expiryDate == null
                ? 'No expiry'
                : 'Expires ${record.expiryDate!.day}/${record.expiryDate!.month}/${record.expiryDate!.year}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _receivedItem(
                icon: Icons.description_outlined,
                title: record.recordTitle,
                from: 'Shared by ${record.ownerId}',
                permission: record.permission,
                footerIcon: record.expiryDate == null
                    ? Icons.all_inclusive
                    : Icons.event_available_outlined,
                footer: expiryText,
                onOpen: () {
                  _message('Opening ${record.recordTitle}');
                },
              ),
            );
          }),
      ],
    ),
  );
}
  Widget _receivedItem({
    required IconData icon,
    required String title,
    required String from,
    required String permission,
    required IconData footerIcon,
    required String footer,
    bool dangerFooter = false,
    VoidCallback? onOpen,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _softDecoration(radius: 16),
      child: Column(
        children: [
          Row(
            children: [
              _VaultReferenceIcon(
                icon,
                color: purple,
                size: 21,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      from,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              _simpleBadge(
                permission,
                color: permission.contains('Download')
                    ? purple
                    : muted,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _VaultReferenceIcon(
                footerIcon,
                color: dangerFooter ? danger : muted,
                size: 16,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  footer,
                  style: TextStyle(
                    color: dangerFooter ? danger : muted,
                    fontSize: 10.5,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (onOpen != null) {
                    onOpen!();
                  } else {
                    _message('Opening $title');
                  }
                },
                child: const Row(
                  children: [
                    Text(
                      'Open',
                      style: TextStyle(
                        color: purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2),
                    _VaultReferenceIcon(
                      Icons.arrow_forward,
                      color: purple,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // ============================================================
  // SHARE NEW RECORD
  // ============================================================
  Widget _buildShareNewRecord() {
    return InkWell(
      onTap: () {
        showShareRecordFlow(context);
      },
      borderRadius: BorderRadius.circular(27),
      child: _VaultPressFeedback(child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: _softDecoration(radius: 16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _VaultReferenceIcon(
              Icons.add,
              color: purple,
              size: 23,
            ),
            SizedBox(width: 10),
            Text(
              'Share New Record',
              style: TextStyle(
                color: purple,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      )),
    );
  }
  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================
  Widget _buildBottomNavigation() {
    return SafeArea(
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
                    child: Padding(padding: const EdgeInsets.all(8), child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
  icon: Icons.home_outlined,
  label: 'Home',
  onTap: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PersonalDashboardScreen(),
      ),
    );
  },
),
_navItem(
  icon: Icons.folder_special_outlined,
  label: 'Vault',
  onTap: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const VaultScreen(),
      ),
    );
  },
),
_navItem(
  icon: Icons.credit_card_outlined,
  label: 'Subs',
  onTap: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SubscriptionsScreen(),
      ),
    );
  },
),
_navItem(
  icon: Icons.share_outlined,
  label: 'Sharing',
  selected: true,
  onTap: () {},
),
              ],
            )),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }
  Widget _navItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: _VaultPressFeedback(child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: selected
            ? BoxDecoration(
                color: const Color(0xFFF0F3FF),
                borderRadius: BorderRadius.circular(16),
                
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _VaultReferenceIcon(
              icon,
              color: selected ? purple : muted,
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? purple : muted,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      )),
    );
  }
  // ============================================================
  // REUSABLE UI
  // ============================================================
  Widget _recipient({
    required String initials,
    required String name,
    required String email,
    required String rightTitle,
    required String rightValue,
    bool verified = false,
    Color rightValueColor = ink,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _softDecoration(radius: 16),
      child: Row(
        children: [
          _initialCircle(initials),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (verified) ...[
                      const SizedBox(width: 5),
                      const _VaultReferenceIcon(
                        Icons.verified_outlined,
                        color: purple,
                        size: 17,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rightTitle,
                style: const TextStyle(
                  color: muted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                rightValue,
                style: TextStyle(
                  color: rightValueColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _initialCircle(String initials) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FE),
        shape: BoxShape.circle,
        boxShadow: _shadow(),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: muted,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  Widget _infoPill(
    IconData icon,
    String text, {
    Color iconColor = muted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: _softDecoration(radius: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _VaultReferenceIcon(
            icon,
            color: iconColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ink,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _actionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: _VaultPressFeedback(child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),
        decoration: _softDecoration(radius: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _VaultReferenceIcon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
  Widget _pill({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: _softDecoration(radius: 22),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VaultReferenceIcon(
            icon,
            color: color,
            size: 17,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  Widget _simpleBadge(
    String text, {
    Color color = muted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  Widget _circleIcon(IconData icon, {required Color color, double size = 44}) {
    return Builder(builder: (context) {
      final hovered = _VaultGlassScope.hoveredOf(context);
      return AnimatedScale(scale: hovered ? 1.05 : 1,
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size, height: size, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hovered ? color : color.withAlpha(18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(30)),
          ),
          child: _VaultReferenceIcon(icon, color: hovered ? Colors.white : color,
            size: size * .45),
        ),
      );
    });
  }
  Widget _topCircle(
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _shadow(),
        ),
        child: _VaultReferenceIcon(
          icon,
          color: muted,
          size: 20,
        ),
      ),
    );
  }
  Widget _card({required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20)}) {
    return SizedBox(width: double.infinity,
      child: _VaultGlassCard(padding: padding, child: child));
  }
  BoxDecoration _softDecoration({double radius = 16}) {
    return BoxDecoration(
      color: Colors.white.withAlpha(220),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFFE0E7FE)),
      boxShadow: _shadow(),
    );
  }
  List<BoxShadow> _shadow() {
    return const [
      BoxShadow(color: Color(0x1464748B), offset: Offset(0, 10),
        blurRadius: 30, spreadRadius: -4),
      BoxShadow(color: Color(0x0864748B), offset: Offset(0, 4),
        blurRadius: 12, spreadRadius: -2),
    ];
  }
  // ============================================================
  // ACTIONS
  // ============================================================
  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
Future<void> _confirmRevoke(SharedRecord record) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: surface,
        title: const Text(
          'Revoke Access?',
          style: TextStyle(
            color: ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '${record.recipientName} will immediately lose access to this shared record.',
          style: const TextStyle(
            color: muted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: muted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text(
              'Revoke',
              style: TextStyle(
                color: danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  try {
    await _sharingService.revokeAccess(record.id);

    if (!mounted) return;

    _message('Access revoked for ${record.recipientName}');
  } catch (e) {
    if (!mounted) return;

    _message('Failed to revoke access: $e');
  }
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
    Icons.search_rounded: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.description_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.arrow_forward_ios_rounded: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2.5" viewBox="0 0 24 24">
<path d="M9 5l7 7-7 7" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
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

class _VaultPressFeedback extends StatefulWidget {
  const _VaultPressFeedback({required this.child});
  final Widget child;
  @override
  State<_VaultPressFeedback> createState() => _VaultPressFeedbackState();
}
class _VaultPressFeedbackState extends State<_VaultPressFeedback> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(scale: _pressed ? .95 : 1,
        duration: const Duration(milliseconds: 150), child: widget.child),
    ),
  );
}
