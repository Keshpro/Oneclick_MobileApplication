import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'smart_upload_review_screen.dart';

class ScanUploadScreen extends StatefulWidget {
  const ScanUploadScreen({super.key});

  @override
  State<ScanUploadScreen> createState() => _ScanUploadScreenState();
}

class _ScanUploadScreenState extends State<ScanUploadScreen> {
  static const Color _background = Color(0xFFE9EBF2);
  static const Color _purple = Color(0xFF6961FF);
  static const Color _ink = Color(0xFF303344);
  static const Color _muted = Color(0xFF686C7C);

  String? _selectedFileName;

Future<void> _chooseFile() async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  );

  if (result.isEmpty) return;

  final file = result.first;

  setState(() {
    _selectedFileName = file.name;
  });
}
  void _openCamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Camera scanning will be available on the mobile version.',
        ),
      ),
    );
  }

  void _continueToReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SmartUploadReviewScreen(
  title: 'Scanned Document',
  recordType: 'Document',
  category: 'Other',
  renewalDate: DateTime.now(),
  expiryNotification: false,
  notes: '',
  tags: const [],
  selectedFile: null,
),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: _ink,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan & Upload',
          style: TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add a document to your Vault',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan a physical document or upload an existing file. '
                    'OneClick will prepare it for Smart Review.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Camera option
                  _UploadOption(
                    icon: Icons.document_scanner_outlined,
                    title: 'Scan with Camera',
                    subtitle:
                        'Capture IDs, receipts, certificates and other documents.',
                    buttonText: 'Open Camera',
                    onPressed: _openCamera,
                  ),

                  const SizedBox(height: 16),

                  // File upload option
                  _UploadOption(
                    icon: Icons.upload_file_rounded,
                    title: 'Upload from Device',
                    subtitle:
                        'Choose a PDF, JPG or PNG already saved on your device.',
                    buttonText: 'Choose File',
                    onPressed: _chooseFile,
                  ),

                  if (_selectedFileName != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _purple.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: _purple.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: _purple,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ready for review',
                                  style: TextStyle(
                                    color: _ink,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedFileName!,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: _purple,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _purple.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: _purple,
                          size: 21,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Smart Review can help identify document details '
                            'before you save the record to your Vault.',
                            style: TextStyle(
                              color: _muted,
                              height: 1.45,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _selectedFileName == null
                          ? null
                          : _continueToReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            _purple.withValues(alpha: 0.25),
                        disabledForegroundColor: Colors.white70,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: const Text(
                        'Continue to Smart Review',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Center(
                    child: Text(
                      'Supported formats: PDF, JPG, JPEG and PNG',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  const _UploadOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6961FF);
    const ink = Color(0xFF303344);
    const muted = Color(0xFF686C7C);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: purple,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: purple,
              side: BorderSide(
                color: purple.withValues(alpha: 0.30),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}