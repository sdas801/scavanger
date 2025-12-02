import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scavenger_app/pages/subcriptions/subcriptionList.dart';

void showCurrentPlanAlertDialog(
    BuildContext context, dynamic subcriptionCheck, String massage) {
  final Map<String, dynamic> data = subcriptionCheck is Map<String, dynamic>
      ? subcriptionCheck
      : jsonDecode(jsonEncode(subcriptionCheck));
  print(data);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Plan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                height: 1,
                color: const Color(0xFF0000D6),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  massage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(221, 207, 17, 17),
                  ),
                ),
              ),
              // Blue progress line
              // Container(
              //   height: 4,
              //   width: 180,
              //   margin: const EdgeInsets.only(left: 24, top: 0),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFF0000D6),
              //     borderRadius: BorderRadius.circular(2),
              //   ),
              // ),
              const SizedBox(height: 20),
              // Basic plan with icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      data['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Price
              // const Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 24),
              //   child: Row(
              //     children: [
              //       Text(
              //         '\$9.99',
              //         style: TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       Text(
              //         '/month',
              //         style: TextStyle(
              //           fontSize: 16,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 12),
              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  data['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Features heading
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Feature list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeatureItem(
                        "Maximum hunts", data['max_hunts'].toString()),
                    _buildFeatureItem("Maximum challenges",
                        data['max_challenges'].toString()),
                    _buildFeatureItem("Maximum hunt items",
                        data['max_hunt_items'].toString()),
                    _buildFeatureItem("Maximum chellenge items",
                        data['max_challenge_items'].toString()),
                    _buildFeatureItem(
                        "Maximum Created Items", data['max_created_items']),
                    _buildFeatureItem("Maximum Purchased items",
                        data['max_purchased_items'].toString()),
                    _buildFeatureItem("Video Available for Download",
                        "${data['video_available'] == null ? 'No limit' : data['video_available']} day"),
                    _buildFeatureItem("Relaunch Available",
                        data['is_relaunch'] == 1 ? "Yes" : "No"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Update plan button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Subcription()));
                      // Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0000D6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Upgrade your plan',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildFeatureItem(String field, text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          "$field :",
          style: const TextStyle(
            color: Color.fromARGB(255, 3, 3, 3),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            " ${(text == 'null') ? 'No Limit' : text}",
            softWrap: true,
            style: const TextStyle(
              color: Color.fromARGB(255, 2, 2, 2),
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}
