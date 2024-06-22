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

  List<dynamic> secondSemesterSubjectAverages = [];
  dynamic firstSemesterTotal = 0;
  dynamic secondSemesterTotal = 0;
  dynamic secondSemesterTotalAverage = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> _logout() async {
    final AuthManager authManager = AuthManager();
    authManager.clearToken(); // Clear token from local storage

    // Navigate to login page
    Navigator.pushReplacementNamed(context, '/load'); // Replace '/login page
  }

  Future<void> fetchData() async {
    try {
      final AuthManager authManager = AuthManager();
      await authManager.fetchToken();

      final String? token = authManager.token;
      final Map<String, dynamic>? decodedToken = authManager.decodedToken;
      //final String role= decodedToken.role;
  if (decodedToken != null && decodedToken['role'] != "student") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UnauthorizedPage()));
      return; // Exit the function to avoid further execution
    }
      else{

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
            calculateScoresAndRank();
          });
        } else {
          throw Exception('Failed to fetch student data');
        }
      } else {
        throw Exception('Token not found');
      }
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

  void calculateScoresAndRank() {
    if (studentData == null ||
        studentData!['results'] == null ||
        studentData!['grade'] == null ||
        studentData!['grade']['subject'] == null) return;

    // Calculate first semester total
    firstSemesterTotal = studentData!['results']
        .fold<dynamic>(0, (sum, result) => sum + (result['totalScore1'] ?? 0));

    // Calculate second semester total
    secondSemesterTotal = studentData!['results']
        .fold<dynamic>(0, (sum, result) => sum + (result['totalScore2'] ?? 0));

    // Calculate second semester averages
    secondSemesterSubjectAverages = studentData!['grade']['subject']
        .map<dynamic>((subject) {
      final subjectResults = studentData!['results']
          .where((result) => result['subjectId'] == subject['id']);
      final totalScore1 = subjectResults.fold<dynamic>(
          0, (sum, result) => sum + (result['totalScore1'] ?? 0));
      final totalScore2 = subjectResults.fold<dynamic>(
          0, (sum, result) => sum + (result['totalScore2'] ?? 0));
      return (totalScore1 + totalScore2) ~/ 2; // Integer division for average
    }).toList();

    // Calculate overall average for second semester
    secondSemesterTotalAverage = (firstSemesterTotal + secondSemesterTotal) ~/ 2;
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
    final hasRank = studentData?['firstrank'] != null || studentData?['secondtrank'] != null || studentData?['overallrank'] != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Result card')),
        backgroundColor: Colors.green,
        titleTextStyle:TextStyle(color: Colors.white),
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
                if (studentData != null && hasRank) ...[
                  Text(
                    '${studentData?['school_name'] ?? ''} School',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Grade ${studentData?['grade']['grade'] ?? ''} Student Card',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Student Name: ${studentData?['first_name'] ?? ''} ${studentData?['last_name'] ?? ''}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Subject')),
                        DataColumn(label: Text('1st')),
                        DataColumn(label: Text('2nd')),
                        DataColumn(label: Text('Average')),
                      ],
                      rows: List.generate(studentData?['grade']['subject']?.length ?? 0, (index) {
                        final subject = studentData!['grade']['subject'][index];
                        final totalScore1 = studentData!['results']
                            .firstWhere(
                              (result) => result['subjectId'] == subject['id'],
                              orElse: () => {'totalScore1': 0},
                            )['totalScore1'] ?? 0;
                        final totalScore2 = studentData!['results']
                            .firstWhere(
                              (result) => result['subjectId'] == subject['id'],
                              orElse: () => {'totalScore2': 0},
                            )['totalScore2'] ?? 0;
                        final averageScore = (totalScore1 + totalScore2) / 2;
                        return DataRow(cells: [
                          DataCell(Text('${subject['name']}')),
                          DataCell(Text('$totalScore1')),
                          DataCell(Text('$totalScore2')),
                          DataCell(Text('$averageScore')),
                        ]);
                      }),
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(thickness: 1.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: [
                          Text(
                            'Total Score',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '$firstSemesterTotal',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '$secondSemesterTotal',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '$secondSemesterTotalAverage',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Rank',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '${studentData?['firstrank'] ?? ''}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '${studentData?['secondtrank'] ?? ''}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '${studentData?['overallrank'] ?? ''}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  Center(
               child:  Column(
              children: [
                Container(
                  child: Image(
                    image: AssetImage('assets/images/clock.png'),
                    width: 200,
                    height: 200,
                  ),
                ),
                Text('No certificate Available')
              ],
              ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: hasRank
          ? FloatingActionButton(
              onPressed: printCertificate,
              child: Icon(Icons.save),
            )
          : null,
    );
  }
}

class UnauthorizedPage extends StatefulWidget {
  @override
  State<UnauthorizedPage> createState() => _UnauthorizedPageState();
}

class _UnauthorizedPageState extends State<UnauthorizedPage> {
    Future<void> _logout() async {
    final AuthManager authManager = AuthManager();
    authManager.clearToken(); // Clear token from local storage

    // Navigate to login page
    Navigator.pushReplacementNamed(context, '/load'); // Replace '/login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Unauthorized Access')),
        backgroundColor: Colors.red, 
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
        ],// Example color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/unauth.jpg', width: 200, height: 200,),
            Text(
              'You have no privilege to access this page',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}