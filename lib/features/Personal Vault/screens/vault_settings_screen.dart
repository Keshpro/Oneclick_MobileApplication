import 'package:flutter/material.dart';

class VaultSettingsScreen extends StatefulWidget {
  final bool openBackupSection;

  const VaultSettingsScreen({
    super.key,
    this.openBackupSection = false,
  });

  @override
  State<VaultSettingsScreen> createState() =>
      _VaultSettingsScreenState();
}
class _VaultSettingsScreenState extends State<VaultSettingsScreen> {
  final GlobalKey _backupSectionKey = GlobalKey();

  static const background = Color(0xFFE9EBF2);
  static const purple = Color(0xFF6961FF);
  static const ink = Color(0xFF303344);
  static const muted = Color(0xFF686C7C);
  static const softPurple = Color(0xFFDCD9FF);

  String _lockTimeout = '5 Min';

  bool _biometric = true;
  bool _failedAttemptProtection = true;

  bool _pushNotifications = true;
  bool _emailNotifications = false;

  final Set<String> _expiryWarnings = {
    '30 days',
    '14 days',
    '7 days',
  };

  String _renewalWarning = '3 days prior';

  bool _localDocumentProcessing = true;
  bool _aiDocumentReasoning = true;
  bool _credentialMasking = true;

 bool _backupCreated = false;
String _lastBackup = 'Not created';

// Scroll to DATA & BACKUP when opened from Dashboard
@override
void initState() {
  super.initState();

  if (widget.openBackupSection) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final backupContext = _backupSectionKey.currentContext;

      if (backupContext != null) {
        Scrollable.ensureVisible(
          backupContext,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.08,
        );
      }
    });
  }
}

void _message(String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        title: const Text(
          'Vault Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            50,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // VAULT PROTECTION STATUS
                  // =================================================

                  _surface(
                    child: Row(
                      children: [
                        _roundIcon(
                          Icons.shield_outlined,
                          size: 48,
                        ),

                        const SizedBox(width: 16),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Vault Protection Active',
                                      style: TextStyle(
                                        color: ink,
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 7),
                                  CircleAvatar(
                                    radius: 5,
                                    backgroundColor: purple,
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Your Vault security preferences are enabled',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        _statusChip(
                          Icons.lock_outline,
                          'Secured',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // =================================================
                  // SECURITY
                  // =================================================

                  _sectionTitle(
                    Icons.lock_clock_outlined,
                    'SECURITY & MASTER LOCK',
                  ),

                  const SizedBox(height: 14),

                  _surface(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Automatic Lock Timeout',
                          style: TextStyle(
                            color: ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Locks the Vault interface after a period of inactivity',
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Immediate',
                            '1 Min',
                            '5 Min',
                            '15 Min',
                          ].map((time) {
                            return _choiceButton(
                              text: time,
                              selected:
                                  _lockTimeout == time,
                              onTap: () {
                                setState(() {
                                  _lockTimeout = time;
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        _settingSwitch(
                          title: 'Biometric Unlock',
                          subtitle:
                              'Use supported device biometrics for quick access',
                          icon: Icons.fingerprint,
                          value: _biometric,
                          onChanged: (value) {
                            setState(() {
                              _biometric = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        _innerAction(
                          icon: Icons.key_outlined,
                          title: 'Master Passphrase',
                          subtitle:
                              'Last updated 42 days ago',
                          trailing: 'Change',
                          onTap: () {
                            _message(
                              'Master passphrase settings will be connected later.',
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        _settingSwitch(
                          title:
                              'Failed Attempt Protection',
                          subtitle:
                              'Protect Vault access after repeated failed attempts',
                          icon: Icons.security_outlined,
                          value:
                              _failedAttemptProtection,
                          onChanged: (value) {
                            setState(() {
                              _failedAttemptProtection =
                                  value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // =================================================
                  // REMINDERS
                  // =================================================

                  _sectionTitle(
                    Icons.notifications_active_outlined,
                    'REMINDER PREFERENCES',
                  ),

                  const SizedBox(height: 14),

                  _surface(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notification Channels',
                          style: TextStyle(
                            color: ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Choose how Vault reminders are delivered',
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            _channelButton(
                              icon: Icons
                                  .phonelink_ring_outlined,
                              selected:
                                  _pushNotifications,
                              tooltip:
                                  'Device notifications',
                              onTap: () {
                                setState(() {
                                  _pushNotifications =
                                      !_pushNotifications;
                                });
                              },
                            ),

                            const SizedBox(width: 10),

                            _channelButton(
                              icon: Icons.mail_outline,
                              selected:
                                  _emailNotifications,
                              tooltip:
                                  'Email reminders',
                              onTap: () {
                                setState(() {
                                  _emailNotifications =
                                      !_emailNotifications;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Advance Expiry Warning',
                          style: TextStyle(
                            color: ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Schedule reminders before important documents expire',
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: [
                            '60 days',
                            '30 days',
                            '14 days',
                            '7 days',
                            'Day of expiry',
                          ].map((warning) {
                            return _choiceButton(
                              text: warning,
                              selected: _expiryWarnings
                                  .contains(warning),
                              onTap: () {
                                setState(() {
                                  if (_expiryWarnings
                                      .contains(warning)) {
                                    _expiryWarnings
                                        .remove(warning);
                                  } else {
                                    _expiryWarnings
                                        .add(warning);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 22),

                        _innerAction(
                          icon:
                              Icons.event_repeat_outlined,
                          title:
                              'Subscription Renewal Alerts',
                          subtitle:
                              'Early billing warning trigger',
                          trailing: _renewalWarning,
                          onTap:
                              _selectRenewalWarning,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // =================================================
                  // AI
                  // =================================================

                  _sectionTitle(
                    Icons.psychology_outlined,
                    'AI DOCUMENT PROCESSING',
                  ),

                  const SizedBox(height: 14),

                  _surface(
                    child: Column(
                      children: [
                        _settingSwitch(
                          title:
                              'Local Document Processing',
                          subtitle:
                              'Process supported document text on the device when available',
                          icon: Icons
                              .document_scanner_outlined,
                          value:
                              _localDocumentProcessing,
                          onChanged: (value) {
                            setState(() {
                              _localDocumentProcessing =
                                  value;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        _settingSwitch(
                          title:
                              'AI Document Reasoning',
                          subtitle:
                              'Enable AI features such as summaries and Ask Vault AI',
                          icon: Icons.auto_awesome,
                          value:
                              _aiDocumentReasoning,
                          onChanged: (value) {
                            setState(() {
                              _aiDocumentReasoning =
                                  value;
                            });
                          },
                        ),

                        const SizedBox(height: 18),

                        _innerStatus(
                          icon: Icons.shield_outlined,
                          title:
                              'Sensitive Credential Masking',
                          subtitle:
                              'Passwords and backup codes are excluded from AI context',
                          status:
                              _credentialMasking
                                  ? 'ENABLED'
                                  : 'OFF',
                          trailingIcon:
                              Icons.lock_outline,
                          onTap: () {
                            setState(() {
                              _credentialMasking =
                                  !_credentialMasking;
                            });
                          },
                        ),

                        const SizedBox(height: 18),

                        _dangerButton(
                          icon:
                              Icons.delete_sweep_outlined,
                          text:
                              'Clear AI Query History',
                          onTap: () {
                            _showClearHistoryDialog();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // =================================================
                  // DATA & BACKUP
                  // =================================================

                  _sectionTitle(
                    Icons.settings_backup_restore,
                    'DATA & BACKUP',
                  ),

                  const SizedBox(height: 14),

                  _surface(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Secure Vault Export',
                          style: TextStyle(
                            color: ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Create a protected export of your Vault records and metadata',
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _largeActionButton(
                          icon: Icons.download_outlined,
                          text:
                              'Export Encrypted Vault (.oneclick)',
                          onTap: () {
                            _message(
                              'Secure Vault export will be connected later.',
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        _innerAction(
                          icon: Icons
                              .medical_services_outlined,
                          title:
                              'Emergency Recovery Kit',
                          subtitle:
                              'Create recovery information for your Vault',
                          trailing: 'Create PDF',
                          onTap: () {
                            _message(
                              'Recovery Kit generation will be connected later.',
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        _innerStatus(
                          icon:
                              Icons.cloud_done_outlined,
                          title: 'Vault Backup',
                          subtitle: _backupCreated
                              ? 'Last backup: $_lastBackup'
                              : 'No Vault backup has been created yet',
                          status: _backupCreated
                              ? 'BACKED UP'
                              : 'NOT BACKED UP',
                          trailingIcon:
                              Icons.chevron_right,
                          onTap: () {
                            _showBackupOptions();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 38),

                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'OneClick Personal Vault',
                          style: TextStyle(
                            color: muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 7),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: muted,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Security preferences managed in your Vault',
                              style: TextStyle(
                                color: muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
    // ===============================================================
  // DIALOGS
  // ===============================================================

  void _selectRenewalWarning() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        const options = [
          '1 day prior',
          '3 days prior',
          '7 days prior',
          '14 days prior',
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscription Renewal Alert',
                  style: TextStyle(
                    color: ink,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                ...options.map(
                  (option) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option),
                    trailing: _renewalWarning == option
                        ? const Icon(
                            Icons.check_circle,
                            color: purple,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _renewalWarning = option;
                      });

                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearHistoryDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: background,
          title: const Text(
            'Clear AI Query History?',
          ),
          content: const Text(
            'This demo action clears the AI query history associated with the Vault.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                _message(
                  'AI query history cleared.',
                );
              },
              child: const Text(
                'Clear',
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

  void _showBackupOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              18,
              22,
              28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: muted.withValues(
                        alpha: 0.25,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    _roundIcon(
                      Icons.cloud_sync_outlined,
                      size: 48,
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Backup & Restore',
                            style: TextStyle(
                              color: ink,
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Protect your Personal Vault data',
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

                const SizedBox(height: 26),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F1F7),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Backup includes',
                        style: TextStyle(
                          color: ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _backupItem(
                        Icons.description_outlined,
                        'Vault documents',
                      ),

                      _backupItem(
                        Icons.manage_accounts_outlined,
                        'Account access records',
                      ),

                      _backupItem(
                        Icons.credit_card_outlined,
                        'Subscriptions',
                      ),

                      _backupItem(
                        Icons.folder_copy_outlined,
                        'Document packs',
                      ),

                      _backupItem(
                        Icons.settings_outlined,
                        'Vault preferences',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      setState(() {
                        _backupCreated = true;
                        _lastBackup = 'Just now';
                      });

                      _message(
                        'Vault backup created successfully.',
                      );
                    },
                    icon: const Icon(
                      Icons.cloud_upload_outlined,
                    ),
                    label: Text(
                      _backupCreated
                          ? 'Create New Backup'
                          : 'Create Backup',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      _message(
                        'Backup file selection will be connected later.',
                      );
                    },
                    icon: const Icon(
                      Icons.settings_backup_restore,
                    ),
                    label: const Text(
                      'Restore from Backup',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: purple,
                      side: const BorderSide(
                        color: softPurple,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: muted,
                      size: 18,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Backup and restore are currently demonstrated '
                        'as prototype actions. Secure storage integration '
                        'can be connected later.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===============================================================
  // BACKUP ITEM
  // ===============================================================

  Widget _backupItem(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 11,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: purple,
            size: 19,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ink,
                fontSize: 13,
              ),
            ),
          ),

          const Icon(
            Icons.check_circle_outline,
            color: purple,
            size: 18,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // UI COMPONENTS
  // ===============================================================

  Widget _sectionTitle(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: purple,
          size: 21,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: muted,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(26),
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

  Widget _roundIcon(
    IconData icon, {
    double size = 42,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        icon,
        color: purple,
        size: size * 0.52,
      ),
    );
  }

  Widget _statusChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: purple,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: purple,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 160,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF0F0F8)
              : background,
          borderRadius: BorderRadius.circular(22),
          border: selected
              ? Border.all(
                  color: softPurple,
                  width: 1.2,
                )
              : null,
          boxShadow: const [
            BoxShadow(
              color: Colors.white70,
              offset: Offset(-3, -3),
              blurRadius: 7,
            ),
            BoxShadow(
              color: Color(0xFFD0D2DC),
              offset: Offset(3, 3),
              blurRadius: 7,
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? purple : muted,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
    );
  }
    Widget _settingSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: const TextStyle(
                  color: muted,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Switch(
          value: value,
          activeThumbColor: purple,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _channelButton({
    required IconData icon,
    required bool selected,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFDCD9FF)
                : background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.white70,
                offset: Offset(-3, -3),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Color(0xFFD0D2DC),
                offset: Offset(3, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: selected ? purple : muted,
          ),
        ),
      ),
    );
  }

  Widget _innerAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.white70,
              offset: Offset(-3, -3),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Color(0xFFD0D2DC),
              offset: Offset(3, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: purple,
              size: 23,
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

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
              trailing,
              style: const TextStyle(
                color: purple,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 3),

            const Icon(
              Icons.chevron_right,
              color: purple,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _innerStatus({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required IconData trailingIcon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.white70,
              offset: Offset(-3, -3),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Color(0xFFD0D2DC),
              offset: Offset(3, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: purple,
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCD9FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: purple,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              trailingIcon,
              color: purple,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _largeActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 18,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.white70,
              offset: Offset(-3, -3),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Color(0xFFD0D2DC),
              offset: Offset(3, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: purple,
              size: 20,
            ),

            const SizedBox(width: 9),

            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: purple,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dangerButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 18,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.white70,
              offset: Offset(-3, -3),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Color(0xFFD0D2DC),
              offset: Offset(3, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.red,
              size: 20,
            ),

            const SizedBox(width: 8),

            Text(
              text,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}