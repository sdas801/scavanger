import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'login_screen.dart'; // Import the login screen
import 'signup_screen.dart'; // Import the sign-up screen

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: LayoutBuilder(
        builder:(context, constraints) {
          var width = constraints.maxWidth;
          var height = constraints.maxHeight;
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
                        SizedBox(height: height * (5.55/100)),
                         Image(
                            image: const AssetImage('assets/images/1 1.png'),
                            height: height * (18/100),
                            width: width * (32/100)),
                        SizedBox(height: height * (3.13/100)),
                        const Image(
                            image: AssetImage('assets/images/WelcomeMessage.png')),
                        SizedBox(height: height * (3.13/100)),
                        const Image(
                            image: AssetImage('assets/images/landing_ico.png')),
                        SizedBox(height: height * (3.13/100)),
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
                            foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
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
                        SizedBox(height: height * (2.78 / 100)),
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
                            foregroundColor: const Color.fromRGBO(21, 55, 146, 1),
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
