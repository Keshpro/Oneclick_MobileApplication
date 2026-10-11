import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'smart_upload_review_screen.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  static const bg = Color(0xFFE9EBF2);
  static const purple = Color(0xFF6961FF);
  static const violet = Color(0xFF883CFF);
  static const ink = Color(0xFF303344);
  static const muted = Color(0xFF686C7C);

  final _titleController = TextEditingController(
    text: 'Health Insurance Policy 2025',
  );

  final _notesController = TextEditingController(
    text: 'Annual deductible \$500 already satisfied.\n'
        'Emergency line: 1-800-442-9011. Pre-'
        'authorization required for specialists.',
  );

  String _recordType = 'Document';
  String _category = 'Health & Medical';
  DateTime _renewalDate = DateTime(2025, 12, 31);
  bool _expiryNotification = true;
  bool _showSampleFile = true;
  String? _selectedFileName;
  PlatformFile? _selectedFile;

  final List<String> _tags = ['insurance', '2025', 'urgent'];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _placeholder(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is not connected yet.'),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _renewalDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted || date == null) return;

    setState(() => _renewalDate = date);
  }

  Future<void> _addTag() async {
    String value = '';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: bg,
          title: const Text('Add Tag'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter a tag',
            ),
            onChanged: (text) => value = text,
            onSubmitted: (text) {
              Navigator.pop(dialogContext, text);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, value),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) return;

    final tag = result.trim().replaceFirst(RegExp(r'^#'), '');

    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
    }
  }

  String get _formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${_renewalDate.day} '
        '${months[_renewalDate.month - 1]} '
        '${_renewalDate.year}';
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
                                'Warranty, tags',
                                Icons.receipt_long_outlined,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 34),
                        _label('DOCUMENT TITLE'),
                        const SizedBox(height: 12),
                        _inputSurface(
                          child: TextField(
                            controller: _titleController,
                            style: const TextStyle(
                              fontSize: 18,
                              color: ink,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: _label('DOCUMENT SCAN & FILES'),
                            ),
                            const SizedBox(width: 8),
                            _aiBadge(),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _uploadCard(),

                        const SizedBox(height: 30),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _categoryField()),
                            const SizedBox(width: 16),
                            Expanded(child: _dateField()),
                          ],
                        ),

                        const SizedBox(height: 26),
                        _notificationCard(),

                        const SizedBox(height: 30),
                        _label('VAULT TAGS'),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            ..._tags.map(_tagChip),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _smallButton(
                          label: 'Add Tag',
                          icon: Icons.add,
                          color: muted,
                          onTap: _addTag,
                        ),

                        const SizedBox(height: 32),
                        _label('CONFIDENTIAL NOTES'),
                        const SizedBox(height: 12),
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
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 34),
                        _emergencyCard(),
                        const SizedBox(height: 40),

                        _surface(
                          radius: 28,
                          padding: EdgeInsets.zero,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () {
                              if (_titleController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a document title.',
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
                                    tags: List<String>.from(_tags),
                                    selectedFile: _selectedFile,
                                  ),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
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
                                      'Continue to Smart Review',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
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

        final badge = _surface(
          radius: 24,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield, color: purple, size: 17),
              SizedBox(width: 6),
              Text(
                'Zero-Knowledge',
                style: TextStyle(color: purple, fontSize: 14),
              ),
            ],
          ),
        );

        if (constraints.maxWidth < 440) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              const SizedBox(height: 14),
              badge,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            badge,
          ],
        );
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
        onTap: () => setState(() => _recordType = title),
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
            'Camera OCR extracts policy ID, terms & expiry',
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
                            _selectedFileName ?? 'policy_schedule_v4.pdf',
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
                            '2.4 MB • Auto-classified',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove sample file',
                      onPressed: () {
                        setState(() => _showSampleFile = false);
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
                items: [
                  'Health & Medical',
                  'Personal ID',
                  'Home & Lease',
                  'Digital Accounts',
                  'Receipts',
                ].map((category) {
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
        _label('RENEWAL DATE'),
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

  Widget _tagChip(String tag) {
    final color = tag == 'urgent' ? violet : purple;

    return _surface(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(14, 7, 5, 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$tag',
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 25,
            width: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'Remove $tag',
              icon: Icon(Icons.close, color: color, size: 17),
              onPressed: () {
                setState(() => _tags.remove(tag));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _emergencyCard() {
    return _surface(
      radius: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconDisc(Icons.shield, color: purple, size: 44),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-Sync with Emergency Vault',
                  style: TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'When enabled, verified health documents and '
                  'recovery keys are securely encrypted for next-of-kin '
                  'recovery protocols.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 14,
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

  Widget _aiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE0DFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: purple, size: 16),
          SizedBox(width: 5),
          Text(
            'Smart Review AI',
            style: TextStyle(
              color: purple,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
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