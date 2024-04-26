import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About"),
      backgroundColor: Color(0xFFA5D6A7),),
      body:Center(
        child: Text("About"),
      )
    );
  }
}