import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scavenger_app/CreateHunt3rdPage.dart';
import 'package:scavenger_app/custom_textfield.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/services/stepper.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/gameUpdate.model.dart';

class CreateHunt2ndPage extends StatefulWidget {
  final int gameId;
  final String gameuniqueId;
  const CreateHunt2ndPage(
      {super.key, required this.gameId, required this.gameuniqueId});

  @override
  _CreateHunt2ndPageState createState() => _CreateHunt2ndPageState();
}

class _CreateHunt2ndPageState extends State<CreateHunt2ndPage> {
  final TextEditingController _teamNumberController = TextEditingController();

  bool isTimedHunt = false;
  bool willOfferPrizes = false;
  bool willApproveItems = false;
  bool allowMessaging = false;
  bool _isLoading = false;
  String? selectedTeam;
  List<String> teams = ['1', '2', '3', '4'];
  PolicyResult? isCheckSubcription;

  @override
  void initState() {
    super.initState();
    getSubcriptionCheck();
    _gameDetails();
  }

  void getSubcriptionCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    if (subcriptionCheckString != null) {
      Map<String, dynamic> jsonData = jsonDecode(subcriptionCheckString);
      if (mounted)
        setState(() {
          isCheckSubcription = PolicyResult.fromJson(jsonData);
        });
    }
  }

  void _gameDetails() {
    ApiService.gameDetails(widget.gameId).then((value) {
      if (value.success) {
        var result = GameStep2.fromJson(value.response);
        if (mounted)
          setState(() {
            isTimedHunt = result.isTimed!;
            willOfferPrizes = result.isPrized!;
            willApproveItems = result.isItemApproved!;
            allowMessaging = result.isAllowToMsgOthers!;
            _teamNumberController.text = (result.maxTeam?.toString() ??
                isCheckSubcription!.maxHuntTeams?.toString() ??
                '1');
            // (isCheckSubcription!.maxHuntTeams?.toString() ??
            //     result.maxTeam?.toString()??"1");
          });
      }
    });
  }

  Future<void> _createGame2(context) async {
    if (_teamNumberController.text == "" ||
        _teamNumberController.text == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter Maximun Number of Teams !'),
      ));
      return;
    }

    var maxHuntTeams = isCheckSubcription!.maxHuntTeams;
    int enteredTeams = int.tryParse(_teamNumberController.text) ?? 0;
    if (maxHuntTeams != null && maxHuntTeams < enteredTeams) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "As per your current subcription plan, You can create up to $maxHuntTeams hunt teams."),
        ),
      );
      return;
    }
    if (mounted)
      setState(() {
        _isLoading = true;
      });

    var reqData = {
      "id": widget.gameId,
      "is_timed": isTimedHunt,
      "is_prized": willOfferPrizes,
      "is_item_approved": willApproveItems,
      "is_allow_to_msg_others": allowMessaging,
      "max_team": _teamNumberController.text
    };
    ApiService.updateGameCheck(reqData).then((value) async {
      try {
        if (value.success) {
          // final jsonResponseData = CreateHunt2Response.fromJson(value.response);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isTimedHunt', isTimedHunt);
          await prefs.setBool('willOfferPrizes', willOfferPrizes);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateHunt3rdPage(
                      gameId: widget.gameId,
                      gameuniqueId: widget.gameuniqueId)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('hunt failed: ${value.message}'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      }
    });
  }

  void _onMessagingTeamsChanged() {
    if (mounted)
      setState(() {
        if (!allowMessaging) {
          selectedTeam = "1";
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Create Hunt"),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.asset(
                    'assets/images/1 1.png', // Update the image asset accordingly
                    height: 117,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 20),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'Create a Hunt                                     ',
                          style: TextStyle(
                            color: Color(0xFF153792),
                            fontSize: 30,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w800,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  StepperTabPage(
                      activeStep: 1, totalStep: 6, gameId: widget.gameId),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text('Is this a timed hunt?'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: isTimedHunt,
                          onChanged: (bool value) {
                            if (mounted)
                              setState(() {
                                isTimedHunt = value;
                              });
                          },
                        ),
                        const Text('ON'),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Will you offer prizes?'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: willOfferPrizes,
                          onChanged: (bool value) {
                            if (mounted)
                              setState(() {
                                willOfferPrizes = value;
                              });
                          },
                        ),
                        const Text('ON'),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Will you approve items?'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: willApproveItems,
                          onChanged: (bool value) {
                            if (mounted)
                              setState(() {
                                willApproveItems = value;
                              });
                          },
                        ),
                        const Text('ON'),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Allow messaging to other teams?'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: allowMessaging,
                          onChanged: (bool value) {
                            if (mounted)
                              setState(() {
                                allowMessaging = value;
                                _onMessagingTeamsChanged();
                              });
                          },
                        ),
                        const Text('ON'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // allowMessaging
                  //     ?
                  CustomTextField(
                    controller: _teamNumberController,
                    labelText: 'Maximum Number of Teams:',
                    hintText: 'Enter your number of team',
                    maxLines: 1,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    // keyboardType: TextInputType.number,
                  ),
                  // : SizedBox.shrink(),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () {
                            // if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                            // }
                            // else{
                            //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            //     content: Text('Please enter data'),
                            //  ));
                            // }
                            _createGame2(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF153792),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ), //_login,
                          child: const Text('Next'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
