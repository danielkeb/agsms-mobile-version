import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'login.dart';
import 'widgets/about.dart';
import 'materials/course.dart';
import 'landing.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Initialize path_provider and return a Future
  Future<void> initPathProvider() async {
    WidgetsFlutterBinding.ensureInitialized();
    await getApplicationDocumentsDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initPathProvider(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while waiting for initialization
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          // Once initialization is complete, return the MaterialApp
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            routes: {
              '/load': (context) => Landing(),
              'login': (context) => LoginPage(),
              '/about': (context) => About(),
              '/material': (context) => CourseMaterials(),
            },
            home: Landing(),
          );
        }
      },
    );
  }
}
