import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the login screen
import 'signup_screen.dart'; // Import the sign-up screen

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: screenWidth,
        padding: const EdgeInsets.only(left: 30, right: 30),
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/bg_Screen.png'),
              fit: BoxFit.cover),
        ),
        child: SizedBox(
          width: screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 71),
              const Image(
                  image: AssetImage('assets/images/1 1.png'),
                  height: 117,
                  width: 117),
              const SizedBox(height: 40),
              const Image(
                  image: AssetImage('assets/images/WelcomeMessage.png')),
              const SizedBox(height: 40),
              const Image(image: AssetImage('assets/images/landing_ico.png')),
              const SizedBox(height: 40),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
    );
  }
}
