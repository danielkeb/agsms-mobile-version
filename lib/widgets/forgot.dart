import 'dart:convert';
import 'package:abgsms/widgets/resetpassword.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({required Key key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> forgotPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String code = _codeController.text.trim(); // Get the entered shortcode
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3333/auth/forget'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'email': email,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['shortcode'] == code) { // Check if shortcode is correct
            // Navigate to ResetPasswordPage with email and code parameters
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPassword(
                  email: email,
                  code: code, id: '', token: '',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Incorrect shortcode'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
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

  bool _codeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset password'),
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
                onPressed: () => forgotPassword(context),
                child: Text('Send Reset Link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
