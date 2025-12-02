import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/challenge.model.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scavenger_app/pages/challenge/create_step_one.page.dart';
import 'package:scavenger_app/pages/challenge/challenge_details.page.dart';
import 'package:shimmer/shimmer.dart';

const double cardHeight = 110;

class ChalengeList extends StatefulWidget {
  final int type;
  const ChalengeList({super.key, required this.type});

  @override
  State<ChalengeList> createState() => _ChalengeListState();
}

class _ChalengeListState extends State<ChalengeList> {
  bool _isLoading = false;
  List<ChallengeModel> challengeList = [];
  Timer? _timer;
  List<CarouselModel> CarouselList = [];

  @override
  void initState() {
    super.initState();
    _getchallengeList(1);
    _getBannerList(1);
    _timer = Timer.periodic(const Duration(seconds: 50), (_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    _getchallengeList(0);
    _getBannerList(0);
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    super.dispose();
  }

  Future<void> _getchallengeList(int flag) async {
    if (flag == 1) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    }
    ApiService.getChallengeList(
        {"status": widget.type, "limit": 10, "offset": 0}).then((res) {
      try {
        if (res.success) {
          // print("joined data ${res.response}");
          var result = List<ChallengeModel>.from(
              res.response.map((x) => ChallengeModel.fromJson(x)));
          if (mounted) {
            setState(() {
              challengeList = result;
            });
          }
        }
      } catch (error) {
        // print(error);
      } finally {
        if (flag == 1) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    });
  }

  Future<void> _getBannerList(int flag) async {
    if (flag == 1) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    }
    ApiService.getCarouselData({"type": 1}).then((res) {
      try {
        if (res.success) {
          print("joined data ${res.response}");
          var result = List<CarouselModel>.from(
              res.response.map((x) => CarouselModel.fromJson(x)));
          if (mounted) {
            setState(() {
              CarouselList = result;
            });
          }
        }
      } catch (error) {
        // print(error);
      } finally {
        if (flag == 1) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: challengeList.isEmpty && !_isLoading
          ? Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: const Image(image: AssetImage('assets/images/empty.png')),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  _isLoading ? challengeList.length + 6 : challengeList.length,
              itemBuilder: (context, index) {
                if (index < challengeList.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HuntCard(
                      imageUrl: "assets/images/scavenger_hunt.png",
                      title: challengeList[index].name,
                      subtitle: challengeList[index].description,
                      gameId: challengeList[index].id,
                      otp: '',
                      inTime: challengeList[index].createdat,
                      outTime: challengeList[index].endtime,
                      status: challengeList[index].status,
                      cardType: 'active',
                      gameImg: challengeList[index].imageurl,
                      ondelete: (val) => {},
                      isActionMenu: false,
                      totalItems: challengeList[index].totalItems,
                      uploadedItems: challengeList[index].uploadedItems,
                      isprocessed: challengeList[index].isprocessed,
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300] ?? Colors.grey,
                      highlightColor: Colors.grey[100] ?? Colors.grey,
                      child: Container(
                        height: 70,
                        width: 280,
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
    );
  }
}

typedef DeleteCallback = void Function(Map<String, dynamic> val);

class HuntCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final int gameId;
  final String? otp;
  final int status;
  final String? inTime;
  final String? outTime;
  final String? cardType;
  final String? gameImg;
  final DeleteCallback ondelete;
  final bool? isActionMenu;
  final int? totalItems;
  final int? uploadedItems;
  final int? isprocessed;

  const HuntCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.gameId,
    this.otp = '',
    this.status = 0,
    this.inTime = '',
    this.outTime = '',
    this.cardType = 'up',
    this.gameImg = '',
    required this.ondelete,
    this.isActionMenu = true,
    this.totalItems = 0,
    this.uploadedItems = 0,
    this.isprocessed = 0,
    // this.startTime = DateFormat("dd/MM/yy h:mm a").format(inTime)
  });

  @override
  _HuntCardState createState() => _HuntCardState();
}

class _HuntCardState extends State<HuntCard> {
  String imageUrl = '';
  String title = '';
  String subtitle = '';
  int gameId = 0;
  String? otp;
  int status = 0;
  String? inTime;
  String? outTime;
  bool? isTimed;
  bool? isPrized;
  bool? isItemApproved;
  bool? isAllowToMsgOthers;
  int? itemCount;
  int? prizeCount;
  String? gameRules;
  String? gameType;
  String? cardType;
  String? teamId;
  String? gameImg;
  bool d = false;
  int isHost = 1;
  int? gamePlayId = 0;
  String? gamePlayStatus = '0';
  String fetchTime = '';
  String fetchOutTime = '';

  @override
  void initState() {
    super.initState();
    imageUrl = widget.imageUrl;
    title = widget.title;
    subtitle = widget.subtitle;
    gameId = widget.gameId;
    otp = widget.otp;
    status = widget.status;
    inTime = widget.inTime;
    outTime = widget.outTime;
    cardType = widget.cardType;
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

  deleteGame() async {
    widget.ondelete({"id": gameId});
    @override
    void initState() {
      super.initState();
    }
  }

  cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    //     DateTime parsedTime = DateTime.parse(inTime??''); // Parse the ISO string
    // var startTime = DateFormat("dd/MM/yy h:mm a").format(parsedTime);

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
          child: Stack(children: [
            Container(
              width: 280,
              height: cardHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin:
                        const EdgeInsets.only(left: 14), // Apply margin here
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(100), // Circular border
                      child: Container(
                        height:
                            50, // Ensure height and width are equal for a perfect circle
                        width: 50,
                        child: Image.network(
                          gameImg ?? '',
                          fit: BoxFit
                              .cover, // Ensures the image fills the container
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
                                imageUrl); // Fallback for broken image
                          },
                        ),
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
            if (widget.isActionMenu == true)
              Positioned(
                height: 30,
                width: 30,
                // top: 3,
                right: 0,
                child: ElevatedButton(
                  onPressed: () {
                    showActionButtons(context, status);
                  },
                  style: ElevatedButton.styleFrom(
                    // minimumSize: Size(50, 50),
                    padding: const EdgeInsets.all(
                        3), // Adjust padding for smaller size
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
                    size: 24, // Reduce the icon size
                  ),
                ),
              ),
            if (widget.isprocessed == 1)
              const Positioned(
                  top: -2,
                  right: 0,
                  // right: 28,
                  child: Icon(
                    Icons.video_call,
                    size: 30,
                    color: Colors.green,
                  )),
            if ((widget.totalItems ?? 0) > 0)
              Positioned(
                  top: 0,
                  right: widget.isprocessed == 1 ? 40 : 10,
                  // right: 28,
                  child: Text(
                    '${widget.uploadedItems}/${widget.totalItems}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  )),
          ]),
        ));
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        cancel();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        deleteGame();

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
                    cancel();
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
