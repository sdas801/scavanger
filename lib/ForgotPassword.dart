import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:scavenger_app/ResetPassword.dart';
import 'package:scavenger_app/forgotPassword_response.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/signup_screen.dart';
import 'custom_textfield.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;

  bool _isLoading = false;
  bool otpCheck = false;
  int userId = 0;
  String Email = "";

  Future<void> _verifyOTP() async {
    final String otp = textEditingController.text;
    if (otp.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your Otp !'),
      ));
      return;
    }

    final String Email = _emailController.text;
    // final String userId = userId;
    ApiService.verifyOtp({"userId": userId, 'email': Email, "otp": otp})
        .then((value) {
      if (value.success) {
        // final otpverifyResponse = VerifyOtpResponse.fromJson(value.response);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('email fetch successful!'),
        ));
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResertPassword(
                    userId: userId,
                    email: Email,
                  )),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed: ${value.message}'),
        ));
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _forgotPassword(context) async {
    final String email = _emailController.text;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your Email !'),
      ));
      return;
    }
    setState(() {
      _isLoading = true;
    });

    ApiService.forgotPassword({'email': email}).then((res) async {
      try {
        if (res.success) {
          final forgotPasswordResponse = Result.fromJson(res.response);
          setState(() {
            otpCheck = true;
            Email = _emailController.text;
            userId = forgotPasswordResponse.id;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('email fetch successful!'),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Login failed: ${res.message}'),
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
      backgroundColor: const Color.fromARGB(235, 255, 255, 255),
      body: Container(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_Screen.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'assets/images/1 1.png', // Update the image asset accordingly
                    height: 120,
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(height: 30),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: !otpCheck
                            ? 'Forgot Password                     '
                            : 'Verify Otp                         ',
                        style: const TextStyle(
                          color: Color(0xFF153792),
                          fontSize: 34,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w800,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                !otpCheck
                    ? CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Enter your Email',
                        keyboardType: TextInputType.emailAddress,
                        maxLines: 1,
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 20),
                // CustomTextField(
                //   controller: _passwordController,
                //   labelText: 'Password',
                //   hintText: 'Enter your Password',
                //   obscureText: true,
                //   maxLines: 1,
                // ),
                otpCheck
                    ? const Text(
                        "We sent a 6-digit code to your email",
                        textAlign: TextAlign.left,
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF82929D)),
                      )
                    : const SizedBox
                        .shrink(), // or 'null' if you prefer it to return nothing on false

                // const SizedBox(height: 10),
                otpCheck
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 40, left: 20, right: 20),
                        child: PinCodeTextField(
                          appContext: context,
                          length: 6,
                          obscureText: false,
                          animationType: AnimationType.fade,
                          autoDisposeControllers: false,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.circle,
                            borderRadius: BorderRadius.circular(2),
                            fieldHeight: 40,
                            fieldWidth: 40,
                            activeFillColor: Colors.white,
                            activeColor: Colors.blue,
                            selectedColor: Colors.blue,
                            inactiveColor:
                                const Color.fromARGB(255, 93, 45, 204),
                            inactiveFillColor: Colors.white,
                            selectedFillColor:
                                const Color.fromARGB(255, 250, 251, 252),
                          ),
                          animationDuration: const Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          enableActiveFill: true,
                          errorAnimationController: errorController,
                          controller: textEditingController,
                          onCompleted: (v) {},
                          onChanged: (value) {
                            setState(() {
                              // currentText = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            return true;
                          },
                        ),
                      )
                    : const SizedBox.shrink(),

                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          otpCheck
                              ?
                              // Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             const ResertPassword()))
                              _verifyOTP()
                              : _forgotPassword(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B00AB),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ), //_login,
                        child: otpCheck
                            ? const Text('verify')
                            : const Text('Send'),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not yet Registered?'),
                    TextButton(
                      onPressed: () {
                        // Handle login action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 4, 218, 229),
                      ),
                      child: const Text('Signup'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
