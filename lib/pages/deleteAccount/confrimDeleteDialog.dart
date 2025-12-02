import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scavenger_app/login_screen.dart';
import 'package:scavenger_app/pages/deleteAccount/successfullyDelete.dart';
import 'package:scavenger_app/services/api.service.dart';

class PasswordConfirmationAlertDialog extends StatelessWidget {
  static Future<String?> show(
    BuildContext context,
  ) async {
    final TextEditingController passwordController = TextEditingController();
    bool obscurePassword = true;

    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Confirm Delete',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Please enter your password to confirm account deletion.',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // suffixIcon: IconButton(
                        //   icon: Icon(
                        //     obscurePassword
                        //         ? Icons.visibility_off
                        //         : Icons.visibility,
                        //     color: Colors.grey,
                        //   ),
                        //   onPressed: () {
                        //     setState(() {
                        //       obscurePassword = !obscurePassword;
                        //     });
                        //   },
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (passwordController.text == "") {
                      Fluttertoast.showToast(
                        msg: "Enter your password",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity:
                            ToastGravity.CENTER, // Can be TOP, CENTER, BOTTOM
                        backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      Navigator.of(context).pop(passwordController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('CONFIRM DELETE'),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

void showDeleteConfirmation(BuildContext context, String reason) async {
  final password = await PasswordConfirmationAlertDialog.show(context);
  void deleteAccount() {
    ApiService.deleteAccount({"reason": reason, "password": password})
        .then((value) {
      try {
        if (value.success) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
          showSuccessDialog(
            context,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Wrong Password",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER, // Can be TOP, CENTER, BOTTOM
            backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {}
    });
  }

  if (password != null && password.isNotEmpty) {
    deleteAccount();
    print('Deleting account with password: $password');
    print('Deleting account with password: $reason');
  }
  //  else {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text("Enter your password"),
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }
}
