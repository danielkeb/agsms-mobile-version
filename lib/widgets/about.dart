import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: const Color(0xFFA5D6A7),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
        children: <Widget>[
          Image(image: AssetImage('')),
          Text(
            "Welcome to our School Management System! This system is designed to streamline the management of our school's daily operations, including student enrollment, attendance tracking, grade management, and communication with parents. Our goal is to provide a user-friendly and efficient platform for our administrators, teachers, and students to access important information and resources. We hope you find this system helpful and easy to use.",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      ),
    );
  }
}