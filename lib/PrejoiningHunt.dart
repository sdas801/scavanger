import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scavenger_app/CreatedGameDetailsResponse.dart';
import 'package:scavenger_app/GameTeamListResponse.dart';
import 'package:scavenger_app/PrejoiningStartHunt.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/utility/random_picture.dart';

class PreJoiningScreen extends StatefulWidget {
  final int gameId;
  final String gameuniqueId;
  const PreJoiningScreen(
      {super.key, required this.gameId, required this.gameuniqueId});

  @override
  _PreJoiningScreenState createState() => _PreJoiningScreenState();
}

class _PreJoiningScreenState extends State<PreJoiningScreen> {
  List<ResultGameteamItem> items = [];
  bool _isLoading = false;
  String gameTitle = "";
  String gamedesc = "";
  String gameduration = "";
  Timer? _timer;
  Widget gamePictureWidget = getPicture(50, 50);
  bool isTimeCheck = false;
  String assignFor = "self";
  String startTime = "";
  String endTime = "";
  String huntImg = "";

  @override
  void initState() {
    super.initState();
    _teamList(1);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _teamList(0));
    _getgameDetails();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  int getTotalSeconds(Duration duration) {
    return duration.inSeconds; // Convert Duration to total seconds
  }

  Future<void> _getgameDetails() async {
    setState(() {
      _isLoading = true;
    });
    ApiService.gameDetails(widget.gameId).then((value) {
      try {
        if (value.success) {
          final homeResponse = Result.fromJson(value.response);
          huntImg = homeResponse.gameImg ?? '';
          gameTitle = homeResponse.title;
          gamedesc = homeResponse.description;
          isTimeCheck = homeResponse.isTimed;
          if (isTimeCheck) {
            DateTime dateTime1 = DateTime.parse(homeResponse.inTime!);
            DateTime dateTime2 = DateTime.parse(homeResponse.outTime!);
            startTime = DateFormat("MMM d, y 'at' h:mm a").format(
                dateTime1); //DateFormat('dd-MM-yy hh:mm a').format(dateTime1);
            endTime = DateFormat("MMM d, y 'at' h:mm a").format(
                dateTime2); //DateFormat('dd-MM-yy hh:mm a').format(dateTime2);
            // Calculate the difference between the two DateTime objects
            Duration difference = dateTime2.difference(dateTime1);
            // Output the difference
            int totalSeconds = getTotalSeconds(difference);
            // Convert seconds to hours and minutes
            int days = totalSeconds ~/ (24 * 3600);
            int remainingSeconds = totalSeconds % (24 * 3600);
            int hours = remainingSeconds ~/ 3600;
            int minutes = (remainingSeconds % 3600) ~/ 60;
            if (days > 0) {
              gameduration =
                  '$days days $hours hrs $minutes mins'; // FIXED: Added remaining hours
            } else if (hours > 0) {
              gameduration = '$hours hrs and $minutes mins';
            } else {
              gameduration = '$minutes mins';
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error fetching game details: ${value.message}'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _teamList(int flag) async {
    if (flag == 1) {
      setState(() {
        _isLoading = true;
      });
    }
    ApiService.getGameTeam({"game_id": widget.gameId}).then((value) {
      if (value.success) {
        // final jsonResponseData = GameTeamListResponse.fromJson(value.response);
        final gameList = List<ResultGameteamItem>.from(
            value.response.map((x) => ResultGameteamItem.fromJson(x)));
        setState(() {
          items = gameList;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed: ${value.message}'),
        ));
      }
    });

    if (flag == 1) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateInTime() {
    ApiService.updateInTime({
      "id": widget.gameId,
      "type": "start",
      "game_time": DateTime.now().toString()
    }).then((res) {
      try {
        if (res.success) {
          print({"object", res});
        }
      } catch (error) {
        // print(error);
      }
    });
  }

  Future<void> _startHunt() async {
    setState(() {
      _isLoading = true;
    });
    _timer!.cancel();

    ApiService.activateGame({
      "id": widget.gameId,
    }).then((res) {
      try {
        if (res.success) {
          if (!isTimeCheck) {
            _updateInTime();
          }
          Navigator.pushReplacement(
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

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Pre joining",
          style: TextStyle(fontFamily: 'Jost', fontSize: 24),
        ),
        automaticallyImplyLeading: false, // Remove the back button
        backgroundColor: const Color(0xFF0B00AB),
        foregroundColor: Colors.white,
        // actions: [
        //   IconButton(
        //     icon: const Image(
        //         image: AssetImage('assets/images/notification.png'),
        //         height: 34,
        //         width: 34),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      backgroundColor: Color(0xFFF2F2F2),
      body: Column(
        children: [
          isTimeCheck
              ? Container(
                  width: double.infinity,
                  height: 155,
                  padding: const EdgeInsets.all(0.0),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/time_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30, top: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Start Time : ${startTime}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "End Time   : ${endTime}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          'Time Duration',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            const Image(
                                image: AssetImage('assets/images/clock_1.png'),
                                height: 44,
                                width: 44),
                            const SizedBox(width: 8.0),
                            Text(
                              gameduration, //'2hs 30min',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 27),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(height: 16),
          // const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Card(
              child: ListTile(
                leading: huntImg != ''
                    ? CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(huntImg),
                      )
                    : const CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            AssetImage('assets/images/defaultImg.jpg'),
                      ),
                title: Text(
                  'Hunt Name: ${gameTitle}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B00AB),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      gamedesc.length > 50
                          ? '${gamedesc.substring(0, 50)}...'
                          : gamedesc,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 4, 4, 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListItem(
                  title: items[index].teamname ?? items[index].player.name,
                  subtitle: "",
                  imagePath: items[index].teamimg ?? "",
                  status: items[index].status,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {

                      // }
                      // else{
                      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      //     content: Text('Please enter data'),
                      //  ));
                      // }

                      _startHunt();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF153792),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ), //_login,
                    child: const Text('Start Hunt'),
                  ),
                ),
        ],
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String status;

  ListItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;

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
