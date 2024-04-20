import 'package:flutter/material.dart';

class CourseMaterial extends StatelessWidget {
  const CourseMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course materials'),),
      body: Center(
        child: Text('Course materials'),
      )
    );
  }
}