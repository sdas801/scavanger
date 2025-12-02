import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/pages/subcriptions/subcriptionList.dart';

void freePlan(BuildContext context, dynamic subcriptionCheck) {
  final Map<String, dynamic> data = subcriptionCheck is Map<String, dynamic>
      ? subcriptionCheck
      : jsonDecode(jsonEncode(subcriptionCheck));

  final String planName = data['name'] ?? 'Unknown Plan';
  final String description = data['description'] ?? 'No description available';
  final String price = data['price_monthly'] != null
      ? '\$${data['price_monthly']} / month'
      : 'Free';
  final int maxHunts = data['max_hunts'] ?? "";
  final int maxChallenges = data['max_challenges'] ?? 0;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  // Logo with crown and hexagon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.teal[400],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.hexagon,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const Positioned(
                        top: 0,
                        child: Icon(
                          Icons.brightness_auto,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Plan name text (dynamic)
                  Text(
                    planName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  // Price text (dynamic)
                  // Text(
                  //   "  subcriptionCheck?.price ?? 'Free'",
                  //   style: TextStyle(
                  //     fontSize: 28,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.indigo[900],
                  //   ),
                  // ),
                  const SizedBox(height: 12),
                  // Description text (dynamic)
                  Text(
                    data['description'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Feature list
                  // Column(
                  //   children: featureList
                  //       .map((feature) => _buildFeatureItem(feature))
                  //       .toList(),
                  // ),
                  // SizedBox(height: 24),
                  // Get Started button
                  // Row(
                  //   children: [
                  //     Text("muximum hunts"),
                  //     _buildFeatureItem(data['max_hunts']),
                  //   ],
                  // ),
                  _buildFeatureItem("Maximum hunts", data['max_hunts']),
                  _buildFeatureItem(
                      "Maximum quest", data['max_challenges']),
                  _buildFeatureItem(
                      "Maximum hunt items", data['max_hunt_items']),
                  _buildFeatureItem(
                      "Maximum hunt teams", data['max_hunt_teams']),
                  _buildFeatureItem(
                      "Maximum quest Items", data['max_challenge_items']),
                  _buildFeatureItem(
                      "Maximum Created Items", data['max_created_items']),
                  _buildFeatureItem(
                      "Maximum Purchased items", data['max_purchased_items']),
                  _buildFeatureItem("Video Available for Download",
                      "${data['video_available']} day"),
                  _buildFeatureItem("Relaunch Available",
                      data['is_relaunch'] == 1 ? "Yes" : "No"),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Get Started For Free'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
                      minimumSize: Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Close icon at top right
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildFeatureItem(String field, text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check,
            size: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$field: ${(text == null) ? 'No Limit' : text}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        )
      ],
    ),
  );
}
