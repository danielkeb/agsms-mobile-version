import 'dart:convert';
import 'package:abgsms/widgets/shorcode.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendForgotPasswordRequest(String email) async {
    try {
      final response = await _makeForgotPasswordRequest(email);
      final forgotPasswordResponse = _parseResponse(response);
      final userId = forgotPasswordResponse['userId'];
      _navigateToShortcodePage(userId);
    } catch (e) {
      _showErrorSnackBar('Failed to send reset code: $e');
    }
  }

  Future<http.Response> _makeForgotPasswordRequest(String email) async {
    final url = 'http://localhost:3333/auth/forget/shortcode';
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final body = jsonEncode(<String, String>{
      'email': email,
    });

    return http.post(Uri.parse(url), headers: headers, body: body);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send reset code: ${response.statusCode}');
    }
  }

  void _navigateToShortcodePage(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Shortcode(userId: userId),
      ),
    );
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
        backgroundColor: Colors.green,
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
                        
                        border: OutlineInputBorder(),
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
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () {
                  if (_emailController.text.isNotEmpty) {
                    _sendForgotPasswordRequest(_emailController.text);
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