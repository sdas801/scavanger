import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'login_screen.dart'; // Import the login screen
import 'custom_textfield.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final TextEditingController _mobilenoController = TextEditingController();

  bool _isLoading = false;

  bool _showPassword = false;
  bool _showCPassword = false;


  Future<void> _signup() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String fullname = _nameController.text;
    final String confirmpassword = _confirmpasswordController.text;
    final String mobile = _mobilenoController.text;
    // final RegExp nameRegExp =
    //     RegExp(r'^[A-Za-z]{2,}\s[A-Za-z]{2,}(\s[A-Za-z]{2,})?$');

    if (fullname.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter the name",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }
    if (mobile.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter the phone no",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }
    // if (!nameRegExp.hasMatch(fullname)) {
    //   Fluttertoast.showToast(
    //     msg: "Enter a valid full name",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     backgroundColor: Colors.black,
    //     textColor: Colors.white,
    //     fontSize: 14.0,
    //   );
    //   return;
    // }
    if (email.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter the email",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    } else if (RegExp(
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
            .hasMatch(email) ==
        false) {
      Fluttertoast.showToast(
        msg: "Please enter a valid email",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      return;
    }
    if (password.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter the password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    if (password.length < 6) {
      Fluttertoast.showToast(
        msg:
            "Password should be alphanumeric with minimum 6 characters and must contain at least 1 upper case, 1 lower case, 1 numeric, 1 special character.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    final RegExp passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).+$',
    );

    if (!passwordRegex.hasMatch(password)) {
      Fluttertoast.showToast(
        msg:
            "Password should be alphanumeric with minimum 6 characters and must contain at least 1 upper case, 1 lower case, 1 numeric, 1 special character.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }
    if (confirmpassword.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter the confirm password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }
    if (password != confirmpassword) {
      Fluttertoast.showToast(
        msg: "Password and Confirm Password do not match",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var reqData = {
      "name": fullname,
      "username": email,
      "email": email,
      "phone": mobile,
      "password": password,
      "confirmPassword": confirmpassword,
      "country": "",
      "state": "",
      "city": "Kolkata",
      "address": "",
      "pincode": ""
    };

    ApiService.signUp(reqData).then((res) async {
      try {
        if (res.success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res.message),
          ));
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('data add failed: ${res.message}'),
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
                const SizedBox(height: 40),
                const Text(
                  'Join with us                                            ',
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF153792)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Create you account with us!                            ',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xFF82929D),
                    fontSize: 18,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w400,
                    height: 0.09,
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  hintText: 'Enter your name',
                  maxLines: 1,
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  ],
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _mobilenoController,
                  labelText: 'Phone Number',
                  hintText: 'Enter your mobile',
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        10), // Set max length to 10
                  ],
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 1,
                ),
                const SizedBox(height: 10),
                // const CustomTextField(
                //   labelText: 'Location',
                //   hintText: 'Enter your location',
                //   maxLines: 1,
                // ),
                // const SizedBox(height: 10),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  obscureText: !_showPassword,
                  maxLines: 1,
                  suffixIcon: Tooltip(
                    message:
                        'Password must contain:\n• At least 6 characters\n• 1 uppercase\n• 1 lowercase\n• 1 number\n• 1 special character',
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      child: Icon( _showPassword ? Icons.visibility : Icons.visibility_off)
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _confirmpasswordController,
                  labelText: 'Confirm Password',
                  hintText: 'Enter your password',
                  obscureText: !_showCPassword,
                  maxLines: 1,
                  suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          _showCPassword = !_showCPassword;
                        });
                      },
                      child: Icon( _showCPassword ? Icons.visibility : Icons.visibility_off)
                    ),
                ),
                const SizedBox(height: 10),
                // Row(
                //   children: [
                //     Checkbox(
                //       value: true, // Update this value as needed
                //       onChanged: (newValue) {
                //         // Handle checkbox change
                //       },
                //     ),
                //     const Text(
                //       'Allow Face Id',
                //       style: TextStyle(
                //           color: Color(0xFF153792),
                //           fontSize: 16,
                //           fontFamily: 'Jost',
                //           fontWeight: FontWeight.w500,
                //           height: 0.06),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          // Handle register action
                          // if (_emailController.text.isNotEmpty &&
                          //     _passwordController.text.isNotEmpty &&
                          //     _confirmpasswordController.text.isNotEmpty &&
                          //     _nameController.text.isNotEmpty &&
                          //     _mobilenoController.text.isNotEmpty) {
                          _signup();
                          // } else {
                          //   ScaffoldMessenger.of(context)
                          //       .showSnackBar(const SnackBar(
                          //     content: Text('Please enter data'),
                          //   ));
                          // }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B00AB),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Register'),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already Registered?'),
                    TextButton(
                      onPressed: () {
                        // Handle login action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 4, 218, 229),
                      ),
                      child: const Text('Login'),
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
