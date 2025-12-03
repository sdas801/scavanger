import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/pages/store/myitem.page.dart';
import 'package:scavenger_app/pages/subcriptions/currentPlandialog.dart';
import 'package:scavenger_app/services/challengeStepper.service.dart';
import 'package:scavenger_app/model/challenge.model.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/pages/challenge/item_add.page.dart';
import 'package:scavenger_app/pages/challenge/challenge_details.page.dart';
import 'package:scavenger_app/pages/challenge/library_item.page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChallengeItemPage extends StatefulWidget {
  final int gameId;
  final String gameuniqueId;
  const ChallengeItemPage(
      {super.key, required this.gameId, required this.gameuniqueId});

  @override
  _ChallengeItemPageState createState() => _ChallengeItemPageState();
}

class _ChallengeItemPageState extends State<ChallengeItemPage> {
  bool _isLoading = false;
  List<ChallengeItem> items = [];
  PolicyResult? isCheckSubcription;
  List<ItemList> myItems = [];
  dynamic globalItemSequenceData = {"items": []};
  List<ChallengeItem> newItems = [];

  void initState() {
    _getgameDetails();
    getSubcriptionCheck();
    getMyItemsApi();
  }

  void _getgameDetails() {
    setState(() {
      _isLoading = true;
    });
    ApiService.getChallengeDetails(widget.gameId).then((value) {
      try {
        if (value.success) {
          var result = ChallengeModel.fromJson(value.response);
          setState(() {
            items = result.items ?? [];
            log("Hunt item >>>>> ${items.map((i) => i.toJson())} ");
            reordering();
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // new
  void reOrderingItemList(dynamic data) async {
    ApiService.reOrderingItemListchalleng(data).then((value) {
      if (value.success) {
        log("successfull the api for the sequence reordering ");
      } else {
        log("failed the api for the sequence reordering  ");
      }
    });
  }

  void reordering() {
    if (items.isNotEmpty &&
        items[0].sequence != 0 &&
        items[0].sequence != null) {
      for (int i = 0; i < items.length; i++) {
        final matchedItem = items.firstWhere(
          (item) => item.sequence == i + 1,
          // orElse: () => null, // prevent error if not found
        );

        if (matchedItem != null) {
          newItems.add(matchedItem);
        }
      }
    } else {
      newItems = items;
    }
  }

  void getSubcriptionCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    if (subcriptionCheckString != null) {
      Map<String, dynamic> jsonData = jsonDecode(subcriptionCheckString);
      setState(() {
        isCheckSubcription = PolicyResult.fromJson(jsonData);
      });
    }
  }

  void getMyItemsApi() async {
    var reqData = {
      "searchText": "",
      "limit": 200,
      "offset": 0,
    };
    ApiService.getMyItems(reqData).then((value) {
      if (!mounted) return;
      if (value.success) {
        var myItem = List<ItemList>.from(
            value.response.map((x) => ItemList.fromJson(x)));
        setState(() {
          myItems = myItem;
        });
      }
    });
  }

  _handleCallback() {
    _getgameDetails();
  }

  _onContinue() {
    int? maxChallengeItems = isCheckSubcription!.maxChallengeItems;
    if (maxChallengeItems != null && items.length > maxChallengeItems) {
      showCurrentPlanAlertDialog(context, isCheckSubcription,
          "You have reached the limit of ${maxChallengeItems} items per Quest under your current subscription plan.");
    } else {
      if (items.isNotEmpty) {
        reOrderingItemList(globalItemSequenceData);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ChallengeDetails(
                      challengeId: widget.gameId,
                    )));
      } else {
        Fluttertoast.showToast(
          msg: "Add items to the quest to continue",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  void onItemParchaseItemlist(
      BuildContext context, String description, String titel, String gameImg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              gameImg.isNotEmpty
                  ? CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(gameImg),
                    )
                  : const CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          AssetImage('assets/images/defaultImg.jpg'),
                    ),
              const SizedBox(width: 10), // Adds spacing between image and title
              Expanded(
                child: Text(
                  titel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(description),
        );
      },
    );
  }

  void onAddItemFromManually() async {
    int? maxChallengeItems = isCheckSubcription!.maxChallengeItems;
    if (maxChallengeItems != null && items.length >= maxChallengeItems) {
      showCurrentPlanAlertDialog(context, isCheckSubcription,
          "You have reached the limit of ${maxChallengeItems} items per Quests under your current subscription plan.");
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints.tight(
          Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * .8,
          ),
        ),
        builder: (context) => LibraryItemPage(
            gameId: widget.gameId, gameuniqueId: '', itemLength: items.length),
      ).whenComplete(() {
        print('completed');
        _handleCallback();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(
                  userName: "",
                  selectedTab: 1,
                ), // Replace `NewScreen` with your desired widget
              ),
            );
          },
        ),
        title: const Text("Create a Challenge"),
        automaticallyImplyLeading: false, // Remove the back button
        backgroundColor: const Color(0xFF0B00AB),
        foregroundColor: Colors.white,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.notifications),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      backgroundColor: const Color(0xFF0B00AB),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Center(
          child: Container(
            width: screenSize.width, // 80% of the screen width
            height: screenSize.height,
            decoration: const ShapeDecoration(
              color: Color(0xFFF2F2F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),
            ),

            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Center(
                    child: Text(
                      'Choose your items',
                      style: TextStyle(
                        color: Color(0xFF153792),
                        fontSize: 24,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w800,
                        height: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Center(
                    child: Text(
                      'It is a long established fact that a reader will be distracted by the readable content',
                      style: TextStyle(
                        color: Color.fromRGBO(79, 68, 68, 1),
                        fontSize: 12,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // const SizedBox(height: 20),
                  ChallengeStepperTabPage(activeStep: 1, totalStep: 5),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Center(
                          child: items.isNotEmpty
                              ? ReorderableListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: items.length,
                                  onReorder: (int oldIndex, int newIndex) {
                                    setState(() {
                                      // Adjust index when moving down
                                      if (newIndex > oldIndex) newIndex -= 1;

                                      // Move the item in the list
                                      final movedItem =
                                          newItems.removeAt(oldIndex);
                                      newItems.insert(newIndex, movedItem);

                                      // 🧠 Build global sequence data dynamically
                                      globalItemSequenceData = {
                                        "items": List.generate(
                                          newItems.length,
                                          (i) => {
                                            "sequence": i + 1,
                                            "itemid": newItems[i].id,
                                          },
                                        ),
                                      };

                                      log("✅ New order data: $globalItemSequenceData");
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    // final current = newItems[index];
                                    final current = newItems[index];

                                    return Container(
                                      key: ValueKey(current
                                          .id), // Required for reorderable list
                                      child: ListItem(
                                        title: current.itemname ?? '',
                                        subtitle: current.description ?? '',
                                        imagePath: current.imageurl ?? '',
                                        id: current.id,
                                        type: current.type ?? '',
                                        index: index,
                                        itemid: current.itemid,
                                        onItemTappedlist:
                                            onItemParchaseItemlist,
                                        onClick: (val, type, idx, itemid) {
                                          if (type == 'edit') {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              constraints: BoxConstraints.tight(
                                                Size(
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.5,
                                                ),
                                              ),
                                              builder: (context) =>
                                                  AddItemManualy(
                                                gameId: widget.gameId,
                                                itemId: val,
                                                itemName: current.itemname!,
                                                itemDescription:
                                                    current.description!,
                                                itemImgUrl: current.imageurl!,
                                                itemid: itemid,
                                              ),
                                            ).whenComplete(() {
                                              _handleCallback();
                                            });
                                          } else if (type == 'delete') {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Delete Confirmation"),
                                                  content: const Text(
                                                      "Are you sure you want to delete the item?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                        "No",
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        ApiService
                                                            .removeChallengeItem({
                                                          "id": current.id,
                                                        }).then((res) {
                                                          if (res.success) {
                                                            setState(() {
                                                              items.removeAt(
                                                                  index);
                                                            });
                                                            Fluttertoast
                                                                .showToast(
                                                              msg:
                                                                  "Item deleted successfully",
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  ToastGravity
                                                                      .BOTTOM,
                                                              backgroundColor:
                                                                  Colors.green,
                                                              textColor:
                                                                  Colors.white,
                                                              fontSize: 16.0,
                                                            );
                                                            _handleCallback();
                                                          } else {
                                                            Fluttertoast
                                                                .showToast(
                                                              msg:
                                                                  "Failed to delete the item",
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  ToastGravity
                                                                      .BOTTOM,
                                                              backgroundColor:
                                                                  Colors.red,
                                                              textColor:
                                                                  Colors.white,
                                                              fontSize: 16.0,
                                                            );
                                                          }
                                                        });
                                                      },
                                                      child: const Text("Yes"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                )
                              : const Text(
                                  "No items created yet",
                                  textAlign: TextAlign
                                      .center, // Optional for multi-line text
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF153792),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      int? maxCreatedItems =
                          isCheckSubcription!.maxCreatedItems;
                      int? maxChallengeItems =
                          isCheckSubcription!.maxChallengeItems;
                      // if (maxCreatedItems != null &&
                      //     (myItems.length >= maxCreatedItems)) {
                      //   showCurrentPlanAlertDialog(context, isCheckSubcription,
                      //       "You have reached the limit of ${maxCreatedItems} items per Quests under your current subscription plan.");
                      // } else
                      if (maxChallengeItems != null &&
                          (items.length >= maxChallengeItems)) {
                        showCurrentPlanAlertDialog(context, isCheckSubcription,
                            "You have reached the limit of ${maxChallengeItems} items per Quests under your current subscription plan.");
                      } else {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          constraints: BoxConstraints.tight(
                            Size(
                              MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.height * .55,
                            ),
                          ),
                          builder: (context) =>
                              AddItemManualy(gameId: widget.gameId),
                        ).whenComplete(() {
                          print('completed');
                          getMyItemsApi();
                          _handleCallback();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF153792),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ), //_login,
                    child: const Text('Add Item Manually'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // showModalBottomSheet(
                      //   context: context,
                      //   isScrollControlled: true,
                      //   constraints: BoxConstraints.tight(
                      //     Size(
                      //       MediaQuery.of(context).size.width,
                      //       MediaQuery.of(context).size.height * .8,
                      //     ),
                      //   ),
                      //   builder: (context) => LibraryItemPage(
                      //       gameId: widget.gameId, gameuniqueId: ''),
                      // ).whenComplete(() {
                      //   print('completed');
                      //   _handleCallback();
                      // });
                      onAddItemFromManually();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B00AB),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Add Item Form Library'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _onContinue();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF153792),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef void ItemClickCallback(int val, String type, int index, int itemid);
typedef ItemTappedCallback = void Function(
    BuildContext context, String name, String titel, String imagePath);

class ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final int id;
  final int itemid;
  final int index;
  final String type;
  final ItemClickCallback onClick;
  final ItemTappedCallback onItemTappedlist;

  const ListItem(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.imagePath,
      required this.id,
      required this.itemid,
      required this.type,
      required this.index,
      required this.onClick,
      required this.onItemTappedlist});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(16), // Adjust the radius as needed
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 0.0),
          color: Colors.white,
          child: GestureDetector(
            // onTap: () {
            //   onItemTappedlist(context, subtitle, title, imagePath);
            // },
            child: ListTile(
              leading: ClipOval(
                child: Image.network(
                  imagePath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // Show the image when fully loaded
                    }
                    return const Center(
                      child:
                          CircularProgressIndicator(), // Show a loader while the image is loading
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                        'assets/images/defaultImg.jpg'); // Fallback for broken image
                  },
                ),
              ),
              title: Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(21, 55, 146, 1),
                    height: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              subtitle: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(19, 49, 131, 1),
                          fontWeight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis),
                    ),
                    GestureDetector(
                      onTap: () {
                        onItemTappedlist(context, subtitle, title, imagePath);
                      },
                      child: subtitle.isNotEmpty
                          ? const Text(
                              "Show More",
                              style: TextStyle(
                                color: Color.fromRGBO(70, 81, 111, 1),
                                fontSize: 12.0,
                                height: 1,
                                decoration: TextDecoration
                                    .underline, // Optional: underline for interactivity
                              ),
                            )
                          : const SizedBox(),
                    )
                  ],
                ),
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    type == "M"
                        ? IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Color.fromRGBO(21, 55, 146, 1),
                            ),
                            onPressed: () {
                              onClick(id, 'edit', index, itemid);
                            },
                          )
                        : const SizedBox(),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 20,
                        color: Color.fromRGBO(221, 4, 4, 1),
                      ),
                      onPressed: () {
                        onClick(id, 'delete', index, itemid);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
