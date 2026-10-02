import 'package:flutter/material.dart';

class SharedWithMeItem {
  final String title;
  final String owner;
  final String permission;
  final String expiry;
  final String fileName;
  final String fileType;
  final String fileSize;
  final IconData icon;
  final bool canDownload;
  final bool expiringSoon;

  const SharedWithMeItem({
    required this.title,
    required this.owner,
    required this.permission,
    required this.expiry,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.icon,
    required this.canDownload,
    this.expiringSoon = false,
  });
}

// ============================================================
// OPEN SHARED WITH ME DETAILS
// ============================================================

Future<void> showSharedWithMeDetails(
  BuildContext context,
  SharedWithMeItem item,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.25),
    builder: (context) {
      return SharedWithMeDetailsScreen(
        item: item,
      );
    },
  );
}

// ============================================================
// SHARED WITH ME DETAILS BOTTOM PANEL
// ============================================================

class SharedWithMeDetailsScreen extends StatelessWidget {
  final SharedWithMeItem item;

  const SharedWithMeDetailsScreen({
    super.key,
    required this.item,
  });

  static const Color bg = Color(0xFFF4F5FB);
  static const Color surface = Color(0xFFF0F1F7);
  static const Color ink = Color(0xFF303246);
  static const Color muted = Color(0xFF6C6F80);
  static const Color purple = Color(0xFF625CFF);
  static const Color danger = Color(0xFFFF3347);
  static const Color success = Color(0xFF38A169);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dragHandle(),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  4,
                  22,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),

                    const SizedBox(height: 24),

                    _buildOwnerCard(),

                    const SizedBox(height: 26),

                    _sectionTitle('ACCESS DETAILS'),

                    const SizedBox(height: 12),

                    _buildAccessDetails(),

                    const SizedBox(height: 26),

                    _sectionTitle('FILE'),

                    const SizedBox(height: 12),

                    _buildFileCard(),

                    const SizedBox(height: 24),

                    _buildSecurityNotice(),

                    const SizedBox(height: 28),

                    _buildOpenButton(context),

                    if (item.canDownload) ...[
                      const SizedBox(height: 12),
                      _buildDownloadButton(context),
                    ],

                    const SizedBox(height: 10),

                    _buildCloseButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _circleIcon(
          item.icon,
          purple,
          size: 52,
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 7),

              const Row(
                children: [
                  Icon(
                    Icons.folder_shared_outlined,
                    color: purple,
                    size: 16,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Shared with Me',
                    style: TextStyle(
                      color: purple,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(
                      color: muted,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Encrypted',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FC),
              shape: BoxShape.circle,
              boxShadow: _shadow(),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: muted,
              size: 21,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OWNER
  // ============================================================

  Widget _buildOwnerCard() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FD),
              shape: BoxShape.circle,
              boxShadow: _shadow(),
            ),
            child: Text(
              _getInitials(item.owner),
              style: const TextStyle(
                color: purple,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shared by',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10.5,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.owner,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    const Icon(
                      Icons.verified_rounded,
                      color: purple,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FC),
              borderRadius: BorderRadius.circular(20),
              boxShadow: _shadow(),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: purple,
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: purple,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
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
  // ACCESS DETAILS
  // ============================================================

  Widget _buildAccessDetails() {
    return _card(
      child: Column(
        children: [
          _detailRow(
            icon: item.canDownload
                ? Icons.cloud_download_outlined
                : Icons.visibility_outlined,
            title: 'Permission',
            value: item.permission,
            valueColor: purple,
          ),

          _divider(),

          _detailRow(
            icon: item.expiringSoon
                ? Icons.timer_outlined
                : Icons.event_available_outlined,
            title: 'Access expiry',
            value: item.expiry,
            valueColor:
                item.expiringSoon ? danger : ink,
          ),

          _divider(),

          _detailRow(
            icon: Icons.check_circle_outline,
            title: 'Status',
            value: 'Active',
            valueColor: success,
          ),

          _divider(),

          _detailRow(
            icon: Icons.lock_outline,
            title: 'Security',
            value: 'Encrypted',
            valueColor: purple,
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8FD),
            shape: BoxShape.circle,
            boxShadow: _shadow(),
          ),
          child: Icon(
            icon,
            color: muted,
            size: 18,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Divider(
        height: 1,
        color: muted.withOpacity(.10),
      ),
    );
  }

  // ============================================================
  // FILE
  // ============================================================

  Widget _buildFileCard() {
    return _card(
      child: Row(
        children: [
          _circleIcon(
            item.icon,
            purple,
            size: 48,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${item.fileType} • ${item.fileSize}',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              item.permission,
              style: const TextStyle(
                color: purple,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECURITY NOTICE
  // ============================================================

  Widget _buildSecurityNotice() {
    return _card(
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: purple,
            size: 21,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'This record was securely shared with your OneClick '
              'account. Access is controlled by the record owner '
              'and may be revoked.',
              style: TextStyle(
                color: muted,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OPEN DOCUMENT BUTTON
  // ============================================================

  Widget _buildOpenButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _showMessage(
          context,
          'Opening ${item.fileName}',
        );
      },
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: purple,
          borderRadius: BorderRadius.circular(28),
          boxShadow: _shadow(),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_outlined,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 9),
            Text(
              'Open Document',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DOWNLOAD BUTTON
  // ============================================================

  Widget _buildDownloadButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _showMessage(
          context,
          'Downloading ${item.fileName}',
        );
      },
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FC),
          borderRadius: BorderRadius.circular(28),
          boxShadow: _shadow(),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_rounded,
              color: purple,
              size: 20,
            ),
            SizedBox(width: 9),
            Text(
              'Download Copy',
              style: TextStyle(
                color: purple,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CLOSE
  // ============================================================

  Widget _buildCloseButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          'Close',
          style: TextStyle(
            color: muted,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REUSABLE WIDGETS
  // ============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: muted,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        letterSpacing: .6,
      ),
    );
  }

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _shadow(),
      ),
      child: child,
    );
  }

  Widget _circleIcon(
    IconData icon,
    Color color, {
    double size = 48,
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
        size: size * .46,
      ),
    );
  }

  Widget _dragHandle() {
    return Container(
      margin: const EdgeInsets.only(
        top: 12,
        bottom: 15,
      ),
      width: 55,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFDADBE3),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  static List<BoxShadow> _shadow() {
    return [
      BoxShadow(
        color: Colors.white.withOpacity(.85),
        offset: const Offset(-3, -3),
        blurRadius: 8,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(.055),
        offset: const Offset(4, 6),
        blurRadius: 12,
      ),
    ];
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'
          .toUpperCase();
    }

    if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }

    return '?';
  }

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}