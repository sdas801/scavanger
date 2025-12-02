import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/model/payment.model.dart';
import 'package:scavenger_app/pages/subcriptions/subcriptionCheckout.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseSubcriptionPlan extends StatefulWidget {
  final int id;
  final String name;
  final String description;
  final dynamic price;
  final bool isMonthly;
  final dynamic maxHuntsTeam;
  final dynamic maxChallenges;
  final dynamic maxhuntitem;
  final dynamic maxcreatedItem;
  final dynamic purchased;
  final String image;
  final dynamic maxHunts;
  final dynamic maxChallenge;
  final dynamic videoAvailable;
  final int isRelaunch;

  const ChooseSubcriptionPlan(
      {super.key,
      required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.isMonthly,
      required this.maxHuntsTeam,
      required this.maxChallenges,
      required this.maxcreatedItem,
      required this.maxhuntitem,
      required this.purchased,
      required this.image,
      required this.maxHunts,
      required this.maxChallenge,
      required this.videoAvailable,
      required this.isRelaunch});

  @override
  _ChooseSubcriptionPlanState createState() => _ChooseSubcriptionPlanState();
}

class _ChooseSubcriptionPlanState extends State<ChooseSubcriptionPlan>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  int paymentId = 0;
  String premiumCheck = "";

  @override
  void initState() {
    super.initState();
    _getSubcriptionData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getSubcriptionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = (prefs.getInt('saved_userId') ?? 0);

    ApiService.getUserSubscriptions({"user_id": userid}).then((res) {
      try {
        if (res.success) {
          var subcriptionCheck =
              res.response != null ? PolicyResult.fromJson(res.response) : null;
          print({
            ">>>>>>>>>subcriptionCheck",
            jsonEncode(subcriptionCheck?.toJson())
          });
          if (subcriptionCheck != null) {
            String jsonString = jsonEncode(subcriptionCheck.toJson());
            prefs.setString('subscription_Check', jsonString);
            setState(() {
              premiumCheck = subcriptionCheck.name;
            });
          } else {
            prefs.setString('subscription_Check', 'null');
          }
          // bool isSubscriptionDataLoaded =
          //     prefs.getBool('isSubscriptionDataLoaded') ?? false;
          // if (isSubscriptionDataLoaded) return;
          // if (!isSubscriptionDataLoaded) {
          //   showModalSec(subcriptionCheck, res.response);
          //   isSubscriptionDataLoaded = true;
          //   prefs.setBool('isSubscriptionDataLoaded', true);
          // }
        }
      } catch (error) {
        // print(error);
      }
    });
  }

  Future<void> initiateIntent() async {
    var reData = {
      "subscription_id": widget.id,
      "plan_type": widget.isMonthly ? "M" : "Y"
    };
    ApiService.subcriptionIntent(reData).then((value) {
      if (value.success) {
        var res = PaymentIntentModel.fromJson(value.response);
        paymentId = res.paymentId;
        processPayment(res.clientSecret);
      }
    });
  }

  Future<void> processPayment(String clientSecret) async {
    setState(() {
      isLoading = true;
    });
    try {
      var result = await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.light,
          merchantDisplayName: 'Scavenger',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      paymentResponse("1");
    } catch (e) {
      paymentResponse("2");
    }
    setState(() {
      isLoading = false;
    });
  }

  void paymentResponse(String status) {
    var reqData = {
      "paymentId": paymentId,
      "status": status,
      "subscription_id": widget.id,
      "plan_type": widget.isMonthly ? "M" : "Y"
    };
    ApiService.subcriptionResponse(reqData).then((value) {
      if (status == "1") {
        // void _getSubcriptionData() async {
        //   SharedPreferences prefs = await SharedPreferences.getInstance();
        //   var userid = (prefs.getInt('saved_userId') ?? 0);

        //   ApiService.getUserSubscriptions({"user_id": userid}).then((res) {
        //     try {
        //       if (res.success) {
        //         var subcriptionCheck = res.response != null
        //             ? PolicyResult.fromJson(res.response)
        //             : null;
        //         print({">>>>>>>>>subcriptionCheck", subcriptionCheck});
        //         if (subcriptionCheck != null) {
        //           String jsonString = jsonEncode(subcriptionCheck.toJson());
        //           prefs.setString('subscription_Check', jsonString);
        //           setState(() {
        //             premiumCheck = subcriptionCheck.name;
        //           });
        //         } else {
        //           prefs.setString('subscription_Check', 'null');
        //         }
        //         bool isSubscriptionDataLoaded =
        //             prefs.getBool('isSubscriptionDataLoaded') ?? false;
        //         if (isSubscriptionDataLoaded) return;
        //         if (!isSubscriptionDataLoaded) {
        //           // showModalSec(subcriptionCheck, res.response);
        //           isSubscriptionDataLoaded = true;
        //           prefs.setBool('isSubscriptionDataLoaded', true);
        //         }
        //       }
        //     } catch (error) {
        //       // print(error);
        //     }
        //   });
        // }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Your payment has been  successful'),
          duration: Duration(seconds: 2),
        ));
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const HomeScreen(userName: '')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Payment failed !'),
          duration: Duration(seconds: 2),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("=================$premiumCheck");
    return Container(
      decoration: const ShapeDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 43, 52, 150), // Deep color
            const Color.fromARGB(255, 251, 251, 252), // Lighter color
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
          ),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Important: only take as much space as needed

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Buy Subscription Plan',
                style: TextStyle(
                  color: Color.fromARGB(255, 252, 252, 253),
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Color.fromARGB(255, 227, 226, 230),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            // padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      widget.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Content with semi-transparent background for readability
                Container(
                  padding: const EdgeInsets.all(10),
                  // decoration: BoxDecoration(
                  //   color: Colors.white.withOpacity(0.7), // Adjust opacity
                  //   borderRadius: BorderRadius.circular(16),
                  // ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:
                        MainAxisSize.min, // Allows height to be flexible
                    children: [
                      // Plan Name
                      Text(
                        widget.name,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Description
                      Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 254, 254, 255),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Price
                      Text(
                        "Price: \$${widget.price} ${widget.isMonthly ? '/month' : '/year'}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 251, 252, 252),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Features:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Maximum hunt  : ${widget.maxHunts ?? "No limit"}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Maximum Quest  : ${widget.maxChallenge ?? "No limit"}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Description
                      Text(
                        "Maximum hunt team : ${widget.maxHuntsTeam ?? "No limit"}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Description
                      Text(
                        "Maximum quest items : ${widget.maxChallenges ?? "No limit"}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 251, 252, 252),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Description
                      Text(
                        "Maximum created items : ${widget.maxcreatedItem == null ? "No limit" : widget.maxcreatedItem}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Description
                      Text(
                        "Maximum hunt items : ${widget.maxhuntitem == null ? "No limit" : widget.maxhuntitem}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 251, 251, 252),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Description
                      Text(
                        "Maximum purchased items: ${widget.purchased == null ? "No limit" : widget.purchased}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 253, 253, 253),
                        ),
                      ),
                      // Description
                      const SizedBox(height: 10),
                      Text(
                        "Video available for download: ${widget.videoAvailable == null ? "No limit" : "${widget.videoAvailable} ${widget.videoAvailable == 1 ? "day" : "days"}"}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 253, 253, 253),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Relaunch Available: ${widget.isRelaunch == 0 ? "No Available" : "Available"}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 253, 253, 253),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: const Color.fromRGBO(21, 55, 146, 1),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    premiumCheck == "Free"
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => subcriptionheckout(
                                  name: widget.name,
                                  price: widget.price,
                                  subcription_id: widget.id,
                                  planType: widget.isMonthly),
                            ),
                          )
                        : showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Existing Subscription'),
                              content: const Text(
                                'You already have a subscription plan. Do you want to switch to a new one?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context), // Cancel
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context); // Close the dialog first
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            subcriptionheckout(
                                          name: widget.name,
                                          price: widget.price,
                                          subcription_id: widget.id,
                                          planType: widget.isMonthly,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color.fromRGBO(21, 55, 146, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('Buy'),
                      const Text('|'),
                      Text('\$ ${widget.price}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
