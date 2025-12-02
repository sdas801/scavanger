import 'package:flutter/material.dart';

class CircularIndicatorExample extends StatelessWidget {
  const CircularIndicatorExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circular Indicator'),
      ),
      body:const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(),
            ),
            SizedBox(height: 20.0),
            SizedBox(
              height: 100.0,
              width: 100.0,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}