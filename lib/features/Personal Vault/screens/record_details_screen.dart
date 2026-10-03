import 'package:flutter/material.dart';

import 'explain_document_screen.dart';

class RecordDetailsScreen extends StatefulWidget {
  const RecordDetailsScreen({super.key});

  @override
  State<RecordDetailsScreen> createState() => _RecordDetailsScreenState();
}

class _RecordDetailsScreenState extends State<RecordDetailsScreen> {
  bool passwordVisible = false;

  static const Color background = Color(0xFFE9EBF2);
  static const Color card = Color(0xFFEEF0F6);
  static const Color purple = Color(0xFF6667FF);
  static const Color ink = Color(0xFF303344);
  static const Color muted = Color(0xFF707383);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 50),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 12),

                  _buildDocumentSummary(),

                  const SizedBox(height: 26),

                  _buildActionButtons(),

                  const SizedBox(height: 28),

                  _buildDocumentView(),

                  const SizedBox(height: 28),

                  _buildExtractedDetails(),

                  const SizedBox(height: 28),

                  _buildResidentPortal(),

                  const SizedBox(height: 28),

                  _buildWarranty(),

                  const SizedBox(height: 35),

                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Row(
      children: [
        _circleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),

        const SizedBox(width: 16),

        const Expanded(
          child: Text(
            'Document Detail',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        _circleButton(
          icon: Icons.more_vert,
          onTap: () {
            _showMoreOptions();
          },
        ),

        const SizedBox(width: 10),

        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: purple,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // DOCUMENT SUMMARY
  // =========================================================

  Widget _buildDocumentSummary() {
    return _surface(
      padding: const EdgeInsets.all(26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F2F7),
              boxShadow: _smallShadow(),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: purple,
              size: 38,
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _smallLabel(
                      'Legal & Property',
                      color: purple,
                    ),

                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 17,
                          color: muted,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Home & Lease',
                          style: TextStyle(
                            color: muted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  'Apartment Lease Agreement',
                  style: TextStyle(
                    color: ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F8),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: _smallShadow(),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              color: purple,
                              size: 9,
                            ),
                            SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                'Active • Renews Oct 31, 2025',
                                style: TextStyle(
                                  color: purple,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Text(
                      '234 days\nleft',
                      style: TextStyle(
                        color: muted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ACTION BUTTONS
  // =========================================================

  Widget _buildActionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _actionButton(
            icon: Icons.auto_awesome,
            text: 'Explain Document',
            highlighted: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExplainDocumentScreen(),
                ),
              );
            },
          ),

          const SizedBox(width: 14),

          _actionButton(
            icon: Icons.share_outlined,
            text: 'Share',
            onTap: () {
              _showMessage('Document sharing will be connected next.');
            },
          ),

          const SizedBox(width: 14),

          _actionButton(
            icon: Icons.download_outlined,
            text: 'Download',
            onTap: () {
              _showMessage('Document download will be connected next.');
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DOCUMENT VIEW
  // =========================================================

  Widget _buildDocumentView() {
    return _surface(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                color: muted,
                size: 22,
              ),

              const SizedBox(width: 10),

              const Text(
                'Document View',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 14),

              _smallLabel(
                'Page 1 of 14',
                color: muted,
              ),

              const Spacer(),

              _miniCircleButton(
                Icons.zoom_in,
                () {
                  _showMessage('Zoom controls will be connected to PDF view.');
                },
              ),

              const SizedBox(width: 8),

              _miniCircleButton(
                Icons.fullscreen,
                () {
                  _showMessage('Full screen PDF view will be connected next.');
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE7E9F0),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 280,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: _smallShadow(),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 105,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD7D9E4),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),

                              const Spacer(),

                              Container(
                                width: 55,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBFC1CE),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          Container(
                            width: 280,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD2D4DE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          const SizedBox(height: 22),

                          _fakeDocumentLine(1),
                          const SizedBox(height: 8),
                          _fakeDocumentLine(1),
                          const SizedBox(height: 8),
                          _fakeDocumentLine(.75),
                          const SizedBox(height: 8),
                          _fakeDocumentLine(.85),
                        ],
                      ),

                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: _smallLabel(
                          'VERIFIED LEASE',
                          color: purple,
                        ),
                      ),

                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(
                          Icons.verified_outlined,
                          color: Color(0xFF8384FF),
                          size: 38,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Tap preview to navigate pages',
                  style: TextStyle(
                    color: muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fakeDocumentLine(double widthFactor) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 11,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E1E8),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // =========================================================
  // EXTRACTED DETAILS
  // =========================================================

  Widget _buildExtractedDetails() {
    return _surface(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Extracted Record Details',
            style: TextStyle(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _informationCard(
                  title: 'Renewal Target',
                  value: 'Oct 31, 2025',
                  footer: '🔔 Alert: 30d before',
                  footerColor: purple,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _informationCard(
                  title: 'Monthly Cost',
                  value: '\$2,350.00 / mo',
                  footer: '◷ Due 1st day',
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          const Text(
            'Tags',
            style: TextStyle(
              color: muted,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _tag('#lease'),
              _tag('#property'),
              _tag('#landlord'),
              _tag('#rent'),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F6),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Internal Notes',
                  style: TextStyle(
                    color: muted,
                    fontSize: 14,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  'Landlord contact: John Doe (555–0192). '
                  'Water included, electricity separate. '
                  'Key renewal clause detailed on page 12.',
                  style: TextStyle(
                    color: ink,
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // RESIDENT PORTAL
  // =========================================================

  Widget _buildResidentPortal() {
    return _surface(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF1F2F7),
                  boxShadow: _smallShadow(),
                ),
                child: const Icon(
                  Icons.key_outlined,
                  color: purple,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resident Portal Account',
                      style: TextStyle(
                        color: ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'tenant.residencegate.io',
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              _smallLabel(
                'Encrypted',
                color: purple,
              ),
            ],
          ),

          const SizedBox(height: 22),

          _credentialBox(
            title: 'USERNAME',
            value: 'alex.miller@domain.com',
            trailing: IconButton(
              onPressed: () {
                _showMessage('Username copied.');
              },
              icon: const Icon(
                Icons.copy_outlined,
                color: muted,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 15, 12, 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F6),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'SECRET PASSWORD',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                        letterSpacing: .5,
                      ),
                    ),

                    Spacer(),

                    Icon(
                      Icons.lock_outline,
                      color: muted,
                      size: 15,
                    ),

                    SizedBox(width: 5),

                    Text(
                      'Protected',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        passwordVisible
                            ? 'MySecurePassword123'
                            : '••••••••••••••',
                        style: const TextStyle(
                          color: ink,
                          fontSize: 19,
                          letterSpacing: 3,
                        ),
                      ),
                    ),

                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.fingerprint,
                        color: purple,
                      ),
                      label: Text(
                        passwordVisible ? 'Hide' : 'Unlock',
                        style: const TextStyle(
                          color: purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          InkWell(
            onTap: () {
              _showRecoveryCodes();
            },
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F6),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.pin_outlined,
                    color: muted,
                    size: 18,
                  ),

                  SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      '3 Backup Recovery Codes Stored',
                      style: TextStyle(
                        color: muted,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  Text(
                    'View',
                    style: TextStyle(
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
    );
  }

  // =========================================================
  // WARRANTY
  // =========================================================

  Widget _buildWarranty() {
    return _surface(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF1F2F7),
                  boxShadow: _smallShadow(),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: purple,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appliance Warranty Coverage',
                      style: TextStyle(
                        color: ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'HVAC & Washer Unit #404',
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Text(
                'Valid till 2026',
                style: TextStyle(
                  color: purple,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _warrantyItem(
            icon: Icons.receipt_long_outlined,
            title: 'Original Installation Invoice',
            subtitle: 'Matched warranty serial: #HVAC-8849-ELM',
            date: 'Jan 12, 2024',
          ),

          const SizedBox(height: 20),

          _warrantyItem(
            icon: Icons.build_outlined,
            title: 'Annual Filter Replacement',
            subtitle: 'Technician: Apex Climate Care • \$0 under warranty',
            date: 'Nov 04, 2024',
          ),
        ],
      ),
    );
  }

  Widget _warrantyItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String date,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F2F7),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: purple,
            size: 17,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

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

        const SizedBox(width: 8),

        Text(
          date,
          style: const TextStyle(
            color: muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // BOTTOM ACTIONS
  // =========================================================

  Widget _buildBottomActions() {
    return Column(
      children: [
        _largeActionButton(
          icon: Icons.drive_file_move_outline,
          text: 'Move to Another Folder',
          onTap: () {
            _showMessage('Folder management will be connected next.');
          },
        ),

        const SizedBox(height: 15),

        _largeActionButton(
          icon: Icons.history,
          text: 'Export Encrypted Archive',
          onTap: () {
            _showMessage('Encrypted export will be connected next.');
          },
        ),

        const SizedBox(height: 15),

        _largeActionButton(
          icon: Icons.delete_outline,
          text: 'Delete Record',
          danger: true,
          onTap: _confirmDelete,
        ),
      ],
    );
  }

  // =========================================================
  // REUSABLE WIDGETS
  // =========================================================

  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.white70,
            offset: Offset(-5, -5),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Color(0xFFD0D2DC),
            offset: Offset(5, 5),
            blurRadius: 14,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF0F1F6),
          boxShadow: _smallShadow(),
        ),
        child: Icon(
          icon,
          color: ink,
          size: 24,
        ),
      ),
    );
  }

  Widget _miniCircleButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF1F2F7),
          boxShadow: _smallShadow(),
        ),
        child: Icon(
          icon,
          color: muted,
          size: 20,
        ),
      ),
    );
  }

  Widget _smallLabel(
    String text, {
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: _smallShadow(),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F6),
          borderRadius: BorderRadius.circular(28),
          boxShadow: _smallShadow(),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: highlighted ? purple : ink,
              size: 20,
            ),

            const SizedBox(width: 8),

            Text(
              text,
              style: TextStyle(
                color: highlighted ? purple : ink,
                fontSize: 14,
                fontWeight:
                    highlighted ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _informationCard({
    required String title,
    required String value,
    required String footer,
    Color footerColor = muted,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F6),
        borderRadius: BorderRadius.circular(28),
        boxShadow: _smallShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: muted,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 13),

          Text(
            value,
            style: const TextStyle(
              color: ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            footer,
            style: TextStyle(
              color: footerColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F6),
        borderRadius: BorderRadius.circular(22),
        boxShadow: _smallShadow(),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: muted,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _credentialBox({
    required String title,
    required String value,
    required Widget trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F6),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    letterSpacing: .5,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  value,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 15,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          trailing,
        ],
      ),
    );
  }

  Widget _largeActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 17,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F6),
          borderRadius: BorderRadius.circular(30),
          boxShadow: _smallShadow(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: danger ? Colors.red : muted,
              size: 21,
            ),

            const SizedBox(width: 10),

            Text(
              text,
              style: TextStyle(
                color: danger ? Colors.red : ink,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BoxShadow> _smallShadow() {
    return const [
      BoxShadow(
        color: Colors.white70,
        offset: Offset(-3, -3),
        blurRadius: 8,
      ),
      BoxShadow(
        color: Color(0xFFD5D7E0),
        offset: Offset(4, 4),
        blurRadius: 9,
      ),
    ];
  }

  // =========================================================
  // DIALOGS / ACTIONS
  // =========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit Record'),
                  onTap: () {
                    Navigator.pop(context);
                    _showMessage('Edit record will be connected next.');
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.star_border),
                  title: const Text('Add to Favorites'),
                  onTap: () {
                    Navigator.pop(context);
                    _showMessage('Added to favorites.');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRecoveryCodes() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recovery Codes'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ONECLICK-8294'),
              SizedBox(height: 8),
              Text('ONECLICK-4712'),
              SizedBox(height: 8),
              Text('ONECLICK-6398'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Record?'),
          content: const Text(
            'Are you sure you want to delete this record? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);

                _showMessage(
                  'Demo only. Record was not permanently deleted.',
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}