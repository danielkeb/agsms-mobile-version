import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/rendering.dart';
import 'package:abgsms/authmanager.dart'; // Import AuthManager

class StudentCertificate extends StatefulWidget {
  @override
  _StudentCertificateState createState() => _StudentCertificateState();
}

class _StudentCertificateState extends State<StudentCertificate> {
  Map<String, dynamic>? studentData;

  final GlobalKey<State<StatefulWidget>> containerKey = GlobalKey();


  List<int> secondSemesterSubjectAverages = [];
  int firstSemesterTotal = 0;
  int secondSemesterTotal = 0;
  int secondSemesterTotalAverage = 0;
  int rank = 0;


  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> _logout() async {
    final AuthManager authManager = AuthManager();
    authManager.clearToken(); // Clear token from local storage

    // Navigate to login page
    Navigator.pushReplacementNamed(context, 'login'); // Replace '/login' with your actual login page route
  }


  Future<void> fetchData() async {
    try {
      final AuthManager authManager = AuthManager();
      await authManager.fetchToken();

      final String? token = authManager.token;
      final Map<String, dynamic>? decodedToken = authManager.decodedToken;

      if (token != null && decodedToken != null) {
        final response = await http.get(
          Uri.parse('http://localhost:3333/students/get/${decodedToken['sub']}'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            studentData = data;
          });
        } else {
          throw Exception('Failed to fetch student data');
        }
      } else {
        throw Exception('Token not found');
      }
    } catch (error) {
      print('Error fetching student data: $error');
    }
  }

  Future<Uint8List> generateCertificate() async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text(
            'Certificate',
            style: pw.TextStyle(fontSize: 24),
          ),
        );
      },
    ));

    return pdf.save();
  }

  Future<void> printCertificate() async {
    final RenderRepaintBoundary boundary =
        containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    Printing.layoutPdf(
      onLayout: (_) async => await _generatePdf(pngBytes),
    );
  }

  Future<Uint8List> _generatePdf(Uint8List pngBytes) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Image(
          pw.MemoryImage(pngBytes),
          width: 500,
        );
      },
    ));

    return pdf.save();
  }



  Future<Uint8List?> _captureCertificate() async {
    try {
      final RenderRepaintBoundary boundary =
          containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (error) {
      print('Error capturing certificate: $error');
      return null;
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Center(child: Text('Result card')),
    backgroundColor: Colors.blueGrey,
    actions: [
          PopupMenuButton(
            onSelected: (value) {
              // Handle menu item selection
              if (value == 'logout') {
                _logout(); // Call logout function when 'logout' is selected
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: RepaintBoundary(
          key: containerKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (studentData != null) ...[
                Text(
                  '${studentData?['school_name'] ?? ''} school',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Grade ${studentData?['grade']['grade'] ?? ''} student card',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Student Name: ${studentData?['first_name'] ?? ''} ${studentData?['last_name'] ?? ''}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Number')),
                      DataColumn(label: Text('Subject')),
                      DataColumn(label: Text('First Semester')),
                      DataColumn(label: Text('Second Semester')),
                      DataColumn(label: Text('Average Score (Semester Two)')),
                    ],
                    rows: List.generate(
                      studentData?['grade']['subject'].length ?? 0,
                      (index) {
                        final subject = studentData?['grade']['subject'][index];
                        final totalScore1 = studentData?['results']
                            .firstWhere(
                              (result) => result['subjectId'] == subject['id'],
                              orElse: () => {'totalScore1': 0},
                            )['totalScore1'];
                        final totalScore2 = studentData?['results']
                            .firstWhere(
                              (result) => result['subjectId'] == subject['id'],
                              orElse: () => {'totalScore2': 0},
                            )['totalScore2'];
                        final averageScore =
                            (totalScore1 + totalScore2) / 2;
                        return DataRow(cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text('${subject['name']}')),
                          DataCell(Text('$totalScore1')),
                          DataCell(Text('$totalScore2')),
                          DataCell(Text('$averageScore')),
                        ]);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Total Score: $firstSemesterTotal (First Semester) | $secondSemesterTotal (Second Semester)',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Overall Average Score (Semester Two): $secondSemesterTotalAverage',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: printCertificate,
                child: Text('Download PDF'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}