import 'package:flutter/material.dart';
import 'package:scavenger_app/login_screen.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'custom_textfield.dart';

class ResertPassword extends StatefulWidget {
  final int userId;
  final String email;

  const ResertPassword({super.key, required this.userId, required this.email});

  @override
  _ResertPasswordState createState() => _ResertPasswordState();
}

class _ResertPasswordState extends State<ResertPassword> {
  final TextEditingController _newpasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _resetPassword(context) async {
    final String newPassword = _newpasswordController.text;
    final String password = _passwordController.text;
    final RegExp passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).+$',
    );
    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter New Password !'),
      ));
      return;
    } else if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Password should be alphanumeric with minimum 6 characters and must contain at least 1 upper case, 1 lower case, 1 numeric, 1 special character.'),
      ));
      return;
    } else if ((!passwordRegex.hasMatch(newPassword))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Password should be alphanumeric with minimum 6 characters and must contain at least 1 upper case, 1 lower case, 1 numeric, 1 special character.'),
      ));
      return;
    } else if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter Confrim Password !'),
      ));
      return;
    } else if (newPassword != password) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('New Password & Confirm Password Not Matched'),
      ));
      return;
    }
    setState(() {
      _isLoading = true;
    });
    var reqData = {'password': password, "userId": widget.userId};
    print({">>>>>>>>>>reqData", reqData});
    ApiService.resetPassword(reqData).then((res) async {
      try {
        if (res.success) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
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
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Reset Password                                     ',
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
                const SizedBox(height: 0),
                // const Text(
                //   "If not signup yet, we'll redirect you to register page",
                //   textAlign: TextAlign.left,
                //   style: TextStyle(fontSize: 18, color: Color(0xFF82929D)),
                // ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _newpasswordController,
                  labelText: 'New Password',
                  hintText: 'Enter New Password',
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 1,
                  suffixIcon: const Tooltip(
                    message:
                        'Password must contain:\n• At least 6 characters\n• 1 uppercase\n• 1 lowercase\n• 1 number\n• 1 special character',
                    child: Icon(Icons.info_outline),
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Confrim Password',
                  hintText: 'Enter Confrim Password',
                  obscureText: true,
                  maxLines: 1,
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          // _login(context);
                          _resetPassword(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B00AB),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ), //_login,
                        child: const Text('Reset Password'),
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
