import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:abgsms/widgets/resetpassword.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key, });

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _codeEnabled = false;

  Future<void> forgotPassword(BuildContext context) async {
  if (_formKey.currentState!.validate()) {
    String email = _emailController.text.trim();
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

        setState(() {
          _codeEnabled = true; // Enable code input field
        });
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset link failed: Forbidden'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

Future<void> verifyshortcode(BuildContext context) async {
  if (_formKey.currentState!.validate()) {
    String code = _codeController.text.trim(); // Get the entered shortcode
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3333/verify/shortcode'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'shortcode': code, // Send the entered shortcode to verify
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response to get token and user ID
        final responseData = json.decode(response.body);
        String token = responseData['token'];
        String userId = responseData['id'];
        print("object token: " + token);
        print("object user ID: " + userId);
        // Redirect to ResetPasswordPage and pass token and user ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPassword(
              token: token,
              id: userId,
            ),
          ),
        );
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: Forbidden'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('forgot password'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
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
              SizedBox(height: 20),
              if (_codeEnabled)
                Container(
                  width: 300,
                  child: TextFormField(
                    
                    controller: _codeController,
                    decoration: InputDecoration(
                      hintText: 'Enter shortcode', 
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the shortcode';
                      }
                      return null;
                    },
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_codeEnabled) {
                    verifyshortcode(context);
                  } else {
                    forgotPassword(context);
                  }
                },
                child: Text(_codeEnabled ? 'Verify Shortcode' : 'Send shortcode'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
