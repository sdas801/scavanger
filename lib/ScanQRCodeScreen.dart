import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/HuntCreationCompleteScreen.dart';
import 'package:scavenger_app/OTPScreen.dart';
import 'package:scavenger_app/WaitingScreen.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/pages/subcriptions/currentPlandialog.dart';
import 'package:scavenger_app/qr_scanner.dart';
import 'package:scavenger_app/CreateNewTeam.dart';
import 'package:scavenger_app/JoinGameResponse.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/chalangeDetails.model.dart';
import 'package:scavenger_app/HuntDashboard.dart';
import 'package:scavenger_app/pages/challenge/challenge_details.page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanQRCodeScreen extends StatefulWidget {
  String type;
  ScanQRCodeScreen({super.key, this.type = 'hunt'});

  @override
  _ScanQRCodeScreenState createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState extends State<ScanQRCodeScreen> {
  bool _isLoading = false;
  String status = '0';
  bool isAllowToMsgOthers = false;
  String checkMyteam = '';
  int statusChangeid = 0;

  @override
  void initState() {
    super.initState();
  }

  joinChallenge(query) async {
    print("=====================");
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
    print('fetching game details');
    setState(() {
      _isLoading = true;
    });
    ApiService.gameDetails(query).then((res) {
      try {
        setState(() {
          _isLoading = false;
        });
        print('res.success >>> ${res.success}');
        if (res.success) {
          final homeResponse = ChallangeDetailsModel.fromJson(res.response);
          status = homeResponse.status;
          isAllowToMsgOthers = homeResponse.isAllowToMsgOthers ?? false;
          // _joinGame(
          //     homeResponse.id, homeResponse.gameId, homeResponse.gameType);
          print('fetch game details completed');
          showHardcoreConfirmDialog(context, title: homeResponse.title, gameid: homeResponse.id, gameuniqueId: homeResponse.gameId, gameType: homeResponse.gameType);
        }
      } catch (error) {
        // print(error);
      }
    });
  }

  Future<bool?> showHardcoreConfirmDialog(
    BuildContext context, {
    String title = '',
    String message =
        'Are you sure? You want to join the hunt.',
    String confirmLabel = 'Join Hunt',
    String cancelLabel = 'Cancel',
    IconData icon = Icons.warning_amber_rounded,
    Color? dangerColor, // defaults to Theme.error
    bool barrierDismissible = true,
    gameid, gameuniqueId, gameType
  }) async {
    final errorColor = dangerColor ?? Theme.of(context).colorScheme.error;
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: errorColor.withOpacity(0.35), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: errorColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: errorColor, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  message,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(null),
                            icon: const Icon(Icons.close),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 14),

                      // Countdown + actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(cancelLabel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: errorColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed:  (){
                                Navigator.of(context).pop(true);
                                _joinGame(gameid, gameuniqueId, gameType);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(confirmLabel),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          
      },
    ).whenComplete(() {
      // ensure timers are cleaned up if dialog is dismissed early
      // (Timers are tied to the StatefulBuilder scope above)
      return null;
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
          checkMyteam = jsonResponseData.gamePlay.teamId;
          statusChangeid = jsonResponseData.gamePlay.id;
          print(jsonResponseData);
          if (gameType == 'hunt') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('game joined successful!'),
            ));
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateNewTeam(
                        myteam: jsonResponseData.gamePlay.teamId,
                        statusChangeid: jsonResponseData.gamePlay.id,
                        gameid: gameid)));
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
        print("error");
      }
    });
  }

  void _changeStatus(statusChangeId, teamId, gameid, gameType, gameuniqueId) {
    ApiService.changeGameStatus({"id": statusChangeId}).then((res) {
      try {
        if (res.success) {
          if (gameType != 'hunt') {
            if (status == '0') {
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => const HomeScreen(userName: '')));

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
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        WaitingScreen(gameId: gameid, myteam: teamId)));
          }
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
                  builder: (context) => HomeScreen(userName: '', selectedTab: widget.type.toLowerCase() == 'hunt' ? 0 : 1,)));
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
                            HomeScreen(userName: '', selectedTab: widget.type.toLowerCase() == 'hunt' ? 0 : 1)));
              },
            ),
            title: const Text("Scan QR Code"),
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
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/images/scanqttxt.png', // Update the image asset accordingly
                        height: 100,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(height: 80),
                      Image.asset(
                        'assets/images/scanQRpic.png', // Update the image asset accordingly
                        height: 255,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(height: 40),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () async {
                                final qrResult = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const QRScanner(),
                                  ),
                                );
                                if (qrResult != null) {
                                  print("qrResult >>>>>>>>>>>>> ${qrResult}");
                                  if (widget.type == 'Hunt') {
                                    _getgameDetails(qrResult);
                                  } else {
                                    joinChallenge(qrResult);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(21, 55, 146, 1),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ), //_login,
                              child: const Text('Scan'),
                            ),
                      const SizedBox(height: 20),
                      Image.asset('assets/images/or_border.png'),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OTPScreen(OTP: '', type: widget.type),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(21, 55, 146, 1),
                              fontWeight: FontWeight.w600),
                        ), //_login,
                        child: const Text('Enter code'),
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
