import 'package:flutter/material.dart';

import 'share_record_screen.dart';
import 'shared_with_me_details_screen.dart';
import 'dashboard.dart';
import 'vault_screen.dart';
import 'subscriptions_screen.dart';

class SharingCenterScreen extends StatefulWidget {
  const SharingCenterScreen({super.key});

  @override
  State<SharingCenterScreen> createState() => _SharingCenterScreenState();
}

class _SharingCenterScreenState extends State<SharingCenterScreen> {
  static const Color bg = Color(0xFFF5F6FC);
  static const Color surface = Color(0xFFF1F2F8);
  static const Color ink = Color(0xFF292B43);
  static const Color muted = Color(0xFF686B7D);
  static const Color purple = Color(0xFF625CFF);
  static const Color purple2 = Color(0xFF8138FF);
  static const Color danger = Color(0xFFFF202C);

  bool sharedByMe = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 15, 24, 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
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

                          _buildApartmentLease(),

                          const SizedBox(height: 18),

                          _buildHomePurchase(),

                          const SizedBox(height: 18),

                          _buildWifiAdmin(),

                          const SizedBox(height: 30),

                          _buildReceivedSection(),
                        ] else ...[
                          _buildReceivedSection(),
                        ],

                        const SizedBox(height: 28),

                        _buildShareNewRecord(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            _buildBottomNavigation(),
          ],
        ),
      ),
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
                      prefixIcon: const Icon(
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
                                leading: const Icon(
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
                                trailing: const Icon(
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
  return Container(
    padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F1F8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.025),
          blurRadius: 12,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Row(
          children: [
            _smallLogo(),

            const SizedBox(width: 10),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OneClick',
                    style: TextStyle(
                      color: ink,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.6,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'SHARING',
                    style: TextStyle(
                      color: purple,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            _topCircle(
              Icons.search_rounded,
              onTap: _showSharingSearch,
            ),
          ],
        ),
      ),
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
      child: const Icon(
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
      padding: const EdgeInsets.fromLTRB(27, 29, 27, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _circleIcon(
                Icons.share_outlined,
                color: purple,
                size: 54,
              ),

              const SizedBox(width: 16),

              const Expanded(
                child: Text(
                  'Sharing Center',
                  style: TextStyle(
                    color: ink,
                    fontSize: 27,
                    fontWeight: FontWeight.w500,
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
      decoration: _softDecoration(radius: 25),
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
              ? const Color(0xFFF5F5FD)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: selected ? _shadow() : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
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
                color: const Color(0xFFEAE9FA),
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
            size: 47,
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
                size: 54,
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
                        fontSize: 18,
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
                    _confirmRevoke('Marcus Vance');
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
                size: 54,
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
                        fontSize: 18,
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
                    _confirmRevoke('Elena Rostova');
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
            decoration: _softDecoration(radius: 25),
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
              const Icon(
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
                '2 Received',
                style: TextStyle(
                  color: purple.withOpacity(.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'Decrypted items sent to your OneClick address from '
            'verified contacts.',
            style: TextStyle(
              color: muted,
              fontSize: 12,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 21),

          _receivedItem(
            icon: Icons.health_and_safety_outlined,
            title: 'Family Health Insurance Group',
            from: 'From Arthur Miller (Owner)',
            permission: 'View & Download',
            footerIcon: Icons.event_available_outlined,
            footer: 'Valid until Dec 2026',
            onOpen: () {
              showSharedWithMeDetails(
                context,
                const SharedWithMeItem(
                  title: 'Family Health Insurance Group',
                  owner: 'Arthur Miller',
                  permission: 'View & Download',
                  expiry: 'Valid until Dec 2026',
                  fileName: 'Family_Health_Insurance.pdf',
                  fileType: 'PDF',
                  fileSize: '2.8 MB',
                  icon: Icons.health_and_safety_outlined,
                  canDownload: true,
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          _receivedItem(
            icon: Icons.directions_car_outlined,
            title: 'Rental Car Protection Receipt',
            from: 'From Chloe Bennett (Owner)',
            permission: 'View only',
            footerIcon: Icons.timer_outlined,
            footer: 'Expires tomorrow',
            dangerFooter: true,
            onOpen: () {
              showSharedWithMeDetails(
                context,
                const SharedWithMeItem(
                  title: 'Rental Car Protection Receipt',
                  owner: 'Chloe Bennett',
                  permission: 'View only',
                  expiry: 'Expires tomorrow',
                  fileName: 'Rental_Car_Protection_Receipt.pdf',
                  fileType: 'PDF',
                  fileSize: '1.4 MB',
                  icon: Icons.directions_car_outlined,
                  canDownload: false,
                  expiringSoon: true,
                ),
              );
            },
    ),
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
      decoration: _softDecoration(radius: 25),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
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
              Icon(
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
                    Icon(
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: _softDecoration(radius: 27),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
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
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 13, 32, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Row(
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
  icon: Icons.lock_outline,
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
  icon: Icons.subscriptions_outlined,
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
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        decoration: selected
            ? BoxDecoration(
                color: const Color(0xFFF7F7FD),
                borderRadius: BorderRadius.circular(25),
                boxShadow: _shadow(),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? purple : muted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? purple : muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
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
      decoration: _softDecoration(radius: 28),
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
                      const Icon(
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
        color: const Color(0xFFE9EAF2),
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
          Icon(
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
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),
        decoration: _softDecoration(radius: 26),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
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
      ),
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
          Icon(
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
        color: const Color(0xFFECECF4),
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

  Widget _circleIcon(
    IconData icon, {
    required Color color,
    double size = 50,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FD),
        shape: BoxShape.circle,
        boxShadow: _shadow(),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * .45,
      ),
    );
  }

  Widget _topCircle(
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5FA),
          shape: BoxShape.circle,
          boxShadow: _shadow(),
        ),
        child: Icon(
          icon,
          color: muted,
          size: 25,
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(22),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _shadow(),
      ),
      child: child,
    );
  }

  BoxDecoration _softDecoration({
    double radius = 25,
  }) {
    return BoxDecoration(
      color: const Color(0xFFF7F7FC),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: _shadow(),
    );
  }

  List<BoxShadow> _shadow() {
    return [
      BoxShadow(
        color: Colors.white.withOpacity(.9),
        offset: const Offset(-4, -4),
        blurRadius: 10,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(.065),
        offset: const Offset(5, 7),
        blurRadius: 15,
      ),
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

  void _confirmRevoke(String person) {
    showDialog(
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
            '$person will immediately lose access to this shared record.',
            style: const TextStyle(
              color: muted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: muted),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _message('Access revoked for $person');
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
  }
}