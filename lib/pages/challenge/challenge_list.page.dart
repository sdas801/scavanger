import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/model/challenge.model.dart';
import 'package:scavenger_app/pages/challenge/challenge_details.page.dart';
import 'package:scavenger_app/pages/challenge/create_step_one.page.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/shared/nodatafound.widget.dart';
import 'package:shimmer/shimmer.dart';

const double cardHeight = 110;

class ChallengesListPage extends StatefulWidget {
  final String? type;
  final String checkType;
  const ChallengesListPage({
    super.key,
    required this.type,
    required this.checkType,
  });

  @override
  _ChallengesListPage createState() => _ChallengesListPage();
}

class _ChallengesListPage extends State<ChallengesListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<ChallengeModel> challengesList = [];
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
    }
  }

// here list api call
  Future<void> _getUpcommingData() async {
    setState(() {
      _isLoading = true;
    });

    var reqData = {
      "status": widget.checkType,
      "limit": limit,
      "offset": pageNum * limit
    };
    ApiService.getChallengeList(reqData).then((res) {
      try {
        if (res.success) {
          List<ChallengeModel> result = (res.response as List)
              .map((i) => ChallengeModel.fromJson(i))
              .toList();
          setState(() {
            challengesList = challengesList + result;
            _hasMore = result.length == limit;
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
                  builder: (context) =>
                      const HomeScreen(userName: '', selectedTab: 1)));
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
                              const HomeScreen(userName: '', selectedTab: 1)));
                },
              ),
              title: const Text("Quest List"),
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
                    child: challengesList.isEmpty && !_isLoading
                        ? const NoDataFound()
                        : ListView.builder(
                            controller:
                                _scrollController, // Attach scroll controller here
                            padding: const EdgeInsets.all(20),
                            itemCount: _isLoading
                                ? challengesList.length +
                                    6 // Show shimmer effect while loading
                                : challengesList.length,
                            itemBuilder: (context, index) {
                              if (index < challengesList.length) {
                                final item = challengesList[index];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: ListItem(
                                    key: ValueKey(item.id),
                                    imageUrl:
                                        "assets/images/scavenger_hunt.png",
                                    title: item.name,
                                    subtitle: item.description,
                                    gameId: item.id,
                                    gameImg: item.imageurl,
                                    inTime: item.createdat,
                                    outTime: item.endtime,
                                    status: item.status,
                                    otp: item.otp,
                                    index: index,
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                ))));
  }
}

class ListItem extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final int gameId;
  final String? gameImg;
  final String? inTime;
  final String? outTime;
  final int? status;
  final String? otp;
  final int index;

  const ListItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.gameId,
    this.otp = '',
    this.status = 0,
    this.inTime = '',
    this.outTime = '',
    this.gameImg = '',
    required this.index,
  });

  @override
  _HuntCardState createState() => _HuntCardState();
}

class _HuntCardState extends State<ListItem> {
  String imageUrl = '';
  String title = '';
  String subtitle = '';
  int gameId = 0;
  String? otp;
  int status = 0;
  String? inTime;
  String? outTime;
  String? gameImg;
  String fetchTime = '';
  String fetchOutTime = '';
  String? gameType;

  @override
  void initState() {
    super.initState();
    imageUrl = widget.imageUrl;
    title = widget.title;
    subtitle = widget.subtitle;
    gameId = widget.gameId;
    otp = widget.otp;
    inTime = widget.inTime;
    outTime = widget.outTime;
    gameImg = widget.gameImg;
    _loadData();
  }

  Future<void> _loadData() async {
    if (inTime != null && inTime != "") {
      var gameStartDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(inTime ?? '');
      fetchTime = DateFormat("dd MMM, yyyy HH:mm aaa").format(gameStartDate);
    }

    if (outTime != null && outTime != "") {
      var gameEndDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(outTime ?? '');
      fetchOutTime = DateFormat("dd MMM, yyyy HH:mm aaa").format(gameEndDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ChallengeDetails(
                        challengeId: gameId,
                      )));
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
                          if (fetchTime != '')
                            Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Start Time :${inTime == null ? 'Unknown' : fetchTime}",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 10,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )),
                          if (fetchOutTime != '')
                            Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "End Time: ${fetchOutTime}",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 10,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // if (widget.status == 1)
              //   Positioned(
              //     // height: 30,
              //     // width: 30,
              //     // top: 3,
              //     right: 0,
              //     child: ElevatedButton(
              //       onPressed: () {
              //         showActionButtons(context, status);
              //       },
              //       style: ElevatedButton.styleFrom(
              //         // minimumSize: Size(50, 50),
              //         padding: const EdgeInsets.all(
              //             3), // Adjust padding for smaller size
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //             side: const BorderSide(
              //               color: Color.fromARGB(255, 255, 255, 255),
              //             )),

              //         backgroundColor: const Color.fromARGB(
              //             255, 255, 255, 255), // Button color
              //         foregroundColor: Colors.red,
              //         elevation: 0, // Splash color
              //       ),
              //       child: const Icon(
              //         Icons.settings,
              //         color: Color.fromARGB(255, 47, 12, 104),
              //         size: 24, // Reduce the icon size
              //       ),
              //     ),
              //   ),
            ],
          ),
        ));
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        // cancel();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        // deleteGame();

        // cancel();
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

  showActionButtons(BuildContext context, status) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
        title: Center(child: Text(title)),
        content: SizedBox(
          height: 100,
          child: Column(
            children: [
              OutlinedButton(
                onPressed: () {
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
                                gameId: gameId, gameuniqueId: '')));
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
                          ? "Your Challenges already started. You can't delete."
                          : "Your Hunt already started. You can't delete.",
                      toastLength: Toast
                          .LENGTH_SHORT, // Toast.LENGTH_LONG for a longer duration
                      gravity: ToastGravity.BOTTOM, // Position of the toast
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 12.0,
                    );
                  } else {
                    // cancel();
                    showAlertDialog(context);
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
}
