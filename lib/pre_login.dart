import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the login screen
import 'signup_screen.dart'; // Import the sign-up screen

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                              image: const AssetImage('assets/images/1 1.png'),
                              height: imageHeight,
                              width: imageWidth),
                          const Image(
                              image: AssetImage(
                                  'assets/images/WelcomeMessage.png')),
                          const SizedBox(height: 20),
                          const Image(
                              image:
                                  AssetImage('assets/images/landing_ico.png')),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              //  throw StateError('This is test exception');
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUpScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B00AB),
                              foregroundColor:
                                  const Color.fromRGBO(255, 255, 255, 1),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ), //_login,
                            child: const Text('Create Account',
                                style: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              foregroundColor:
                                  const Color.fromRGBO(21, 55, 146, 1),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ), //_login,
                            child: const Text('Sign In',
                                style: TextStyle(
                                    color: Color.fromRGBO(21, 55, 146, 1),
                                    fontWeight: FontWeight.w600)),
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
