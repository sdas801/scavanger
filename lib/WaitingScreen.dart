import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scavenger_app/CreatedGameDetailsResponse.dart';
import 'package:scavenger_app/GameStatusResponse.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/HuntDashboard.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/shared/details.Widget.dart';
import 'dart:async';
import 'package:scavenger_app/services/progress.bar.dart';

class WaitingScreen extends StatefulWidget {
  final int gameId;
  final String myteam;
  const WaitingScreen({super.key, required this.gameId, required this.myteam});

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  late Timer _timer;
  String gameName = "";
  String desData = "";
  String gameStatus = '0';
  String gameStartDate = "";
  String fetchDate = "";
  String fetchTime = "";
  String gameImg = "";
  String gameType = "";
  List<String> splitData = [];

  @override
  void initState() {
    _gameStatus();
    _getgameDetails();
    _timer = Timer.periodic(Duration(seconds: 3), (_) => _gameStatus());
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _gameStatus() async {
    // setState(() {
    //   _isLoading = true;
    // });
    ApiService.getGameStatus({"id": widget.gameId}).then((value) {
      if (value.success) {
        final jsonResponseData = GameStatus.fromJson(value.response);
        if (jsonResponseData.status == "1") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HuntDashboard(
                      myteam: widget.myteam, gameId: widget.gameId)));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('hunt failed with status: ${value.message}'),
        ));
      }
    });

    // setState(() {
    //   _isLoading = false;
    // });
  }

  Future<void> _getgameDetails() async {
    setState(() {
      _isLoading = true;
    });

    ApiService.gameDetails(widget.gameId).then((value) {
      if (value.success) {
        var homeResponse = Result.fromJson(value.response);
        
          gameName = homeResponse.title;
          desData = homeResponse.description;
          gameStatus = homeResponse.status;
          gameImg = homeResponse.gameImg ?? "";
          gameType = homeResponse.gameType;
          var startDate = homeResponse.inTime ?? "";
          if (startDate != '') {
            var date =
                DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(startDate);
            gameStartDate = DateFormat("MM/dd/yyyy HH:mm aaa").format(date);
            // fetchDate = DateFormat('MM/dd/yy').format(date);
            fetchDate = DateFormat("MMM d, y 'at' h:mm a").format(date);
            fetchTime = DateFormat('hh:mm a').format(date);
          }
          if (homeResponse != null && homeResponse.gameRules != null) {
            splitData = homeResponse.gameRules!
                .split('_')
                .where((element) => element.trim().isNotEmpty)
                .toList();
          } else {
            splitData = []; // Default value or handle the error gracefully
          }
          if(mounted) {
            setState(() {});
          }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${value.message}'),
        ));
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
                  builder: (context) => const HomeScreen(userName: '')));
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Waiting for host"),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DetailsWidget(
                          gameImg: gameImg,
                          gameName: gameName,
                          fetchDate: fetchDate,
                          fetchTime: fetchTime,
                          desData: desData,
                          splitData: splitData,
                          gameType: gameType),
                      const SizedBox(height: 60),
                      gameType == "hunt"
                          ? const Text(
                              'Please Wait to start the Hunt!',
                              style: TextStyle(
                                color: Color(0xFF153792),
                                fontSize: 20,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : const Text(
                              'Please Wait to start the Quest!',
                              style: TextStyle(
                                color: Color(0xFF153792),
                                fontSize: 20,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w600,
                                height: 0.04,
                              ),
                            ),
                      const SizedBox(height: 20),
                      const Text(
                        "Once the host starts the hunt you will recieve your items to hunt. Be sure to follow all instructions and happy hunting!",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF82929D)),
                      ),
                      const SizedBox(height: 20),
                      const progressBar(),
                      const SizedBox(height: 20),
                      const Text(
                        "Your host will start the hunt soon......",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF82929D)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const HomeScreen(userName: ""),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF153792),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ), //_login,
                        child: const Text('Back To Dashboard'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
