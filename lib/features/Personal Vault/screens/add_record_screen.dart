import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'smart_upload_review_screen.dart';
import '../services/vault_service.dart';

class AddRecordScreen extends StatefulWidget {
  final String initialRecordType;

  const AddRecordScreen({
    super.key,
    this.initialRecordType = 'Document',
  });

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  static const bg = Color(0xFFE9EBF2);
  static const purple = Color(0xFF6961FF);
  static const violet = Color(0xFF883CFF);
  static const ink = Color(0xFF303344);
  static const muted = Color(0xFF686C7C);

  final VaultService _vaultService = VaultService();
  final _titleController = TextEditingController();

  final _notesController = TextEditingController();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _usernameController = TextEditingController();
  final _recoveryEmailController = TextEditingController();
  final _recoveryPhoneController = TextEditingController();
  final _recoveryInstructionsController = TextEditingController();

  bool _twoFactorEnabled = false;
  bool _hasBackupCodes = false;

  DateTime _purchaseDate = DateTime.now();

  late String _recordType;

  @override
  void initState() {
    super.initState();
    _recordType = widget.initialRecordType;
    _category = _categoriesForRecordType.first;
  }
  String _category = 'Health & Medical';
  DateTime _renewalDate = DateTime.now();
  bool _renewalDateSelected = false;
  bool _expiryNotification = true;
  bool _showSampleFile = false;
  String? _selectedFileName;
  PlatformFile? _selectedFile;

Future<void> _saveAccount() async {
  final title = _titleController.text.trim();
  final username = _usernameController.text.trim();

  if (title.isEmpty || username.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter an account name and username.'),
      ),
    );
    return;
  }

  final notes = [
    'Username: $username',
    if (_recoveryEmailController.text.trim().isNotEmpty)
      'Recovery Email: ${_recoveryEmailController.text.trim()}',
    if (_recoveryPhoneController.text.trim().isNotEmpty)
      'Recovery Phone: ${_recoveryPhoneController.text.trim()}',
    'Two-Factor Authentication: ${_twoFactorEnabled ? 'Enabled' : 'Not enabled'}',
    'Backup Codes: ${_hasBackupCodes ? 'Available' : 'Not available'}',
    if (_recoveryInstructionsController.text.trim().isNotEmpty)
      'Recovery Instructions: ${_recoveryInstructionsController.text.trim()}',
    if (_notesController.text.trim().isNotEmpty)
      'Notes: ${_notesController.text.trim()}',
  ].join('\n');

  try {
    await _vaultService.addRecord(
      title: title,
      recordType: 'Account',
      category: _category,
      notes: notes,
      tags: const ['account'],
      renewalDate: DateTime.now(),
      expiryNotification: false,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account saved to Vault')),
    );

    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save account: $e')),
    );
  }
}

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _merchantController.dispose();
    _amountController.dispose();

    _usernameController.dispose();
    _recoveryEmailController.dispose();
    _recoveryPhoneController.dispose();
    _recoveryInstructionsController.dispose();

    super.dispose();
}

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _renewalDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted || date == null) return;

    setState(() {
      _renewalDate = date;
      _renewalDateSelected = true;
    });
  }

  Future<void> _pickPurchaseDate() async {
  final date = await showDatePicker(
    context: context,
    initialDate: _purchaseDate,
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
  );

  if (!mounted || date == null) return;

  setState(() {
    _purchaseDate = date;
  });
}

  String get _formattedDate {
    if (!_renewalDateSelected) {
    return 'Select date';
  }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${_renewalDate.day} '
        '${months[_renewalDate.month - 1]} '
        '${_renewalDate.year}';
  }

  String get _formattedPurchaseDate {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  return '${_purchaseDate.day} '
      '${months[_purchaseDate.month - 1]} '
      '${_purchaseDate.year}';
}

Future<void> _chooseFile() async {
  final result = await FilePicker.pickFiles(
  type: FileType.custom,
  allowedExtensions: [
    'pdf',
    'jpg',
    'jpeg',
    'png',
  ],
);

  if (result.isEmpty) return;

  final file = result.first;

setState(() {
  _selectedFile = file;
  _selectedFileName = file.name;
  _showSampleFile = true;
});
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _intro(),
                        const SizedBox(height: 32),
                        _label('SELECT RECORD TYPE'),
                        const SizedBox(height: 14),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _typeCard(
                                'Document',
                                'IDs, policies',
                                Icons.description_outlined,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _typeCard(
                                'Account',
                                'Keys, logins',
                                Icons.key_outlined,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _typeCard(
                                'Receipt',
                                'Purchase, warranty',
                                Icons.receipt_long_outlined,
                              ),
                            ),
                          ],
                        ),

                        // Common title field
                        const SizedBox(height: 34),

                        if (_recordType == 'Account') ...[
                          const Text(
                            'Account Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Add the basic information used to identify this account.',
                            style: TextStyle(
                              fontSize: 13,
                              color: muted,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        _label(_titleLabel),
                        const SizedBox(height: 12),
                        _inputSurface(
                        child: TextField(
                          controller: _titleController,
                          style: const TextStyle(
                            fontSize: 18,
                            color: ink,
                          ),
                          decoration: InputDecoration(
                            hintText: _recordType == 'Account'
                                ? 'e.g. Gmail, GitHub, NSBM Portal'
                                : null,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                        ),
                      ),

                      // Account-specific fields
                      if (_recordType == 'Account') ...[
                        const SizedBox(height: 20),
                        _categoryField(),
                        const SizedBox(height: 24),

                        _label('EMAIL OR USERNAME'),
                        const SizedBox(height: 12),
                        _inputSurface(
                          child: TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. name@gmail.com or username',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        const Text(
                          'Recovery Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Keep the information you may need if you lose account access.',
                          style: TextStyle(
                            fontSize: 13,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _label('RECOVERY EMAIL'),
                        const SizedBox(height: 12),
                        _inputSurface(
                          child: TextField(
                            controller: _recoveryEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Enter recovery email (optional)',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _label('RECOVERY PHONE'),
                        const SizedBox(height: 12),
                        _inputSurface(
                          child: TextField(
                            controller: _recoveryPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Enter recovery phone (optional)',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),


                        // Two-Factor Authentication box
                        _inputSurface(
                          radius: 28,
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            title: const Text(
                              'Two-Factor Authentication',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ink,
                              ),
                            ),
                            subtitle: const Text(
                              'Is 2FA enabled for this account?',
                              style: TextStyle(color: muted, fontSize: 13),
                            ),
                            value: _twoFactorEnabled,
                            activeThumbColor: purple,
                            onChanged: (value) {
                              setState(() {
                                _twoFactorEnabled = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Backup Codes box
                        _inputSurface(
                          radius: 28,
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            title: const Text(
                              'Backup Codes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ink,
                              ),
                            ),
                            subtitle: const Text(
                              'Do you have backup codes stored safely?',
                              style: TextStyle(color: muted, fontSize: 13),
                            ),
                            value: _hasBackupCodes,
                            activeThumbColor: purple,
                            onChanged: (value) {
                              setState(() {
                                _hasBackupCodes = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        const SizedBox(height: 20),

                        _label('RECOVERY INSTRUCTIONS'),
                        const SizedBox(height: 12),
                        _inputSurface(
                          radius: 28,
                          child: TextField(
                            controller: _recoveryInstructionsController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Recovery steps (optional — no passwords or codes)',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(20),
                            ),
                          ),
                        ),
                      ],

                          // Receipt-specific fields
                          if (_recordType == 'Receipt') ...[
                          const SizedBox(height: 28),

                          _label('MERCHANT / STORE'),
                          const SizedBox(height: 12),

                          _inputSurface(
                            child: TextField(
                              controller: _merchantController,
                              decoration: const InputDecoration(
                                hintText: 'Enter merchant or store name',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('PURCHASE DATE'),
                                    const SizedBox(height: 12),
                                    _inputSurface(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(30),
                                        onTap: _pickPurchaseDate,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _formattedPurchaseDate,
                                                  style: const TextStyle(
                                                    color: ink,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.calendar_month_outlined,
                                                color: purple,
                                                size: 22,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('AMOUNT'),
                                    const SizedBox(height: 12),
                                    _inputSurface(
                                      child: TextField(
                                        controller: _amountController,
                                        keyboardType: const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: '0.00',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (_recordType != 'Account') ...[
                          const SizedBox(height: 32),
                          _label('DOCUMENT SCAN & FILES'),
                          const SizedBox(height: 14),
                          _uploadCard(),
                        ],

                        if (_recordType != 'Account') ...[
                          const SizedBox(height: 30),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _categoryField()),
                              const SizedBox(width: 16),
                              Expanded(child: _dateField()),
                            ],
                          ),
                        ],

                        if (_recordType != 'Account') ...[
                          const SizedBox(height: 26),
                          _notificationCard(),
                        ],

                        const SizedBox(height: 32),

                        if (_recordType == 'Account') ...[
                          const Text(
                            'Additional Notes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Add any extra information about this account (optional).',
                            style: TextStyle(
                              fontSize: 13,
                              color: muted,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          _label('CONFIDENTIAL NOTES'),
                          const SizedBox(height: 12),
                        ],
                        _inputSurface(
                          radius: 28,
                          child: TextField(
                            controller: _notesController,
                            minLines: 4,
                            maxLines: 8,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.45,
                              color: ink,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Type a note here...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        _surface(
                          radius: 28,
                          padding: EdgeInsets.zero,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () {
                              if (_recordType == 'Account') {
                                _saveAccount();
                                return;
                              }

                              if (_titleController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a record title.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (_recordType != 'Account' && !_renewalDateSelected) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select a renewal or expiry date.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SmartUploadReviewScreen(
                                  title: _titleController.text.trim(),
                                  recordType: _recordType,
                                  category: _category,
                                  renewalDate: _renewalDate,
                                  expiryNotification: _expiryNotification,
                                  notes: _notesController.text.trim(),
                                  tags: const [],
                                  selectedFile: _selectedFile,
                                  merchant: _recordType == 'Receipt'
                                      ? _merchantController.text.trim()
                                      : null,
                                  purchaseDate: _recordType == 'Receipt'
                                      ? _purchaseDate
                                      : null,
                                  amount: _recordType == 'Receipt'
                                      ? _amountController.text.trim()
                                      : null,
                                ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 23,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios_new,
                                    color: purple,
                                    size: 21,
                                  ),
                                  SizedBox(width: 10),
                                 Flexible(
                                  child: Text(
                                    _recordType == 'Account'
                                        ? 'Save Account to Vault'
                                        : 'Continue to Review',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: purple,
                                    ),
                                  ),
                                ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: purple,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel & Discard',
                              style: TextStyle(
                                color: muted,
                                fontSize: 16,
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
      ),
    );
  }

Widget _header() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
    child: Row(
      children: [
        _roundButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.maybePop(context),
        ),

        const SizedBox(width: 16),

        const Expanded(
          child: Text(
            'My Vault',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _intro() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('STEP 1 OF 2'),
          const SizedBox(height: 8),
          const Text(
            'Add New Record',
            style: TextStyle(
              fontSize: 27,
              color: ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );

      return heading;
    },
  );
}

  Widget _typeCard(String title, String subtitle, IconData icon) {
    final selected = _recordType == title;

    return _surface(
      radius: 30,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          setState(() {
            _recordType = title;
            _category = _categoriesForRecordType.first;
          });
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 20,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    _iconDisc(
                      icon,
                      color: selected ? purple : muted,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (selected)
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  Icons.circle,
                  color: purple,
                  size: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _uploadCard() {
    return _surface(
      radius: 30,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          _inputSurface(
            radius: 22,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Icon(
                Icons.document_scanner_outlined,
                color: purple,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Tap to upload PDF or scan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Upload a PDF, JPG or PNG file',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: muted),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _smallButton(
                  label: 'Scan Now',
                  icon: Icons.camera_alt_outlined,
                  color: purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Camera scanning is available when running OneClick on a supported mobile device.',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _smallButton(
                  label: 'Files',
                  icon: Icons.upload_file_outlined,
                  color: muted,
                  onTap: _chooseFile,
                ),
              ),
            ],
          ),
          if (_showSampleFile) ...[
            const SizedBox(height: 18),
            _inputSurface(
              radius: 26,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    _iconDisc(
                      Icons.picture_as_pdf_outlined,
                      color: violet,
                      size: 38,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFileName ?? 'No file selected',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            _selectedFile != null
                              ? 'Selected file'
                              : 'No file selected',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove file',
                      onPressed: () {
                        setState(() {
                          _showSampleFile = false;
                          _selectedFile = null;
                          _selectedFileName = null;
                        });
                      },
                      icon: const Icon(Icons.close, color: muted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> get _categoriesForRecordType {
    switch (_recordType) {
      case 'Account':
        return [
          'Email',
          'Banking',
          'Social Media',
          'Cloud Storage',
          'Work',
          'Other',
        ];

    case 'Receipt':
      return [
        'Electronics',
        'Home',
        'Vehicle',
        'Clothing',
        'Health',
        'Other',
      ];

    case 'Document':
    default:
      return [
        'Personal ID',
        'Health & Medical',
        'Insurance',
        'Home & Lease',
        'Education',
        'Legal',
        'Other',
      ];
  }
}

String get _titleLabel {
  switch (_recordType) {
    case 'Account':
      return 'SERVICE / ACCOUNT NAME';
    case 'Receipt':
      return 'ITEM / PURCHASE TITLE';
    case 'Document':
    default:
      return 'DOCUMENT TITLE';
  }
}

String get _dateLabel {
  switch (_recordType) {
    case 'Receipt':
      return 'WARRANTY / EXPIRY DATE';
    case 'Account':
      return 'REVIEW / RENEWAL DATE';
    case 'Document':
    default:
      return 'RENEWAL / EXPIRY DATE';
  }
}

  Widget _categoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('CATEGORY'),
        const SizedBox(height: 12),
        _inputSurface(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                dropdownColor: bg,
                icon: const Icon(Icons.expand_more, color: muted),
                style: const TextStyle(color: ink, fontSize: 16),
                items: _categoriesForRecordType.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(_dateLabel),
        const SizedBox(height: 12),
        _inputSurface(
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _pickDate,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formattedDate,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: purple,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _notificationCard() {
    return _surface(
      radius: 28,
      child: Row(
        children: [
          _iconDisc(
            Icons.notifications_active_outlined,
            color: violet,
            size: 42,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expiry Notification',
                  style: TextStyle(
                    color: ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Alert me 30 & 7 days prior',
                  style: TextStyle(color: muted, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: _expiryNotification,
            activeThumbColor: purple,
            activeTrackColor: const Color(0xFFD6D4ED),
            onChanged: (value) {
              setState(() => _expiryNotification = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: muted,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return _surface(
      radius: 40,
      padding: EdgeInsets.zero,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: ink, size: 24),
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _iconDisc(
    IconData icon, {
    required Color color,
    double size = 52,
  }) {
    return _surface(
      radius: size,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }

  Widget _smallButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _surface(
      radius: 26,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 19),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _surface({
    required Widget child,
    double radius = 24,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF8F9FC),
            offset: Offset(-5, -5),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Color(0xFFD2D4DD),
            offset: Offset(6, 7),
            blurRadius: 13,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _inputSurface({
    required Widget child,
    double radius = 30,
  }) {
    // Layered gradients approximate the inset shadows in the reference.
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD6D8E1),
            Color(0xFFE9EBF2),
            Color(0xFFF7F8FC),
          ],
          stops: [0, 0.5, 1],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius - 3),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE4E6ED), bg],
          ),
        ),
        child: child,
      ),
    );
  }
}
