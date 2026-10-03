import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'food_application_status_screen.dart';

class FoodVerificationScreen extends StatefulWidget {
  const FoodVerificationScreen({super.key});

  @override
  State<FoodVerificationScreen> createState() => _FoodVerificationScreenState();
}

class _FoodVerificationScreenState extends State<FoodVerificationScreen> {
  PlatformFile? identityDocument;
  PlatformFile? businessRegistration;
  PlatformFile? foodPermit;

  // Pick a document from the device
  Future<void> pickDocument(String documentType) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    // User cancelled the file picker
    if (file == null) {
      return;
    }

    // Save the selected file
    setState(() {
      if (documentType == 'identity') {
        identityDocument = file;
      } else if (documentType == 'business') {
        businessRegistration = file;
      } else if (documentType == 'permit') {
        foodPermit = file;
      }
    });

    // Show confirmation
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${file.name} selected.')));
  }

  // Submit the seller application
  void submitForVerification() {
    // Required documents
    if (identityDocument == null || businessRegistration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add the required documents.')),
      );
      return;
    }

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Application Submitted'),
          content: const Text(
            'Your seller application has been submitted for verification.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FoodApplicationStatusScreen(),
                  ),
                );
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Verification')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title
            const Text(
              'Verify Your Business',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              'Please provide the required documents so we can verify your seller account.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 28),

            // Identity Document
            _DocumentCard(
              title: 'Identity Document',
              description: 'NIC or another accepted identity document',
              file: identityDocument,
              requiredDocument: true,
              onUpload: () => pickDocument('identity'),
            ),

            const SizedBox(height: 14),

            // Business Registration
            _DocumentCard(
              title: 'Business Registration',
              description: 'Business Registration / BR document',
              file: businessRegistration,
              requiredDocument: true,
              onUpload: () => pickDocument('business'),
            ),

            const SizedBox(height: 14),

            // Food / Business Permit
            _DocumentCard(
              title: 'Food / Business Permit',
              description: 'Relevant permit or supporting certificate',
              file: foodPermit,
              requiredDocument: false,
              onUpload: () => pickDocument('permit'),
            ),

            const SizedBox(height: 30),

            // Information box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.blue.shade700),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Your documents will be reviewed by the Oneclick admin team before your seller account is approved.',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: submitForVerification,
                child: const Text(
                  'Submit for Verification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// DOCUMENT CARD
// ------------------------------------------------------------

class _DocumentCard extends StatelessWidget {
  final String title;
  final String description;
  final PlatformFile? file;
  final bool requiredDocument;
  final VoidCallback onUpload;

  const _DocumentCard({
    required this.title,
    required this.description,
    required this.file,
    required this.requiredDocument,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final uploaded = file != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: uploaded ? Colors.green.shade300 : Colors.grey.shade200,
        ),
      ),

      child: Row(
        children: [
          // Document icon
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: uploaded ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              uploaded
                  ? Icons.check_circle_rounded
                  : Icons.description_outlined,
              color: uploaded ? Colors.green : Colors.grey.shade700,
            ),
          ),

          const SizedBox(width: 14),

          // Document information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    // Required star
                    if (requiredDocument)
                      const Text(
                        ' *',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                // File name or description
                Text(
                  uploaded ? file!.name : description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: uploaded
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Add / Change button
          TextButton(
            onPressed: onUpload,
            child: Text(uploaded ? 'Change' : 'Add'),
          ),
        ],
      ),
    );
  }
}
