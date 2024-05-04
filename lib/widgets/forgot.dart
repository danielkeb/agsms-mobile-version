import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailacontroller =TextEditingController();
  Future<void> forgotPass(BuildContext context) async {
    String email =_emailacontroller.text.trim();
    try{
    final response = await http.post(
      Uri.parse('http://localhost:3333/auth/signin'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
   
      
    }
    }catch (e) {}

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset password'),),
      body: Center(
        child: TextFormField(
          controller: _emailacontroller,
          autofocus: true, decoration: InputDecoration(hintText: 'Email or phone number'),validator: (value) {
          if(value == null || value.isEmpty){
            return 'please enter a valid email or phone number';
          
          }
          else if(!value.contains('@')){
            return 'please enter a valid email';
          }
          return null; 

            
          }
        ),
      ),
    );
  }
}