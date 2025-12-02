import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scavenger_app/ChangePassword.dart';
import 'package:scavenger_app/VerifyOtpResponse.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'dart:convert';
import 'constants.dart';
import 'dart:async';
import 'package:pin_code_fields/pin_code_fields.dart';

class otpVerification extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
  final String email;
  final int userId;

  const otpVerification({super.key, required this.email, required this.userId});
}

class _VerificationScreenState extends State<otpVerification> {
  final TextEditingController _controller = TextEditingController();
  final int codeLength = 4;
  bool _isLoading = false;
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  bool hasError = false;
  String currentText = "";

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
    });

    final String otp = textEditingController.text;
    final String userId = '${widget.userId}';
    ApiService.sentOtp({"userId": userId, "otp": otp}).then((value) {
      if (value.success) {
        // final otpverifyResponse = VerifyOtpResponse.fromJson(value.response);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('email fetch successful!'),
        ));
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChangePassword(userId: userId)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/images/logo.jpg',
                height: 100, // Adjust height as needed
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Enter verification code',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Enter the 4-digit that we have sent to your email ID ${widget.email}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            //Row(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            PinCodeTextField(
              appContext: context,
              length: 4,
              obscureText: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                  shape: PinCodeFieldShape.circle,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  activeColor: Colors.blue,
                  selectedColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: const Color.fromARGB(255, 250, 251, 252)),
              animationDuration: const Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              enableActiveFill: true,
              errorAnimationController: errorController,
              controller: textEditingController,
              onCompleted: (v) {
                print("Completed");
              },
              onChanged: (value) {
                print(value);
                setState(() {
                  currentText = value;
                });
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                return true;
              },
            ),
            Text(
              hasError ? "*Please fill up all the cells properly" : "",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle continue button press
                print(textEditingController.text);
                setState(() {
                  if (currentText.length != 4) {
                    //|| currentText != "1234") {
                    errorController!.add(ErrorAnimationType.shake);
                    hasError = true;
                  } else {
                    hasError = false;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("otp Code Verified!"),
                    ));
                    _verifyOTP();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B00AB),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Verify'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Handle resend code button press
              },
              child: const Text('Resend code'),
            ),
          ],
        ),
      ),
    );
  }
}
