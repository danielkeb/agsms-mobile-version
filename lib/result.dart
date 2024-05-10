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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Result card')),
        backgroundColor: const Color.fromARGB(255, 103, 139, 96),
        actions: [
            PopupMenuButton(
              onSelected: (value) {
                // Handle menu item selection
                if (value == 'item1') {
                  // Do something for item 1
                } else if (value == 'item2') {
                  // Do something for item 2
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'item1',
                  child: Text('Help'),
                ),
                const PopupMenuItem(
                  value: 'item2',
                  child: Text('About'),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Grade ${studentData?['grade']['grade'] ?? ''} student card',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Student Name: ${studentData?['first_name'] ?? ''} ${studentData?['last_name'] ?? ''}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      dataRowHeight: 30,
                      columns: [
                        DataColumn(label: Text('Number', style: TextStyle(fontSize: 14))),
                        DataColumn(label: Text('Subject', style: TextStyle(fontSize: 14))),
                        DataColumn(label: Text('First Semester', style: TextStyle(fontSize: 14))),
                        DataColumn(label: Text('Second Semester', style: TextStyle(fontSize: 14))),
                        DataColumn(label: Text('Average Score (Semester Two)', style: TextStyle(fontSize: 14))),
                      ],
                      rows: List.generate(
                        studentData?['grade']['subject'].length ?? 0,
                        (index) {
                          final subject = studentData?['grade']['subject'][index];
                          final totalScore1 = studentData?['results']
                                  .firstWhere(
                                    (result) => result['subjectId'] == subject['id'],
                                    orElse: () => {'totalScore1': 0},
                                  )['totalScore1'] ??
                              0;
                          final totalScore2 = studentData?['results']
                                  .firstWhere(
                                    (result) => result['subjectId'] == subject['id'],
                                    orElse: () => {'totalScore2': 0},
                                  )['totalScore2'] ??
                              0;
                          final averageScore = (totalScore1 + totalScore2) / 2;
                          return DataRow(cells: [
                            DataCell(Text('${index + 1}', style: TextStyle(fontSize: 14))),
                            DataCell(Text('${subject['name']}', style: TextStyle(fontSize: 14))),
                            DataCell(Text('$totalScore1', style: TextStyle(fontSize: 14))),
                            DataCell(Text('$totalScore2', style: TextStyle(fontSize: 14))),
                            DataCell(Text('$averageScore', style: TextStyle(fontSize: 14))),
                          ]);
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      printCertificate();
    });
  }
}
