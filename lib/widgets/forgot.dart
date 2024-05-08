import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:abgsms/widgets/resetpassword.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late int _userId;
  ForgotFormState _formState = ForgotFormState.email;

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
              if (_formState == ForgotFormState.code)
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
                onPressed: () async {
                  if (_formState == ForgotFormState.email) {
                    final email = _emailController.text.trim();
                    final forgotPasswordService = ForgotPasswordService();
                    final response = await forgotPasswordService.sendForgotPasswordRequest(email);
                    if (response != null) {
                      _userId = response.userId;
                      setState(() {
                        _formState = ForgotFormState.code;
                      });
                    }
                  } else if (_formState == ForgotFormState.code) {
                    final code = _codeController.text.trim();
                    final shortcodeVerificationService = ShortcodeVerificationService(_userId, code);
                    final response = await shortcodeVerificationService.verifyShortcode();
                    if (response != null && response.statusCode == 200) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResetPassword(
                            id: _userId.toString(),
                          ),
                        ),
                      );
                    } else {
                      _showErrorSnackBar('Verification failed');
                    }
                  }
                },
                child: Text(_formState == ForgotFormState.email ? 'Send shortcode' : 'Verify Shortcode'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ForgotFormState { email, code }

class ForgotPasswordService {
  Future<ForgotPasswordResponse?> sendForgotPasswordRequest(String email) async {
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
        return ForgotPasswordResponse.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}

class ShortcodeVerificationService {
  final int userId;
  final String code;

  ShortcodeVerificationService(this.userId, this.code);

  Future<http.Response?> verifyShortcode() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3333/verify/shortcode?userId=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'shortcode': code,
        }),
      );

      return response;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}

class ForgotPasswordResponse {
  final int userId;
  final String message;
  final int statusCode;

  ForgotPasswordResponse({
    required this.userId,
    required this.message,
    required this.statusCode,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      userId: json['userId'],
      message: json['message'],
      statusCode: json['statuscode'],
    );
  }
}
