import 'package:flutter/material.dart';
import 'vault_screen.dart';
import 'package:file_picker/file_picker.dart';
import '../services/vault_service.dart';

class SmartUploadReviewScreen extends StatefulWidget {
  final String title;
  final String recordType;
  final String category;
  final DateTime renewalDate;
  final bool expiryNotification;
  final String notes;
  final List<String> tags;
  final PlatformFile? selectedFile;

  const SmartUploadReviewScreen({
    super.key,
    required this.title,
    required this.recordType,
    required this.category,
    required this.renewalDate,
    required this.expiryNotification,
    required this.notes,
    required this.tags,
    this.selectedFile,
  });

  @override
  State<SmartUploadReviewScreen> createState() =>
      _SmartUploadReviewScreenState();
}

class _SmartUploadReviewScreenState
    extends State<SmartUploadReviewScreen> {

  final VaultService _vaultService = VaultService();
  bool _isSaving = false;

  bool renewalReminder = true;

late String selectedCategory;
late TextEditingController titleController;

final TextEditingController amountController = TextEditingController();

late List<String> tags;

  static const Color backgroundColor = Color(0xFFF2F3F8);
  static const Color cardColor = Color(0xFFF7F8FC);
  static const Color primaryColor = Color(0xFF6667FF);
  static const Color textColor = Color(0xFF303244);
  static const Color secondaryText = Color(0xFF6F7180);

@override
void initState() {
  super.initState();

  selectedCategory = widget.category;
  titleController = TextEditingController(
    text: widget.title,
  );

  tags = widget.tags
      .map((tag) => tag.startsWith('#') ? tag : '#$tag')
      .toList();

  renewalReminder = widget.expiryNotification;
}

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    const Text(
                      'Smart Upload Review',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: 3),

                    const Text(
                      'Verify AI-extracted details before saving',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryText,
                      ),
                    ),

                    const SizedBox(height: 22),

                    _buildConfidenceCard(),

                    const SizedBox(height: 26),

                    _buildDocumentPreview(),

                    const SizedBox(height: 26),

                    _buildDocumentTitle(),

                    const SizedBox(height: 22),

                    _buildCategorySection(),

                    const SizedBox(height: 22),

                    _buildTagsSection(),

                    const SizedBox(height: 22),

                    _buildKeyDates(),

                    const SizedBox(height: 22),

                    _buildNeedsReview(),

                    const SizedBox(height: 22),

                    _buildRenewalReminder(),

                    const SizedBox(height: 32),

                    _buildSaveButton(),

                    const SizedBox(height: 16),

                    _buildReplaceButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // TOP BAR
  // ---------------------------------------------------------

Widget _buildTopBar(BuildContext context) {
  return Container(
    height: 88,
    padding: const EdgeInsets.symmetric(horizontal: 22),
    child: Row(
      children: [
        _circleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),

        const SizedBox(width: 16),

        const Expanded(
          child: Text(
            'My Vault',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: textColor,
          size: 25,
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // CONFIDENCE CARD
  // ---------------------------------------------------------

  Widget _buildConfidenceCard() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F1FA),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: primaryColor,
              size: 27,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '4 fields extracted with high confidence',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),

                SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Color(0xFF7846FF),
                    ),
                    SizedBox(width: 7),
                    Text(
                      '1 item requires your verification',
                      style: TextStyle(
                        color: Color(0xFF7846FF),
                        fontSize: 14,
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

  // ---------------------------------------------------------
  // DOCUMENT PREVIEW
  // ---------------------------------------------------------

  Widget _buildDocumentPreview() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E6EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.description_outlined,
                    size: 40,
                    color: secondaryText,
                  ),
                ),

                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PDF',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DOCUMENT PREVIEW',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Residential Tenancy Agreement',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  '14 Pages • 3.2 MB • Scanned',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tap to inspect full PDF',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.open_in_new,
                        size: 17,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // DOCUMENT TITLE
  // ---------------------------------------------------------

  Widget _buildDocumentTitle() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Document Title',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F2F8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 15,
                      color: primaryColor,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '98% Match',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F7),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: titleController,
              style: const TextStyle(
                color: textColor,
                fontSize: 15,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                suffixIcon: Icon(
                  Icons.edit_outlined,
                  color: secondaryText,
                  size: 21,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // CATEGORY
  // ---------------------------------------------------------

  Widget _buildCategorySection() {
    return _card(
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              Text(
                'Auto-Suggested',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _categoryChip(
                'Legal & Property',
                Icons.folder,
              ),
              _categoryChip('Finance', null),
              _categoryChip('Tax Records', null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, IconData? icon) {
    final bool selected = selectedCategory == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F3F8),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: selected ? primaryColor : secondaryText,
              ),
              const SizedBox(width: 7),
            ],

            Text(
              label,
              style: TextStyle(
                color: selected ? primaryColor : secondaryText,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // TAGS
  // ---------------------------------------------------------

  Widget _buildTagsSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              Text(
                'Tap to remove',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...tags.map(_tagChip),

              GestureDetector(
                onTap: _addTag,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F8),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text(
                    '+ Add',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String tag) {
    return GestureDetector(
      onTap: () {
        setState(() {
          tags.remove(tag);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F3F8),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: const TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.close,
              size: 15,
              color: secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();

        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter tag',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String value = controller.text.trim();

                if (value.isNotEmpty) {
                  if (!value.startsWith('#')) {
                    value = '#$value';
                  }

                  setState(() {
                    tags.add(value);
                  });
                }

                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------
  // KEY DATES
  // ---------------------------------------------------------

  Widget _buildKeyDates() {
    return _card(
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Key Dates Extracted',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),

              Icon(
                Icons.verified_outlined,
                color: primaryColor,
                size: 19,
              ),

              SizedBox(width: 5),

              Text(
                'Both Verified',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _dateBox(
                  'EFFECTIVE DATE',
                  'Nov 01, 2024',
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _dateBox(
                  'RENEWAL DATE',
                  'Oct 31, 2025',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateBox(String label, String date) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            date,
            style: const TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            '✓ Confirmed',
            style: TextStyle(
              color: primaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // NEEDS REVIEW
  // ---------------------------------------------------------

  Widget _buildNeedsReview() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.priority_high_rounded,
                color: Color(0xFF814CFF),
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Needs Review • Monthly Rent or Deposit',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Text(
            'Extracted value: \$2,450 / mo. Ambiguity detected with base fee in clause 4.2. Please verify amount below:',
            style: TextStyle(
              color: secondaryText,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 15),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F7),
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              controller: amountController,
              style: const TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      'Clause 4.2',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // REMINDERS
  // ---------------------------------------------------------

  Widget _buildRenewalReminder() {
    return _card(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: primaryColor,
                size: 24,
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Renewal Reminders',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Auto-schedule notice at 60 days and 30 days prior to Oct 31, 2025.',
                      style: TextStyle(
                        color: secondaryText,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Switch(
                value: renewalReminder,
                activeColor: primaryColor,
                onChanged: (value) {
                  setState(() {
                    renewalReminder = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(
            color: Color(0xFFE4E5EC),
          ),

          const SizedBox(height: 8),

          const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 17,
                color: primaryColor,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reminders will only be scheduled after your confirmation.',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // BUTTONS
  // ---------------------------------------------------------

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 67,
      child: ElevatedButton.icon(
        onPressed: _isSaving
    ? null
    : () async {
        setState(() => _isSaving = true);

        try {
          String? fileUrl;

          if (widget.selectedFile != null) {
  final bytes = await widget.selectedFile!.readAsBytes();

  fileUrl = await _vaultService.uploadFile(
    fileName: widget.selectedFile!.name,
    bytes: bytes,
  );
}

          await _vaultService.addRecord(
            title: titleController.text.trim(),
            recordType: widget.recordType,
            category: selectedCategory,
            notes: widget.notes,
            tags: tags
                .map((tag) => tag.replaceFirst('#', ''))
                .toList(),
            renewalDate: widget.renewalDate,
            expiryNotification: renewalReminder,
            fileName: widget.selectedFile?.name,
            fileUrl: fileUrl,
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document saved to Vault'),
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const VaultScreen(),
            ),
            (route) => route.isFirst,
          );
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save document: $e'),
            ),
          );
        } finally {
          if (mounted) {
            setState(() => _isSaving = false);
          }
        }
      },
        icon: const Icon(
          Icons.shield_outlined,
          color: primaryColor,
        ),
        label: const Text(
          'Confirm & Save to Vault',
          style: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.10),
          backgroundColor: const Color(0xFFF4F5F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
      ),
    );
  }

  Widget _buildReplaceButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(
          Icons.sync,
          color: secondaryText,
          size: 20,
        ),
        label: const Text(
          'Retake / Replace File',
          style: TextStyle(
            color: secondaryText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.08),
          backgroundColor: const Color(0xFFF4F5F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // REUSABLE CARD
  // ---------------------------------------------------------

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}