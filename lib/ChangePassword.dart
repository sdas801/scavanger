import 'package:flutter/material.dart';
import 'package:scavenger_app/ChangePasswordResponse.dart';
import 'package:scavenger_app/login_screen.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'custom_textfield.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
  final String userId;

  const ChangePassword({super.key, required this.userId});
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
    });

    final String password = _passwordController.text;
    final String confirmpassword = _confirmpasswordController.text;

    var reqData = {
      "userId": widget.userId,
      "password": password,
      "confirmPassword": confirmpassword
    };
    ApiService.changePassword(reqData).then((value) {
       try {
      if (value.success) {
        // final changepasswordResponse =
        //     ChangePasswordResponse.fromJson(value.response);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed: ${value.message}'),
        ));
      }
        } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(236, 247, 248, 252),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/1 1.png', // Update the image asset accordingly
                  height: 100,
                  alignment: Alignment.topLeft,
                ),
                const SizedBox(height: 80),
                const Text(
                  'New Password',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 1, 31, 81)),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Enter new password',
                  hintText: 'Enter password',
                  obscureText: true,
                  maxLines: 1,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _confirmpasswordController,
                  labelText: 'Confirm Password',
                  hintText: 'Enter confirm Password',
                  obscureText: true,
                  maxLines: 1,
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          if (_passwordController.text.isNotEmpty &&
                              _confirmpasswordController.text.isNotEmpty) {
                            _changePassword();
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Please enter data'),
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B00AB),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Send'),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
