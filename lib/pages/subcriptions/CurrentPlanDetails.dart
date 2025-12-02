import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/pages/subcriptions/purcheseHistory.dart';
import 'package:scavenger_app/pages/subcriptions/subcriptionList.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  const SubscriptionDetailsScreen({super.key});

  @override
  _SubscriptionDetailsScreenState createState() =>
      _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  String currentPlanName = "";
  String description = "";
  dynamic maxHunt = "";
  dynamic maxchallenge = "";
  dynamic maxhuntItem = "";
  dynamic maxChallangeItem = "";
  dynamic maxtHuntTeam = "";
  dynamic maxcreatedItem = "";
  dynamic maxparchedItems = "";
  dynamic videoAbaliable = "";
  int relaunchAbalable = 0;
  String createdDate = "";
  String endDate = "";
  dynamic startDate = "";
  dynamic expiryDate = "";
  bool isExpire = false;
  int isrenew = 0;
  @override
  void initState() {
    super.initState();
    getSubcriptionDetails();
  }

  String? formatDate1(String? dateStr) {
    if (dateStr == null) return null;
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat("MMM d, yyyy").format(date);
    } catch (e) {
      return null; // Return null for invalid date formats
    }
  }

  String formatDate(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    return DateFormat("MMM d, yyyy h:mm a").format(dateTime);
  }

  void getSubcriptionDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    PolicyResult? tempSubcriptionCheckNo;
    if (subcriptionCheckString != null && subcriptionCheckString.isNotEmpty) {
      try {
        Map<String, dynamic> decodedJson = jsonDecode(subcriptionCheckString);
        tempSubcriptionCheckNo = PolicyResult.fromJson(decodedJson);
        print({">>>>>>>>", tempSubcriptionCheckNo});
        setState(() {
          currentPlanName = tempSubcriptionCheckNo!.name;
          description = tempSubcriptionCheckNo.description!;
          maxHunt = tempSubcriptionCheckNo!.maxHunts;
          maxchallenge = tempSubcriptionCheckNo!.maxChallenges;
          maxhuntItem = tempSubcriptionCheckNo.maxHuntItems;
          maxChallangeItem = tempSubcriptionCheckNo!.maxChallengeItems;
          maxtHuntTeam = tempSubcriptionCheckNo!.maxHuntTeams;
          maxcreatedItem = tempSubcriptionCheckNo!.maxCreatedItems;
          maxparchedItems = tempSubcriptionCheckNo!.maxPurchasedItems;
          videoAbaliable = tempSubcriptionCheckNo!.video_available;
          relaunchAbalable = tempSubcriptionCheckNo!.isRelaunch;
          createdDate = formatDate(tempSubcriptionCheckNo.createdTime);
          endDate = formatDate(tempSubcriptionCheckNo!.endTime);
          startDate = formatDate1(tempSubcriptionCheckNo.startDate);
          expiryDate = formatDate1(tempSubcriptionCheckNo!.expiryDate);
          isrenew = tempSubcriptionCheckNo.is_renew!;
        });
      } catch (e) {
        tempSubcriptionCheckNo = null;
        setState(() {
          isExpire = true;
        });
      }
    } else {
      print({subcriptionCheckString});
      // setState(() {
      //   isExpire = true;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a237e),
        title: const Text(
          'Current Plan details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: isExpire
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        "assets/images/detailsCard.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Badge and basic plan
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.workspace_premium,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Your Subcription plan is already expried", // Placeholder
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 247, 1, 1),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),

                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Subcription()));
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Upgrade Now',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SubscriptionHistoryPage()));
                              },
                              child: const Text(
                                'Purchase History',
                                style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          "assets/images/detailsCard.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Background image placeholder
                      // Positioned.fill(
                      //   child: Container(
                      //     color: Colors.blueGrey, // Placeholder for background image
                      //   ),
                      // ),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Badge and basic plan
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.workspace_premium,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    currentPlanName, // Placeholder
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),

                            const SizedBox(height: 16),

                            // Description placeholder
                            Text(
                              description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Features section
                            const Text(
                              'Features',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Feature list placeholder
                            _buildFeatureItem(
                                maxHunt.toString(), "Maximum hunt "),
                            _buildFeatureItem(
                                maxchallenge.toString(), "Maximum quest"),
                            _buildFeatureItem(
                                maxhuntItem.toString(), "Maximum hunt item"),
                            _buildFeatureItem(maxChallangeItem.toString(),
                                "Maximum quest item"),
                            _buildFeatureItem(
                                maxtHuntTeam.toString(), "Maximum hunt teams"),
                            _buildFeatureItem(maxcreatedItem.toString(),
                                "Maximum created teams"),
                            _buildFeatureItem(maxparchedItems.toString(),
                                "Maximum purchased items"),
                            _buildFeatureItem(
                                "${videoAbaliable} ${videoAbaliable == 1 ? "day" : "days"}",
                                "Video available for download"),
                            _buildFeatureItem(
                                "${relaunchAbalable == "0" ? "No Available" : "Available"} ",
                                "Realaunch Available"),
                            _buildFeatureItem(
                                createdDate.toString(), "Created Date"),
                            _buildFeatureItem(
                                endDate.toString(), "Updated Date"),
                            _buildFeatureItem(
                                startDate.toString(), "Purchesed Date"),
                            _buildFeatureItem(
                                expiryDate.toString(), "Expiry Date"),
                            isrenew == 1
                                ? Text(
                                    "   Your plan auto-renews on ${expiryDate}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 207, 13, 13),
                                    ),
                                  )
                                : SizedBox(),

                            const SizedBox(height: 24),

                            // Subscribe button placeholder
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Subcription()));
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Upgrade Now',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.black,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SubscriptionHistoryPage()));
                                },
                                child: const Text(
                                  'Purchase History',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.blue),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFeatureItem(String text, String field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            field,
            style: const TextStyle(
              color: Colors.white,
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
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
