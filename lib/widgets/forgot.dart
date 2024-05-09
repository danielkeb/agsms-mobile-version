import 'dart:convert';
import 'package:abgsms/widgets/shorcode.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;// Assuming the correct import for the Shortcode widget

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> sendForgotPasswordRequest(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3333/auth/forget/shortcode'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final userId = responseData['userId'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Shortcode(userId: userId),
          ),
        );
      } else {
        final responseData = json.decode(response.body);
        //final userId = responseData['userId'];
        _showErrorSnackBar('Failed to send reset code'+ responseData);
      }
    } catch (e) {
      print('Error: $e');
      _showErrorSnackBar('Failed to send reset code');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Center(
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                child: TextFormField(
                  controller: _emailController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Email or phone number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email or phone number';
                    } else if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_emailController.text.isNotEmpty) {
                    sendForgotPasswordRequest(_emailController.text);
                  } else {
                    _showErrorSnackBar('Please enter an email or phone number');
                  }
                },
                child: Text('Send Reset Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
