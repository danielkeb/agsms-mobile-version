import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class CourseMaterials extends StatefulWidget {
  const CourseMaterials({Key? key}) : super(key: key);

  @override
  State<CourseMaterials> createState() => _CourseMaterialsState();
}

class _CourseMaterialsState extends State<CourseMaterials> {
  List<dynamic> materials = [];
  String filter = "";
  String pdfUrl = '';
  bool showPdf = false;

  @override
  void initState() {
    super.initState();
    fetchMaterials();
  }

  Future<void> fetchMaterials() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3333/coursematerial/get'));
      List<dynamic> allMaterials = jsonDecode(response.body);

      List<dynamic> filteredMaterials = allMaterials;

      if (filter.trim() != "") {
        filteredMaterials = filteredMaterials.where((material) =>
            material['description']?.toLowerCase()?.contains(filter.toLowerCase()) ?? false ||
            material['gradeLevel']?.any((grade) => grade['grade'] == filter) ?? false ||
            material['gradeLevel']?.any((grade) =>
                grade['subject']?.any((subject) => subject['name']?.toLowerCase() == filter.toLowerCase()) ?? false) ?? false).toList();
      }

      setState(() {
        materials = filteredMaterials;
      });
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Please start the server or check your network connection."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void handleFilterChange(String? value) {
    setState(() {
      filter = value ?? "";
    });
    fetchMaterials();
  }

  void handleOpenMaterial(String? filename) async {
    if(filename == null) return;
    setState(() {
      showPdf = true;
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:3333/$filename'));
      final pdfData = response.bodyBytes;
      setState(() {
        pdfUrl = 'data:application/pdf;base64,${base64Encode(pdfData)}';
      });
    } catch (error) {
      print("Error opening material: $error");
    }
  }

  void handleClosePdf() {
    setState(() {
      showPdf = false;
      pdfUrl = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Course Materials"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(30, 30, 15, 30),
                  child: Text('Courses'),
                ),
                Expanded(
                  child: Container(
                    child: TextField(
                            
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Filter by keyword (e.g., description, grade, subject)',
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: handleFilterChange,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final material = materials[index];
                  return ListTile(
                    leading: Icon(Icons.book),
                    title: Text(material['description'] ?? ''),
                    onTap: () => handleOpenMaterial(material['filename']),
                  );
                },
              ),
            ),
            if (showPdf)
              Expanded(
                child: PDFView(
                  filePath: pdfUrl,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: false,
                  onPageChanged: (page, totalPages) {
                    if (page == totalPages) {
                      handleClosePdf();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
