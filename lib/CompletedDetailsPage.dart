import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/HuntCreationCompleteScreen.dart';
import 'package:scavenger_app/LeaderBoardPage.dart';
import 'package:scavenger_app/MyGameItemListResponse.dart';
import 'package:scavenger_app/WinnerLeaderBoard.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/model/completedDetails.model.dart';
import 'package:scavenger_app/model/relanch.result.dart';
import 'package:scavenger_app/pages/subcriptions/currentPlandialog.dart';
import 'package:scavenger_app/pages/subcriptions/subcription_popup.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/services/download.service.dart';
import 'package:scavenger_app/shared/video.widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CompletedDetailsPage extends StatefulWidget {
  final int gameId;
  final int isHost;
  final String gameuniqueId;
  final String gameType;
  final String cardType;
  final String myteam;

  const CompletedDetailsPage(
      {Key? key,
      required this.gameId,
      required this.isHost,
      required this.gameuniqueId,
      required this.gameType,
      required this.cardType,
      required this.myteam});

  @override
  _CompletedDetailsPageState createState() => _CompletedDetailsPageState();
}

class _CompletedDetailsPageState extends State<CompletedDetailsPage> {
  bool _isLoading = false;
  String gameImg = "";
  String gameTitle = "";
  String gameDes = "";
  String fetchDate = "";
  String fetchTime = "";
  String gameStartDate = "";
  List<String> splitData = [];
  List<HuntItem> items = [];
  List<Prize> prizes = [];
  StreamController<ErrorAnimationType>? errorController;
  int isPrize = 0;
  int isItem = 0;
  final String baseUrl = "https://d1nb9mmvrnnzth.cloudfront.net";
  String videoMainFile = "";
  String videoProcessed = "0";
  late DateTime endMainTime;
  late Duration remainingTime;
  Timer? _timer;
  List<ResultGameTeam> items1 = [];

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>.broadcast();
    super.initState();
    _getEndgameDetails();
    _NewmyGameItemList();
  }

  Future<void> _NewmyGameItemList() async {
    ApiService.fetchNewGameItemsList(
        {"teamId": widget.myteam, "gameId": widget.gameId}).then((res) {
      try {
        if (res.success) {
          // final jsonResponseData = List<ResultGameTeam>.from(
          //     res.response.map((x) => ResultGameTeam.fromJson(x)));
          final jsonResponseData = ResultData.fromJson(res.response);

          if (jsonResponseData.items.isNotEmpty) {
            items1 = jsonResponseData.items;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('hunt failed: ${res.message}'),
          ));
        }
      } catch (e) {}
    });
  }

  Future<void> _getEndgameDetails() async {
    setState(() {
      _isLoading = true;
    });
    var reqData = {"gameId": widget.gameId, "teamId": widget.myteam};
    ApiService.getEndGameDetails(reqData).then((value) {
      try {
        if (value.success) {
          final homeResponse = CompletedGameDetails.fromJson(value.response);
          setState(() {
            gameTitle = homeResponse.title;
            gameDes = homeResponse.description;
            videoMainFile = homeResponse.videoFile ?? "";
            videoProcessed = homeResponse.videoProcessed;
            var startDate = homeResponse.inTime ?? "";
            gameImg = homeResponse.gameImg ?? '';
            if (startDate != '') {
              var date =
                  DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(startDate);
              gameStartDate = DateFormat("MM/dd/yyyy HH:mm aaa").format(date);
              fetchDate = DateFormat("MMM d, y 'at' h:mm a").format(date);
              // fetchDate = DateFormat('MM/dd/yy').format(date);
              fetchTime = DateFormat('hh:mm a').format(date);
            }

            if (homeResponse != null && homeResponse.gameRules != null) {
              splitData = homeResponse.gameRules!
                  .split('_')
                  .where((element) => element.trim().isNotEmpty)
                  .toList();
            } else {
              splitData = [];
            }
            // items = homeResponse.items;
            prizes = homeResponse.prizes;
          });
        } else {}
      } catch (error) {
        // print(error);
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onDownloadVideo(String url, String fileName) async {
    await downloadVideo(url, fileName);
  }

  void deleteGame() async {
    try {
      final res = await ApiService.deleteGame({"id": widget.gameId});
      if (res.success) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(userName: "", gameId: widget.gameId)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to delete : ${res.message ?? "Unknown error"}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {}
  }

  void _onRelanch() async {
    try {
      final res = await ApiService.relaunchGame({"gameId": widget.gameId});
      if (res.success) {
        var relanchData = RelanchModel.fromJson(res.response);
        // Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) =>
        //             HomeScreen(userName: "", gameId: widget.gameId)));
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HuntCreationCompleteScreen(
                    gameId: relanchData.id,
                    gameuniqueId: widget.gameuniqueId,
                    gameType: widget.gameType ?? 'hunt',
                    cardType: widget.cardType ?? "",
                    myteam: widget.myteam ?? '')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${res.message ?? "Unknown error"}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {}
  }

  void showDeleteDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Delete',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 89, 54, 244),
            ),
          ),
          content: const Text(
            'Are you sure you want to delete the game ?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            // Confirm Button
            TextButton(
                onPressed: () {
                  deleteGame();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 16),
                )),
          ],
        );
      },
    );
  }

  void onDelete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    PolicyResult? tempSubcriptionCheckNo;
    if (subcriptionCheckString != null && subcriptionCheckString.isNotEmpty) {
      try {
        Map<String, dynamic> decodedJson = jsonDecode(subcriptionCheckString);
        tempSubcriptionCheckNo = PolicyResult.fromJson(decodedJson);
      } catch (e) {
        tempSubcriptionCheckNo = null;
      }
    } else {
      tempSubcriptionCheckNo = null;
    }
    if (tempSubcriptionCheckNo != null) {
      showDeleteDialog(context);
    } else {
      showSubscriptionModal(context);
    }
  }

  void onRelaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    PolicyResult? tempSubcriptionCheckNo;
    if (subcriptionCheckString != null && subcriptionCheckString.isNotEmpty) {
      try {
        Map<String, dynamic> decodedJson = jsonDecode(subcriptionCheckString);
        tempSubcriptionCheckNo = PolicyResult.fromJson(decodedJson);
      } catch (e) {
        tempSubcriptionCheckNo = null;
      }
    } else {
      tempSubcriptionCheckNo = null;
    }
    if (tempSubcriptionCheckNo != null) {
      if (tempSubcriptionCheckNo.isRelaunch == 0) {
        // Fluttertoast.showToast(
        //   msg: "You can not relaunch the hunt.",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
        showCurrentPlanAlertDialog(context, tempSubcriptionCheckNo,
            "As per your current subscription plan you can not relaunch the hunt.");
      } else {
        showRelanchDialog(context);
      }
    } else {
      showSubscriptionModal(context);
    }
  }

  void showRelanchDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Relaunch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 89, 54, 244),
            ),
          ),
          content: const Text(
            'Are you sure you want to relaunch the hunt ?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            // Confirm Button
            TextButton(
                onPressed: () {
                  _onRelanch();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFD4E8E1),
                  foregroundColor: const Color(0xFF45AA6E),
                ),
                child: const Text(
                  'Relaunch',
                  style: TextStyle(fontSize: 16),
                )),
          ],
        );
      },
    );
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

    bool isPrizeAvailable = prizes.any((prize) =>
        (prize.firstDesc?.isNotEmpty ?? false) ||
        (prize.firstPrizeImgUrl?.isNotEmpty ?? false) ||
        (prize.secondDesc?.isNotEmpty ?? false) ||
        (prize.secondPrizeImgUrl?.isNotEmpty ?? false) ||
        (prize.thirdDesc?.isNotEmpty ?? false) ||
        (prize.thirdPrizeImgUrl?.isNotEmpty ?? false));

    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) {
            return;
          }
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const HomeScreen(userName: '')));
        },
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const HomeScreen(userName: '')));
                },
              ),
              title: const Text("Completed Details "),
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
            body: Skeletonizer(
                enabled: _isLoading,
                enableSwitchAnimation: true,
                child: Center(
                    child: Container(
                        padding: const EdgeInsets.only(top: 15),
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
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(0xFF153792),
                                    width: 3,
                                  ),
                                ),
                                child: gameImg.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          gameImg,
                                          fit: BoxFit.cover,
                                          width: 150,
                                          height: 150,
                                        ),
                                      )
                                    : const CircleAvatar(
                                        radius: 75,
                                        backgroundImage: AssetImage(
                                            'assets/images/defaultImg.jpg'),
                                      ),
                              ),
                              Text(
                                gameTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF153792),
                                  fontSize: 22,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (fetchDate != "" && fetchTime != "") ...[
                                Text(
                                  gameDes,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF153792),
                                    fontSize: 15,
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ] else ...[
                                const SizedBox.shrink(),
                              ],
                              Text(
                                fetchDate,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF153792),
                                  fontSize: 14,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (splitData.isNotEmpty) ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Rules:",
                                      style: TextStyle(
                                        color: Color(0xFF153792),
                                        fontSize: 18,
                                        fontFamily: 'Raleway',
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            10), // Add some spacing after "Rules:"
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: splitData.map((rule) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom:
                                                  8.0), // Space between rules
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 6),
                                                  child: Icon(
                                                    Icons.circle,
                                                    color: Color(0xFF153792),
                                                    size: 8,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  rule,
                                                  style: const TextStyle(
                                                    color: Color(0xFF153792),
                                                    fontSize: 14,
                                                    fontFamily: 'Raleway',
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ],

                              items1.isNotEmpty && widget.isHost != 1
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Items:",
                                          style: TextStyle(
                                            color: Color(0xFF153792),
                                            fontSize: 18,
                                            fontFamily: 'Raleway',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                10), // Add some spacing after "Rules:"
                                        ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          physics:
                                              const NeverScrollableScrollPhysics(), // Prevents ListView from scrolling independently
                                          itemCount: items1.length,

                                          itemBuilder: (context, index) {
                                            return ListItem(
                                              item: items1[index],
                                              onItemTappedlist: onItemlist,
                                            );
                                          },
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),

                              //  isPrize
                              const SizedBox(height: 20),
                              if (isPrizeAvailable)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Prizes:",
                                      style: TextStyle(
                                        color: Color(0xFF153792),
                                        fontSize: 18,
                                        fontFamily: 'Raleway',
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            10), // Add some spacing after "Rules:"
                                    ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: prizes.length,
                                      itemBuilder: (context, index) {
                                        return PrizesListItem(
                                          firstDesc:
                                              prizes[index].firstDesc ?? "",
                                          firstPrizeImgUrl:
                                              prizes[index].firstPrizeImgUrl ??
                                                  "",
                                          secondPrizeImgUrl:
                                              prizes[index].secondPrizeImgUrl ??
                                                  "",
                                          secondDesc:
                                              prizes[index].secondDesc ?? "",
                                          thirdPrizeImgUrl:
                                              prizes[index].thirdPrizeImgUrl ??
                                                  "",
                                          thirdDesc:
                                              prizes[index].thirdDesc ?? "",
                                          id: prizes[index].id,
                                          index: index,
                                        );
                                      },
                                    ),
                                  ],
                                )
                              else
                                const Center(
                                  child: Text(
                                    "No Prizes Available",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),
                              widget.isHost == 0
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 0),
                                      child: videoProcessed == "1"
                                          ? videoMainFile == "removed"
                                              ? const Text(
                                                  "Memory was deleted ",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        21, 55, 146, 1),
                                                  ),
                                                )
                                              : ElevatedButton(
                                                  onPressed: () {
                                                    String fullUrl =
                                                        "$baseUrl/${videoMainFile}";
                                                    _onDownloadVideo(
                                                        fullUrl, videoMainFile);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF153792),
                                                    foregroundColor:
                                                        Colors.white,
                                                    minimumSize: const Size(
                                                        double.infinity, 50),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                      'Download Video'))
                                          : const Text(
                                              "Memory is being prepared and will be available in approximately 10 minutes.",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    21, 55, 146, 1),
                                              ),
                                            ),
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LeaderboardPage(
                                                    gameId: widget.gameId)));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 85, 126, 238),
                                    foregroundColor: const Color(0xFFFFFFFF),
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text('Leaderboard')),
                              const SizedBox(
                                height: 10,
                              ),
                              widget.isHost == 1
                                  ? ElevatedButton(
                                      onPressed: () {
                                        // _onRelanch();
                                        onRelaunch();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFD4E8E1),
                                        foregroundColor:
                                            const Color(0xFF45AA6E),
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text('Relaunch'))
                                  : const SizedBox(),
                              const SizedBox(
                                height: 10,
                              ),
                              widget.isHost == 1
                                  ? ElevatedButton(
                                      onPressed: () {
                                        onDelete();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 252, 252, 252),
                                        foregroundColor: const Color.fromARGB(
                                            255, 240, 47, 47),
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text('Delete'))
                                  : const SizedBox(
                                      height: 10,
                                    ),
                            ],
                          ),
                        ))))));
  }
}

void _showImagePopup(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

_showVideoDialog(BuildContext context, String url) {
  var vUrl = url;
  return showDialog(
      context: context,
      builder: (context) {
        return Center(
            child: SizedBox(
                height: 400,
                width: 500,
                child: VideoWidget(url: vUrl, play: true)));
      });
}

typedef ItemTappedCallback = void Function(
    BuildContext context, String name, String titel, String imagePath);

class ListItem extends StatelessWidget {
  final ResultGameTeam item;
  // final String subtitle;
  // final String imagePath;
  // final int id;
  // final int index;
  final ItemTappedCallback onItemTappedlist;

  const ListItem({
    super.key,
    required this.item,
    // required this.subtitle,
    // required this.imagePath,
    // required this.id,
    // required this.index,
    required this.onItemTappedlist,
  });

  @override
  Widget build(BuildContext context) {
    bool isVideo = item.itemImgUrl != null &&
        (item.itemImgUrl.endsWith(".mp4") ||
            item.itemImgUrl.endsWith(".MOV") ||
            item.itemImgUrl.endsWith(".mov"));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          item.item.imgUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(item.item.imgUrl),
                  radius: 30.0,
                )
              : const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/defaultImg.jpg'),
                ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.item.name,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(21, 55, 146, 1.0),
                  ),
                ),
                Text(
                  item.item.description,
                  style: const TextStyle(
                    color: Color.fromRGBO(70, 81, 111, 1),
                    fontSize: 14.0,
                    height: 1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          // title: const Text("Full Description"),
                          content: SingleChildScrollView(
                              child: Column(
                            children: [
                              // Text(
                              //   title,
                              //   style: const TextStyle(
                              //     fontSize: 16,
                              //     color: Colors.black,
                              //     fontFamily: 'Jost',
                              //   ),
                              // ),
                              Text(
                                item.item.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontFamily: 'Jost',
                                ),
                              ),
                            ],
                          )),
                        );
                      },
                    );
                  },
                  child: item.item.description.isNotEmpty &&
                          item.item.description.length > 30
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
                ),
                // Container(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         item.item.description,
                //         style: const TextStyle(
                //           fontSize: 12,
                //           color: Color.fromRGBO(70, 81, 111, 1),
                //           fontWeight: FontWeight.w400,
                //           overflow: TextOverflow.ellipsis,
                //           height: 1,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 4.0),
                // if (isItemApproved)
                //   Text(
                //     gameType == 'hunt' ? statusText : '',
                //     style: TextStyle(
                //       color: statusColor,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
              ],
            ),
          ),
          item.isUploading!
              ? const CircularProgressIndicator()
              : item.itemImgUrl == null || item.status == "2"
                  ? Text("")
                  : isVideo
                      ? GestureDetector(
                          onTap: () =>
                              _showVideoDialog(context, item.itemImgUrl),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              item.snapshot != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(item
                                          .snapshot), // Placeholder for video
                                      radius: 30.0,
                                    )
                                  : const CircleAvatar(
                                      backgroundImage: AssetImage(
                                          "assets/images/logo.jpg"), // Placeholder for video
                                      radius: 30.0,
                                    ),
                              const Icon(
                                Icons.play_circle_fill,
                                color: Color.fromRGBO(21, 55, 146, 1.0),
                                size: 30.0,
                              ),
                            ],
                          ))
                      : GestureDetector(
                          onTap: () =>
                              _showImagePopup(context, item.itemImgUrl),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(item.itemImgUrl),
                            radius: 30.0,
                          ),
                        ),
        ],
      ),
    );
    // ClipRRect(
    //   borderRadius: BorderRadius.circular(16), // Adjust the radius as needed
    //   child: Container(
    //     margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
    //     color: Colors.white,
    //     child: ListTile(
    //       leading: imagePath != ''
    //           ? CircleAvatar(
    //               radius: 20,
    //               backgroundImage: NetworkImage(imagePath),
    //             )
    //           : const CircleAvatar(
    //               radius: 20,
    //               backgroundImage: AssetImage('assets/images/defaultImg.jpg'),
    //             ),
    //       title: Text(
    //         title,
    //         style: const TextStyle(
    //           fontSize: 16,
    //           fontWeight: FontWeight.bold,
    //           color: Color.fromRGBO(21, 55, 146, 1),
    //           overflow: TextOverflow.ellipsis,
    //           height: 1,
    //         ),
    //       ),
    //       subtitle: Container(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text(
    //               subtitle,
    //               style: const TextStyle(
    //                   fontSize: 12,
    //                   color: Color.fromRGBO(19, 49, 131, 1),
    //                   fontWeight: FontWeight.w400,
    //                   overflow: TextOverflow.ellipsis),
    //             ),
    //             GestureDetector(
    //               onTap: () {
    //                 onItemTappedlist(context, subtitle, title, imagePath);
    //               },
    //               child: subtitle.isNotEmpty
    //                   ? const Text(
    //                       "Show More",
    //                       style: TextStyle(
    //                         color: Color.fromRGBO(70, 81, 111, 1),
    //                         fontSize: 12.0,
    //                         height: 1,
    //                         decoration: TextDecoration
    //                             .underline, // Optional: underline for interactivity
    //                       ),
    //                     )
    //                   : const SizedBox(),
    //             )
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class PrizesListItem extends StatelessWidget {
  final String firstDesc;
  final String firstPrizeImgUrl;
  final String secondPrizeImgUrl;
  final String secondDesc;
  final String thirdPrizeImgUrl;
  final String thirdDesc;

  final int id;
  final int index;

  const PrizesListItem({
    super.key,
    required this.firstDesc,
    required this.firstPrizeImgUrl,
    required this.secondPrizeImgUrl,
    required this.secondDesc,
    required this.thirdPrizeImgUrl,
    required this.thirdDesc,
    required this.id,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(16), // Rounded corners for the container
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: 4.0, horizontal: 8.0), // Spacing around the container
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Padding inside the container
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row for first image and description
              // firstPrizeImgUrl.isNotEmpty && firstDesc.isNotEmpty
              // ?
              if (firstPrizeImgUrl.isNotEmpty || firstDesc.isNotEmpty)
                Row(
                  children: [
                    const Text(
                      "1st",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(21, 55, 146, 1),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    firstPrizeImgUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(firstPrizeImgUrl),
                          )
                        : const CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                AssetImage('assets/images/defaultImg.jpg'),
                          ),
                    const SizedBox(width: 8), // Spacing between image and text
                    Expanded(
                      child: firstDesc.isNotEmpty
                          ? Text(
                              firstDesc,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 55, 146, 1),
                              ),
                            )
                          : const Text(
                              "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 55, 146, 1),
                              ),
                            ),
                    ),
                  ],
                ),
              // : const SizedBox(),
              const SizedBox(height: 8),
              //  secondPrizeImgUrl.isNotEmpty && secondDesc.isNotEmpty
              //
              //  ?
              if (secondPrizeImgUrl.isNotEmpty || secondDesc.isNotEmpty)
                Row(
                  children: [
                    const Text(
                      "2nd",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(21, 55, 146, 1),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    secondPrizeImgUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(secondPrizeImgUrl),
                          )
                        : const CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                AssetImage('assets/images/defaultImg.jpg'),
                          ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: secondDesc.isNotEmpty
                          ? Text(
                              secondDesc,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 55, 146, 1),
                              ),
                            )
                          : const Text(
                              "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 55, 146, 1),
                              ),
                            ),
                    ),
                  ],
                ),
              // : const SizedBox(),
              const SizedBox(height: 8),
              // Row for third image and description
              if (thirdPrizeImgUrl.isNotEmpty || thirdDesc.isNotEmpty)
                Row(
                  children: [
                    const Text(
                      "3rd",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(21, 55, 146, 1),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    thirdPrizeImgUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(thirdPrizeImgUrl),
                          )
                        : const CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                AssetImage('assets/images/defaultImg.jpg'),
                          ),
                    const SizedBox(width: 8), // Spacing between image and text
                    Expanded(
                      child: thirdDesc.isNotEmpty
                          ? Text(
                              thirdDesc,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 55, 146, 1),
                              ),
                            )
                          : const Text(
                              "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 55, 146, 1),
                              ),
                            ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
