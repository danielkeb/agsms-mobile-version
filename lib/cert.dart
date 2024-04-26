import 'dart:typed_data';
import 'dart:ui';
//import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:abgsms/authmanager.dart'; // Import AuthManager

class StudentCertificate extends StatefulWidget {
  @override
  _StudentCertificateState createState() => _StudentCertificateState();
}

class _StudentCertificateState extends State<StudentCertificate> {
  Map<String, dynamic>? studentData;
  List<int> secondSemesterSubjectAverages = [];
  int firstSemesterTotal = 0;
  int secondSemesterTotal = 0;
  int secondSemesterTotalAverage = 0;
  int rank = 0;

  final GlobalKey<State<StatefulWidget>> containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchData();
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

void downloadCertificate() async {
  final certificate = await _captureCertificate();
  if (certificate != null) {
    final pdf = pw.Document();

    // Create a Uint8ListImage from the certificate bytes
    final imageProvider = pw.MemoryImage(certificate);

    // Add certificate content to the PDF document
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Column(
            children: [
              pw.Text('Certificate', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              // Use Uint8ListImage
              pw.Image(imageProvider),
            ],
          ),
        ),
      ),
    );

    // Save PDF bytes
    final pdfBytes = await pdf.save();

    // Create a Blob from PDF bytes
    final blob = html.Blob([pdfBytes], 'application/pdf');

    // Create object URL from Blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element to trigger download
    final anchor = html.AnchorElement(href: url)
      ..style.display = 'none'
      ..download = 'certificate.pdf';

    // Add anchor element to body and click it programmatically
    html.document.body!.children.add(anchor);
    anchor.click();

    // Remove anchor element from body and revoke object URL
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
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
    appBar: AppBar(title: Center(child: Text('Result card')),backgroundColor: Colors.blueGrey,),
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
                onPressed: downloadCertificate,
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