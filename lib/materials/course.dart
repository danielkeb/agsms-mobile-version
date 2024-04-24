import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import './reserv.dart'; // Import PdfViewer class

class MaterialService {
  static Future<List<dynamic>> fetchMaterials(String filter) async {
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

      return filteredMaterials;
    } catch (error) {
      throw Exception("Error fetching materials: $error");
    }
  }

  static Future<String> loadPDF(String url) async {
    try {
      var response = await http.get(Uri.parse(url));

      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/data.pdf");
      await file.writeAsBytes(response.bodyBytes, flush: true);
      return file.path;
    } catch (error) {
      throw Exception("Error loading PDF: $error");
    }
  }
}

class CourseMaterials extends StatefulWidget {
  const CourseMaterials({Key? key}) : super(key: key);

  @override
  State<CourseMaterials> createState() => _CourseMaterialsState();
}

class _CourseMaterialsState extends State<CourseMaterials> {
  List<dynamic> materials = [];
  String filter = "";

  void handleFilterChange(String? value) {
    setState(() {
      filter = value ?? "";
    });
    fetchMaterials();
  }

  Future<void> fetchMaterials() async {
    try {
      List<dynamic> fetchedMaterials = await MaterialService.fetchMaterials(filter);
      setState(() {
        materials = fetchedMaterials;
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

  Future<void> loadPDF(String? filename) async {
    if (filename == null) {
      // Handle the case where filename is null
      print("filename is null");
      return;
    }

    try {
      String localPath = await MaterialService.loadPDF('http://localhost:3333/$filename');
      print(localPath);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PdfViewer(pdfUrl: localPath, description: '')),
      );
    } catch (error) {
      throw new Exception('not found');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMaterials();
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
              onTap: () {
                if (material['filename'] != null) {
                  loadPDF(material['file']);
                } else {
                  print('filename is null');
                }
              },
            );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}