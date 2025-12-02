import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/model/payment.model.dart';
import 'package:scavenger_app/model/subcriptionList.modal.dart';
import 'package:scavenger_app/pages/subcriptions/chooseSubcriptionPage.dart';
import 'package:scavenger_app/pages/subcriptions/subcriptionCheckout.dart';
import 'package:scavenger_app/pages/subcriptions/subcriptionList.dart';
import 'package:scavenger_app/services/api.service.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final SubcriptionList plandata;
  final bool isMonthly;
  final bool isMonthlyBuyCheck;
  final String detailsImage;

  const SubscriptionPlanCard(
      {Key? key,
      required this.plandata,
      required this.isMonthly,
      required this.isMonthlyBuyCheck,
      required this.detailsImage})
      : super(key: key);

  Future<void> initiateIntent(BuildContext context) async {
    var reData = {
      "subscription_id": plandata.id,
      "plan_type": isMonthly ? "M" : "Y"
    };
    ApiService.subcriptionIntent(reData).then((value) {
      if (value.success) {
        var res = PaymentIntentModel.fromJson(value.response);
        var paymentId = res.paymentId;
        processPayment(context, res.clientSecret, paymentId);
      }
    });
  }

  Future<void> processPayment(
      BuildContext context, String clientSecret, int paymentId) async {
    try {
      var result = await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.light,
          merchantDisplayName: 'Scavenger',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      paymentResponse(context, "1", paymentId);
    } catch (e) {
      paymentResponse(context, "2", paymentId);
    }
  }

  void paymentResponse(BuildContext context, String status, int paymentId) {
    var reqData = {
      "paymentId": paymentId,
      "status": status,
      "subscription_id": plandata.id,
      "plan_type": isMonthly ? "M" : "Y"
    };
    ApiService.subcriptionResponse(reqData).then((value) {
      if (status == "1") {
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a237e), // Deep blue color
        title: const Text(
          'Subscription Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            // Makes the height adapt to content
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    detailsImage,
                    fit: BoxFit.cover,
                  ),
                ),

                // Content overlay
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
                              plandata.name,
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
                      // Price
                      plandata.priceMonthly != null
                          ? Container(
                              height: 40,
                              child: isMonthly
                                  ? Row(
                                      children: [
                                        plandata.priceMonthly != null
                                            ? Row(
                                                children: [
                                                  Text(
                                                    "\$${plandata.priceMonthly?.toStringAsFixed(2) ?? '0.00'}",
                                                    style: const TextStyle(
                                                      fontSize: 34,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    "/ month",
                                                    style: TextStyle(
                                                      fontSize: 20,
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
                                        plandata.priceAnnually != null
                                            ? Row(
                                                children: [
                                                  Text(
                                                    "\$${plandata.priceAnnually?.toStringAsFixed(2) ?? '0.00'}",
                                                    style: const TextStyle(
                                                      fontSize: 34,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    "/ year",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox()
                                      ],
                                    ),
                            )
                          : const SizedBox(),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        "${plandata.description}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Features
                      const Text(
                        'Features',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Feature bullets
                      _buildFeatureItem(
                          plandata.maxHunts.toString(), "Max Stored Hunts "),
                      _buildFeatureItem(plandata.maxChallenge.toString(),
                          "Max Stored Quests"),
                      _buildFeatureItem(plandata.maxHuntItems.toString(),
                          "Max Items per Hunt"),
                      _buildFeatureItem(plandata.maxChallengeItems.toString(),
                          "Max Items per Quest"),
                      _buildFeatureItem(plandata.maxHuntTeams.toString(),
                          "Max Hunt Teams"),
                      _buildFeatureItem(plandata.maxCreatedItems.toString(),
                          "Max Created Teams"),
                      _buildFeatureItem(plandata.maxPurchasedItems.toString(),
                          "Max Purchased Items"),
                      _buildFeatureItem(
                          "${plandata.videoAvailable} ${plandata.videoAvailable == 1 ? "day" : "days"}",
                          "Video available for download"),
                      _buildFeatureItem(
                          "${plandata.isRelaunch == 0 ? "No Available" : "Available"} ",
                          "Realaunch Available"),

                      const SizedBox(height: 24),

                      // Subscribe button
                      isMonthlyBuyCheck || plandata.name == "Free"
                          ? const SizedBox()
                          : Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    // initiateIntent(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            subcriptionheckout(
                                                name: plandata.name,
                                                price: isMonthly
                                                    ? plandata.priceMonthly
                                                    : plandata.priceAnnually,
                                                subcription_id: plandata.id,
                                                planType: isMonthly),
                                      ),
                                    );
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
                                        'Subscribe Now',
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
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
