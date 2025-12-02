import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scavenger_app/CompletedDetailsPage.dart';
import 'package:scavenger_app/CreateHunt1stPage.dart';
import 'package:scavenger_app/CreateHunt2ndPage.dart';
import 'package:scavenger_app/CreateHuntFormLastPage.dart';
import 'package:scavenger_app/CreateHuntFormTime.dart';
import 'package:scavenger_app/CreateHuntPictureForm.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/HomeScreenResponse.dart';
import 'package:scavenger_app/HuntCreationCompleteScreen.dart';
import 'package:scavenger_app/HuntDashboard.dart';
import 'package:scavenger_app/model/videoPlayList.modal.dart';
import 'package:scavenger_app/pages/challenge/challenge_time_set.page.dart';
import 'package:scavenger_app/pages/challenge/create_step_one.page.dart';
import 'package:scavenger_app/pages/challenge/player_dashboard.page.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/shared/nodatafound.widget.dart';
import 'package:shimmer/shimmer.dart';

const double cardHeight = 110;

class HuntChallengesListPage extends StatefulWidget {
  final String? type;
  final String checkType;
  const HuntChallengesListPage({
    super.key,
    required this.type,
    required this.checkType,
  });

  @override
  _HuntChallengesListPage createState() => _HuntChallengesListPage();
}

class _HuntChallengesListPage extends State<HuntChallengesListPage> {
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  List<HuntItemList> items = [];
  List<Result> upcomingitems = [];
  int limit = 7;
  int pageNum = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _getUpcommingData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onScroll() async {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      setState(() {
        _isLoading = true;
      });
      pageNum = pageNum + 1;
      await _getUpcommingData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

// here list api call
  Future<void> _getUpcommingData() async {
    setState(() {
      _isLoading = true;
    });

    var reqData = {
      "status": widget.checkType == "upcoming"
          ? "upcomming"
          : widget.checkType == "active"
              ? "active"
              : "end",
      "gameType": widget.type,
      "limit": limit.toString(),
      "offset": (pageNum * limit).toString(),
    };
    ApiService.getGameList(reqData).then((res) {
      try {
        if (res.success) {
          var huntList =
              List<Result>.from(res.response.map((x) => Result.fromJson(x)));
          setState(() {
            upcomingitems = upcomingitems + huntList;
            _hasMore = huntList.length == limit;
          });
        }
      } catch (error) {
        // print(error);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

// this is show Action button
  showActionButtons(BuildContext context, status, gameId, gameuniqueId,
      gameType, title, isHost) {
    AlertDialog alert = AlertDialog(
        title: Center(child: Text(title)),
        content: SizedBox(
          height: 100,
          child: Column(
            children: [
              OutlinedButton(
                onPressed: () {
                  if (gameType == 'challenge') {
                    if (status == "1" || status == "2") {
                      Fluttertoast.showToast(
                        msg: status == "1"
                            ? "Quest is already started. You can't edit"
                            : "Quest is already ended. You can't edit",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 12.0,
                      );
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateChallenge1stPage(
                                  gameId: gameId, gameuniqueId: gameuniqueId)));
                    }
                  } else {
                    if (status == "1" || status == "2") {
                      Fluttertoast.showToast(
                        msg: status == "1"
                            ? "Hunt is already started. You can't edit"
                            : "Hunt is already ended. You can't edit",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 12.0,
                      );
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateHunt1stPage(
                                  gameId: gameId, gameuniqueId: gameuniqueId)));
                    }
                  }
                },
                style: ButtonStyle(
                  minimumSize:
                      WidgetStateProperty.all(Size(double.infinity, 40)),
                ),
                child: const Text('Edit'),
              ),
              OutlinedButton(
                onPressed: () {
                  if (status == "1") {
                    Fluttertoast.showToast(
                      msg: gameType == 'challenge'
                          ? "Your Quest already started. You can't delete."
                          : "Your Hunt already started. You can't delete.",
                      toastLength: Toast
                          .LENGTH_SHORT, // Toast.LENGTH_LONG for a longer duration
                      gravity: ToastGravity.BOTTOM, // Position of the toast
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 12.0,
                    );
                  } else {
                    cancel(context);
                    showAlertDialog(context, gameId, isHost);
                  }
                },
                style: ButtonStyle(
                  minimumSize:
                      WidgetStateProperty.all(Size(double.infinity, 40)),
                ),
                child: const Text('Delete'),
              )
            ],
          ),
        ));
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showDeleteButtons(BuildContext context, status, gameId, gameuniqueId,
      gameType, title, isHost) {
    showAlertDialog(context, gameId, isHost);
    // show the dialog
  }

// this is show dialog button
  showAlertDialog(BuildContext context, gameId, isHost) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        cancel(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        deleteGame(context, gameId, isHost);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Are you sure?"),
      content: const Text(
          "You want to delete this game. Once deleted, you can't recover it."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

// here delete game api call
  void deleteGame(context, int id, int isHost) async {
    if (isHost == 0) {
      print(">>>>>>>>>>>>>>>>>response.body");
      try {
        final res = await ApiService.deletegameJoiner({"gameId": id});
        if (res.success) {
          setState(() {
            upcomingitems.removeWhere((element) => element.id == id);
          });
          Navigator.of(context).pop(); // Close the dialog if open
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to delete : ${res.message ?? "Unknown error"}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $error'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      try {
        final res = await ApiService.deleteGame({"id": id});
        if (res.success) {
          setState(() {
            upcomingitems.removeWhere((element) => element.id == id);
          });
          Navigator.of(context).pop(); // Close the dialog if open
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to delete : ${res.message ?? "Unknown error"}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $error'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

// this function used for cancel showDialog
  cancel(context) {
    Navigator.of(context).pop();
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
                          builder: (context) =>
                              const HomeScreen(userName: '')));
                },
              ),
              title: (widget.type?.toLowerCase() ?? '') == "hunt"
                  ? const Text("Hunt List")
                  : const Text("Quest List"),
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
                        child: upcomingitems.isEmpty && !_isLoading
                            ? const NoDataFound()
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                controller: _scrollController,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        physics: const ClampingScrollPhysics(),
                                        itemCount: _isLoading
                                            ? upcomingitems.length + 6
                                            : upcomingitems
                                                .length, //upcomingitems.length,

                                        itemBuilder: (context, index) {
                                          if (index < upcomingitems.length) {
                                            final item = upcomingitems[index];
                                            return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: ListItem(
                                                  key: ValueKey(item.id),
                                                  imageUrl:
                                                      "assets/images/scavenger_hunt.png",
                                                  title: upcomingitems[index]
                                                      .title,
                                                  subtitle: upcomingitems[index]
                                                      .description,
                                                  gameId:
                                                      upcomingitems[index].id,
                                                  gameuniqueId:
                                                      upcomingitems[index]
                                                          .gameId,
                                                  otp: upcomingitems[index].otp,
                                                  status: upcomingitems[index]
                                                      .status,
                                                  inTime: upcomingitems[index]
                                                      .inTime,
                                                  outTime: upcomingitems[index]
                                                      .outTime,
                                                  isTimed: upcomingitems[index]
                                                      .isTimed,
                                                  isPrized: upcomingitems[index]
                                                      .isPrized,
                                                  isItemApproved:
                                                      upcomingitems[index]
                                                          .isItemApproved,
                                                  isAllowToMsgOthers:
                                                      upcomingitems[index]
                                                          .isAllowToMsgOthers,
                                                  itemCount:
                                                      upcomingitems[index]
                                                          .items
                                                          ?.length,
                                                  prizeCount:
                                                      upcomingitems[index]
                                                          .prizes
                                                          ?.length,
                                                  gameRules:
                                                      upcomingitems[index]
                                                          .gameRules,
                                                  gameType: upcomingitems[index]
                                                      .gameType,
                                                  gameImg: upcomingitems[index]
                                                      .gameImg,
                                                  isHost: upcomingitems[index]
                                                          .isHost ??
                                                      1,
                                                  cardType: upcomingitems[index]
                                                              .isHost ==
                                                          0
                                                      ? 'joined'
                                                      : 'host',
                                                  gamePlayId:
                                                      upcomingitems[index]
                                                          .gamePlayId,
                                                  gamePlayStatus:
                                                      upcomingitems[index]
                                                          .gamePlayStatus,
                                                  index: index,
                                                  teamId: upcomingitems[index]
                                                      .teamId,
                                                  onClick: (val, index) {
                                                    showActionButtons(
                                                        context,
                                                        upcomingitems[index]
                                                            .status,
                                                        upcomingitems[index].id,
                                                        upcomingitems[index]
                                                            .gameId,
                                                        upcomingitems[index]
                                                            .gameType,
                                                        upcomingitems[index]
                                                            .title,
                                                        upcomingitems[index]
                                                            .isHost);
                                                  },
                                                  onDelete: (val, index) {
                                                    showDeleteButtons(
                                                        context,
                                                        upcomingitems[index]
                                                            .status,
                                                        upcomingitems[index].id,
                                                        upcomingitems[index]
                                                            .gameId,
                                                        upcomingitems[index]
                                                            .gameType,
                                                        upcomingitems[index]
                                                            .title,
                                                        upcomingitems[index]
                                                            .isHost);
                                                  },
                                                  isActionMenu:
                                                      widget.checkType ==
                                                              "upcoming"
                                                          ? true
                                                          : widget.checkType ==
                                                                  "completed"
                                                              ? true
                                                              : false,
                                                ));
                                          } else {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20.0),
                                              child: Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: Container(
                                                  height: 100,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ])))))));
  }
}

typedef void DeleteCallback(int val, int index);

class ListItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final int gameId;
  final String gameuniqueId;
  final String? otp;
  final String? status;
  final String? inTime;
  final String? outTime;
  final bool? isTimed;
  final bool? isPrized;
  final bool? isItemApproved;
  final bool? isAllowToMsgOthers;
  final int? itemCount;
  final int? prizeCount;
  final String? gameRules;
  final String? gameType;
  final String? cardType;
  final String? teamId;
  final String? gameImg;
  final DeleteCallback onClick;
  final DeleteCallback onDelete;
  final bool? isActionMenu;
  final int isHost;
  final int? gamePlayId;
  final int index;
  final String? gamePlayStatus;

  const ListItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.gameId,
    required this.gameuniqueId,
    this.otp = '',
    this.status = '0',
    this.inTime = '',
    this.outTime = '',
    this.isTimed = false,
    this.isPrized = false,
    this.isItemApproved = false,
    this.isAllowToMsgOthers = false,
    this.itemCount = 0,
    this.prizeCount = 0,
    this.gameRules = '',
    this.gameType = 'hunt',
    this.cardType = 'up',
    this.teamId = '',
    this.gameImg = '',
    required this.onClick,
    required this.onDelete,
    this.isActionMenu = true,
    this.isHost = 1,
    this.gamePlayId = 0,
    required this.index,
    this.gamePlayStatus = '',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (status == '2') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CompletedDetailsPage(
                        gameId: gameId,
                        isHost: isHost,
                        gameuniqueId: gameuniqueId,
                        gameType: gameType ?? 'hunt',
                        cardType: cardType ?? "",
                        myteam: teamId ?? '')));
          } else if (status == '2' && cardType == 'joined') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlayerDashboard(
                        gameId: gameId,
                        teamId: teamId ?? '',
                        gameType: gameType ?? 'hunt')));
          } else {
            if (status == '0' && cardType != 'joined') {
              if (title == '' || title.isEmpty) {
                if (gameType == 'challenge') {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const CreateChallenge1stPage()));
                } else {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateHunt1stPage(
                              gameId: gameId, gameuniqueId: gameuniqueId)));
                }
              } else if (isTimed == false &&
                  isPrized == false &&
                  isItemApproved == false &&
                  isAllowToMsgOthers == false &&
                  gameType == 'hunt') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateHunt2ndPage(
                            gameId: gameId, gameuniqueId: gameuniqueId)));
              } else if (isTimed == true && (inTime == null || isTimed == '')) {
                if (gameType == 'challenge') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChallengeTimeSet(
                              gameId: gameId, gameuniqueId: gameuniqueId)));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateHuntFormTime(
                              gameId: gameId, gameuniqueId: gameuniqueId)));
                }
              } else if (isPrized == true &&
                  prizeCount == 0 &&
                  gameType != 'challenge') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateHuntPictureForm(
                            gameId: gameId, gameuniqueId: gameuniqueId)));
              } else if (gameRules == null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateHuntFormLastPage(
                            gameId: gameId, gameuniqueId: gameuniqueId)));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HuntCreationCompleteScreen(
                            gameId: gameId,
                            gameuniqueId: gameuniqueId,
                            gameType: gameType ?? 'hunt',
                            cardType: 'host',
                            myteam: teamId ?? '')));
              }
            } else if (cardType == 'joined') {
              if (status == '1' || status == '0') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HuntCreationCompleteScreen(
                            gameId: gameId,
                            gameuniqueId: gameuniqueId,
                            gameType: gameType ?? 'hunt',
                            cardType: cardType ?? "",
                            myteam: teamId ?? '')));
              }
            } else if (cardType == 'ended' && status == '2') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HuntDashboard(
                          myteam: teamId ?? '',
                          gameId: gameId,
                          gameType: gameType ?? 'hunt')));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HuntCreationCompleteScreen(
                          gameId: gameId,
                          gameuniqueId: gameuniqueId,
                          gameType: gameType ?? 'hunt',
                          cardType: "host",
                          myteam: teamId ?? '')));
            }
          }
        },
        child: Container(
          width: 280,
          height: cardHeight,
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
          child: Stack(
            children: [
              Container(
                width: 280,
                height: cardHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
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
                    Container(
                      width: 210,
                      height: 200,
                      //padding: EdgeInsets.only(top: 20, left: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              padding: const EdgeInsets.only(left: 5),
                              child: Align(
                                alignment: Alignment.topLeft,
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
                              )),
                          inTime == null
                              ? const SizedBox()
                              : Container(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Start Time :${DateFormat("dd MMM, yyyy HH:mm aaa").format(DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(inTime ?? ''))}",
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Color(0xFF153792),
                                        fontSize: 11,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )),
                          outTime == null
                              ? const SizedBox()
                              : Container(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "End Time: ${DateFormat("dd MMM, yyyy HH:mm aaa").format(DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(outTime ?? ''))}",
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Color(0xFF153792),
                                        fontSize: 11,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )),
                          /* Container(
                              padding: const EdgeInsets.only(left: 5),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Description : ${subtitle}",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Color(0xFF153792),
                                    fontSize: 11,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    height: 1,
                                  ),
                                ),
                              )), */
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isActionMenu == true)
                Positioned(
                  height: 30,
                  width: 30,
                  // top: 3,
                  right: 0,
                  child: ElevatedButton(
                    onPressed: () {
                      onClick(gameId, index);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 255, 255, 255),
                          )),

                      backgroundColor: const Color.fromARGB(
                          255, 255, 255, 255), // Button color
                      foregroundColor: Colors.red,
                      elevation: 0, // Splash color
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Color.fromARGB(255, 47, 12, 104),
                      size: 24,
                    ),
                  ),
                ),
              // : const SizedBox(),
              if (isActionMenu == true)
                // isHost == 1 &&
                status != '0'
                    ? Positioned(
                        height: 30,
                        width: 30,
                        top: 30,
                        right: 0,
                        child: ElevatedButton(
                          onPressed: () {
                            onDelete(gameId, index);
                            // deleteGame();
                            // showActionButtons(context, status);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(3),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                )),
                            backgroundColor: const Color.fromARGB(
                                255, 255, 255, 255), // Button color
                            foregroundColor: Colors.red,
                            elevation: 0, // Splash color
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Color.fromARGB(255, 47, 12, 104),
                            size: 24, // Reduce the icon size
                          ),
                        ),
                      )
                    : const SizedBox(),
              Positioned(
                top: 48,
                left: -48,
                // right: 28,
                child: Transform.rotate(
                    angle: 4.7124,
                    child: Container(
                      width: cardHeight,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isHost == 0
                            ? const Color.fromARGB(255, 3, 139, 121)
                            : const Color.fromARGB(255, 223, 90, 28),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12), // Top-right corner
                          topRight: Radius.circular(12), // Bottom-right corner
                        ),
                      ),
                      child: isHost == 0
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Joined',
                                    style: TextStyle(
                                        color: Colors.white, height: 0.8)),
                              ],
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Host',
                                    style: TextStyle(
                                        color: Colors.white, height: 0.8)),
                              ],
                            ),
                    )),
              )
            ],
          ),
        ));
  }
}
