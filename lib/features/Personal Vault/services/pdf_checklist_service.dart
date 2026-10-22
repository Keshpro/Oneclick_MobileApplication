
import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfChecklistService {
  Future<String> extractText(Uint8List bytes) async {
    if (bytes.isEmpty) {
      throw Exception('The selected PDF is empty.');
    }

    PdfDocument? document;

    try {
      document = PdfDocument(inputBytes: bytes);

      final text = PdfTextExtractor(document).extractText().trim();

      if (text.isEmpty) {
        throw Exception(
          'No selectable text was found in this PDF. '
          'Scanned documents may require OCR.',
        );
      }

      return text;
    } finally {
      document?.dispose();
    }
  }
}
