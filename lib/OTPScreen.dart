import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:scavenger_app/CreateNewTeam.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/HuntCreationCompleteScreen.dart';
import 'package:scavenger_app/JoinGameResponse.dart';
import 'package:scavenger_app/ScanQRCodeScreen.dart';
import 'package:scavenger_app/WaitingScreen.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/chalangeDetails.model.dart';
import 'package:scavenger_app/HuntDashboard.dart';
import 'package:scavenger_app/pages/challenge/challenge_details.page.dart';

class OTPScreen extends StatefulWidget {
  @override
  _OTPScreenState createState() => _OTPScreenState();

  final String OTP;
  String type;
  OTPScreen({super.key, required this.OTP, this.type = 'hunt'});
}

class _OTPScreenState extends State<OTPScreen> {
  bool _isLoading = false;
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  bool hasError = false;
  String currentText = "";
  bool isAllowToMsgOthers = false;
  String status = '0';

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    //textEditingController.text = widget.OTP.toString();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  joinChallenge(query) async {
    ApiService.joinChallenge({"qry": query}).then((res) {
      try {
        if (res.success) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ChallengeDetails(challengeId: res.response['id'])));
        } else {
          Fluttertoast.showToast(
            msg: res.message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: const Color.fromARGB(255, 21, 3, 87),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (error) {}
    });
  }

  Future<void> _getgameDetails(query) async {
    setState(() {
      _isLoading = true;
    });
    ApiService.gameDetails(currentText).then((res) {
      try {
        setState(() {
          _isLoading = false;
        });
        print(res.success);
        if (res.success) {
          final homeResponse = ChallangeDetailsModel.fromJson(res.response);
          print(homeResponse.gameId);
          isAllowToMsgOthers = homeResponse.isAllowToMsgOthers ?? false;
          status = homeResponse.status;

          query = "";
          _joinGame(
              homeResponse.id, homeResponse.gameId, homeResponse.gameType);
        } else {
          Fluttertoast.showToast(
            msg: "Invalid Code",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        }
      } catch (error) {
        // print(error);
      }
    });
  }

  Future<void> _joinGame(gameid, gameuniqueId, gameType) async {
    setState(() {
      _isLoading = true;
    });
    ApiService.joinGame({"game_id": gameid, "game_unique_id": gameuniqueId})
        .then((res) {
      try {
        setState(() {
          _isLoading = false;
        });
        if (res.success) {
          final jsonResponseData = JoinGameDtl.fromJson(res.response);
          if (gameType == 'hunt') {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('game joined successful!'),
            ));
            // if (isAllowToMsgOthers) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateNewTeam(
                        myteam: jsonResponseData.gamePlay.teamId,
                        statusChangeid: jsonResponseData.gamePlay.id,
                        gameid: gameid)));
            // } else {
            //   _changeStatus(
            //       jsonResponseData.gamePlay.id,
            //       jsonResponseData.gamePlay.teamId,
            //       gameid,
            //       gameType,
            //       gameuniqueId);
            // }
          } else {
            _changeStatus(
                jsonResponseData.gamePlay.id,
                jsonResponseData.gamePlay.teamId,
                gameid,
                gameType,
                gameuniqueId);
          }
        } else {
          Fluttertoast.showToast(
            msg: res.message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: const Color.fromARGB(255, 21, 3, 87),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (error) {
        // print(error);
      }
    });
  }

  void _changeStatus(statusChangeId, teamId, gameid, gameType, gameuniqueId) {
    ApiService.changeGameStatus({"id": statusChangeId}).then((res) {
      try {
        setState(() {
          _isLoading = false;
        });
        if (res.success) {
          if (gameType != 'hunt') {
            if (status == '0') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HuntCreationCompleteScreen(
                          gameId: gameid,
                          gameuniqueId: gameuniqueId,
                          gameType: gameType ?? 'hunt',
                          cardType: 'joined',
                          myteam: teamId ?? '')));
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HuntDashboard(
                          myteam: teamId, gameId: gameid, gameType: gameType)));
            }
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        WaitingScreen(gameId: gameid, myteam: teamId)));
          }
        }
      } catch (error) {
        // print(error);
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
              title: const Text('Unique Code'),
              backgroundColor: const Color(0xFF0B00AB),
              foregroundColor: Colors.white,
              // actions: [
              //   IconButton(
              //     icon: Icon(Icons.notifications),
              //     onPressed: () {},
              //   ),
              // ],
            ),
            body: SingleChildScrollView(
              child: DecoratedBox(
                decoration: BoxDecoration(
                color: const Color(0xFF0B00AB),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/images/otpphimg.png', // Update the image asset accordingly
                      height: 195,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Unique Code',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter the code received for joining',
                      style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFFD1D1D1),
                          fontFamily: 'Jost'),
                    ),
                    const SizedBox(height: 70),
                    Container(
                      width: screenSize.width,
                      height: screenSize.height - 468,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          //Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // children: [
                          //   OtpBox(number: '1'),
                          //   OtpBox(number: '2'),
                          //   OtpBox(number: '3'),
                          //   OtpBox(number: '4'),
                          // ],

                          PinCodeTextField(
                            appContext: context,
                            length: 6,
                            obscureText: false,
                            animationType: AnimationType.scale,
                            pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                activeBoxShadow: [
                                  const BoxShadow(
                                      color: Color.fromRGBO(219, 219, 219, 1),
                                      blurRadius: 10)
                                ],
                                fieldHeight: 50,
                                fieldWidth: 50,
                                activeFillColor: Colors.white,
                                activeColor: Colors.blue,
                                selectedColor: Colors.blue,
                                inactiveColor:
                                    const Color.fromARGB(255, 251, 246, 246),
                                inactiveFillColor: Colors.white,
                                selectedFillColor:
                                    const Color.fromARGB(255, 250, 251, 252)),
                            animationDuration:
                                const Duration(milliseconds: 300),
                            backgroundColor: Colors.transparent,
                            enableActiveFill: true,
                            errorAnimationController: errorController,
                            controller: textEditingController,
                            onCompleted: (v) {
                              print("Completed");
                            },
                            onChanged: (value) {
                              print(value);
                              setState(() {
                                currentText = value; //widget.OTP.toString();
                              });
                            },
                            beforeTextPaste: (text) {
                              print("Allowing to paste $text");
                              return true;
                            },
                          ),
                          // ),
                          //),

                          /*const SizedBox(height: 20),
                       Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Didn't receive OTP?",
                            style: TextStyle(
                              color: Color(0xFFA0ABC2),
                              fontSize: 16,
                              fontFamily: 'Jost',
                            ),
                          ),
                          const SizedBox(height: 0),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                color:  Color(0xFF0B00AB),
                              ),
                            ),
                          ),
                        ],
                      ), */
                          const SizedBox(height: 30),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: () {
                                    if (widget.type == 'Hunt') {
                                      print({">>>>>>>>vvvavavva"});
                                      _getgameDetails(currentText);
                                    } else {
                                      joinChallenge(currentText);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0B00AB),
                                    foregroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ), //_login,
                                  child: const Text('OK'),
                                ),
                          const SizedBox(height: 20),
                          const Text('OR'),
                          const SizedBox(height: 5),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ScanQRCodeScreen(type: widget.type),
                                ),
                              );
                            },
                            child: const Text(
                              'Scan QR Code',
                              style: TextStyle(
                                color: Color(0xFF0B00AB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}

class OtpBox extends StatelessWidget {
  final String number;

  const OtpBox({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}
