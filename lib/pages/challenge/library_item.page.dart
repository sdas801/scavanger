import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scavenger_app/LibraryItemList.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/model/item.model.dart';
import 'package:scavenger_app/pages/store/myitem.page.dart';
import 'package:scavenger_app/pages/subcriptions/currentPlandialog.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scavenger_app/model/challenge.model.dart';
import 'package:shimmer/shimmer.dart';

const double cardHeight = 80;

class LibraryItemPage extends StatefulWidget {
  final int gameId;
  final String gameuniqueId;
  final int itemLength;
  const LibraryItemPage(
      {super.key,
      required this.gameId,
      required this.gameuniqueId,
      required this.itemLength});

  @override
  _LibraryItemPageState createState() => _LibraryItemPageState();
}

class _LibraryItemPageState extends State<LibraryItemPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  List<ChallengeItem> items = [];
  var userid = 0;
  late List<HuntItemList> libraryItemListData = [];
  List<ItemList> myItems = [];
  bool _isChooseLoader = false;
  List finalArrData = [];
  bool isTimeCheck = false;
  bool isPrizedCheck = false;
  bool isItemApproved = false;
  bool isListLoader = true;
  bool isNextLoader = false;
  int limit = 100;
  int pageNum = 0;
  bool _hasMore = true;
  int myItemlimit = 100;
  int myItempageNum = 0;
  bool _myItemhasMore = true;
  bool _isLoading1 = false;
  List<SearchItemList> searchItems = [];
  PolicyResult? isCheckSubcription;
  List<itemCatagory> catagoryArr = [];
  List<itemCatagory> subCatagoryArr = [];
  List<LibraryItemGroup> packageItemListData = [];
  bool showItem = false;
  int catagoryId = 0;
  int subCatagoryId = 0;
  int itemId = 0;

  @override
  void initState() {
    super.initState();
    _getgameDetails();
    getSubcriptionCheck();
    _onCatagoryApiCall();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _searchController.clear(); // Clear search input on tab switch
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void getMyItemsApi(String value) async {
    setState(() {
      _isLoading1 = true;
    });
    List<ItemList> itemArr = [];
    List<ItemList> mainItemArr = [];

    ApiService.getMyItems({
      "searchText": value,
      "limit": myItemlimit,
      "offset": (myItempageNum * myItemlimit),
      "categoryId": catagoryId,
      "subcategoryId": subCatagoryId
    }).then((value) {
      if (value.success) {
        var myItem = List<ItemList>.from(
            value.response.map((x) => ItemList.fromJson(x)));

        for (var i = 0; i < myItem.length; i++) {
          itemArr.add(myItem[i]);
        }
        for (var i = 0; i < items.length; i++) {
          for (var j = 0; j < itemArr.length; j++) {
            if (items[i].itemname == itemArr[j].itemname) {
              itemArr[j].ischeckItem = true;
            }
          }
        }
        for (var i = 0; i < itemArr.length; i++) {
          var f = 0;
          for (var j = 0; j < items.length; j++) {
            if (itemArr[i].itemname == items[j].itemname) {
              f = 1;
              break;
            }
          }
          if (f == 0) {
            mainItemArr.add(itemArr[i]);
          }
        }
        setState(() {
          myItems = mainItemArr;
        });
      }
    });
    setState(() {
      _isLoading1 = false;
    });
  }

  void _itemListApicall(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('saved_userId')) {
      setState(() {
        userid = (prefs.getInt('saved_userId') ?? 0);
      });
    }
    List<HuntItemList> itemArr = [];
    List<HuntItemList> mainItemArr = [];

    ApiService.fetchUserPurchaseHistory({
      "userId": userid,
      "searchText": value,
      "limit": limit,
      "offset": (pageNum * limit),
    }).then((value) {
      if (value.success) {
        final libraryItemList = List<LibraryItemGroup>.from(
            value.response.map((x) => LibraryItemGroup.fromJson(x)));

        setState(() {
          packageItemListData = libraryItemList;
        });

        for (var i = 0; i < libraryItemList.length; i++) {
          for (var j = 0; j < libraryItemList[i].items.length; j++) {
            itemArr.add(libraryItemList[i].items[j]);
          }
        }
        for (var i = 0; i < items.length; i++) {
          for (var j = 0; j < itemArr.length; j++) {
            if (items[i].itemname == itemArr[j].itemName) {
              itemArr[j].checkItem = true;
            }
          }
        }
        for (var i = 0; i < itemArr.length; i++) {
          var f = 0;
          for (var j = 0; j < items.length; j++) {
            if (itemArr[i].itemName == items[j].itemname) {
              f = 1;
              break;
            }
          }
          if (f == 0) {
            mainItemArr.add(itemArr[i]);
          }
        }
        setState(() {
          libraryItemListData = mainItemArr;
          isListLoader = false;
        });
      } else {
        setState(() {
          isListLoader = false;
        });
      }
    });
  }

  void _onCatagoryApiCall() {
    try {
      ApiService.getAllCategories().then((value) {
        if (value.success) {
          setState(() {
            catagoryArr = (value.response as List)
                .map((i) => itemCatagory.fromJson(i))
                .toList();
          });
        } else {
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

  void _onSubCatagoryApiCall(int? id) {
    try {
      ApiService.getAllSubCatagory({"category_id": id}).then((value) {
        if (value.success) {
          setState(() {
            subCatagoryArr = (value.response as List)
                .map((i) => itemCatagory.fromJson(i))
                .toList();
            catagoryId = id!;
          });
        } else {
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

  void _getgameDetails() {
    setState(() {
      isListLoader = true;
    });
    ApiService.getChallengeDetails(widget.gameId).then((value) {
      if (value.success) {
        var result = ChallengeModel.fromJson(value.response);
        setState(() {
          items = result.items ?? [];
        });
        _itemListApicall("");
        getMyItemsApi("");
      } else {
        setState(() {
          isListLoader = false;
        });
      }
    });
  }

  void _searchApicall(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('saved_userId')) {
      setState(() {
        userid = (prefs.getInt('saved_userId') ?? 0);
      });
    }

    List<HuntItemList> itemArr = [];
    List<SearchItemList> mainItemArr = [];

    ApiService.globalSearchItem({
      "userId": userid,
      "searchText": value,
      "limit": limit,
      "offset": (pageNum * limit),
    }).then((value) {
      if (value.success) {
        final libraryItemList = List<SearchItemList>.from(
            value.response.map((x) => SearchItemList.fromJson(x)));

        // for (var i = 0; i < libraryItemList.length; i++) {
        //   for (var j = 0; j < libraryItemList[i].items.length; j++) {
        //     itemArr.add(libraryItemList[i].items[j]);
        //   }
        // }

        for (var i = 0; i < items.length; i++) {
          for (var j = 0; j < libraryItemList.length; j++) {
            if (items[i].itemname == libraryItemList[j].item_name) {
              libraryItemList[j].checkItem = true;
            }
          }
        }

        for (var i = 0; i < libraryItemList.length; i++) {
          var f = 0;
          for (var j = 0; j < items.length; j++) {
            if (libraryItemList[i].item_name == items[j].itemname) {
              f = 1;
              break;
            }
          }
          if (f == 0) {
            mainItemArr.add(libraryItemList[i]);
          }
        }
        setState(() {
          searchItems = mainItemArr;
        });
      }
    });
  }

  void _onNextPress() async {
    setState(() {
      isNextLoader = true;
    });
    List mainArrData = [];

    for (var i = 0; i < libraryItemListData.length; i++) {
      if (libraryItemListData[i].checkItem) {
        var reqData = {
          "challengeid": widget.gameId,
          "id": libraryItemListData[i].itemId,
          "type": "P",
        };
        mainArrData.add(reqData);
      }
    }

    for (var i = 0; i < myItems.length; i++) {
      if (myItems[i].id == myItems[i].id) {}
      if (myItems[i].ischeckItem) {
        var reqData = {
          "challengeid": widget.gameId,
          "type": "M",
          "id": myItems[i].id
        };
        mainArrData.add(reqData);
      }
    }

    for (var i = 0; i < searchItems.length; i++) {
      if (searchItems[i].item_id == searchItems[i].item_id) {}
      if (searchItems[i].checkItem) {
        var reqData = {
          "challengeid": widget.gameId,
          "type": searchItems[i].type,
          "id": searchItems[i].item_id
        };
        mainArrData.add(reqData);
      }
    }
    // String jsonString = jsonEncode(mainArrData);
    // print(jsonString);
    int? maxChallengeItems = isCheckSubcription!.maxChallengeItems;
    if (maxChallengeItems != null &&
        mainArrData.length + widget.itemLength > maxChallengeItems) {
      showCurrentPlanAlertDialog(context, isCheckSubcription,
          "You have reached the limit of ${maxChallengeItems} items per Quests under your current subscription plan.");
    } else {
      if (mainArrData.isNotEmpty) {
        var payload = {
          "items": mainArrData,
          "challengeid": widget.gameId,
        };
        ApiService.insertChallengeItems(payload).then((respoData) {
          try {
            if (respoData.success) {
              Navigator.pop(context, 'add item from Screen!');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Failed to add item: ${respoData.message}'),
              ));
            }
          } catch (error) {
            // print(error);
          }
        });
      } else {
        Fluttertoast.showToast(
          msg: "Please choose atleast one item",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    }
    setState(() {
      isNextLoader = false;
    });
  }

  void getItemslist(itemId) async {
    print(packageItemListData[itemId].items);
    List<HuntItemList> itemArr = [];
    List<HuntItemList> mainItemArr = [];
    // List<ItemGroup> items = [];
    var libraryItemList = packageItemListData[itemId].items;

    for (var i = 0; i < libraryItemList.length; i++) {
      itemArr.add(libraryItemList[i]);
    }
    for (var i = 0; i < items.length; i++) {
      for (var j = 0; j < itemArr.length; j++) {
        if (items[i].itemname == itemArr[j].itemName) {
          itemArr[j].checkItem = true;
        }
      }
    }

    for (var i = 0; i < itemArr.length; i++) {
      var f = 0;
      for (var j = 0; j < items.length; j++) {
        if (itemArr[i].itemName == items[j].itemname) {
          f = 1;
          break;
        }
      }
      if (f == 0) {
        mainItemArr.add(itemArr[i]);
      }
    }
    setState(() {
      libraryItemListData = mainItemArr;
    });
  }

  void onItemTappedlist(
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

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Padding(
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

          child: Column(
            children: [
              const SizedBox(height: 20),
              // Row with Title and Close Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose Items',
                      style: TextStyle(
                        color: Color(0xFF153792),
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    // Close Button
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color.fromARGB(255, 47, 12, 104),
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close the current screen
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: "Search...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: const BorderSide(
                        color: Color(0xFF153792),
                        width: 2.0,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchItems.clear();
                      pageNum = 0;
                      _hasMore = true;
                    });
                    _searchApicall(value);
                    if (value.isNotEmpty) {
                      libraryItemListData = [];
                      myItems = [];
                    } else {
                      _getgameDetails();
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              if (_searchController.text.isEmpty) ...[
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.blue,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: "Purchase Items "),
                    Tab(text: "My Items"),
                  ],
                ),
                const SizedBox(height: 15),

                const SizedBox(height: 10),
                showItem && _tabController.index == 0
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.only(left: 20),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showItem = false;
                              });
                            },
                            child: const Text(
                              "Back",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Purchased Items List
                      isListLoader
                          ? const Center(child: CircularProgressIndicator())
                          : packageItemListData.isNotEmpty
                              ? showItem
                                  ? ListView.builder(
                                      itemCount: libraryItemListData.length,
                                      itemBuilder: (context, index) {
                                        // print("libary${packageItemListData[index].groupName}");
                                        return ListItemData(
                                            title: libraryItemListData[index]
                                                .itemName,
                                            description:
                                                libraryItemListData[index]
                                                    .itemDescription,
                                            imagePath:
                                                libraryItemListData[index]
                                                    .itemImageUrl,
                                            id: libraryItemListData[index]
                                                .itemId,
                                            index: index,
                                            checkItem:
                                                libraryItemListData[index]
                                                    .checkItem,
                                            onClick: (id, index, isCheck) {
                                              setState(() {
                                                libraryItemListData[index]
                                                  ..checkItem = isCheck;
                                              });
                                            },
                                            onItemTappedlist:
                                                onItemParchaseItemlist);
                                      },
                                    )
                                  : ListView.builder(
                                      itemCount: packageItemListData.length,
                                      itemBuilder: (context, index) {
                                        // print("libary${packageItemListData[index].groupName}");
                                        return ListItems(
                                            title: packageItemListData[index]
                                                .groupName,
                                            description:
                                                packageItemListData[index]
                                                    .groupDescription,
                                            imagePath:
                                                packageItemListData[index]
                                                    .groupImageUrl,
                                            id: packageItemListData[index]
                                                .groupId,
                                            index: index,
                                            checkItem: showItem,
                                            onClick: (id, index, isCheck) {
                                              getItemslist(index);
                                              setState(() {
                                                showItem = isCheck;
                                                itemId = index;

                                                print(showItem);
                                              });
                                            },
                                            onItemTappedlist:
                                                onItemParchaseItemlist);
                                      },
                                    )
                              : const Center(
                                  child: Text(
                                    'No Purchased Items Here',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                ),

                      // My Items List (Updated)
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            myItems.isNotEmpty
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: _isLoading1
                                        ? myItems.length + 6
                                        : myItems.length,
                                    itemBuilder: (context, index) {
                                      if (index < myItems.length) {
                                        final item = myItems[index];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: ListItem(
                                              key: ValueKey(item.id),
                                              imageUrl:
                                                  "assets/images/scavenger_hunt.png",
                                              title: item.itemname,
                                              description:
                                                  item.description ?? '',
                                              gameImg: item.imageurl,
                                              id: item.id,
                                              index: index,
                                              ischeckItem: item.ischeckItem,
                                              onClick: (id, index, isCheck) {
                                                setState(() {
                                                  myItems[index].ischeckItem =
                                                      isCheck;
                                                });
                                              },
                                              onItemTappedlist:
                                                  onItemTappedlist),
                                        );
                                      } else {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20.0),
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              height: 100,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : const Center(
                                    child: Text(
                                      "No My Items Here",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.grey),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_searchController.text.isNotEmpty) ...[
                Expanded(
                  child: searchItems.isNotEmpty
                      ? ListView.builder(
                          itemCount: searchItems.length,
                          itemBuilder: (context, index) {
                            return SearchListItemData(
                              title: searchItems[index].item_name,
                              description: searchItems[index].item_description,
                              imagePath: searchItems[index].item_iamge_url,
                              id: searchItems[index].item_id,
                              index: index,
                              checkItem: searchItems[index].checkItem,
                              onClick: (id, index, isCheck) {
                                setState(() {
                                  searchItems[index].checkItem = isCheck;
                                });
                              },
                              onItemTappedlist: onItemParchaseItemlist,
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            "No Items Here",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                ),
              ],

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    _onNextPress();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF153792),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef void packageItemCallback(int id, int index, bool isCheck);

typedef packageItemCallback1 = void Function(
    BuildContext context, String name, String titel, String imagePath);

class ListItems extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final int id;
  final int index;
  final ItemCallback onClick;
  final bool checkItem;
  final ItemTappedCallback onItemTappedlist;

  const ListItems(
      {super.key,
      required this.title,
      required this.description,
      required this.imagePath,
      required this.id,
      required this.index,
      required this.onClick,
      required this.checkItem,
      required this.onItemTappedlist});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
      color: Color(0xFFF2F2F2),
      child: GestureDetector(
          onTap: () {
            onItemTappedlist(context, description, title, imagePath);
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(21, 55, 146, 1),
                overflow: TextOverflow.ellipsis,
                height: 1,
              ),
            ),
            subtitle: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
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
                      onItemTappedlist(context, description, title, imagePath);
                    },
                    child: description.isNotEmpty
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
                  checkItem
                      ? SizedBox(
                          height: 40, // Set the desired height
                          width: 95, // Set the desired width
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 240, 51, 51),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              onClick(id, index, false);
                              // ApiService.deleteItem(id).then((res) {
                              //   if (res.success) {
                              //     Fluttertoast.showToast(
                              //       msg: "Item deleted successfully",
                              //       toastLength: Toast.LENGTH_SHORT,
                              //       gravity: ToastGravity.BOTTOM,
                              //       backgroundColor: Colors.green,
                              //       textColor: Colors.white,
                              //       fontSize: 16.0,
                              //     );
                              //   } else {
                              //     Fluttertoast.showToast(
                              //       msg: "Failed to delete the item",
                              //       toastLength: Toast.LENGTH_SHORT,
                              //       gravity: ToastGravity.BOTTOM,
                              //       backgroundColor: Colors.red,
                              //       textColor: Colors.white,
                              //       fontSize: 16.0,
                              //     );
                              //   }
                              // });
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 251, 253, 255),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ))
                      : SizedBox(
                          height: 40, // Set the desired height
                          width: 100, // Set the desired width
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF45AA6E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              onClick(id, index, true);
                            },
                            child: const Text(
                              "View",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 251, 253, 255),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ),
          )),
    );
  }
}

typedef void ItemCallback(int id, int index, bool isCheck);

typedef ItemTappedCallback = void Function(
    BuildContext context, String name, String titel, String imagePath);

class ListItemData extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final int id;
  final int index;
  final ItemCallback onClick;
  final bool checkItem;
  final ItemTappedCallback onItemTappedlist;

  const ListItemData(
      {super.key,
      required this.title,
      required this.description,
      required this.imagePath,
      required this.id,
      required this.index,
      required this.onClick,
      required this.checkItem,
      required this.onItemTappedlist});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 0.0),
        color: Color(0xFFF2F2F2),
        child: GestureDetector(
          // onTap: () {
          //   onItemTappedlist(context, description, title, imagePath);
          // },
          child: ListTile(
            leading: imagePath != ''
                ? CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(imagePath),
                  )
                : const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/no-image.jpg'),
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
                    description,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(19, 49, 131, 1),
                        fontWeight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis),
                  ),
                  GestureDetector(
                    onTap: () {
                      onItemTappedlist(context, description, title, imagePath);
                    },
                    child: description.isNotEmpty
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
                  checkItem
                      ? SizedBox(
                          height: 40, // Set the desired height
                          width: 95, // Set the desired width
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 240, 51, 51),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              onClick(id, index, false);
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 251, 253, 255),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ))
                      : SizedBox(
                          height: 40, // Set the desired height
                          width: 100, // Set the desired width
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF45AA6E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              onClick(id, index, true);
                            },
                            child: const Text(
                              "Choose",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 251, 253, 255),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ),
          ),
        ));
  }
}

typedef void myItemCallback(int id, int index, bool isCheck);
typedef ItemTappedlistCallback = void Function(
    BuildContext context, String name, String titel, String gameImg);

class ListItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String gameImg;
  final int id;
  final int index;
  final bool ischeckItem;
  final myItemCallback onClick;
  final ItemTappedlistCallback onItemTappedlist;

  const ListItem(
      {super.key,
      required this.imageUrl,
      required this.title,
      required this.description,
      required this.gameImg,
      required this.id,
      required this.index,
      required this.ischeckItem,
      required this.onClick,
      required this.onItemTappedlist});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 0.0),
        color: Color(0xFFF2F2F2),
        child: GestureDetector(
          // onTap: () {
          //   onItemTappedlist(context, description, title, gameImg);
          // },
          child: ListTile(
            leading: gameImg != ''
                ? CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(gameImg),
                  )
                : const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/defaultImg.jpg'),
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
                    description,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(19, 49, 131, 1),
                        fontWeight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis),
                  ),
                  GestureDetector(
                    onTap: () {
                      onItemTappedlist(context, description, title, gameImg);
                    },
                    child: description.isNotEmpty
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
                  ischeckItem
                      ? SizedBox(
                          height: 40, // Set the desired height
                          width: 95, // Set the desired width
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 240, 51, 51),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              onClick(id, index, false);
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 251, 253, 255),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ))
                      : SizedBox(
                          height: 40, // Set the desired height
                          width: 100, // Set the desired width
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF45AA6E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              onClick(id, index, true);
                            },
                            child: const Text(
                              "Choose",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 251, 253, 255),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ),
          ),
        ));
  }
}

typedef void SearchItemCallback(int id, int index, bool isCheck);

typedef SearchItemTappedCallback = void Function(
    BuildContext context, String name, String titel, String imagePath);

class SearchListItemData extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final int id;
  final int index;
  final SearchItemCallback onClick;
  final bool checkItem;
  final SearchItemTappedCallback onItemTappedlist;

  const SearchListItemData(
      {super.key,
      required this.title,
      required this.description,
      required this.imagePath,
      required this.id,
      required this.index,
      required this.onClick,
      required this.checkItem,
      required this.onItemTappedlist});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
      color: Color(0xFFF2F2F2),
      child: GestureDetector(
          onTap: () {
            onItemTappedlist(context, description, title, imagePath);
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(21, 55, 146, 1),
                overflow: TextOverflow.ellipsis,
                height: 1,
              ),
            ),
            subtitle: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
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
                      onItemTappedlist(context, description, title, imagePath);
                    },
                    child: description.isNotEmpty
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
                  checkItem
                      ? SizedBox(
                          height: 40, // Set the desired height
                          width: 95, // Set the desired width
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 240, 51, 51),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              onClick(id, index, false);
                              // ApiService.deleteItem(id).then((res) {
                              //   if (res.success) {
                              //     Fluttertoast.showToast(
                              //       msg: "Item deleted successfully",
                              //       toastLength: Toast.LENGTH_SHORT,
                              //       gravity: ToastGravity.BOTTOM,
                              //       backgroundColor: Colors.green,
                              //       textColor: Colors.white,
                              //       fontSize: 16.0,
                              //     );
                              //   } else {
                              //     Fluttertoast.showToast(
                              //       msg: "Failed to delete the item",
                              //       toastLength: Toast.LENGTH_SHORT,
                              //       gravity: ToastGravity.BOTTOM,
                              //       backgroundColor: Colors.red,
                              //       textColor: Colors.white,
                              //       fontSize: 16.0,
                              //     );
                              //   }
                              // });
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 251, 253, 255),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ))
                      : SizedBox(
                          height: 40, // Set the desired height
                          width: 100, // Set the desired width
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF45AA6E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              onClick(id, index, true);
                            },
                            child: const Text(
                              "Choose",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 251, 253, 255),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ),
          )),
    );
  }
}
