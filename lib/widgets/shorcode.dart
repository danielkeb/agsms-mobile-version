import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:abgsms/widgets/resetpassword.dart';

class Shortcode extends StatefulWidget {
  final int userId;

  Shortcode({required this.userId});

  @override
  State<Shortcode> createState() => _ShortcodeState();
}

class _ShortcodeState extends State<Shortcode> {
  http.Response? _verificationResponse;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  Future<void> _verifyShortcode() async {
    if (!_formKey.currentState!.validate()) return;
    final code = _codeController.text.trim();
    try {
      final response = await _makeVerifyShortcodeRequest(code, widget.userId);
      _handleSuccessResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<http.Response> _makeVerifyShortcodeRequest(String code, int userId) async {
    final uri = Uri.parse('http://localhost:3333/verify/shortcode?userId=$userId');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final body = jsonEncode(<String, String>{
      'shortcode': code,
    });

    return await http.post(uri, headers: headers, body: body);
  }

  void _handleSuccessResponse(http.Response response) {
    setState(() {
      _verificationResponse = response;
    });
  }

  void _handleError(Object error) {
    _showErrorSnackBar('Error: ${error.toString()}');
    setState(() {
      _verificationResponse = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
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
          ElevatedButton(
            onPressed: _verifyShortcode,
            child: Text('Verify'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationResult() {
    if (_verificationResponse!= null && _verificationResponse!.statusCode == 200) {
      return TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPassword(id: widget.userId.toString()),
            ),
          );
        },
        child: Text('Verify'),
      );
    } else if (_verificationResponse!= null) {
      return Text('Verification failed');
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Short code verification'),
      ),
      body: Container(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildForm(),
            _buildVerificationResult(),
          ],
        ),
      ),
    );
  }
}