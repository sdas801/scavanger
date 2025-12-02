import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scavenger_app/UploadImageResponse.dart';
import 'package:scavenger_app/constants.dart';
import 'package:scavenger_app/custom_textfield.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/model/item.model.dart';
import 'package:scavenger_app/pages/store/item_details.page.dart';
import 'package:scavenger_app/pages/store/myitem.page.dart';
import 'package:scavenger_app/pages/subcriptions/currentPlandialog.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/services/crop.service.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:http/http.dart' as http;

const double cardHeight = 110;

class PurchaseItemPage extends StatefulWidget {
  final bool isBottom;
  const PurchaseItemPage({Key? key, required this.isBottom}) : super(key: key);

  @override
  _PurchaseItemPageState createState() => _PurchaseItemPageState();
}

class _PurchaseItemPageState extends State<PurchaseItemPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  List<ItemGroup> items = [];

  List<ItemList> myItems = [];
  bool _enableLoader = true;
  int limit = 200;
  int pageNum = 0;
  bool _hasMore = true;

  int purchaseLimit = 200;
  int purchasePageNum = 0;
  bool _purchasehasMore = true;
  File? galleryFile;
  final picker = ImagePicker();
  String uplodedImgUrl = "";
  bool _isLoading1 = false;
  bool imageLoader = false;
  List<itemCatagory> catagoryArr = [];
  List<itemCatagory> subCatagoryArr = [];
  int catagoryId = 0;
  int subCatagoryId = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getItemGroup("", catagoryId, subCatagoryId);
    getMyItemsApi("");
    _onCatagoryApiCall();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _enableLoader = false;
        });
      }
      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          if (mounted) {
            setState(() {
              _searchController.clear();
            });
          }
        }
        if (_tabController.index == 0) {
          getItemGroup("", catagoryId, subCatagoryId);
        } else {
          getMyItemsApi("");
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onCatagoryApiCall() {
    try {
      ApiService.getAllCategories().then((value) {
        if (value.success) {
          if (mounted) {
            setState(() {
              catagoryArr = (value.response as List)
                  .map((i) => itemCatagory.fromJson(i))
                  .toList();
            });
          }
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
          if (mounted) {
            setState(() {
              subCatagoryArr = (value.response as List)
                  .map((i) => itemCatagory.fromJson(i))
                  .toList();
              catagoryId = id!;
            });
          }
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

  getItemGroup(String value, catagoryId, subCatagoryId) {
    var reqData = {
      "searchText": value,
      "limit": purchaseLimit,
      "offset": (purchasePageNum * purchaseLimit),
      "category_id": catagoryId == 0 ? "" : catagoryId,
      "sub_category_id": subCatagoryId == 0 ? "" : subCatagoryId,
    };
    try {
      ApiService.purchaseItemList(reqData).then((value) {
        if (value.success) {
          if (mounted) {
            setState(() {
              items = (value.response as List)
                  .map((i) => ItemGroup.fromJson(i))
                  .toList();
              _enableLoader = false;
            });
          }
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  void getMyItemsApi(String value) async {
    if (mounted) {
      setState(() {
        _isLoading1 = true;
      });
    }
    var reqData = {
      "searchText": value,
      "limit": limit,
      "offset": (pageNum * limit),
    };
    ApiService.getMyItems(reqData).then((value) {
      if (value.success) {
        var myItem = List<ItemList>.from(
            value.response.map((x) => ItemList.fromJson(x)));
        if (mounted) {
          setState(() {
            myItems = myItem;
          });
        }
      }
    });
    if (mounted) {
      setState(() {
        _isLoading1 = false;
      });
    }
  }

  void onItemlist(
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
                  // "pallab",
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
    return Scaffold(
      appBar: widget.isBottom == false
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text('Library'),
              backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
              foregroundColor: Colors.white,
            )
          : null,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: "Purchase Items "),
              Tab(text: "My Items"),
            ],
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                if (_tabController.index == 0) {
                  setState(() {
                    items.clear();
                    purchasePageNum = 0;
                    _purchasehasMore = true;
                    catagoryId = 0;
                    subCatagoryId = 0;
                  });
                  getItemGroup(value, catagoryId, subCatagoryId);
                } else {
                  setState(() {
                    myItems.clear();
                    pageNum = 0;
                    _hasMore = true;
                  });
                  getMyItemsApi(value);
                }
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildItemList(items), _buildMyItemList(myItems)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(List<ItemGroup> itemsList) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Container(
              height: Platform.isAndroid ? 40 : 45,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    DropdownButton<int>(
                      value: catagoryId == 0 ? null : catagoryId,
                      hint: const Text('Select a Category'),
                      isExpanded: true,
                      underline: SizedBox(), // Remove the default underline
                      icon: catagoryId ==
                              0 // Hide dropdown arrow when an item is selected
                          ? const Icon(Icons.arrow_drop_down,
                              color: Colors.grey)
                          : const SizedBox.shrink(),
                      items: catagoryArr.map((category) {
                        return DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          catagoryId = value ?? 0;
                          subCatagoryId = 0;
                        });
                        if (catagoryId != 0) {
                          _onSubCatagoryApiCall(value);
                        } else {
                          getItemGroup("", 0, 0);
                          setState(() {
                            catagoryId = 0;
                          });
                        }
                      },
                    ),
                    if (catagoryId !=
                        0) // Show clear button only when a value is selected
                      Positioned(
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              catagoryId = 0;
                              subCatagoryId = 0;
                            });
                            getItemGroup("", 0, 0);
                          },
                          child: const Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          catagoryId != 0
              ? Container(
                  height: Platform.isAndroid ? 40 : 45,
                  // margin: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    // border:
                    //     Border.all(color: Colors.grey), // Set your desired color
                    borderRadius: BorderRadius.circular(
                        30), // Optional: Add rounded corners
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        DropdownButton<int>(
                          value: subCatagoryId == 0 ? null : subCatagoryId,
                          hint: const Text('Select a Sub Category'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: subCatagoryId == 0
                              ? const Icon(Icons.arrow_drop_down,
                                  color: Colors.grey)
                              : const SizedBox.shrink(),
                          items: subCatagoryArr.map((subCatagory) {
                            return DropdownMenuItem<int>(
                              value: subCatagory.id,
                              child: Text(subCatagory.name),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            setState(() {
                              subCatagoryId = value ?? 0;
                            });
                            if (subCatagoryId != 0) {
                              getItemGroup("", catagoryId, subCatagoryId);
                            }
                          },
                        ),
                        if (subCatagoryId != 0)
                          Positioned(
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  subCatagoryId = 0;
                                });
                                getItemGroup("", 0, 0);
                              },
                              child: const Icon(
                                Icons.clear,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ))
              : const SizedBox(),
          const SizedBox(height: 10),
          Expanded(
            child: itemsList.isNotEmpty
                ? GridView.builder(
                    itemCount: itemsList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.75,
                            mainAxisExtent: 200),
                    itemBuilder: (_, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailsPage(
                                itemGroupId: itemsList[index].id,
                                isbuy: 0,
                              ),
                            ),
                          );
                        },
                        child: ItemCard(item: itemsList[index]),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      "No Purchase Item Here",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
          )
        ]));
  }

  // Function to show the image picker

  void _showEditModal(BuildContext context, String imageUrl, String name,
      String description, int id) {
    uplodedImgUrl = imageUrl;
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController descriptionController =
        TextEditingController(text: description);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ItemEdit(
            imageUrl: imageUrl, name: name, description: description, id: id);
      },
    ).whenComplete(() {
      print('completed');
      getMyItemsApi("");
    });
  }

  void _showAddItemModal(BuildContext context, Itemlist) {
    // uplodedImgUrl = imageUrl;
    // TextEditingController nameController = TextEditingController(text: name);
    // TextEditingController descriptionController =
    //     TextEditingController(text: description);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ItemAdd(
          Itemlist: Itemlist,
        );
      },
    ).whenComplete(() {
      print('completed');
      getMyItemsApi("");
    });
  }

  Widget _buildMyItemList(List<ItemList> itemsList) {
    // var screenSize = MediaQuery.of(context).size;
    return Stack(children: [
      Padding(
          padding: const EdgeInsets.all(0.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.only(top: 15),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                  padding: const EdgeInsets.all(20),
                  controller: _scrollController,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        itemsList.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: const ClampingScrollPhysics(),
                                itemCount: _isLoading1
                                    ? itemsList.length + 6
                                    : itemsList.length, //upcomingitems.length,
                                itemBuilder: (context, index) {
                                  if (index < itemsList.length) {
                                    final item = itemsList[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: ListItem(
                                        key: ValueKey(item.id),
                                        imageUrl:
                                            "assets/images/defaultImg.jpg",
                                        title: itemsList[index].itemname,
                                        description:
                                            itemsList[index].description ?? '',
                                        gameImg: itemsList[index].imageurl,
                                        id: itemsList[index].id,
                                        index: index,
                                        onItemTappedlist: onItemlist,
                                        onClick: (val, type, index) {
                                          if (type == 'edit') {
                                            _showEditModal(
                                                context,
                                                itemsList[index].imageurl,
                                                itemsList[index].itemname,
                                                itemsList[index].description ??
                                                    '',
                                                itemsList[index].id);
                                          } else {
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
                                                            .pop(); // Close the dialog
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
                                                            .pop(); // Close the dialog
                                                        ApiService
                                                            .deleteMyItems({
                                                          "id": itemsList[index]
                                                              .id
                                                        }).then((res) {
                                                          if (res.success) {
                                                            // Perform any additional actions here
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
                                                            getMyItemsApi("");
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
                                                      child: Text("Yes"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
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
                      ])),
            ),
          )),
      Positioned(
        bottom: 20,
        right: 20,
        child: FloatingActionButton(
          onPressed: () {
            _showAddItemModal(context,
                itemsList.length); // Call function to open the add item modal
          },
          backgroundColor: Color(0xFF153792),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    ]);
  }
}

class ItemCard extends StatelessWidget {
  final ItemGroup item;

  const ItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("this is the store page in the app");
    final discountedPrice = item.price * (1 - (item.discount / 100));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image(
              image: NetworkImage(item.image),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //   child: Text(
          //     discountedPrice != 0
          //         ? 'Free'
          //         : '\$${discountedPrice.toStringAsFixed(2)}',
          //     // "Free",
          //     style: const TextStyle(
          //         fontSize: 14,
          //         color: Colors.green,
          //         fontWeight: FontWeight.bold),
          //   ),
          // ),

          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //   child: Text(
          //     'Original: \$${item.price.toStringAsFixed(2)}',
          //     style: const TextStyle(
          //         fontSize: 12,
          //         color: Colors.red,
          //         decoration: TextDecoration.lineThrough),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //   child: Text(
          //     '${item.discount.toStringAsFixed(0)}% OFF',
          //     style: const TextStyle(fontSize: 12, color: Colors.orange),
          //   ),
          // ),
        ],
      ),
    );
  }
}

typedef void DeleteCallback(int val, String type, int index);

typedef ItemTappedCallback = void Function(
    BuildContext context, String name, String titel, String gameImg);

class ListItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String gameImg;
  final int id;
  final int index;
  final DeleteCallback onClick;
  final ItemTappedCallback onItemTappedlist;

  const ListItem(
      {super.key,
      required this.imageUrl,
      required this.title,
      required this.description,
      required this.gameImg,
      required this.id,
      required this.index,
      required this.onClick,
      required this.onItemTappedlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 280,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // Shadow position
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main Content
            Container(
              width: 280,
              height: cardHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Game Image
                  Container(
                    height: 50,
                    width: 50,
                    margin: const EdgeInsets.only(left: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: gameImg == null || gameImg == ''
                          ? DecorationImage(
                              image: AssetImage(imageUrl),
                              fit: BoxFit.fill,
                            )
                          : DecorationImage(
                              image: NetworkImage(gameImg ?? ''),
                              fit: BoxFit.fill,
                            ),
                    ),
                  ),
                  // Title & Description
                  Container(
                    width: 210,
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            title,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Color(0xFF153792),
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 5),
                          child: Container(
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
                                    onItemTappedlist(
                                        context, description, title, gameImg);
                                  },
                                  child: description.isNotEmpty
                                      ? const Text(
                                          "Show More",
                                          style: TextStyle(
                                            color:
                                                Color.fromRGBO(70, 81, 111, 1),
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Positioned Edit & Delete Buttons at Bottom Right
            Positioned(
              bottom: 8,
              right: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Show edit button only if editType is "M"
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Color.fromRGBO(21, 55, 146, 1),
                    ),
                    onPressed: () {
                      onClick(id, 'edit', index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      size: 20,
                      color: Color.fromRGBO(221, 4, 4, 1),
                    ),
                    onPressed: () {
                      onClick(
                        id,
                        'delete',
                        index,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemEdit extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String description;
  final int id;
  const ItemEdit(
      {super.key,
      required this.imageUrl,
      required this.name,
      required this.description,
      required this.id});
  @override
  _ItemEditState createState() => _ItemEditState();
}

class _ItemEditState extends State<ItemEdit> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String imageUrl = '';
  bool _isLoading = false;
  bool _isLoading1 = false;
  bool _isNameError = false;
  bool imageLoader = false;

//class CreateHuntFormManualAdd extends StatelessWidget {
  File? galleryFile;
  final picker = ImagePicker();
  String uplodedImgUrl = "";
  @override
  void initState() {
    super.initState();

    nameController.text = widget.name!;
    descriptionController.text = widget.description!;
    uplodedImgUrl = widget.imageUrl!;
  }

  void _showImagePicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

// Function to get image from gallery or camera
  Future getImage(ImageSource img) async {
    final pickedFile = await picker.pickImage(source: img, imageQuality: 25);
    // if (pickedFile == null) return; // No image selected

    final cropImgData = await CropImageService.cropImage(pickedFile);
    setState(() {
      if (cropImgData != null) {
        imageLoader = true;
        galleryFile = File(cropImgData!.path);
        _uploadImage();
        // uplodedImgUrl = File(cropImgData!.path) as String;
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
      }
    });
  }

// Upload image function with async behavior
  Future<void> _uploadImage() async {
    if (galleryFile == null) return;
    String uploadUrl = '${ApiConstants.uploadUrl}/upload';
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files
        .add(await http.MultipartFile.fromPath('file', galleryFile!.path));
    var response = await request.send();
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      final jsonResponseData = UploadImageResponse.fromJson(jsonResponse);
      if (jsonResponseData.success) {
        print(jsonResponseData.result.secureUrl);
        setState(() {
          uplodedImgUrl = jsonResponseData.result.secureUrl;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('hunt failed: ${jsonResponseData.mesasge}'),
        ));
      }
    } else {
      print('Image upload failed with status: ${response.statusCode}');
    }
    setState(() {
      imageLoader = false;
    });
  }

  Future<void> onSave(String name, String desc, String img, int id) async {
    setState(() {
      _isLoading1 = true;
    });
    var reqData = {
      "name": name,
      "description": desc,
      "imageurl": uplodedImgUrl,
      "id": id
    };
    ApiService.updateChallengeItem(reqData).then((res) {
      try {
        if (res.success) {
          Navigator.pop(context, 'add item from Screen!');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add item: ${res.message}'),
          ));
        }
      } catch (error) {
        // print(error);
      } finally {
        setState(() {
          _isLoading1 = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modal Header
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          // Image Section
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              imageLoader == true
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : CircleAvatar(
                      radius: 50,
                      backgroundImage: uplodedImgUrl.isNotEmpty
                          ? NetworkImage(uplodedImgUrl)
                          : const AssetImage('assets/images/defaultImg.jpg')
                              as ImageProvider,
                    ),
              imageLoader == true
                  ? SizedBox()
                  : IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.blue),
                      onPressed: () {
                        _showImagePicker(context: context);
                      },
                    ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: nameController,
            labelText: 'Name:',
            hintText: 'Enter Name',
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: descriptionController,
            labelText: 'Description:',
            hintText: 'Enter Description',
            maxLines: 3,
          ),

          const SizedBox(height: 20),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(11, 0, 171, 1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextButton(
                onPressed: () {
                  onSave(nameController.text, descriptionController.text,
                      imageUrl, widget.id);
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
                      'Save',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // child: ElevatedButton(
            //   onPressed: () {
            //     onSave(nameController.text, descriptionController.text,
            //         imageUrl, widget.id);
            //   },
            //   child: const Text("Save"),
            // ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ItemAdd extends StatefulWidget {
  final int Itemlist;
  const ItemAdd({
    required this.Itemlist,
    super.key,
  });
  @override
  _ItemAddState createState() => _ItemAddState();
}

class _ItemAddState extends State<ItemAdd> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String imageUrl = '';
  bool _isLoading = false;
  bool _isLoading1 = false;
  bool _isNameError = false;
  bool imageLoader = false;
  PolicyResult? isCheckSubcription;

//class CreateHuntFormManualAdd extends StatelessWidget {
  File? galleryFile;
  final picker = ImagePicker();
  String uplodedImgUrl = "";
  @override
  void initState() {
    super.initState();
    nameController.text = "";
    descriptionController.text = "";
    uplodedImgUrl = "";
    getSubcriptionCheck();
  }

  void _showImagePicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

// Function to get image from gallery or camera
  Future getImage(ImageSource img) async {
    final pickedFile = await picker.pickImage(source: img, imageQuality: 25);
    // if (pickedFile == null) return; // No image selected

    final cropImgData = await CropImageService.cropImage(pickedFile);
    setState(() {
      if (cropImgData != null) {
        imageLoader = true;
        galleryFile = File(cropImgData!.path);
        _uploadImage();
        // uplodedImgUrl = File(cropImgData!.path) as String;
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
      }
    });
  }

// Upload image function with async behavior
  Future<void> _uploadImage() async {
    if (galleryFile == null) return;
    String uploadUrl = '${ApiConstants.uploadUrl}/upload';
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files
        .add(await http.MultipartFile.fromPath('file', galleryFile!.path));
    var response = await request.send();
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      final jsonResponseData = UploadImageResponse.fromJson(jsonResponse);
      if (jsonResponseData.success) {
        setState(() {
          uplodedImgUrl = jsonResponseData.result.secureUrl;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('hunt failed: ${jsonResponseData.mesasge}'),
        ));
      }
    } else {
      print('Image upload failed with status: ${response.statusCode}');
    }
    setState(() {
      imageLoader = false;
    });
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

  void onaddItem() async {
    if (nameController.text == "") {
      Fluttertoast.showToast(
        msg: "Please Enter The Item Name",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFF0B00AB),
        textColor: Colors.white,
      );
    } else {
      int? maxCreatedItems = isCheckSubcription?.maxCreatedItems;
      if (maxCreatedItems != null && (widget.Itemlist >= maxCreatedItems)) {
        showCurrentPlanAlertDialog(context, isCheckSubcription,
            "You have reached the limit of ${maxCreatedItems} items per hunt & Quests under your current subscription plan.");
      } else {
        onAdd(nameController.text, descriptionController.text, imageUrl);
      }
    }
  }

  Future<void> onAdd(String name, String desc, String img) async {
    setState(() {
      _isLoading1 = true;
    });
    var reqData = {
      "itemname": name,
      "description": desc,
      "imageurl": uplodedImgUrl,
      "point": 10
    };
    ApiService.addChallengeItem(reqData).then((res) {
      try {
        if (res.success) {
          Fluttertoast.showToast(
            msg: "Item Add succesfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Navigator.pop(context, 'add item from Screen!');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add item: ${res.message}'),
          ));
        }
      } catch (error) {
        // print(error);
      } finally {
        setState(() {
          _isLoading1 = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modal Header
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          // Image Section
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              imageLoader == true
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : CircleAvatar(
                      radius: 50,
                      backgroundImage: uplodedImgUrl.isNotEmpty
                          ? NetworkImage(uplodedImgUrl)
                          : const AssetImage('assets/images/defaultImg.jpg')
                              as ImageProvider,
                    ),
              imageLoader == true
                  ? SizedBox()
                  : IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.blue),
                      onPressed: () {
                        _showImagePicker(context: context);
                      },
                    ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: nameController,
            labelText: 'Name:',
            hintText: 'Enter Name',
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: descriptionController,
            labelText: 'Description:',
            hintText: 'Enter Description',
            maxLines: 3,
          ),

          const SizedBox(height: 20),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(11, 0, 171, 1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextButton(
                onPressed: () {
                  onaddItem();
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
                      'Add',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     onaddItem();
            //   },
            //   child: const Text("Add"),
            // ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
