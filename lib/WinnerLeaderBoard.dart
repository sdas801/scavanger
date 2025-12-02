import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scavenger_app/model/leaderboard.model.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/utility/random_picture.dart';

class WinnerLeaderBoard extends StatefulWidget {
  final int gameId;
  WinnerLeaderBoard({super.key, required this.gameId});
  @override
  _WinnerLeaderBoardState createState() => _WinnerLeaderBoardState();
}

class _WinnerLeaderBoardState extends State<WinnerLeaderBoard> {
  List<LeaderBoardModel> teams = [];
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLeaderboardData();
  }

  void getLeaderboardData() async {
    ApiService.getLeaderboardData(widget.gameId).then((value) async {
      if (value.success) {
        setState(() {
          teams = List<LeaderBoardModel>.from(
              value.response.map((x) => LeaderBoardModel.fromJson(x)));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          // Do something
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
              title: const Text('Leaderboard'),
              automaticallyImplyLeading: false, // Remove the back button
              backgroundColor: const Color(0xFF0B00AB),
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                color: const Color(0xFF0B00AB),
                child: Column(
                  children: [
                    const SizedBox(height: 40.8),
                    Image.asset(
                      'assets/images/winnerBadge.png', // Update the image asset accordingly
                      height: screenSize.height * 0.25,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(height: screenSize.height * 0.1),
                    Container(
                      width: screenSize.width,
                      height: screenSize.height * 0.5,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Expanded(child: _buildLeaderboardList()),
                          const SizedBox(height: 50),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: () async {
                                    _showAlertDialog(context);
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    if (prefs.containsKey('saved_userId')) {
                                      var username =
                                          (prefs.getString('saved_userName') ??
                                              "");
                                      Timer(
                                          const Duration(seconds: 1),
                                          () => Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeScreen(
                                                          userName:
                                                              username))));
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
                          const SizedBox(height: 35),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  Widget _buildLeaderboardList() {
    return ListView.builder(
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return ListTile(
          leading: getPicture(100, 100),
          title: Text(
            team.userName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Total accepted Items: ${team.acceptedItems}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Icon(Icons.star,
                  color: (index + 1) == 1
                      ? Colors.yellow
                      : (index + 1) == 2
                          ? Colors.blue
                          : Colors.green),
            ],
          ),
        );
      },
    );
  }
}

class Team {
  final String name;
  final String description;
  final String imageUrl;
  final int rank;

  Team(
      {required this.name,
      required this.description,
      required this.imageUrl,
      required this.rank});
}

void _showAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(20.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/greatImg.png', width: 73, height: 73),
            const SizedBox(height: 20),
            const Text(
              'Great',
              style: TextStyle(
                color: Color(0xFF0EA771),
                fontSize: 32,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w800,
                height: 0.01,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Hope you enjoyed \nevery time',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF153792),
                fontSize: 16,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    },
  );
}
