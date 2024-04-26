// import 'package:abgsms/materials/reserv.dart';
import 'package:abgsms/materials/reserv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MaterialService {
  static Future<List<dynamic>> fetchMaterials(String filter) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3333/coursematerial/get'));
      List<dynamic> allMaterials = jsonDecode(response.body);

      List<dynamic> filteredMaterials = allMaterials;

      if (filter.trim()!= "") {
        filteredMaterials = filteredMaterials.where((material) =>
            material['description']?.toLowerCase()?.contains(filter.toLowerCase())?? false ||
            material['gradeLevel']?.any((grade) => grade['grade'] == filter)?? false ||
            material['gradeLevel']?.any((grade) =>
                grade['subject']?.any((subject) => subject['name']?.toLowerCase() == filter.toLowerCase())?? false)?? false).toList();
      }

      return filteredMaterials;
    } catch (error) {
      throw Exception("Error fetching materials: $error");
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
      filter = value?? "";
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
  Future<void> _handleOpenMaterial(String filename, String description) async {
  final url = 'http://localhost:3333/$filename';
  final response = await http.get(Uri.parse(url));
  final contentType = response.headers['content-type'];
  final data = response.bodyBytes;

  if (contentType == 'application/pdf') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PdfViewer(data: data, description: description,)),
    );
  } else {
    throw Exception('Invalid content type: $contentType');
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
                    title: Text(material['description']?? ''),
                    onTap: () {
                      if (material['file']!= null) {
                        _handleOpenMaterial(material['file'], material['description']);
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