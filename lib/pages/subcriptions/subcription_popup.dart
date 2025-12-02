import 'package:flutter/material.dart';
import 'package:scavenger_app/pages/subcriptions/subcriptionList.dart';

void showSubscriptionModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 400,
            height: 550,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        "No subscription plan",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Get access to exclusive features with a subscription.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        decoration: const BoxDecoration(
                          // border: Border.all(
                          //   color: const Color.fromRGBO(
                          //       11, 0, 171, 1), // Set your border color here
                          //   width: 3, // Adjust the border thickness
                          // ),
                          // borderRadius: BorderRadius.circular(
                          //     20), // Same as ClipRRect for smooth edges
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            'https://krestomatio.com/images/subscription-plans.png',
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.2), // Shadow color
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(
                                    0, 4), // Shadow position (bottom shadow)
                              ),
                            ],
                          ),
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const Subcription()));
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color.fromRGBO(
                                    11, 0, 171, 1), // Border color
                                width: 1,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors
                                  .white, // Ensure the button background is white
                            ),
                            child: const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromRGBO(11, 0, 171, 1),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                  ),
                ),
              ],
            ),
          ));
    },
  );
}
