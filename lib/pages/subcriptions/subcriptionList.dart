import 'dart:convert';
import 'dart:developer' show log;
// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/model/subcriptionList.modal.dart';
import 'package:scavenger_app/pages/subcriptions/cancelSubcription.dart';
import 'package:scavenger_app/pages/subcriptions/chooseSubcriptionPage.dart';
import 'package:scavenger_app/pages/subcriptions/planDetails.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Subcription extends StatefulWidget {
  const Subcription({Key? key}) : super(key: key);

  @override
  State<Subcription> createState() => _SubcriptionState();
}

class _SubcriptionState extends State<Subcription> {
  bool isMonthly = true;
  bool isMonthlyPlan = true;
  bool _isLoading = false;
  List<SubcriptionList> subcriptionListMonthly = [];
  List<SubcriptionList> subcriptionListYearly = [];
  PolicyResult? SubcriptionCheck;
  SubcriptionList? selectedPlan;
  List<SubcriptionList> filteredPlans = [];
  bool tabButtonCheck = false;

  @override
  void initState() {
    super.initState();
    getSubcriptionData();
    _getSubcriptionDetails();
  }

  Future<void> getSubcriptionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    if (subcriptionCheckString != null && subcriptionCheckString.isNotEmpty) {
      try {
        Map<String, dynamic>? decodedJson = jsonDecode(subcriptionCheckString);
        SubcriptionCheck =
            decodedJson != null ? PolicyResult.fromJson(decodedJson) : null;
      } catch (e) {
        SubcriptionCheck = null;
      }
    } else {
      SubcriptionCheck = null;
    }
  }

  Future<void> _getSubcriptionDetails() async {
    setState(() {
      _isLoading = true;
    });

    ApiService.getAllActiveSubscriptions().then((value) {
      try {
        if (value.success) {
          final homeResponse = List<SubcriptionList>.from(
            value.response.map((x) => SubcriptionList.fromJson(x)),
          );
          final monthlySubscriptions = homeResponse
              .where((sub) =>
                  sub.priceMonthly != null && sub.priceAnnually == null)
              .toList();
          final yearlySubscriptions = homeResponse
              .where((sub) =>
                  sub.priceAnnually != null && sub.priceMonthly == null)
              .toList();
          final bothSubscriptions = homeResponse
              .where((sub) =>
                  sub.priceMonthly != null && sub.priceAnnually != null)
              .toList();
          final freePlan = homeResponse
              .where((sub) =>
                  sub.priceMonthly == null && sub.priceAnnually == null)
              .toList();

          var monthlyArr = [
            ...monthlySubscriptions,
            ...yearlySubscriptions,
            ...bothSubscriptions,
            ...freePlan,
          ];

          if (SubcriptionCheck != null) {
            if (SubcriptionCheck!.planType == "M" ||
                SubcriptionCheck!.planType == null) {
              setState(() {
                isMonthly = true;
                isMonthlyPlan = true;
              });
            } else {
              setState(() {
                isMonthly = false;
                isMonthlyPlan = false;
              });
            }
          }

          setState(() {
            subcriptionListMonthly = monthlyArr;
          });

          setState(() {
            filteredPlans = subcriptionListMonthly
                .where((plan) =>
                    (isMonthly && plan.priceMonthly != null) ||
                    (!isMonthly && plan.priceAnnually != null ||
                        plan.priceAnnually == null &&
                            plan.priceMonthly == null))
                .toList();

            if (filteredPlans.isNotEmpty) {
              selectedPlan = filteredPlans.first;
            }
          });
        }
      } catch (error) {
        print("Error: $error");
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 25,
          ),
        ),
        title: const Text(
          'Subcriptions',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            // padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      _buildSectionHeader(
                        title: 'Choose the plan that\'s right for you',
                        description:
                            'Join StreamVibe and select from our flexible subscription options tailored to suit your viewing preferences.',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 220,
                            height: 60,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildToggleButton('Monthly', isMonthly),
                                _buildToggleButton('Yearly', !isMonthly)
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children:
                            subcriptionListMonthly.asMap().entries.map((entry) {
                          if (isMonthly && entry.value.priceMonthly != null) {
                            return _buildPlanCard(
                                entry.value, isMonthly, entry.key);
                          } else if (!isMonthly &&
                              entry.value.priceAnnually != null) {
                            return _buildPlanCard(
                                entry.value, isMonthly, entry.key);
                          } else if (entry.value.priceAnnually == null &&
                              entry.value.priceMonthly == null) {
                            return _buildPlanCard(
                                entry.value, isMonthly, entry.key);
                          } else if (entry.value.priceAnnually != null &&
                              entry.value.priceMonthly != null) {
                            return _buildPlanCard(
                                entry.value, isMonthly, entry.key);
                          } else {
                            return const SizedBox.shrink();
                          }
                        }).toList(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                //  =============================================================================================================================
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.indigo[900]!, // Deep color
                        const Color.fromARGB(
                            255, 251, 251, 252)!, // Lighter color
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      _buildSectionHeader1(
                        title: 'Choose the plan that\'s right for you',
                        description:
                            'Join StreamVibe and select from our flexible subscription options tailored to suit your viewing preferences. Get ready for non-stop entertainment!',
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 60,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: filteredPlans.length,
                                itemBuilder: (context, index) {
                                  final plan = filteredPlans[index];
                                  final isSelected =
                                      selectedPlan?.id == plan.id;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPlan = plan;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF0000A0)
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        plan.name,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      //
                      Container(
                          // height: 450,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9E3E3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: selectedPlan != null
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Price section
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Price',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                selectedPlan != null
                                                    ? (isMonthly
                                                        ? (selectedPlan!
                                                                    .priceMonthly !=
                                                                null
                                                            ? "\$${selectedPlan!.priceMonthly} / month"
                                                            : "N/A")
                                                        : (selectedPlan!
                                                                    .priceAnnually !=
                                                                null
                                                            ? "\$${selectedPlan!.priceAnnually} / year"
                                                            : "N/A"))
                                                    : "N/A",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            ],
                                          ),
                                          const SizedBox(width: 40),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Max Hunt Items',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                selectedPlan!.maxHuntItems
                                                        ?.toString() ??
                                                    "N/A",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),

                                      // Content section
                                      const TableSectionTitle(
                                          title: 'Description'),
                                      TableFeatureRow(
                                        description:
                                            selectedPlan!.description ?? '',
                                      ),
                                      const SizedBox(height: 16),
                                      TableTwoColumnRow(
                                        title: 'Max Hunt',
                                        value: selectedPlan!.maxHunts
                                                ?.toString() ??
                                            "N/A",
                                      ),
                                      const SizedBox(height: 16),
                                      TableTwoColumnRow(
                                        title: 'Max Quest',
                                        value: selectedPlan!.maxChallenge
                                                ?.toString() ??
                                            "N/A",
                                      ),
                                      const SizedBox(height: 16),
                                      TableTwoColumnRow(
                                        title: 'Max Hunt Items',
                                        value: selectedPlan!.maxHuntItems
                                                ?.toString() ??
                                            "N/A",
                                      ),
                                      const SizedBox(height: 16),
                                      // Devices section
                                      TableTwoColumnRow(
                                        title: 'Max Quest Items',
                                        value: selectedPlan!.maxChallengeItems
                                                ?.toString() ??
                                            "N/A",
                                      ),
                                      const SizedBox(height: 16),

                                      // Created Items
                                      TableTwoColumnRow(
                                        title: 'Max Created Items',
                                        value: selectedPlan!.maxCreatedItems
                                                ?.toString() ??
                                            "N/A",
                                      ),
                                      const SizedBox(height: 16),

                                      // Purchased Items
                                      TableTwoColumnRow(
                                        title: 'Max Purchased Items',
                                        value: selectedPlan!.maxPurchasedItems
                                                ?.toString() ??
                                            "No Limit",
                                      ),
                                      const SizedBox(height: 16),

                                      // Hunt Teams
                                      TableTwoColumnRow(
                                        title: 'Max Hunt Teams',
                                        value: selectedPlan!.maxHuntTeams
                                                ?.toString() ??
                                            "N/A",
                                      ),
                                      const SizedBox(height: 16),
                                      TableTwoColumnRow(
                                        title: 'Relaunch Available',
                                        value: selectedPlan!.isRelaunch == 0
                                            ? "No Available"
                                            : "Available"?.toString() ?? "N/A",
                                      ),
                                      const SizedBox(height: 16),
                                      TableTwoColumnRow(
                                        title: 'Video Available',
                                        value:
                                            '${selectedPlan!.videoAvailable.toString()} days',
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox()),
                      const SizedBox(height: 24),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubcriptionList d, bool isMonthly, int index) {
    final List<List<String>> images = [
      ["assets/images/basic.jpg", "assets/images/basic.jpg"],
      ["assets/images/standerd.jpg", "assets/images/detailsCard.png"],
      ["assets/images/premium.png", "assets/images/premium.png"]
    ];
    print("================1=========${SubcriptionCheck?.is_renew}");
    bool isCurrentPlan = false;
    bool isRenew = false;
    if (SubcriptionCheck != null) {
      isCurrentPlan = d.id == SubcriptionCheck!.id &&
          (isMonthlyPlan == isMonthly || SubcriptionCheck!.planType == null);
      if (SubcriptionCheck!.is_renew == 1) {
        isRenew = true;
      }
    } else {
      isCurrentPlan = false;
    }
    bool isMonthlyBuyCheck = false;
    if (SubcriptionCheck != null) {
      isMonthlyBuyCheck =
          d.id == SubcriptionCheck!.id && SubcriptionCheck!.planType == "Y";
    } else {
      isMonthlyBuyCheck = false;
    }

    // Alternate images based on the index
    String image = images[index % images.length][0];
    String detailsImage = images[index % images.length][1];

    return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Container(
          height: 210,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(image), // Use AssetImage, not Image.asset
              fit: BoxFit.cover, // Ensures the image covers the container
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 10, left: 20, right: 20, bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Center(
                          child: Column(
                        children: [
                          Image.asset(
                            'assets/images/Award.png',
                            fit: BoxFit.contain, // Adjust based on your needs
                            width: 80, // Optional: control image size
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            d.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 40,
                            child: isMonthly
                                ? Row(
                                    children: [
                                      d.priceMonthly != null
                                          ? Row(
                                              children: [
                                                Text(
                                                  "\$${d.priceMonthly?.toStringAsFixed(2) ?? '0.00'}",
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  "/ month",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox()
                                    ],
                                  )
                                : Row(
                                    children: [
                                      d.priceAnnually != null
                                          ? Row(
                                              children: [
                                                Text(
                                                  "\$${d.priceAnnually?.toStringAsFixed(2) ?? '0.00'}",
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  "/ year",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox()
                                    ],
                                  ),
                          ),
                          Container(
                            height: 40,
                            child: Align(
                              alignment: Alignment
                                  .centerLeft, // Align text to the start (left)
                              child: Text(
                                (d.description ?? '').length > 60
                                    ? '${d.description?.substring(0, 60)}...'
                                    : d.description ?? '',
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          d.name == "Free" || !isRenew
                              ? const SizedBox(
                                  height: 20,
                                )
                              : SizedBox(),
                          isCurrentPlan
                              ? const Text(
                                  "This is your current plan",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 250, 249, 248),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                )
                              : const SizedBox(),
                          const SizedBox(height: 32),
                          d.name == "Free"
                              ? SizedBox()
                              : isCurrentPlan
                                  // (SubcriptionCheck?.is_renew == 1)
                                  ? isRenew
                                      ? ElevatedButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (context) => Wrap(
                                                children: [
                                                  cancelSubcription(
                                                      id: d.id,
                                                      name: d.name,
                                                      description:
                                                          d.description ?? "",
                                                      price: isMonthly
                                                          ? d.priceMonthly
                                                                  ?.toStringAsFixed(
                                                                      2) ??
                                                              '0.00'
                                                          : d.priceAnnually
                                                                  ?.toStringAsFixed(
                                                                      2) ??
                                                              '0.00',
                                                      isMonthly: isMonthly,
                                                      maxHuntsTeam:
                                                          d.maxHuntTeams,
                                                      maxChallenges:
                                                          d.maxChallengeItems,
                                                      maxcreatedItem:
                                                          d.maxCreatedItems,
                                                      maxhuntitem:
                                                          d.maxHuntItems,
                                                      purchased:
                                                          d.maxPurchasedItems,
                                                      image: image,
                                                      maxHunts: d.maxHunts,
                                                      maxChallenge:
                                                          d.maxChallenge,
                                                      videoAvailable:
                                                          d.videoAvailable,
                                                      isRelaunch: d.isRelaunch,
                                                      stripe_id:
                                                          SubcriptionCheck!
                                                              .stripe_id,
                                                      endDate: SubcriptionCheck!
                                                          .expiryDate)
                                                ],
                                              ),
                                            ).whenComplete(() {
                                              print('completed');
                                              _getSubcriptionDetails();
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            backgroundColor: Colors.white,
                                            shadowColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Cancel Subcription',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      255,
                                                      218,
                                                      55,
                                                      55), // Text is black on white/gradient background
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 16,
                                                color: Color.fromARGB(
                                                    255, 218, 55, 55),
                                              )
                                            ],
                                          ),
                                        )
                                      : SizedBox()
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Plan Details Button (Blue)
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SubscriptionPlanCard(
                                                          plandata: d,
                                                          isMonthly: isMonthly,
                                                          isMonthlyBuyCheck:
                                                              isMonthlyBuyCheck,
                                                          detailsImage:
                                                              detailsImage,
                                                        )));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                                0xFF0000D6), // Deep blue color
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Text(
                                                'Plan Details',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 16), // Space between buttons
                                        d.name == "Free"
                                            ? const SizedBox()
                                            : isMonthlyBuyCheck
                                                ? const SizedBox()
                                                : Flexible(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          builder: (context) =>
                                                              Wrap(
                                                            children: [
                                                              ChooseSubcriptionPlan(
                                                                  id: d.id,
                                                                  name: d.name,
                                                                  description:
                                                                      d.description ??
                                                                          "",
                                                                  price: isMonthly
                                                                      ? d.priceMonthly?.toStringAsFixed(2) ??
                                                                          '0.00'
                                                                      : d.priceAnnually?.toStringAsFixed(
                                                                              2) ??
                                                                          '0.00',
                                                                  isMonthly:
                                                                      isMonthly,
                                                                  maxHuntsTeam: d
                                                                      .maxHuntTeams,
                                                                  maxChallenges: d
                                                                      .maxChallengeItems,
                                                                  maxcreatedItem: d
                                                                      .maxCreatedItems,
                                                                  maxhuntitem: d
                                                                      .maxHuntItems,
                                                                  purchased: d
                                                                      .maxPurchasedItems,
                                                                  image: image,
                                                                  maxHunts: d
                                                                      .maxHunts,
                                                                  maxChallenge: d
                                                                      .maxChallenge,
                                                                  videoAvailable: d
                                                                      .videoAvailable,
                                                                  isRelaunch: d
                                                                      .isRelaunch),
                                                            ],
                                                          ),
                                                        ).whenComplete(() {
                                                          print('completed');
                                                          _getSubcriptionDetails();
                                                        });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 6),
                                                        backgroundColor:
                                                            Colors.white,
                                                        shadowColor:
                                                            Colors.transparent,
                                                        foregroundColor:
                                                            Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: const Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: const [
                                                          Text(
                                                            'Buy Plan',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors
                                                                  .black, // Text is black on white/gradient background
                                                            ),
                                                          ),
                                                          SizedBox(width: 4),
                                                          Icon(
                                                              Icons
                                                                  .arrow_forward,
                                                              size: 16,
                                                              color:
                                                                  Colors.black),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                      ],
                                    ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isMonthly = text == 'Monthly';
        });
        filteredPlans = subcriptionListMonthly
            .where((plan) =>
                (isMonthly && plan.priceMonthly != null) ||
                (!isMonthly && plan.priceAnnually != null) ||
                (plan.priceMonthly == null && plan.priceAnnually == null))
            .toList();

        if (filteredPlans.isNotEmpty) {
          selectedPlan = filteredPlans.first; // Default to first item
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0000A0) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      {required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

Widget _buildSectionHeader1(
    {required String title, required String description}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.3,
        ),
      ),
      const SizedBox(height: 16.0),
      Text(
        description,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );
}

class TableSectionTitle extends StatelessWidget {
  final String title;

  const TableSectionTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class TableFeatureRow extends StatelessWidget {
  final String description;

  const TableFeatureRow({
    Key? key,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: const TextStyle(
        fontSize: 14,
      ),
    );
  }
}

class TableTwoColumnRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isMultiline;

  TableTwoColumnRow({
    Key? key,
    required this.title,
    required this.value,
    this.isMultiline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
