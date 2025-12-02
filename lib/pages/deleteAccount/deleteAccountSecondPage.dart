import 'package:flutter/material.dart';
import 'package:scavenger_app/pages/deleteAccount/confrimDeleteDialog.dart';
import 'package:scavenger_app/pages/deleteAccount/successfullyDelete.dart';

class DeleteProfileConfirmationScreen extends StatefulWidget {
  final String reason;
  const DeleteProfileConfirmationScreen({Key? key, required this.reason})
      : super(key: key);

  @override
  _DeleteProfileConfirmationScreenState createState() =>
      _DeleteProfileConfirmationScreenState();
}

class _DeleteProfileConfirmationScreenState
    extends State<DeleteProfileConfirmationScreen> {
  bool _sendDataToEmail = false;
  void initState() {
    super.initState();
    print({widget.reason});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // title: const Text(
        //   'Delete profile',
        //   style: TextStyle(
        //     color: Colors.black,
        //     fontWeight: FontWeight.bold,
        //     fontSize: 20,
        //   ),
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delete Account',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Are you sure you want to delete your account? This action is irreversible, and all your data will be permanently lost. If you’re experiencing issues, we’d love to help—please reach out to our support team before proceeding",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Container(
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.grey.shade300),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: CheckboxListTile(
            //     value: _sendDataToEmail,
            //     onChanged: (value) {
            //       setState(() {
            //         _sendDataToEmail = value ?? false;
            //       });
            //     },
            //     title: const Text(
            //       'Yes,I want to Delete My Account',
            //       style: TextStyle(
            //         fontSize: 16,
            //         color: Colors.black87,
            //       ),
            //     ),
            //     controlAffinity: ListTileControlAffinity.leading,
            //     contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            //     activeColor: const Color.fromRGBO(11, 0, 171, 1),
            //   ),
            // ),
            // const Spacer(),
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  showDeleteConfirmation(context, widget.reason);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'CONFIRM DELETION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You will permanently lose all your movies, contacts, messages, and profile info. After this, there\'s no turning back.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
