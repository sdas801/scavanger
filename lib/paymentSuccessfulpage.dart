import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scavenger_app/MyTeamResponse.dart';
import 'package:scavenger_app/services/api.service.dart';

class PaymentSuccesfullPage extends StatefulWidget {
  // final int gameId;
  const PaymentSuccesfullPage({
    super.key,
  });

  @override
  _PaymentSuccessfullPage createState() => _PaymentSuccessfullPage();
}

class _PaymentSuccessfullPage extends State<PaymentSuccesfullPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0xFF6ED782), // Outer green circle
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Colors.white, // Inner white circle
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check, // Checkmark icon
                        color: Color(0xFF6ED782),
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Payment Successful!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your payment has been processed successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 90),
              // Continue Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                ),
                child: const Text(
                  "Back to dashboard",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
