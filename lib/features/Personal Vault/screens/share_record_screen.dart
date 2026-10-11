import 'package:flutter/material.dart';
import '../services/sharing_service.dart';
import '../services/vault_service.dart';

class ShareRecordItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPack;

  const ShareRecordItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isPack = false,
  });
}

// ============================================================
// OPEN THE SHARE FLOW
// ============================================================

Future<void> showShareRecordFlow(BuildContext context) async {
  final selectedRecord = await showModalBottomSheet<ShareRecordItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.25),
    builder: (context) {
      return const ChooseRecordSheet();
    },
  );

  if (selectedRecord == null || !context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.25),
    builder: (context) {
      return ShareRecordSheet(
        selectedRecord: selectedRecord,
      );
    },
  );
}

// ============================================================
// STAGE 1: CHOOSE WHAT TO SHARE
// ============================================================

class ChooseRecordSheet extends StatefulWidget {
  const ChooseRecordSheet({super.key});

  @override
  State<ChooseRecordSheet> createState() => _ChooseRecordSheetState();
}

class _ChooseRecordSheetState extends State<ChooseRecordSheet> {
  static const Color bg = Color(0xFFF4F5FB);
  static const Color ink = Color(0xFF303246);
  static const Color muted = Color(0xFF6C6F80);
  static const Color purple = Color(0xFF625CFF);

 int? selectedIndex;

final VaultService _vaultService = VaultService();

List<ShareRecordItem> records = [];

@override
void initState() {
  super.initState();
  _loadVaultRecords();
}

void _loadVaultRecords() {
  _vaultService.getRecords().listen((vaultRecords) {
    if (!mounted) return;

    setState(() {
      records = vaultRecords.map((record) {
        return ShareRecordItem(
          title: record.title,
          subtitle: '${record.category} • ${record.recordType}',
          icon: Icons.description_outlined,
        );
      }).toList();
    });
  });
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
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

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
              child: Row(
                children: [
                  _circleIcon(
                    Icons.folder_open_outlined,
                    purple,
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose What to Share',
                          style: TextStyle(
                            color: ink,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Select a record or document pack.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _closeButton(),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
                child: Column(
                  children: [
                    for (int i = 0; i < records.length; i++) ...[
                      _recordOption(
                        index: i,
                        record: records[i],
                      ),
                      if (i != records.length - 1)
                        const SizedBox(height: 13),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
              child: _continueButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recordOption({
    required int index,
    required ShareRecordItem record,
  }) {
    final selected = selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? purple.withOpacity(.55)
                : Colors.transparent,
            width: 1.4,
          ),
          boxShadow: _shadow(),
        ),
        child: Row(
          children: [
            _circleIcon(
              record.icon,
              selected ? purple : muted,
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.subtitle,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                color: selected ? purple : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? purple
                      : muted.withOpacity(.35),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 15,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _continueButton() {
    final enabled = selectedIndex != null;

    return InkWell(
      onTap: enabled
          ? () {
              Navigator.pop(
                context,
                records[selectedIndex!],
              );
            }
          : null,
      borderRadius: BorderRadius.circular(28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: enabled
              ? purple
              : const Color(0xFFE3E4EC),
          borderRadius: BorderRadius.circular(28),
          boxShadow: enabled ? _shadow() : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(
                color: enabled
                    ? Colors.white
                    : muted.withOpacity(.6),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 7),
            Icon(
              Icons.arrow_forward_rounded,
              color: enabled
                  ? Colors.white
                  : muted.withOpacity(.6),
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dragHandle() {
    return Container(
      margin: const EdgeInsets.only(
        top: 12,
        bottom: 14,
      ),
      width: 55,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFDADBE3),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _closeButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FC),
          shape: BoxShape.circle,
          boxShadow: _shadow(),
        ),
        child: const Icon(
          Icons.close,
          color: muted,
          size: 21,
        ),
      ),
    );
  }

  Widget _circleIcon(
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FD),
        shape: BoxShape.circle,
        boxShadow: _shadow(),
      ),
      child: Icon(
        icon,
        color: color,
        size: 23,
      ),
    );
  }

  List<BoxShadow> _shadow() {
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
}

// ============================================================
// STAGE 2: CONFIGURE SHARING
// ============================================================

class ShareRecordSheet extends StatefulWidget {
  final ShareRecordItem selectedRecord;

  const ShareRecordSheet({
    super.key,
    required this.selectedRecord,
  });

  @override
  State<ShareRecordSheet> createState() => _ShareRecordSheetState();
}

class _ShareRecordSheetState extends State<ShareRecordSheet> {
  static const Color bg = Color(0xFFF4F5FB);
  static const Color surface = Color(0xFFF0F1F7);
  static const Color ink = Color(0xFF303246);
  static const Color muted = Color(0xFF6C6F80);
  static const Color purple = Color(0xFF625CFF);

  final SharingService _sharingService = SharingService();

  String permission = 'View only';
  String expiry = 'No expiry';

  bool recipientSelected = false;

  final TextEditingController recipientController =
      TextEditingController();

  @override
  void dispose() {
    recipientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: Container(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height * 0.90,
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

              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(22, 3, 22, 30),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildTitle(),

                      const SizedBox(height: 14),

                      const Text(
                        'Zero-knowledge encrypted transmission via OneClick relay',
                        style: TextStyle(
                          color: muted,
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 23),

                      _buildSelectedRecord(),

                      const SizedBox(height: 28),

                      _sectionTitle('FIND RECIPIENT'),

                      const SizedBox(height: 11),

                      _buildRecipientSearch(),

                      if (recipientSelected) ...[
                        const SizedBox(height: 13),
                        _buildConfirmedRecipient(),
                      ],

                      const SizedBox(height: 28),

                      _sectionTitle('PERMISSION'),

                      const SizedBox(height: 12),

                      _permissionOption(
                        value: 'View only',
                        icon: Icons.visibility_outlined,
                        description:
                            'Recipient can view the record inside OneClick.',
                      ),

                      const SizedBox(height: 12),

                      _permissionOption(
                        value: 'View and download',
                        icon: Icons.cloud_download_outlined,
                        description:
                            'Recipient can view and download a copy.',
                      ),

                      const SizedBox(height: 28),

                      _buildExpiryTitle(),

                      const SizedBox(height: 12),

                      _buildExpiryOptions(),

                      const SizedBox(height: 27),

                      _buildWarning(),

                      const SizedBox(height: 28),

                      _buildConfirmButton(),

                      const SizedBox(height: 10),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: muted,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _buildTitle() {
    return Row(
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          color: purple,
          size: 25,
        ),
        const SizedBox(width: 9),

        const Expanded(
          child: Text(
            'Share Record Securely',
            style: TextStyle(
              color: ink,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7FC),
              shape: BoxShape.circle,
              boxShadow: _shadow(),
            ),
            child: const Icon(
              Icons.close,
              color: muted,
              size: 21,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SELECTED RECORD
  // ============================================================

  Widget _buildSelectedRecord() {
    return _card(
      child: Row(
        children: [
          _circleIcon(
            widget.selectedRecord.icon,
            purple,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedRecord.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.selectedRecord.subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          TextButton(
            onPressed: _changeRecord,
            child: const Text(
              'Change',
              style: TextStyle(
                color: purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECIPIENT
  // ============================================================

  Widget _buildRecipientSearch() {
    return Container(
      decoration: _softDecoration(),
      child: TextField(
        controller: recipientController,
        onChanged: (_) {
          if (recipientSelected) {
            setState(() {
              recipientSelected = false;
            });
          }
        },
        onSubmitted: _findRecipient,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: ink,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search username or email',
          hintStyle: const TextStyle(
            color: muted,
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: const Icon(
            Icons.search,
            color: muted,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              _findRecipient(
                recipientController.text,
              );
            },
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: purple,
            ),
          ),
        ),
      ),
    );
  }

  void _findRecipient(String value) {
    if (value.trim().isEmpty) {
      _message('Enter a username or email first.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      recipientSelected = true;
    });
  }

  Widget _buildConfirmedRecipient() {
    return _card(
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
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
                child: const Text(
                  'MV',
                  style: TextStyle(
                    color: purple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: purple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Marcus Vance',
                        style: TextStyle(
                          color: ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.verified_rounded,
                      color: purple,
                      size: 16,
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  '@marcus.vance',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () {
              setState(() {
                recipientSelected = false;
                recipientController.clear();
              });
            },
            child: const Text(
              'Change',
              style: TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERMISSION
  // ============================================================

  Widget _permissionOption({
    required String value,
    required IconData icon,
    required String description,
  }) {
    final selected = permission == value;

    return InkWell(
      onTap: () {
        setState(() {
          permission = value;
        });
      },
      borderRadius: BorderRadius.circular(24),
      child: _card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected ? purple : muted,
              size: 22,
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Container(
              width: 21,
              height: 21,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    selected ? purple : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? purple
                      : muted.withOpacity(.35),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EXPIRY
  // ============================================================

  Widget _buildExpiryTitle() {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'EXPIRY',
            style: TextStyle(
              color: muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: .5,
            ),
          ),
        ),
        Text(
          'Optional',
          style: TextStyle(
            color: muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryOptions() {
    const options = [
      'No expiry',
      '24 Hours',
      '7 Days',
      '30 Days',
      'Custom',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: options.map((option) {
        final selected = expiry == option;

        return InkWell(
          onTap: () async {
            if (option == 'Custom') {
              await _chooseCustomDate();
              return;
            }

            setState(() {
              expiry = option;
            });
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? purple.withOpacity(.10)
                  : const Color(0xFFF7F7FC),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected
                    ? purple.withOpacity(.35)
                    : Colors.transparent,
              ),
              boxShadow: _shadow(),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: selected ? purple : muted,
                fontSize: 11.5,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

Future<void> _chooseCustomDate() async {
  final now = DateTime.now();

  final date = await showDatePicker(
    context: context,
    initialDate: now.add(const Duration(days: 1)),
    firstDate: now,
    lastDate: DateTime(now.year + 10),
  );

  if (date == null) return;

  setState(() {
    expiry = '${date.day}/${date.month}/${date.year}';
  });
}

Future<void> _confirmSharing() async {
  final recipient = recipientController.text.trim();

  if (recipient.isEmpty) {
    _message('Please select or enter a recipient.');
    return;
  }

  DateTime? expiryDate;

  if (expiry == '24 Hours') {
    expiryDate = DateTime.now().add(const Duration(hours: 24));
  } else if (expiry == '7 Days') {
    expiryDate = DateTime.now().add(const Duration(days: 7));
  } else if (expiry == '30 Days') {
    expiryDate = DateTime.now().add(const Duration(days: 30));
  } else if (expiry.contains('/')) {
    final parts = expiry.split('/');

    if (parts.length == 3) {
      expiryDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: bg,
        title: const Text(
          'Confirm Sharing',
          style: TextStyle(
            color: ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Share "${widget.selectedRecord.title}" with '
          '$recipient?\n\n'
          'Permission: $permission\n'
          'Expiry: $expiry',
          style: const TextStyle(
            color: muted,
            height: 1.5,
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
              'Share',
              style: TextStyle(
                color: purple,
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
    await _sharingService.shareRecord(
      recordTitle: widget.selectedRecord.title,
      recipientName: recipient,
      recipientEmail: recipient,
      permission: permission,
      expiryDate: expiryDate,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Record shared successfully'),
      ),
    );

    Navigator.pop(context, true);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to share record: $e'),
      ),
    );
  }
}

  // ============================================================
  // CONFIRM
  // ============================================================

  Widget _buildConfirmButton() {
    
    final enabled = recipientSelected;

    return InkWell(
      onTap: enabled ? _confirmSharing : null,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 17,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: enabled
              ? purple
              : const Color(0xFFE2E3EB),
          borderRadius: BorderRadius.circular(28),
          boxShadow: enabled ? _shadow() : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: enabled
                  ? Colors.white
                  : muted.withOpacity(.55),
              size: 20,
            ),

            const SizedBox(width: 9),

            Text(
              'Confirm Sharing',
              style: TextStyle(
                color: enabled
                    ? Colors.white
                    : muted.withOpacity(.55),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildWarning() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7ED),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: const Color(0xFFFED7AA),
      ),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          color: Color(0xFFEA580C),
          size: 20,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Only share records with people you trust. Access can be revoked later from the Sharing Center.',
            style: TextStyle(
              color: Color(0xFF9A3412),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}


  // ============================================================
  // CHANGE RECORD
  // ============================================================

  Future<void> _changeRecord() async {
    Navigator.pop(context);

    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    if (!mounted) return;

    showShareRecordFlow(context);
  }

  // ============================================================
  // REUSABLE
  // ============================================================

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: muted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: .5,
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
    Color color,
  ) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FD),
        shape: BoxShape.circle,
        boxShadow: _shadow(),
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }

  Widget _dragHandle() {
    return Container(
      margin: const EdgeInsets.only(
        top: 12,
        bottom: 14,
      ),
      width: 55,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFDADBE3),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  BoxDecoration _softDecoration() {
    return BoxDecoration(
      color: const Color(0xFFF7F7FC),
      borderRadius: BorderRadius.circular(25),
      boxShadow: _shadow(),
    );
  }

  List<BoxShadow> _shadow() {
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

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}