import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'model/leaderboard.model.dart';
import 'services/api.service.dart';

class LeaderboardPage extends StatefulWidget {
  final int gameId;
  const LeaderboardPage({super.key, required this.gameId});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<LeaderBoardModel> teams = [];
  List<LeaderBoardModel> mainArr = [];
  LeaderBoardModel firstPl = LeaderBoardModel(
      teamId: '',
      userId: 0,
      userName: "",
      totalItems: 0,
      notAttemptedItems: 0,
      acceptedItems: 0,
      rejectItems: 0,
      userImg: "");
  LeaderBoardModel secondPl = LeaderBoardModel(
      teamId: '',
      userId: 0,
      userName: "",
      totalItems: 0,
      notAttemptedItems: 0,
      acceptedItems: 0,
      rejectItems: 0,
      userImg: "");
  LeaderBoardModel thirdPl = LeaderBoardModel(
      teamId: '',
      userId: 0,
      userName: "",
      totalItems: 0,
      notAttemptedItems: 0,
      acceptedItems: 0,
      rejectItems: 0,
      userImg: "");

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getLeaderboardData();
  }

  void getLeaderboardData() async {
    ApiService.getLeaderboardData(widget.gameId).then((value) async {
      if (value.success) {
       log(value.response.toString());
        teams = List<LeaderBoardModel>.from(
              value.response.map((x) => LeaderBoardModel.fromJson(x)));
      
        var modArr = [];
        for (var i = 0; i < teams.length; i++) {
          if (teams.length > 0) {
            firstPl = teams[0];
          }
          if (teams.length > 1) {
            secondPl = teams[1];
          }
          if (teams.length > 2) {
            thirdPl = teams[2];
          }
        }
        if (teams.length > 3) {
          mainArr = teams.sublist(3);
        } else {
          mainArr = [];
        }
        if(mounted) {
          setState((){});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) {
            return;
          }
          // Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => const HomeScreen(userName: '')));

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(userName: ''),
            ),
            (Route<dynamic> route) => false,
          );
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(userName: ''),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            title: const Text("Leaderboard"),
            automaticallyImplyLeading: false, // Remove the back button
            backgroundColor: const Color(0xFF0B00AB),
            foregroundColor: Colors.white,
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.share),
            //     onPressed: () {},
            //   ),
            // ],
          ),
          body: Stack(
            children: [
              Stack(
                children: [
                  Positioned(
                    // height: ,
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/leaderboard1.png",
                          fit: BoxFit.cover,
                          // height: 300,
                        ),
                        SizedBox(
                          height: 10,
                          child: Image.asset(
                            "assets/images/line.png",
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height / 2.1,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: mainArr.length,
                      itemBuilder: (context, index) {
                        final item = mainArr[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                              right: 20, left: 20, bottom: 15),
                          child: Row(
                            children: [
                              Text(
                                '#${index + 4}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              const CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                    AssetImage('assets/images/greatImg.png'),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                item.userName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                height: 25,
                                width: 70,
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Row(
                                  children: [
                                    const SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ),
              // Positioned(
              //   top: 290,
              //   height: 40,
              //   width: MediaQuery.of(context).size.width - 20,
              //   left: 10,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Navigator.pushReplacement(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) =>
              //                   const HomeScreen(userName: "")));
              //     },
              //     style: ElevatedButton.styleFrom(
              //       padding: const EdgeInsets.only(left: 2),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //         side: const BorderSide(
              //           color: Color(0xFF153792),
              //         ),
              //       ),
              //       backgroundColor: const Color.fromARGB(255, 249, 248, 252),
              //       // foregroundColor: const Color.fromARGB(255, 227, 227, 231),
              //       elevation: 0,
              //     ),
              //     child: const Text(
              //       'Back to Dashboard',
              //       style:
              //           TextStyle(fontSize: 14, color: const Color(0xFF153792)),
              //     ),
              //   ),
              // ),
              firstPl.userName.isNotEmpty
                  ? Positioned(
                      top: 35,
                      right: Platform.isAndroid ? 145 : 155,
                      width: Platform.isAndroid ? 100 : 120,
                      child: rank(
                          radius: 45.0,
                          height: 20,
                          image: firstPl.userImg ?? '',
                          name: firstPl.userName ?? '',
                          point: "23131"),
                    )
                  : SizedBox(),
              // for rank 2nd
              secondPl.userName.isNotEmpty
                  ? Positioned(
                      top: 115,
                      left: 30,
                      width: Platform.isAndroid ? 100 : 120,
                      child: rank(
                          radius: 30.0,
                          height: 10,
                          image: secondPl.userImg ?? '',
                          name: secondPl.userName,
                          point: "12323"),
                    )
                  : SizedBox(),
              // For 3rd rank
              thirdPl.userName.isNotEmpty
                  ? Positioned(
                      top: 138,
                      right: 35,
                      width: Platform.isAndroid ? 100 : 120,
                      child: rank(
                          radius: 30.0,
                          height: 10,
                          image: thirdPl.userImg ?? '',
                          name: thirdPl.userName,
                          point: "6343"),
                    )
                  : SizedBox()
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(userName: ''),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.only(left: 2),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFF153792),
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 249, 248, 252),
                // foregroundColor: const Color.fromARGB(255, 227, 227, 231),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text('Back to Dashboard',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  // const Text('|'),
                  // Text('\$ ${itemGroupDetails.price}',
                  // ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterFloat,
        ));
  }

  Column rank({
    required double radius,
    required double height,
    required String image,
    required String name,
    required String point,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor:
              Colors.grey, // Helps in debugging if the image doesn't load
          backgroundImage: image.isNotEmpty
              ? NetworkImage(image) as ImageProvider
              : const AssetImage('assets/images/defaultImg.jpg'),
        ),
        SizedBox(
          height: height,
        ),
        Text(
          name,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.white,
              overflow: TextOverflow.ellipsis),
        ),
        SizedBox(
          height: height,
        ),
      ],
    );
  }
}
