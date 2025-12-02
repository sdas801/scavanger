import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/model/item.model.dart';
import 'package:scavenger_app/pages/store/item_details.page.dart';
import 'package:scavenger_app/pages/subcriptions/currentPlandialog.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final ScrollController _scrollController = ScrollController();
  List<ItemGroup> items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int limit = 10;
  int pageNum = 0;
  PolicyResult? isCheckSubcription;
  List<itemCatagory> catagoryArr = [];
  List<itemCatagory> subCatagoryArr = [];
  int catagoryId = 0;
  int subCatagoryId = 0;
  bool hideSearchBox = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getItemGroup("", catagoryId, subCatagoryId);
    getSubcriptionCheck();
    _onCatagoryApiCall();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  void getSubcriptionCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    if (subcriptionCheckString != null) {
      Map<String, dynamic> jsonData = jsonDecode(subcriptionCheckString);
      if (mounted) {
        setState(() {
          isCheckSubcription = PolicyResult.fromJson(jsonData);
        });
      }
    }
  }

  // Future<void> _onScroll() async {
  //   if (_scrollController.position.pixels ==
  //           _scrollController.position.maxScrollExtent &&
  //       !_isLoading &&
  //       _hasMore) {
  //     // Check if more data is available
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     pageNum = pageNum + 1;
  //     await getItemGroup("", catagoryId, subCatagoryId);
  //   }
  // }

  Future<void> _onScroll() async {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !_isLoading &&
        _hasMore) {
      pageNum += 1;
      await getItemGroup("", catagoryId, subCatagoryId);
    }
  }

  Future<void> getItemGroup(
      String value, int catagoryId, int subCatagoryId) async {
    if (_isLoading) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
        if (value.isEmpty && pageNum == 0) {
          items.clear();
        }
      });
    }

    try {
      var reqData = {
        "searchText": value,
        "limit": limit.toString(),
        "offset": (pageNum * limit).toString(),
        "category_id": catagoryId == 0 ? "" : catagoryId,
        "sub_category_id": subCatagoryId == 0 ? "" : subCatagoryId,
      };
      var response = await ApiService.getItemGroupList(reqData);
      if (response.success) {
        List<ItemGroup> newItems = (response.response as List)
            .map((i) => ItemGroup.fromJson(i))
            .toList();
        if (mounted) {
          setState(() {
            if (pageNum == 0) {
              items = newItems;
            } else {
              items.addAll(newItems);
            }
            _hasMore = newItems.length == limit;
          });
        }
      }
    } catch (e) {
      print("Error fetching items: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(11, 0, 171, 1),
      width: double.infinity,
      height: double.infinity,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height - 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
              child: TextField(
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
                  if (mounted) {
                    setState(() {
                      items.clear();
                      pageNum = 0;
                      _hasMore = true;
                      catagoryId = 0;
                      subCatagoryId = 0;
                    });
                  }
                  getItemGroup(value, catagoryId, subCatagoryId);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                height: Platform.isAndroid ? 40 : 45,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 241, 239, 239),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 241, 239, 239),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      DropdownButton<int>(
                        value: catagoryId == 0 ? null : catagoryId,
                        hint: const Text('Select a Category  '),
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
                          if (mounted) {
                            setState(() {
                              catagoryId = value ?? 0;
                              subCatagoryId = 0;
                              pageNum = 0;
                            });
                          }
                          getItemGroup("", catagoryId, subCatagoryId);
                          if (catagoryId != 0) {
                            _onSubCatagoryApiCall(value);
                          } else {
                            getItemGroup("", 0, 0);
                            if (mounted) {
                              setState(() {
                                catagoryId = 0;
                              });
                            }
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
                ),
              ),
            ),
            // const SizedBox(height: 8),
            catagoryId != 0
                ? Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      height: Platform.isAndroid ? 40 : 45,
                      // margin: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 241, 239, 239),
                        // border:
                        //     Border.all(color: Colors.grey), // Set your desired color
                        borderRadius: BorderRadius.circular(
                            30), // Optional: Add rounded corners
                      ),

                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 241, 239, 239),
                          borderRadius: BorderRadius.circular(30),
                        ),
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
                                    getItemGroup("", catagoryId, 0);
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
                      ),
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 20),
            if (items.isEmpty && !_isLoading)
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  const Center(
                      child: Icon(Icons.store, size: 50, color: Colors.red)),
                  const SizedBox(height: 10),
                  const Center(child: Text('No items available')),
                ],
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: GridView.builder(
                  controller: _scrollController,
                  itemCount: _isLoading ? items.length + 6 : items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.75,
                    // mainAxisExtent: 200
                  ),
                  itemBuilder: (_, int index) {
                    if (index < items.length) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ItemDetailsPage(itemGroupId: items[index].id),
                            ),
                          );
                          // }
                        },
                        child: ItemCard(item: items[index]),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final ItemGroup item;

  ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final discountedPrice = item.price * (1 - (item.discount / 100));
    // log("this is the store page in the app>>>> $discountedPrice");
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image(
            image: NetworkImage(
              item.image,
            ),
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            item.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            discountedPrice == 0.0
                ? 'Free'
                : '\$${discountedPrice.toStringAsFixed(2)}',

            // "free",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (item.discount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Original: \$${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        if (item.discount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${(item.discount).toStringAsFixed(0)}% OFF',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.orange,
              ),
            ),
          )
      ]),
    );
  }
}
