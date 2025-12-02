import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/model/item.model.dart';
import 'package:scavenger_app/model/payment.model.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:scavenger_app/pages/store/checkout.page.dart';

class ItemDetailsPage extends StatefulWidget {
  final int itemGroupId;
  final int isbuy;
  const ItemDetailsPage({super.key, required this.itemGroupId, this.isbuy = 1});

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  bool _enableLoader = true;
  bool _isProcessingFree = false;
  ItemGroupDetails itemGroupDetails = ItemGroupDetails(
      id: 0,
      name: '',
      description: 'sample description',
      image: '',
      bannerImg: '',
      price: 0,
      discount: 0,
      itemcount: 0,
      items: [
        Item(id: 0, name: '', image: '', groupId: 0, description: ''),
        Item(id: 0, name: '', image: '', groupId: 0, description: ''),
        Item(id: 0, name: '', image: '', groupId: 0, description: ''),
        Item(id: 0, name: '', image: '', groupId: 0, description: ''),
      ]);

  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    getItemGroupDetails();
  }

  getItemGroupDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = (prefs.getInt('saved_userId') ?? 0);
    ApiService.getItemGroupDetails(
        {"groupId": widget.itemGroupId, "userId": userid}).then((value) {
      if (value.success) {
        setState(() {
          itemGroupDetails = ItemGroupDetails.fromJson(value.response);
          _enableLoader = false;
        });

        itemCount = itemGroupDetails.itemcount ?? 0;
      }
    });
  }

  Future<void> initiateIntentFree() async {
    setState(() {
      _isProcessingFree = true;
    });

    ApiService.paymentIntentFree({
      "itemGroupId": widget.itemGroupId,
    }, context)
        .then((value) {
      if (value.success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Your free item  has been  added to library'),
          duration: Duration(seconds: 2),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userName: "",
            ),
          ),
        );
        // var res = PaymentIntentModel.fromJson(value.response);
        // log("this is the store page in the app>>>> ${res.paymentId}");
        // paymentId = res.paymentId;
        // processPayment(res.clientSecret);
      }
    }).catchError((error) {
      setState(() {
        _isProcessingFree = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${error.toString()}'),
        duration: const Duration(seconds: 2),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
        foregroundColor: Colors.white,
        title: Text(
          itemGroupDetails.name,
          style: const TextStyle(
              fontFamily: 'Jost',
              fontSize: 24,
              color: Color.fromRGBO(255, 255, 255, 1)),
        ),
      ),
      body: Skeletonizer(
          enabled: _enableLoader,
          enableSwitchAnimation: true,
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  itemGroupDetails.bannerImg.isNotEmpty
                      ? SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: Image.network(
                            itemGroupDetails.bannerImg,
                            fit: BoxFit.cover,
                          ),
                        )
                      : SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: Image.asset(
                            'assets/images/grey.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height - 250,
                      child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, left: 14, right: 14),
                                child: Text(itemGroupDetails.description,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'Jost',
                                        color: Color.fromRGBO(70, 81, 110, 1))),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 14, right: 14, top: 20, bottom: 2),
                                child: Text(
                                  'Total Items  :  ${itemGroupDetails.itemcount}',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Color.fromRGBO(21, 55, 146, 1),
                                      fontSize: 16),
                                ),
                              ),
                              const Padding(
                                padding: const EdgeInsets.only(
                                    left: 14, right: 14, top: 20, bottom: 10),
                                child: Text(
                                  'Sample Items',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color.fromRGBO(21, 55, 146, 1),
                                      fontSize: 16),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: EdgeInsets.all(15),
                                height: 350,
                                child:
                                    // Column(
                                    //   children: itemGroupDetails.items.map((item) {
                                    //     return ItemCard(item: item);
                                    //   }).toList(),
                                    // ),
                                    ListView.builder(
                                  itemCount: itemGroupDetails.items.length,
                                  // scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return ItemCard(
                                        item: itemGroupDetails.items[index]);
                                  },
                                ),
                              ),
                              // SizedBox(
                              //   height: 20,
                              // )
                            ]),
                      )),
                ],
              ),
            ),
          )),
      floatingActionButton: _enableLoader || widget.isbuy == 0
          ? null
          : ElevatedButton(
              onPressed: _isProcessingFree
                  ? null
                  : () async {
                      itemGroupDetails.price == 0
                          ? await initiateIntentFree()
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutPage(
                                  itemGroupDetails: itemGroupDetails,
                                ),
                              ),
                            );
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color.fromRGBO(21, 55, 146, 1),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: _isProcessingFree
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('Buy '),
                        const Text('|'),
                        Text(
                            itemGroupDetails.price == 0
                                ? 'Free'
                                : '\$ ${itemGroupDetails.price}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
            ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}

class ItemCard extends StatelessWidget {
  final Item item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // const SizedBox(
          //   height: 3,
          // ),
          Container(
            width: (MediaQuery.of(context).size.width - 30),
            height: 90,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: (MediaQuery.of(context).size.width - 40),
                  height: 88,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 65,
                        width: 65,
                        margin: const EdgeInsets.only(left: 14),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 65, 15, 15),
                          borderRadius: BorderRadius.circular(50),
                          image: item.image.isEmpty
                              ? const DecorationImage(
                                  image: AssetImage(
                                      'assets/images/defaultImg.jpg'),
                                  fit: BoxFit.fill,
                                )
                              : DecorationImage(
                                  image: NetworkImage(item.image ?? ''),
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width - 120),
                        height: 100,
                        padding: EdgeInsets.only(left: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    item.name,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      height: 1,
                                    ),
                                  ),
                                )),
                            const SizedBox(
                              height: 5,
                            ),

                            // Container(
                            //     padding: const EdgeInsets.only(left: 5),
                            //     child: Align(
                            //       alignment: Alignment.topLeft,
                            //       child: Text(
                            //         item.description,
                            //         textAlign: TextAlign.left,
                            //         style: const TextStyle(
                            //           color: Color(0xFF153792),
                            //           fontSize: 12,
                            //           fontFamily: 'Roboto',
                            //           fontWeight: FontWeight.w500,
                            //           overflow: TextOverflow.ellipsis,
                            //           height: 1,
                            //         ),
                            //       ),
                            //     )),
                            // if (HuntEndTime != '')
                            GestureDetector(
                              onTap: () {
                                // Show dialog when the container is tapped
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize:
                                              16, // Set your desired font size
                                          fontWeight: FontWeight
                                              .bold, // Optional: Make the text bold
                                        ),
                                      ),
                                      content: Text(item.description),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    item.description,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 12,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
