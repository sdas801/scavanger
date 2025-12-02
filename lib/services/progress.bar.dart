import 'package:flutter/material.dart';

class progressBar extends StatelessWidget {
  const progressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: 70,
      child: CircularProgressIndicator(
        color:Color(0xFF153792),
        strokeWidth: 8.0,
      ),
    );
  }
}
