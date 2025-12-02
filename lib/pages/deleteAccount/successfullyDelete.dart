import 'package:flutter/material.dart';
import 'package:scavenger_app/login_screen.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: const ContentBox(),
    );
  }
}

class ContentBox extends StatelessWidget {
  const ContentBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkmark icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.grey,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          // Title
          const Text(
            'Success!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 16),
          // Message
          Text(
            'Your account was successfully deleted. Fair well.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => {
                Navigator.of(context).pop(),
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF79CCEF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example of how to show the dialog
void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const SuccessDialog();
    },
  );
}
