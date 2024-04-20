import 'package:abgsms/landing.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'widgets/about.dart';
import 'widgets/material.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        routes:{
        '/load': (context) => Landing(),
        '/login': (context) => LoginPage(),
        '/about': (context) => About(),
        '/material': (context) => CourseMaterial(),
      },
        home: Landing(),
      ),
    );
