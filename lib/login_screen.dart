import 'package:flutter/material.dart';
import 'package:scavenger_app/ForgotPassword.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/forgotPassword_response.dart';
import 'package:scavenger_app/otpVerification.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/signup_screen.dart';
import 'custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login(context) async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter email '),
      ));
      return;
    } else if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter password'),
      ));
      return;
    }
    setState(() {
      _isLoading = true;
    });
    var reqData = {
      'username': email,
      'password': password,
    };
    ApiService.logIn(reqData).then((res) async {
      try {
        if (res.success) {
          final loginResponse = LoginResult.fromJson(res.response);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('saved_userId', loginResponse.id);
          prefs.setString('saved_userName', loginResponse.name);
          prefs.setString('auth_token', loginResponse.token);
          print({">>>>>>>>>>>>>>>loginResponse.token", loginResponse.token});
          await prefs.setBool('isSubscriptionDataLoaded', false); // Reset flag
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Login successful!'),
          ));
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen(userName: loginResponse.name)));
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

  Future<void> _forgotPassword(context) async {
    setState(() {
      _isLoading = true;
    });
    final String email = _emailController.text;
    ApiService.forgotPassword({'email': email}).then((res) async {
      try {
        if (res.success) {
          final forgotPasswordResponse = Result.fromJson(res.response);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => otpVerification(
                    email: _emailController.text,
                    userId: forgotPasswordResponse.id)),
          );
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;
          final double imageWidth = width * 0.30;
          final double imageHeight = height * 0.25;

          return SafeArea(
            child: SizedBox.expand(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "assets/images/bg_Screen.png",
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                              image: const AssetImage('assets/images/1 1.png'),
                              height: imageHeight,
                              width: imageWidth),
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Welcome                                     ',
                                  style: TextStyle(
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
                          const Text(
                            "If not signup yet, we'll redirect you to register page",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 18, color: Color(0xFF82929D)),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'Enter your Email',
                            keyboardType: TextInputType.emailAddress,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _passwordController,
                            labelText: 'Password',
                            hintText: 'Enter your Password',
                            obscureText: true,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPassword()));
                                //   _forgotPassword(context);
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey),
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: () {
                                    _login(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0B00AB),
                                    foregroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ), //_login,
                                  child: const Text('Sign In'),
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
                                        builder: (context) =>
                                            const SignUpScreen()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      const Color.fromARGB(255, 4, 218, 229),
                                ),
                                child: const Text('Signup'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
