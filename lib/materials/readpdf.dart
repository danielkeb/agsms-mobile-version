import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ReadingMaterialsPage extends StatefulWidget {
  const ReadingMaterialsPage({Key? key}) : super(key: key);

  @override
  State<ReadingMaterialsPage> createState() => _ReadingMaterialsPageState();
}

class _ReadingMaterialsPageState extends State<ReadingMaterialsPage> {
  List<dynamic> materials = [];
  String filter = "";
  String? selectedGrade; // Updated to allow null value
  String selectedSubject = "";
  String pdfUrl = '';
  late PDFViewController pdfController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMaterials();
  }

  Future<void> fetchMaterials() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3333/coursematerial/get'));
      if (response.statusCode == 200) {
        List<dynamic> allMaterials = jsonDecode(response.body);

        List<dynamic> filteredMaterials = allMaterials;

        if (filter.trim() != "") {
          filteredMaterials = filteredMaterials.where((material) =>
              material['description'].toLowerCase().contains(filter.toLowerCase())).toList();
        }

        if (selectedGrade != null && selectedGrade != "") {
          filteredMaterials = filteredMaterials.where((material) =>
              material['gradeLevel'].any((grade) => grade['grade'] == selectedGrade)).toList();
        }

        if (selectedSubject != "") {
          filteredMaterials = filteredMaterials.where((material) =>
              material['gradeLevel'].any((grade) =>
                  grade['subject'].any((subject) => subject['name'].toLowerCase() == selectedSubject.toLowerCase()))).toList();
        }

        setState(() {
          materials = filteredMaterials;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load materials');
      }
    } catch (error) {
      print("Error fetching materials: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleFilterChange(String value) {
    setState(() {
      filter = value;
    });
    fetchMaterials();
  }

  void handleGradeChange(String? value) {
    setState(() {
      selectedGrade = value;
    });
    fetchMaterials();
  }

  void handleSubjectChange(String? value) {
    setState(() {
      selectedSubject = value ?? "";
    });
    fetchMaterials();
  }

  void handleOpenMaterial(String filename) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reading Materials"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : materials.isEmpty
              ? Center(child: Text('No course materials available'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text("courses"),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Filter by keyword (e.g., description)',
                              ),
                              onChanged: handleFilterChange,
                            ),
                          ),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            value: selectedGrade ?? '', // Use an empty string as the default value if selectedGrade is null
                            hint: Text('Select grade'),
                            onChanged: handleGradeChange,
                            items: <String>['12', '11', '10']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text('Grade $value'),
                              );
                            }).toList(),
                          ),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            value: selectedSubject,
                            hint: Text('Select subject'),
                            onChanged: handleSubjectChange,
                            items: <String>[
                              'Chemistry',
                              'Mathematics'
                            ]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: materials.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: Icon(Icons.book),
                            title: Text(materials[index]['description']),
                            onTap: () =>
                                handleOpenMaterial(materials[index]['file']),
                          );
                        },
                      ),
                    ),
                    if (pdfUrl != '')
                      Container(
                        height: 400,
                        child: Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () {
                                setState(() {
                                  pdfUrl = '';
                                });
                              },
                            ),
                            Expanded(
                              child: PDFView(
                                filePath: pdfUrl,
                                enableSwipe: true,
                                swipeHorizontal: true,
                                autoSpacing: false,
                                pageFling: false,
                                onError: (error) {
                                  print(error.toString());
                                },
                                onPageError: (page, error) {
                                  print('$page: ${error.toString()}');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ReadingMaterialsPage(),
  ));
}
