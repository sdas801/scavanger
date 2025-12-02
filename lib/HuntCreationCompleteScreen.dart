import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:scavenger_app/CreateHunt1stPage.dart';
import 'package:scavenger_app/CreateHuntFormTime.dart';

import 'package:scavenger_app/CreateNewTeam.dart';
import 'package:scavenger_app/GameTeamListResponse.dart';

import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/HuntDashboard.dart';
import 'package:scavenger_app/PrejoiningHunt.dart';
import 'package:scavenger_app/PrejoiningStartHunt.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/pages/challenge/create_step_one.page.dart';
import 'package:scavenger_app/pages/subcriptions/subcription_popup.dart';
import 'package:scavenger_app/shared/details.Widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:convert';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:scavenger_app/CreatedGameDetailsResponse.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/JoinGameResponse.dart';
import 'package:intl/intl.dart';

class HuntCreationCompleteScreen extends StatefulWidget {
  final int gameId;
  final String gameuniqueId;
  final String gameType;
  final String cardType;
  final String myteam;

  const HuntCreationCompleteScreen(
      {super.key,
      required this.gameId,
      required this.gameuniqueId,
      required this.gameType,
      required this.cardType,
      required this.myteam});

  @override
  _HuntCreationCompleteScreenState createState() =>
      _HuntCreationCompleteScreenState();
}

class _HuntCreationCompleteScreenState
    extends State<HuntCreationCompleteScreen> {
  List<ResultGameteamItem> items = [];
  bool isTimedHunt = false;
  bool willOfferPrizes = false;
  bool willApproveItems = false;
  bool allowMessaging = false;
  bool _isLoading = false;
  String? selectedTeam;
  String qrCode = "";
  String assignFor = "self";
  String gameName = "";
  String gameStartDate = "";
  String? inTime = "";
  ScreenshotController screenshotController = ScreenshotController();

  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  bool hasError = false;
  String currentText = "";
  String teamId = "";
  String desData = "";
  String fetchDate = "";
  String fetchTime = "";
  List<String> splitData = [];
  String gameStatus = '0';
  String status = "";
  List<HuntItem> itemArr = [];

  int teamStatusId = 0;
  int gameId = 0;
  String gameImg = "";
  Timer? _timer;
  bool isTimeCheck = false;
  bool startTimeCheck = false;
  String gameRules = "";
  List<ResultGameteamItem> teams = [];
  List<Prize> prizes = [];

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>.broadcast();
    super.initState();
    _getgameDetails();
  }

  Future<void> _getgameDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    String authToken = "";
    String OTP = '';

    ApiService.gameDetails(widget.gameId).then((value) {
      if (value.success) {
        var homeResponse = Result.fromJson(value.response);
        prizes = homeResponse.prizes;
        qrCode = homeResponse.qrCode.replaceAll('data:image/png;base64,', '');
        gameName = homeResponse.title;
        desData = homeResponse.description;
        gameStatus = homeResponse.status;
        gameId = homeResponse.id;
        gameImg = homeResponse.gameImg ?? "";
        isTimeCheck = homeResponse.isTimed;
        status = homeResponse.status;
        var startDate = homeResponse.inTime ?? "";
        if (homeResponse.gameRules != null) {
          splitData = (homeResponse.gameRules ?? '')
              .split('_')
              .where((element) => element.trim().isNotEmpty)
              .toList();
        } else {
          splitData = [];
        }
        gameRules = homeResponse.gameRules ?? '';
        itemArr = homeResponse.items;
        if (startDate != '') {
          var date =
              DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(startDate);
          gameStartDate = DateFormat("MMM d, y 'at' h:mm a").format(date);
          fetchDate = DateFormat('MMM dd, yyyy').format(date);
          fetchTime = DateFormat('hh:mm a').format(date);
        }

        OTP = homeResponse.otp;
        textEditingController.text = OTP.toString();
        assignFor = homeResponse.assignFor ?? "others";
        inTime = homeResponse.inTime;
        if (widget.cardType != "joined") {
          _teamList();
          if (status != '2') {
            _timer =
                Timer.periodic(const Duration(seconds: 15), (_) => _teamList());
          }
        }
        if (mounted) setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed: ${value.message}'),
        ));
      }
    });
    if (mounted)
      setState(() {
        _isLoading = false;
      });
  }

  Future<void> _teamList() async {
    ApiService.getGameTeam({"game_id": widget.gameId}).then((value) {
      if (value.success) {
        // final jsonResponseData = GameTeamListResponse.fromJson(value.response);
        teams = List<ResultGameteamItem>.from(
            value.response.map((x) => ResultGameteamItem.fromJson(x)));
        if (mounted) setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed: ${value.message}'),
        ));
      }
    });
  }

  Future<void> _joinGame(gameid, gameuniqueId, gameType) async {
    ApiService.joinGame({"game_id": gameid, "game_unique_id": gameuniqueId})
        .then((res) {
      try {
        if (res.success) {
          final jsonResponseData = JoinGameDtl.fromJson(res.response);
          if (mounted)
            setState(() {
              teamId = jsonResponseData.gamePlay.teamId;
              teamStatusId = jsonResponseData.gamePlay.id;
            });
          _changeStatus(jsonResponseData.gamePlay.id);
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } catch (error) {
        // print(error);
      }
    });
  }

  void _changeStatus(statusChangeId) {
    ApiService.changeGameStatus({"id": statusChangeId}).then((res) {
      try {
        print('status changed');
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } catch (error) {
        // print(error);
      }
    });
  }

  void _activateGame() {
    ApiService.activateGame({
      "id": widget.gameId,
    }).then((res) {
      try {
        if (res.success) {
          if (assignFor == "self") {
            _joinGame(widget.gameId, widget.gameuniqueId, widget.gameType);
          }
          if (inTime == null || inTime == '') {
            _updateInTime();
          } else {}
        }
      } catch (error) {
        // print(error);
      }
    });
  }

  void _updateInTime() {
    ApiService.updateInTime({
      "id": widget.gameId,
      "type": "start",
      "game_time": DateTime.now().toString()
    }).then((res) {
      try {
        if (res.success) {}
      } catch (error) {
        // print(error);
      }
    });
  }

  void deleteGame() async {
    try {
      final res = await ApiService.deleteGame({"id": gameId});
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

  void leaveHunt() async {
    try {
      final res = await ApiService.leaveGame({"gameId": gameId});
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

  Future<void> _startHunt() async {
    if (mounted)
      setState(() {
        _isLoading = true;
      });
    if (_timer != null) {
      _timer?.cancel();
    }
    ApiService.activateGame({
      "id": widget.gameId,
    }).then((res) {
      try {
        if (res.success) {
          if (!isTimeCheck) {
            _updateInTime();
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PrejoiningStartHunt(gameId: widget.gameId)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('hunt failed: ${res.message}'),
          ));
        }
      } catch (error) {
        // print(error);
      }
    });
    if (mounted)
      setState(() {
        _isLoading = false;
      });
  }

  void showDeleteDialog(BuildContext context, String type, String gameType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: type == "leave"
              ? const Text(
                  'Confirm Leave',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                )
              : const Text(
                  'Confirm Delete',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 89, 54, 244),
                  ),
                ),
          content: type == "leave"
              ? Text(
                  'Are you sure you want to leave $gameType?',
                  style: const TextStyle(fontSize: 16),
                )
              : Text(
                  'Are you sure you want to delete $gameType?',
                  style: const TextStyle(fontSize: 16),
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
                  if (type == "leave") {
                    leaveHunt();
                  } else {
                    deleteGame();
                  }
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: type == "leave"
                    ? const Text(
                        'Leave',
                        style: TextStyle(fontSize: 16),
                      )
                    : const Text(
                        'Delete',
                        style: TextStyle(fontSize: 16),
                      )),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (errorController != null) errorController!.close();
    if (_timer != null) {
      _timer?.cancel();
    }
    super.dispose();
  }

  void _showTimeDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "As the $gameName  is a timed hunt. you need to modify the game details.",
            style: const TextStyle(
              fontSize: 15,
              color: Color.fromARGB(255, 14, 8, 8),
              fontWeight: FontWeight.w500,
            ),
          ),
          content: const Text("Do you want to proceed or cancel"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel",
                  style: TextStyle(color: Color.fromARGB(255, 202, 74, 65))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateHuntFormTime(
                            gameId: widget.gameId,
                            gameuniqueId: widget.gameuniqueId)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 57, 41, 206),
              ),
              child: const Text(
                "Proceed",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onGameStartEarly() async {
    if (mounted)
      setState(() {
        _isLoading = true;
      });
    var reData = {
      "id": widget.gameId,
      "start_time": DateTime.now().toString(),
    };
    ApiService.updateIntimeGame(reData).then((res) {
      try {
        if (res.success) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PreJoiningScreen(
                        gameId: widget.gameId,
                        gameuniqueId: widget.gameuniqueId,
                      )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('hunt failed: ${res.message}'),
          ));
        }
      } catch (error) {
        // print(error);
      }
    });
    if (mounted)
      setState(() {
        _isLoading = false;
      });
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Start Hunt Early?"),
          content: const Text(
            "You are about to start the hunt before the scheduled time. Do you want to start it early?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _onGameStartEarly();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void onStart() async {
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
      if (widget.gameType == 'challenge') {
        _activateGame();
      } else {
        if (isTimeCheck) {
          if (fetchDate != "" && fetchTime != "") {
            DateFormat format = DateFormat("MMM d, y 'at' h:mm a");
            DateTime now = DateTime.now();
            DateTime roundedTime = DateTime(
              now.year,
              now.month,
              now.day,
              now.hour,
              now.minute,
            );
            DateTime startTime = format.parse(gameStartDate);
            bool isStartEqualToCurrent =
                roundedTime.isAtSameMomentAs(startTime);
            bool isCurrentGreaterThanStart = roundedTime.isAfter(startTime);
            bool startTimeCheck =
                isStartEqualToCurrent || isCurrentGreaterThanStart;

            if (startTimeCheck == false) {
              showCustomDialog(context);
              // Fluttertoast.showToast(
              //   msg:
              //       "You can't start the game.Your game will be started at $gameStartDate",
              //   toastLength: Toast.LENGTH_SHORT,
              //   gravity: ToastGravity.CENTER,
              //   backgroundColor: const Color.fromARGB(
              //       255, 17, 16, 16),
              //   textColor: const Color.fromARGB(
              //       255, 240, 236, 236),
              //   fontSize: 14.0,
              // );
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PreJoiningScreen(
                            gameId: widget.gameId,
                            gameuniqueId: widget.gameuniqueId,
                          )));
            }
          } else {
            _showTimeDialog(context, "startHunt");
            // Fluttertoast.showToast(
            //   msg:
            //       "Please complete your hunt information",
            //   toastLength: Toast.LENGTH_SHORT,
            //   gravity: ToastGravity.CENTER,
            //   backgroundColor:
            //       const Color.fromARGB(255, 22, 20, 20),
            //   textColor: const Color.fromARGB(
            //       255, 243, 238, 238),
            //   fontSize: 14.0,
            // );
          }
        } else if (itemArr.isEmpty) {
          Fluttertoast.showToast(
            msg: "Please complete your hunt information",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: const Color.fromARGB(255, 19, 18, 18),
            textColor: const Color.fromARGB(255, 233, 230, 230),
            fontSize: 14.0,
          );
        } else if (gameRules == "") {
          Fluttertoast.showToast(
            msg: "Please complete your hunt information",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: const Color.fromARGB(255, 14, 13, 13),
            textColor: const Color.fromARGB(255, 243, 240, 240),
            fontSize: 14.0,
          );
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PreJoiningScreen(
                        gameId: widget.gameId,
                        gameuniqueId: widget.gameuniqueId,
                      )));
        }
      }
    } else {
      showSubscriptionModal(context);
    }
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
    // if (tempSubcriptionCheckNo != null) {
    showDeleteDialog(context, "delete", widget.gameType);
    // } else {
    //   showSubscriptionModal(context);
    // }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
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
                        builder: (context) => const HomeScreen(userName: '')));
              },
            ),
            title: const Text("Details"),
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
            // padding: const EdgeInsets.all(0.0),
            // controller: screenshotController,
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
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DetailsWidget(
                          gameImg: gameImg,
                          gameName: gameName,
                          fetchDate: fetchDate,
                          fetchTime: fetchTime,
                          desData: desData,
                          splitData: splitData,
                          gameType: widget.gameType),

                      // Prize shows
                      if (prizes.isNotEmpty &&
                          ((prizes[0].firstPrizeImgUrl?.isNotEmpty ?? false) ||
                              (prizes[0].firstDesc?.isNotEmpty ?? false)) &&
                          ((prizes[0].secondPrizeImgUrl?.isNotEmpty ?? false) ||
                              (prizes[0].secondDesc?.isNotEmpty ?? false)) &&
                          ((prizes[0].thirdPrizeImgUrl?.isNotEmpty ?? false) ||
                              (prizes[0].thirdDesc?.isNotEmpty ?? false))) ...[
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Prizes:",
                            style: TextStyle(
                              color: Color(0xFF153792),
                              fontSize: 18,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        // First Prize
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            leading:
                                prizes[0].firstPrizeImgUrl?.isNotEmpty ?? false
                                    ? CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                            prizes[0].firstPrizeImgUrl ?? ''),
                                      )
                                    : const CircleAvatar(
                                        radius: 30,
                                        backgroundImage: AssetImage(
                                            'assets/images/defaultImg.jpg'),
                                      ),
                            title: Text(
                              prizes[0].firstDesc ?? '',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // second prize
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            leading:
                                prizes[0].secondPrizeImgUrl?.isNotEmpty ?? false
                                    ? CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                            prizes[0].secondPrizeImgUrl ?? ''),
                                      )
                                    : const CircleAvatar(
                                        radius: 30,
                                        backgroundImage: AssetImage(
                                            'assets/images/defaultImg.jpg'),
                                      ),
                            title: Text(
                              prizes[0].secondDesc ?? '',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // Third prize
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            leading:
                                prizes[0].thirdPrizeImgUrl?.isNotEmpty ?? false
                                    ? CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                            prizes[0].thirdPrizeImgUrl ?? ''),
                                      )
                                    : const CircleAvatar(
                                        radius: 30,
                                        backgroundImage: AssetImage(
                                            'assets/images/defaultImg.jpg'),
                                      ),
                            title: Text(
                              prizes[0].thirdDesc ?? '',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],

                      Container(
                        margin: const EdgeInsets.only(top: 50),
                      ),
                      if (teams.isNotEmpty) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Teams:",
                            style: TextStyle(
                              color: Color(0xFF153792),
                              fontSize: 18,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        ListView.builder(
                          itemCount: teams.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListItem(
                              title: teams[index].teamname ??
                                  teams[index].player.name,
                              subtitle: "",
                              imagePath: teams[index].teamimg ?? "",
                              status: teams[index].status,
                              issubmitted: teams[index].issubmitted ?? 0,
                            );
                          },
                        )
                      ],
                      if (teams.isEmpty && widget.cardType != "joined")
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.group_outlined,
                                  size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                "No one has joined the hunt yet",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF153792),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Invite your friends to begin the adventure!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      if ((widget.cardType == 'joined' &&
                              widget.gameType != 'challenge') ||
                          widget.cardType == 'host')
                        ElevatedButton(
                            onPressed: () {
                              if (widget.cardType == "joined") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CreateNewTeam(
                                            myteam: teamId,
                                            statusChangeid: teamStatusId,
                                            gameid: widget.gameId)));
                              } else {
                                if (widget.gameType == "challenge") {
                                  if (gameStatus == '0') {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CreateChallenge1stPage(
                                                    gameId: widget.gameId,
                                                    gameuniqueId:
                                                        widget.gameuniqueId)));
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Quest is already started. You can't edit",
                                      toastLength: Toast
                                          .LENGTH_SHORT, // Toast.LENGTH_LONG for a longer duration
                                      gravity: ToastGravity
                                          .BOTTOM, // Position of the toast
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 12.0,
                                    );
                                  }
                                } else {
                                  if (gameStatus == '0') {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CreateHunt1stPage(
                                                    gameId: widget.gameId,
                                                    gameuniqueId:
                                                        widget.gameuniqueId)));
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Hunt is already started. You can't edit",
                                      toastLength: Toast
                                          .LENGTH_SHORT, // Toast.LENGTH_LONG for a longer duration
                                      gravity: ToastGravity
                                          .BOTTOM, // Position of the toast
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 12.0,
                                    );
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 214, 208, 208),
                              foregroundColor: const Color(0xFF0B00AB),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: widget.cardType == "joined"
                                ? const Text('Edit Team')
                                : Text('Edit ${widget.gameType}')),
                      const SizedBox(height: 20),
                      if (widget.cardType == 'joined')
                        ElevatedButton(
                          onPressed: () {
                            if (status == "0") {
                              Fluttertoast.showToast(
                                msg: "The hunt hasn’t started",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                fontSize: 14.0,
                              );
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HuntDashboard(
                                          myteam: widget.myteam,
                                          gameId: widget.gameId,
                                          gameType: widget.gameType)));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B00AB),
                            foregroundColor:
                                const Color.fromARGB(255, 214, 208, 208),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Continue'),
                        ),
                      if (widget.cardType == 'host' && gameStatus == '0')
                        ElevatedButton(
                            onPressed: () {
                              onStart();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF153792),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text('Start ${widget.gameType}')),
                      if (widget.cardType == 'host' && gameStatus == '1')
                        ElevatedButton(
                            onPressed: () {
                              // if (widget.gameType == 'challenge') {
                              //   // _activateGame();
                              // } else {
                              //   // Navigator.push(
                              //   //     context,
                              //   //     MaterialPageRoute(
                              //   //         builder: (context) => PreJoiningScreen(
                              //   //               gameId: widget.gameId,
                              //   //               gameuniqueId: widget.gameuniqueId,
                              //   //             )));
                              //   _startHunt();
                              // }
                              // _startHunt();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PrejoiningStartHunt(
                                          gameId: widget.gameId)));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF153792),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Continue')),
                      if (widget.cardType == 'host' &&
                          (gameStatus == '0' || gameStatus == '1')) ...[
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (isTimeCheck) {
                              if (fetchDate != "" && fetchTime != "") {
                                showModalBottomSheet<void>(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(45),
                                      topRight: Radius.circular(45),
                                    ),
                                  ),
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return Container(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(45),
                                            topRight: Radius.circular(45),
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                // Close Button
                                                Container(
                                                  alignment: Alignment.topRight,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.black,
                                                      size: 30,
                                                      semanticLabel: 'Close',
                                                    ),
                                                  ),
                                                ),

                                                Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(45),
                                                      topRight:
                                                          Radius.circular(45),
                                                    ),
                                                  ),
                                                  child: Screenshot(
                                                    controller:
                                                        screenshotController,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 20),
                                                      color: Colors.white,
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Container(
                                                            width: 50,
                                                            height: 50,
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 20.0,
                                                                    left: 20.0,
                                                                    right:
                                                                        20.0),
                                                            decoration:
                                                                const BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image: AssetImage(
                                                                    "assets/images/logo.jpg"),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            gameName,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              color: Color(
                                                                  0xFF153792),
                                                              fontSize: 22,
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          ),
                                                          if (fetchDate != "" &&
                                                              fetchTime !=
                                                                  "") ...[
                                                            Text(
                                                              "$fetchDate $fetchTime",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                color: Color(
                                                                    0xFF153792),
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Raleway',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                            ),
                                                          ] else ...[
                                                            const SizedBox
                                                                .shrink(),
                                                          ],

                                                          // Display an image (QR code or placeholder)
                                                          qrCode != ''
                                                              ? Image.memory(
                                                                  base64Decode(
                                                                      qrCode),
                                                                  height: 180,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )
                                                              : Image.asset(
                                                                  'assets/images/qrcode.png', // Update the image asset accordingly
                                                                  height: 180,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),

                                                          const Text(
                                                            "Scan the QR Code to Join The Hunt",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF153792),
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 25),
                                                          const Text(
                                                            "Or",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF153792),
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 25,
                                                          ),
                                                          const Text(
                                                            "Use this code to enter hunt on your app",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF153792),
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),

                                                          IgnorePointer(
                                                            ignoring: true,

                                                            // padding:
                                                            //     const EdgeInsets.only(
                                                            //         top: 20,
                                                            //         bottom: 40,
                                                            //         left: 20,
                                                            //         right: 20),
                                                            child:
                                                                PinCodeTextField(
                                                              appContext:
                                                                  context,
                                                              length: 6,
                                                              obscureText:
                                                                  false,
                                                              animationType:
                                                                  AnimationType
                                                                      .fade,
                                                              autoDisposeControllers:
                                                                  false,
                                                              pinTheme:
                                                                  PinTheme(
                                                                shape:
                                                                    PinCodeFieldShape
                                                                        .circle,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            2),
                                                                fieldHeight: 40,
                                                                fieldWidth: 40,
                                                                activeFillColor:
                                                                    Colors
                                                                        .white,
                                                                activeColor:
                                                                    Colors.blue,
                                                                selectedColor:
                                                                    Colors.blue,
                                                                inactiveColor:
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        251,
                                                                        246,
                                                                        246),
                                                                inactiveFillColor:
                                                                    Colors
                                                                        .white,
                                                                selectedFillColor:
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        250,
                                                                        251,
                                                                        252),
                                                              ),
                                                              animationDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              enableActiveFill:
                                                                  true,
                                                              errorAnimationController:
                                                                  errorController,
                                                              controller:
                                                                  textEditingController,
                                                              onCompleted:
                                                                  (v) {},
                                                              onChanged:
                                                                  (value) {
                                                                if (mounted)
                                                                  setState(() {
                                                                    currentText =
                                                                        value;
                                                                  });
                                                              },
                                                              beforeTextPaste:
                                                                  (text) {
                                                                return true;
                                                              },
                                                            ),
                                                          ),

                                                          const SizedBox(
                                                              height: 20),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                ElevatedButton(
                                                  onPressed: () {
                                                    screenshotController
                                                        .capture(
                                                            delay:
                                                                const Duration(
                                                                    milliseconds:
                                                                        1))
                                                        .then(
                                                            (capturedImage) async {
                                                      print(capturedImage);
                                                      _shareHuntCode(
                                                          capturedImage,
                                                          gameName,
                                                          gameStartDate);
                                                    }).catchError((onError) {
                                                      print(onError);
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 214, 208, 208),
                                                    foregroundColor:
                                                        const Color(0xFF0B00AB),
                                                    minimumSize: const Size(
                                                        double.infinity, 50),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                  ),
                                                  child: const Text('Share'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                _showTimeDialog(context, "share");
                                // Fluttertoast.showToast(
                                //   msg: "You can't share incomplete hunt ",
                                //   toastLength: Toast.LENGTH_SHORT,
                                //   gravity: ToastGravity.CENTER,
                                //   backgroundColor:
                                //       const Color.fromARGB(255, 19, 17, 17),
                                //   textColor:
                                //       const Color.fromARGB(255, 243, 234, 234),
                                //   fontSize: 14.0,
                                // );
                              }
                            } else if (itemArr.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "You can't share incomplete hunt ",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor:
                                    const Color.fromARGB(255, 12, 12, 12),
                                textColor:
                                    const Color.fromARGB(255, 240, 232, 232),
                                fontSize: 14.0,
                              );
                            } else if (gameRules == "") {
                              Fluttertoast.showToast(
                                msg: "You can't share incomplete hunt",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor:
                                    const Color.fromARGB(255, 15, 15, 15),
                                textColor:
                                    const Color.fromARGB(255, 240, 238, 238),
                                fontSize: 14.0,
                              );
                            } else {
                              showModalBottomSheet<void>(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(45),
                                    topRight: Radius.circular(45),
                                  ),
                                ),
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return Container(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(45),
                                          topRight: Radius.circular(45),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              // Close Button
                                              Container(
                                                alignment: Alignment.topRight,
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.black,
                                                    size: 30,
                                                    semanticLabel: 'Close',
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(45),
                                                    topRight:
                                                        Radius.circular(45),
                                                  ),
                                                ),
                                                child: Screenshot(
                                                  controller:
                                                      screenshotController,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20,
                                                            right: 20),
                                                    color: Colors.white,
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Container(
                                                          width: 50,
                                                          height: 50,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 20.0,
                                                                  left: 20.0,
                                                                  right: 20.0),
                                                          decoration:
                                                              const BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image: AssetImage(
                                                                  "assets/images/logo.jpg"),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          gameName,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            color: Color(
                                                                0xFF153792),
                                                            fontSize: 22,
                                                            fontFamily:
                                                                'Raleway',
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                                        if (fetchDate != "" &&
                                                            fetchTime !=
                                                                "") ...[
                                                          Text(
                                                            "$fetchDate $fetchTime",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              color: Color(
                                                                  0xFF153792),
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          ),
                                                        ] else ...[
                                                          const SizedBox
                                                              .shrink(),
                                                        ],

                                                        // Display an image (QR code or placeholder)
                                                        qrCode != ''
                                                            ? Image.memory(
                                                                base64Decode(
                                                                    qrCode),
                                                                height: 180,
                                                                fit:
                                                                    BoxFit.fill,
                                                              )
                                                            : Image.asset(
                                                                'assets/images/qrcode.png', // Update the image asset accordingly
                                                                height: 180,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),

                                                        const Text(
                                                          "Scan the QR Code to Join The Hunt",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF153792),
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Raleway',
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 25),
                                                        const Text(
                                                          "Or",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF153792),
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Raleway',
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 25,
                                                        ),
                                                        const Text(
                                                          "Use this code to enter hunt on your app",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF153792),
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Raleway',
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),

                                                        IgnorePointer(
                                                          ignoring: true,

                                                          // padding:
                                                          //     const EdgeInsets.only(
                                                          //         top: 20,
                                                          //         bottom: 40,
                                                          //         left: 20,
                                                          //         right: 20),
                                                          child:
                                                              PinCodeTextField(
                                                            appContext: context,
                                                            length: 6,
                                                            obscureText: false,
                                                            animationType:
                                                                AnimationType
                                                                    .fade,
                                                            autoDisposeControllers:
                                                                false,
                                                            pinTheme: PinTheme(
                                                              shape:
                                                                  PinCodeFieldShape
                                                                      .circle,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          2),
                                                              fieldHeight: 40,
                                                              fieldWidth: 40,
                                                              activeFillColor:
                                                                  Colors.white,
                                                              activeColor:
                                                                  Colors.blue,
                                                              selectedColor:
                                                                  Colors.blue,
                                                              inactiveColor:
                                                                  const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      251,
                                                                      246,
                                                                      246),
                                                              inactiveFillColor:
                                                                  Colors.white,
                                                              selectedFillColor:
                                                                  const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      250,
                                                                      251,
                                                                      252),
                                                            ),
                                                            animationDuration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            enableActiveFill:
                                                                true,
                                                            errorAnimationController:
                                                                errorController,
                                                            controller:
                                                                textEditingController,
                                                            onCompleted: (v) {},
                                                            onChanged: (value) {
                                                              if (mounted)
                                                                setState(() {
                                                                  currentText =
                                                                      value;
                                                                });
                                                            },
                                                            beforeTextPaste:
                                                                (text) {
                                                              return true;
                                                            },
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                            height: 20),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              ElevatedButton(
                                                onPressed: () {
                                                  screenshotController
                                                      .capture(
                                                          delay: const Duration(
                                                              milliseconds: 1))
                                                      .then(
                                                          (capturedImage) async {
                                                    print(capturedImage);
                                                    _shareHuntCode(
                                                        capturedImage,
                                                        gameName,
                                                        gameStartDate);
                                                  }).catchError((onError) {
                                                    print(onError);
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 214, 208, 208),
                                                  foregroundColor:
                                                      const Color(0xFF0B00AB),
                                                  minimumSize: const Size(
                                                      double.infinity, 50),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                                child: const Text('Share'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 214, 208, 208),
                            foregroundColor: const Color(0xFF0B00AB),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Share'),
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                        userName: "", gameId: widget.gameId)));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF153792),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Go to dashboard')),
                      const SizedBox(height: 20),
                      if (widget.cardType == 'host' && gameStatus == '0')
                        ElevatedButton(
                            onPressed: () {
                              onDelete();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  const Color.fromARGB(242, 231, 6, 36),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text('Delete ${widget.gameType}')),
                      if (widget.cardType == "joined")
                        ElevatedButton(
                            onPressed: () {
                              showDeleteDialog(
                                  context, "leave", widget.gameType);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  const Color.fromARGB(242, 231, 6, 36),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text('Leave ${widget.gameType}')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Future<dynamic> showCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text("Captured widget screenshot"),
        ),
        body: Center(
            child: capturedImage != null
                ? Image.memory(capturedImage)
                : Container()),
      ),
    );
  }

  _shareHuntCode(image, gameName, gameStartDate) async {
    // final result = await ImageGallerySaver.saveImage(image);
    // print("File Saved to Gallery");
    // convert Uint8List image to a XFile
    final imageFile =
        XFile.fromData(image, name: 'image.png', mimeType: 'image/png');
    final result = await Share.shareXFiles([imageFile],
        text:
            'You are invited to join the Scavengertime Hunt called $gameName that will begin on $gameStartDate. Click this link to join or enter the code into your Scavengertime App. If you do not have Scavengertime download here and click this link once you have Scavengertime.');
    if (result.status == ShareResultStatus.success) {
      print('Thank you for sharing the picture!');
    }
  }
}

class ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String status;
  final int issubmitted;

  ListItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.status,
    required this.issubmitted,
  });

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;
    print('status is $status');
    if (issubmitted == 1) {
      statusText = 'Submitted';
      statusColor = Colors.blue;
    } else {
      switch (status) {
        case "0":
          statusText = '';
          statusColor = Colors.grey;
          break;
        case "1":
          statusText = 'Ready';
          statusColor = Colors.green;
          break;
        case "2":
          statusText = 'Joined';
          statusColor = Color(0xFFFFB700);
          break;

        default:
          statusText = 'Unknown';
          statusColor = Colors.black;
      }
    }
    return Card(
      // margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w400,
          ),
        ),

        // trailing: Text(
        //   status,
        //   style: TextStyle(
        //     color: status == 'Ready' ? Colors.green : Colors.grey,
        //     fontSize: 16,
        //   ),
        // ),
      ),
    );
  }
}

class Item {
  final String title;
  final String subtitle;
  final String imagePath;
  final String status;

  Item(this.title, this.subtitle, this.imagePath, this.status);
}
