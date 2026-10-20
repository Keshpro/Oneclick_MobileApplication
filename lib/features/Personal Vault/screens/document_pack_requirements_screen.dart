import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'document_pack_matches_screen.dart';
import 'document_requirements_editor.dart';
import '../models/document_pack.dart';
import 'pdf_preview_screen.dart';
import '../services/pdf_checklist_service.dart';

class DocumentPackRequirementsScreen extends StatefulWidget {
  const DocumentPackRequirementsScreen({super.key});

  @override
  State<DocumentPackRequirementsScreen> createState() =>
      _DocumentPackRequirementsScreenState();
}

class _DocumentPackRequirementsScreenState
    extends State<DocumentPackRequirementsScreen> {
  static const background = Color(0xFFE9EBF2);
  static const card = Color(0xFFEEF0F6);
  static const purple = Color(0xFF6667FF);
  static const ink = Color(0xFF303344);
  static const muted = Color(0xFF707383);

  final TextEditingController _packNameController =
    TextEditingController();

  List<String> _checklistItems = [];

  @override
  void dispose() {
    _packNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 50),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 20),
                  _progress(),
                  const SizedBox(height: 28),
                  _packInfo(),
                  const SizedBox(height: 28),
                  _requirements(),
                  const SizedBox(height: 25),
                  _continueButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        _circleButton(
          Icons.arrow_back_ios_new_rounded,
          () => Navigator.pop(context),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Document Pack Builder',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _circleButton(
          Icons.more_vert,
          () => _message('More pack options will be connected later.'),
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
            Icons.person_outline,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _progress() {
    return _surface(
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                '● Step 1 of 4',
                style: TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                'Enter Requirements',
                style: TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _step('1', 'Requisite', true),
              _line(false),
              _step('2', 'Matches', false),
              _line(false),
              _step('3', 'Gaps', false),
              _line(false),
              _step('4', 'Export', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _packInfo() {
  return _surface(
    child: Row(
      children: [
        const Icon(
          Icons.folder_copy_outlined,
          color: purple,
          size: 28,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NEW DOCUMENT PACK',
                style: TextStyle(
                  color: purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _packNameController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  color: ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter pack name',
                  hintStyle: TextStyle(color: muted),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


Future<void> _selectRequirementsPdf() async {
  try {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (!mounted || files.isEmpty) return;

    final file = files.first;

    if (!file.name.toLowerCase().endsWith('.pdf')) {
      _message('Please select a PDF file.');
      return;
    }

    // Keep the existing working PDF preview.
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(file: file),
      ),
    );

    if (!mounted) return;

    // Read the same selected PDF for text extraction.
    final bytes = await file.readAsBytes();

    if (!mounted) return;

    final extractedText =
        await PdfChecklistService().extractText(bytes);

    if (!mounted) return;

    final reviewController = TextEditingController(
      text: extractedText,
    );

    try {
      final approvedText = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Review PDF Requirements'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: TextField(
                  controller: reviewController,
                  maxLines: 12,
                  minLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Edit extracted requirements',
                    helperText:
                        'Keep one document requirement per line.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  reviewController.text,
                ),
                child: const Text('Add to Checklist'),
              ),
            ],
          );
        },
      );

      if (!mounted || approvedText == null) return;

      final newItems = approvedText
          .split(RegExp(r'\r?\n'))
          .map(
            (line) => line
                .trim()
                .replaceFirst(
                  RegExp(r'^(?:[-*•]\s*|\d+[.)]\s*)'),
                  '',
                )
                .trim(),
          )
          .where((line) => line.isNotEmpty)
          .toList();

      final combined = List<String>.from(_checklistItems);
      final existing = combined
          .map((item) => item.toLowerCase())
          .toSet();

      for (final item in newItems) {
        if (existing.add(item.toLowerCase())) {
          combined.add(item);
        }
      }

      setState(() {
        _checklistItems = combined;
      });

      _message('PDF requirements added. Review your checklist.');
    } finally {
      reviewController.dispose();
    }
  } catch (error) {
    if (!mounted) return;

    _message(
      'Unable to extract PDF text. Try a text-based PDF.',
    );
  }
}


  Widget _requirements() {
    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What documents are required?',
            style: TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Upload a checklist or enter the required documents manually.',
            style: TextStyle(
              color: muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),

          InkWell(
            onTap: _selectRequirementsPdf,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F6),
                borderRadius: BorderRadius.circular(25),
                boxShadow: _shadow(),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.upload_file_outlined,
                    color: purple,
                    size: 34,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Upload Requirements Checklist',
                    style: TextStyle(
                      color: purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'PDF files only',
                    style: TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'OR',
              style: TextStyle(
                color: muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F6),
              borderRadius: BorderRadius.circular(24),
              boxShadow: _shadow(),
            ),
            child: DocumentRequirementsEditor(
              requirements: _checklistItems,
              onChanged: (updated) {
                setState(() {
                  _checklistItems = updated;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _continueButton() {
    return InkWell(
      onTap: () {
        final packName = _packNameController.text.trim();

        if (packName.isEmpty) {
          _message('Please enter a pack name.');
          return;
        }

        if (_checklistItems.isEmpty) {
          _message('Please add at least one document requirement.');
          return;
        }

        final pack = DocumentPack(
          name: packName,
          requirements: [
            for (var index = 0; index < _checklistItems.length; index++)
              DocumentRequirement(
                id: 'requirement_${index + 1}',
                name: _checklistItems[index],
              ),
          ],
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentPackMatchesScreen(pack: pack),
          ),
        );
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F6),
          borderRadius: BorderRadius.circular(30),
          boxShadow: _shadow(),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Find Vault Matches',
              style: TextStyle(
                color: purple,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_rounded,
              color: purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(String number, String label, bool active) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? purple : const Color(0xFFF1F2F7),
              boxShadow: _shadow(),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: active ? Colors.white : muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? purple : muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(bool active) {
    return Container(
      width: 18,
      height: 3,
      color: active ? purple : const Color(0xFFD7D9E4),
    );
  }

  Widget _surface({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _shadow(),
      ),
      child: child,
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF0F1F6),
          boxShadow: _shadow(),
        ),
        child: Icon(icon, color: ink),
      ),
    );
  }

  List<BoxShadow> _shadow() {
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

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}