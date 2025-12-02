import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:scavenger_app/AddItemFromLibrary.dart';
import 'package:scavenger_app/CreateHuntFormLastPage.dart';
import 'package:scavenger_app/CreateHuntFormManualAdd.dart';
import 'package:scavenger_app/CreateHuntFormTime.dart';
import 'package:scavenger_app/CreateHuntPictureForm.dart';
import 'package:scavenger_app/CreatedGameDetailsResponse.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/pages/store/myitem.page.dart';
import 'package:scavenger_app/pages/subcriptions/currentPlandialog.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/services/stepper.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateHunt3rdPage extends StatefulWidget {
  final int gameId;
  final String gameuniqueId;
  const CreateHunt3rdPage(
      {super.key, required this.gameId, required this.gameuniqueId});

  @override
  _CreateHunt3rdPageState createState() => _CreateHunt3rdPageState();
}

class _CreateHunt3rdPageState extends State<CreateHunt3rdPage> {
  String gameTitle = "";
  bool _isLoading = false;
  List<HuntItem> items = [];
  List<HuntItem> newItems = [];
  bool _isItemAvailable = true;
  bool isTimeCheck = false;
  bool isPrizedCheck = false;
  bool isItemApproved = false;
  PolicyResult? isCheckSubcription;
  List<ItemList> myItems = [];
  dynamic globalItemSequenceData = {"items": []};
  bool isSorted = true;
  void initState() {
    _getgameDetails();
    getSubcriptionCheck();
    getMyItemsApi();
  }

  void reordering() {
    if (items.isNotEmpty && items[0].sequence != 0) {
      for (int i = 0; i < items.length; i++) {
        final matchedItem = items.firstWhere(
          (item) => item.sequence == i + 1,
          // orElse: () => null, // prevent error if not found
        );

        if (matchedItem != null) {
          newItems.add(matchedItem); // ✅ add instead of assign by index
        }
      }
    } else {
      newItems = items;
    }
  }

  Future<void> _getgameDetails() async {
    if (mounted)
      setState(() {
        _isLoading = true;
      });
    ApiService.gameDetails(widget.gameId).then((value) {
      // debugPrint(jsonEncode(value.response), wrapWidth: 1001190200000000024);
      try {
        if (value.success) {
          var homeResponse = Result.fromJson(value.response);
          gameTitle = homeResponse.title;
          var huntItem = homeResponse.items;
          items = huntItem;

          log("Hunt item ${items.map((e) => e.toJson())}");
          reordering();

          isTimeCheck = homeResponse.isTimed;
          isPrizedCheck = homeResponse.isPrized;
          isItemApproved = homeResponse.isItemApproved;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${value.message}'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      }
    });
  }

  void getSubcriptionCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    if (subcriptionCheckString != null) {
      Map<String, dynamic> jsonData = jsonDecode(subcriptionCheckString);
      if (mounted)
        setState(() {
          isCheckSubcription = PolicyResult.fromJson(jsonData);
        });
    }
  }

  void _handleCallback() {
    _getgameDetails();
  }

  void getMyItemsApi() async {
    var reqData = {
      "searchText": "",
      "limit": 200,
      "offset": 0,
    };
    ApiService.getMyItems(reqData).then((value) {
      if (value.success) {
        var myItem = List<ItemList>.from(
            value.response.map((x) => ItemList.fromJson(x)));
        if (mounted)
          setState(() {
            myItems = myItem;
          });
      }
    });
  }

  void reOrderingItemList(dynamic data) async {
    ApiService.reOrderingItemList(data).then((value) {
      if (value.success) {
        log("successfull the api for the sequence reordering ");
      } else {
        log("failed the api for the sequence reordering  ");
      }
    });
  }

  void _onNextPress() async {
    int? maxHuntItems = isCheckSubcription!.maxHuntItems;
    if (maxHuntItems != null && items.length > maxHuntItems) {
      showCurrentPlanAlertDialog(context, isCheckSubcription,
          "You have reached the limit of ${maxHuntItems} items per hunt under your current subscription plan.");
    } else {
      if (items.isNotEmpty) {
        reOrderingItemList(globalItemSequenceData);
        if (isTimeCheck) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateHuntFormTime(
                      gameId: widget.gameId,
                      gameuniqueId: widget.gameuniqueId)));
        } else if (isPrizedCheck) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateHuntPictureForm(
                      gameId: widget.gameId,
                      gameuniqueId: widget.gameuniqueId)));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateHuntFormLastPage(
                      gameId: widget.gameId,
                      gameuniqueId: widget.gameuniqueId)));
        }
      } else {
        if (mounted)
          setState(() {
            _isItemAvailable = false;
          });
        Fluttertoast.showToast(
          msg: "Add items to the Hunt to continue",
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

  void onAddItemFromLibrary() async {
    int? maxHuntItems = isCheckSubcription!.maxHuntItems;
    if (maxHuntItems != null && items.length >= maxHuntItems) {
      showCurrentPlanAlertDialog(context, isCheckSubcription,
          "You have reached the limit of ${maxHuntItems} items per hunt under your current subscription plan.");
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
        builder: (context) => AddItemFromLibrary(
            gameId: widget.gameId,
            gameuniqueId: widget.gameuniqueId,
            itemLength: items.length),
      ).whenComplete(() {
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
            Navigator.pop(context);
          },
        ),
        title: const Text("Create Hunt"),
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
            width: screenSize.width,
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
                  Image.asset(
                    'assets/images/1 1.png',
                    height: 117,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: gameTitle,
                          style: const TextStyle(
                            color: Color(0xFF153792),
                            fontSize: 30,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w800,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  StepperTabPage(
                      activeStep: 2, totalStep: 6, gameId: widget.gameId),
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
                                    if (mounted)
                                      setState(() {
                                        isSorted = false;
                                        // Reorder handling: adjust newIndex when moving down the list
                                        if (newIndex > oldIndex) newIndex -= 1;
                                        final movedItem =
                                            newItems.removeAt(oldIndex);
                                        newItems.insert(newIndex, movedItem);
                                        // 🧠 Create the new sequence map
                                        globalItemSequenceData = {
                                          "items": List.generate(
                                            newItems.length,
                                            (i) => {
                                              "sequence": i + 1,
                                              "itemid": newItems[i].id,
                                            },
                                          ),
                                        };
                                        // reordering();

                                        log("✅ New order data: $globalItemSequenceData");
                                        // Keep track of the order by IDs (or any unique identifier)
                                        final List<dynamic> newOrderIds =
                                            items.map((e) => e.id).toList();
                                        log("✅ New order IDs: $newOrderIds");
                                      });
                                  },
                                  itemBuilder: (context, index) {
                                    dynamic current = newItems[index];
                                    // ignore: curly_braces_in_flow_control_structures

                                    return Container(
                                      key: ValueKey(current
                                          .id), // <- required for ReorderableListView
                                      // You can wrap ListItem in a Card/Container if you want elevation/padding
                                      child: ListItem(
                                        title: current.name ?? '',
                                        subtitle: current.description ?? '',
                                        imagePath: current.imgUrl ?? '',
                                        id: current.id,
                                        index: index,
                                        editType: current.type ?? '',
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
                                                      .55,
                                                ),
                                              ),
                                              builder: (context) =>
                                                  CreateHuntFormManualAdd(
                                                gameId: widget.gameId,
                                                gameuniqueId:
                                                    widget.gameuniqueId,
                                                itemId: val,
                                                itemName: items[idx].name!,
                                                itemDescription:
                                                    items[idx].description!,
                                                itemImgUrl: items[idx].imgUrl,
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
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: const Text("No",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey)),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        ApiService.deleteItem(
                                                                items[idx].id)
                                                            .then((res) {
                                                          if (res.success) {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Item deleted successfully",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                            _handleCallback();
                                                          } else {
                                                            Fluttertoast.showToast(
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
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
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
                  const SizedBox(height: 90),
                  ElevatedButton(
                    onPressed: () {
                      int? maxCreatedItems =
                          isCheckSubcription!.maxCreatedItems;
                      int? maxHuntItems = isCheckSubcription!.maxHuntItems;
                      // if (maxCreatedItems != null &&
                      //     (myItems.length >= maxCreatedItems)) {
                      //   showCurrentPlanAlertDialog(context, isCheckSubcription,
                      //       "You have reached the limit of ${maxCreatedItems} items per hunt under your current subscription plan.");
                      // } else
                      if (maxHuntItems != null &&
                          (items.length >= maxHuntItems)) {
                        showCurrentPlanAlertDialog(context, isCheckSubcription,
                            "You have reached the limit of ${maxHuntItems} items per hunt under your current subscription plan.");
                      } else {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          constraints: BoxConstraints.tight(Size(
                              MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.height * .5)),
                          builder: (context) => CreateHuntFormManualAdd(
                            gameId: widget.gameId,
                            gameuniqueId: widget.gameuniqueId,
                          ),
                        ).whenComplete(() {
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
                      onAddItemFromLibrary();
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
                  // items.isNotEmpty
                  //     ?
                  ElevatedButton(
                    onPressed: () {
                      _onNextPress();
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
                  )
                  // : const SizedBox(),
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
  final ItemClickCallback onClick;
  final String editType;
  final ItemTappedCallback onItemTappedlist;

  const ListItem(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.imagePath,
      required this.id,
      required this.index,
      required this.itemid,
      required this.onClick,
      required this.editType,
      required this.onItemTappedlist});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 0.0),
        color: Colors.white,
        child: GestureDetector(
          onTap: () {
            onItemTappedlist(context, subtitle, title, imagePath);
          },
          child: ListTile(
            leading: imagePath != ''
                ? CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(imagePath),
                  )
                : const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/defaultImg.jpg'),
                  ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(
                  21,
                  55,
                  146,
                  1,
                ),
                overflow: TextOverflow.ellipsis,
                height: 2,
              ),
            ),
            subtitle: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(70, 81, 111, 1),
                      fontWeight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      height: 1,
                    ),
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
                  editType == "M"
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
        ));
  }
}
