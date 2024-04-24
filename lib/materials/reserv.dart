import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'course.dart'; // Import CourseMaterials class

class PdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String description;

  PdfViewer({required this.pdfUrl, required this.description});

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  String? localPath;

  @override
  void initState() {
    super.initState();

    // Load PDF from the provided URL
    loadPDF();
  }

  Future<void> loadPDF() async {
    try {
      final value = await MaterialService.loadPDF(widget.pdfUrl);
      setState(() {
        localPath = value;
      });
    } catch (error) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.description),
      ),
      body: localPath != null
          ? PDFView(
              filePath: localPath!,
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
