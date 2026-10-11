import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfPreviewScreen extends StatelessWidget {
  final PlatformFile file;

  const PdfPreviewScreen({
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          file.name,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder(
        future: file.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to open PDF: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final bytes = snapshot.data;

          if (bytes == null || bytes.isEmpty) {
            return const Center(
              child: Text('No PDF data available.'),
            );
          }

          return SfPdfViewer.memory(bytes);
        },
      ),
    );
  }
}