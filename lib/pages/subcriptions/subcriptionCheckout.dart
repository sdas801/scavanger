import 'package:flutter/material.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/couponList.dart';
import 'package:scavenger_app/model/couponListModel.dart';
import 'package:scavenger_app/model/item.model.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:scavenger_app/pages/store/purchase.page.dart';
import 'package:scavenger_app/pages/subcriptions/subcriptionCouponList.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/payment.model.dart';

class subcriptionheckout extends StatefulWidget {
  final String name;
  final dynamic price;
  final dynamic subcription_id;
  final bool planType;

  final CouponList? coupon;
  const subcriptionheckout(
      {super.key,
      required this.name,
      required this.price,
      required this.planType,
      required this.subcription_id,
      this.coupon});

  @override
  _subcriptionheckoutState createState() => _subcriptionheckoutState();
}

class _subcriptionheckoutState extends State<subcriptionheckout> {
  double discountedPrice = 0;
  double totalPrice = 0;
  double gstCharges = 0;
  int paymentId = 0;
  bool isLoading = false;
  bool applyLoder = false;
  double discountedPrice1 = 0;
  String discount_type = "";
  bool isApplied = false;
  double mainPrice = 0;

  TextEditingController couponController = TextEditingController();
  List<CouponList> coupons = [];
  int discount_id = 0;
  // ApplyRespo userDetails = {};

  @override
  void initState() {
    super.initState();
    print(">>>>${widget.planType}");
    if (widget.coupon != null) {
      setState(() {
        couponController.text = widget.coupon!.discount_code;
      });
      addCoupon(widget.coupon!.discount_code);
      // if (widget.itemGroupDetails.discount == null ||
      //     widget.itemGroupDetails.discount == 0) {
      //   discountedPrice = widget.itemGroupDetails.price.toDouble();
      // } else {
      //   discountedPrice = widget.itemGroupDetails.price *
      //       (1 - (widget.itemGroupDetails.discount ?? 0 / 100));
      // }
      // totalPrice = discountedPrice;
    } else {
      totalPrice = double.tryParse(widget.price.toString()) ?? 0.0;
    }
  }

  Future<void> initiateIntent() async {
    var reData = {
      "subscription_id": widget.subcription_id,
      "plan_type": widget.planType ? "M" : "Y",
      "discount_id": discount_id,
    };
    print(">>>>>>>>>initiateIntent>>>>>>>$reData");
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
      "subscription_id": widget.subcription_id,
      "plan_type": widget.planType ? "M" : "Y"
    };
    print("====================$reqData");
    // ApiService.subcriptionResponse(reqData).then((value) {
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
    // });
  }

  void addCoupon(String coupon) {
    try {
      setState(() {
        applyLoder = true;
      });
      ApiService.addCoupon({"discount_code": coupon}).then((value) {
        print(value);
        if (value.success) {
          var discountData = ApplyRespo.fromJson(value.response);
          print(">>>>>>>>>>>>>${discountData.discount_amount}");

          setState(() {
            discount_type = discountData.discount_type;

            mainPrice = double.parse(widget.price);
            double discountAmount =
                (double.tryParse(discountData.discount_amount.toString()) ??
                        0.0)
                    .toDouble();
            discountedPrice1 = discount_type == "0"
                ? discountAmount
                : (mainPrice * (discountAmount / 100));

            if (discountedPrice1 >= mainPrice) {
              discountedPrice = 0;
              totalPrice = mainPrice;
              applyLoder = false;
              discount_id = 0;
              // isApplied = true;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Invalid coupon"),
              ));
            } else {
              discountedPrice = discountedPrice1;
              totalPrice = (mainPrice) - discountedPrice;
              applyLoder = false;
              isApplied = true;
              discount_id = discountData.discount_id;
            }
          });
        } else {
          setState(() {
            applyLoder = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value.message),
          ));
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No Data Found"),
      ));
    }
  }

  void RemoveCoupon() {
    setState(() {
      // discount_type = discountData.discount_type;
      // discount_id = discountData.discount_id;
      // discountedPrice1 = discount_type == "1"
      //     ? discountData.discount_amount.toDouble()
      //     : widget.itemGroupDetails.price -
      //         (widget.itemGroupDetails.price *
      //             (discountData.discount_amount / 100));
      // ;
      discount_id = 0;
      discountedPrice = 0;
      totalPrice = (mainPrice) - discountedPrice;
      // applyLoder = false;
      isApplied = false;
    });
  }

  // void paymentResponse(String status) {
  //   ApiService.paymentResponse({"paymentId": paymentId, "status": status})
  //       .then((value) {
  //     if (status == "1") {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text('Your payment has been  successful'),
  //         duration: Duration(seconds: 2),
  //       ));
  //       // Navigator.pushReplacement(
  //       //   context,
  //       //   MaterialPageRoute(builder: (context) => const PurchaseItemPage(isBottom: false)), );
  //       Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => const HomeScreen(userName: '')));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text('Payment failed !'),
  //         duration: Duration(seconds: 2),
  //       ));
  //     }
  //   });
  // }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          automaticallyImplyLeading: false, // Remove the back button
          backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
          foregroundColor: Colors.white,
          title: const Text(
            'Checkout',
            style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 22,
                color: Color.fromRGBO(255, 255, 255, 1)),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Cart',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(21, 55, 146, 1),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Image.network(
                      //   widget.itemGroupDetails
                      //       .image, // Replace with actual image
                      //   width: 50,
                      //   height: 50,
                      //   fit: BoxFit.cover,
                      // ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 140,
                        height: 50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                "Subcription : ${widget.name}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  // overflow: TextOverflow.fade,
                                  color: Color.fromRGBO(21, 55, 146, 1),
                                ),
                              ),
                            ),
                            Text(
                              "Price :\$ ${widget.price}",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Row(
                //   children: [
                //     Expanded(
                //       child: TextField(
                //         controller: couponController,
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: isApplied
                //               ? const Color.fromARGB(255, 12, 184, 41)
                //               : const Color.fromARGB(255, 3, 3, 3),
                //         ),
                //         enabled: !isApplied, // Disable when isApplied is true
                //         decoration: InputDecoration(
                //           hintText: 'Enter your coupon code',
                //           border: OutlineInputBorder(
                //             borderRadius: const BorderRadius.only(
                //               topLeft: Radius.circular(8),
                //               bottomLeft: Radius.circular(8),
                //             ),
                //             borderSide: BorderSide(
                //                 color: Colors.grey.shade400,
                //                 width: 2), // Default border color
                //           ),
                //           enabledBorder: OutlineInputBorder(
                //             borderRadius: const BorderRadius.only(
                //               topLeft: Radius.circular(8),
                //               bottomLeft: Radius.circular(8),
                //             ),
                //             borderSide: BorderSide(
                //                 color: Colors.grey.shade400,
                //                 width: 2), // Border when not focused
                //           ),
                //           focusedBorder: const OutlineInputBorder(
                //             borderRadius: BorderRadius.only(
                //               topLeft: Radius.circular(8),
                //               bottomLeft: Radius.circular(8),
                //             ),
                //             borderSide: BorderSide(
                //                 color: Colors.blue,
                //                 width: 2), // Border when focused
                //           ),
                //           disabledBorder: const OutlineInputBorder(
                //             borderRadius: BorderRadius.only(
                //               topLeft: Radius.circular(8),
                //               bottomLeft: Radius.circular(8),
                //             ),
                //             borderSide: BorderSide(
                //                 color: Color.fromARGB(255, 12, 184, 41),
                //                 width: 2), // Border when disabled
                //           ),
                //           filled: true,
                //           fillColor: isApplied
                //               ? Colors.grey.shade200
                //               : Colors.white, // Change fill color if disabled
                //         ),
                //       ),
                //     ),
                //     isApplied
                //         ? ElevatedButton(
                //             onPressed: () {
                //               RemoveCoupon();
                //             },
                //             style: ElevatedButton.styleFrom(
                //               backgroundColor: isApplied
                //                   ? const Color.fromARGB(255, 12, 184, 41)
                //                   : const Color.fromRGBO(21, 55, 146, 1),
                //               foregroundColor: Colors.white,
                //               padding: const EdgeInsets.symmetric(
                //                   horizontal: 24, vertical: 16),
                //               shape: const RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.only(
                //                   topRight: Radius.circular(8),
                //                   bottomRight: Radius.circular(8),
                //                 ),
                //               ),
                //             ),
                //             child: const Text(
                //               'Remove',
                //               style: TextStyle(fontSize: 14),
                //             ),
                //           )
                //         : ElevatedButton(
                //             onPressed: applyLoder
                //                 ? null
                //                 : () {
                //                     String enteredCoupon = couponController.text
                //                         .trim(); // Get the entered text
                //                     if (enteredCoupon.isNotEmpty) {
                //                       addCoupon(
                //                           enteredCoupon); // Pass the value to addCoupon function
                //                     } else {
                //                       // Optionally, show a message if the input is empty
                //                       ScaffoldMessenger.of(context)
                //                           .showSnackBar(
                //                         const SnackBar(
                //                             content: Text(
                //                                 'Please enter a coupon code')),
                //                       );
                //                     }
                //                   },
                //             style: ElevatedButton.styleFrom(
                //               backgroundColor:
                //                   const Color.fromRGBO(21, 55, 146, 1),
                //               foregroundColor: Colors.white,
                //               padding: const EdgeInsets.symmetric(
                //                   horizontal: 24, vertical: 16),
                //               shape: const RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.only(
                //                   topRight: Radius.circular(8),
                //                   bottomRight: Radius.circular(8),
                //                 ),
                //               ),
                //             ),
                //             child: const Text(
                //               'Apply',
                //               style: TextStyle(fontSize: 14),
                //             ),
                //           ),
                //   ],
                // ),
                // isApplied
                //     ? const Padding(
                //         padding: EdgeInsets.only(left: 10),
                //         child: Text(
                //           "Applied",
                //           style: TextStyle(
                //             color: Color.fromARGB(255, 12, 184, 41),
                //           ),
                //         ),
                //       )
                //     : const SizedBox(),
                // const SizedBox(height: 16),
                // !isApplied
                //     ? GestureDetector(
                //         onTap: () {
                //           Navigator.pushReplacement(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) => Subcriptioncouponlist(
                //                       name: widget.name,
                //                       price: widget.price,
                //                       subcription_id: widget.subcription_id,
                //                       planType: widget.planType)));
                //           // // Add your coupon functionality here
                //           // print('Coupon button clicked');
                //           // You could navigate to a coupon page or show a bottom sheet
                //         },
                //         child: Container(
                //           height: 50,
                //           margin: const EdgeInsets.symmetric(vertical: 8),
                //           decoration: BoxDecoration(
                //             border: Border.all(
                //               color: const Color.fromARGB(255, 70, 23, 146),
                //               width: 1.5,
                //             ),
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           child: Row(
                //             children: [
                //               const SizedBox(width: 14),
                //               // Coupon icon
                //               Icon(
                //                 Icons.local_offer_outlined,
                //                 color: Colors.grey[600],
                //                 size: 20,
                //               ),
                //               const SizedBox(width: 12),
                //               // Apply coupon text
                //               Text(
                //                 'COUPON',
                //                 style: TextStyle(
                //                   color: Colors.grey[700],
                //                   fontSize: 14,
                //                   fontWeight: FontWeight.w500,
                //                   letterSpacing: 0.5,
                //                 ),
                //               ),
                //               const Spacer(),
                //               // Forward arrow icon
                //               Icon(
                //                 Icons.chevron_right,
                //                 color: Colors.grey[400],
                //                 size: 24,
                //               ),
                //               const SizedBox(width: 8),
                //             ],
                //           ),
                //         ),
                //       )
                //     : const SizedBox(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SummaryRow(
                          label: 'Item (1)', amount: '\$${widget.price}'),
                      SummaryRow(
                          label: 'Discount',
                          amount: '\$ ${discountedPrice.toStringAsFixed(2)}'),
                      const Divider(),
                      SummaryRow(
                        label: 'Total Price',
                        amount: '\$ ${totalPrice.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromRGBO(21, 55, 146, 1),
                        ),
                      )
                    : Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Call the payment gateway
                            initiateIntent();
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor:
                                const Color.fromRGBO(21, 55, 146, 1),
                            foregroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                          child: const Text(
                            'Check Out',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //     onPressed: () {},
                //     child: const Text(
                //       'Coupon List',
                //       style: TextStyle(
                //           color: Colors.blue,
                //           decoration: TextDecoration.underline,
                //           decorationColor: Colors.blue),
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ));
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isTotal;

  const SummaryRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color:
                  isTotal ? const Color.fromRGBO(21, 55, 146, 1) : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              color: isTotal ? Colors.red : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
