import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scavenger_app/model/couponListModel.dart';
import 'package:scavenger_app/model/item.model.dart';
import 'package:scavenger_app/pages/store/checkout.page.dart';

import 'package:scavenger_app/services/api.service.dart';

class CouponScreen extends StatefulWidget {
  final ItemGroupDetails itemGroupDetails;
  const CouponScreen({super.key, required this.itemGroupDetails});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  List<CouponList> coupons = [];
  bool _isLoading = false;

  @override
  void initState() {
    _couponList();
  }

  Future<void> _couponList() async {
    if (mounted)
      setState(() {
        _isLoading = true;
      });
    try {
      ApiService.allCouponList().then((value) {
        if (value.success) {
          var couponlist = List<CouponList>.from(
              value.response.map((x) => CouponList.fromJson(x)));
          if (mounted)
            setState(() {
              coupons = couponlist;
              _isLoading = false;
            });
        } else {
          if (mounted)
            setState(() {
              _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 23, 10, 141),
        title: const Text(
          'Apply Coupon',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(), // ✅ Show loader while fetching coupons
            )
          : coupons.length == 0
              ? const Center(
                  child: Text(
                  "No coupon abalivle",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        'Save more with',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // ListView for coupon items
                    Expanded(
                      child: ListView.builder(
                        itemCount: coupons.length,
                        itemBuilder: (context, index) {
                          // final coupon = coupons[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CouponItem(
                              coupons[index],
                              // code: coupon['code'],
                              // description: coupon['description'],
                              // color: coupon['color'],
                              // borderColor: coupon['borderColor'],
                              onApply: () {
                                // Handle apply button press
                                _applyCoupon(coupons[index]);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  void _applyCoupon(CouponList coupon) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
            itemGroupDetails: widget.itemGroupDetails, coupon: coupon),
      ),
    );
    // You can implement the coupon application logic here
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Applied coupon: $couponCode'),
    //     duration: const Duration(seconds: 2),
    //   ),
    // );
  }
}

class CouponItem extends StatelessWidget {
  final CouponList coupons;
  final VoidCallback onApply;

  const CouponItem(
    this.coupons, {
    super.key,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left orange section with "30% OFF" text
          Container(
            width: 50,
            decoration: const BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: RotatedBox(
              quarterTurns: 3,
              child: Center(
                child: Text(
                  coupons.discount_type == "0"
                      ? "\$ ${coupons.discount_amount} Flat off"
                      : "Get ${coupons.discount_amount} % off",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Main content section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupons.discount_name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // JUMBO text
                      Text(
                        "Code: ${coupons.discount_code}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 55, 2, 146)),
                      ),

                      // APPLY button
                      GestureDetector(
                        onTap: () {
                          // Call your function here
                          onApply();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: const Text(
                            "APPLY",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  // Save text with highlighted amount
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text(
                          "Save ",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "\$125 ",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "on this order!",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      "Use code JUMBO & get 30% off on orders above ₹400. Maximum discount ₹150.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  // Description text
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
