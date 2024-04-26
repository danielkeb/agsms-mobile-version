import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewer extends StatefulWidget {
  final Uint8List data;
  final String description;

  const PdfViewer({Key? key, required this.data, required this.description}) : super(key: key);

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  late PdfController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfController(document: PdfDocument.openData(widget.data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.description),),
      body: PdfView(
        scrollDirection: Axis.vertical,
        controller: _controller,
      ),
    );
  }
}