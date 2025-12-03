import 'dart:async';
import 'dart:developer';

import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:scavenger_app/CreatedGameDetailsResponse.dart';
import 'package:scavenger_app/GameTeamListResponse.dart';
import 'package:scavenger_app/JoinGameResponse.dart';
import 'package:scavenger_app/LeaderBoardPage.dart';
import 'package:scavenger_app/chatScreen.dart';
import 'package:scavenger_app/constants.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/shared/video.widget.dart';
import 'package:scavenger_app/teamListPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:scavenger_app/utility/random_picture.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:logger/logger.dart';
import 'package:scavenger_app/services/chat_socket_service.dart';

class PrejoiningStartHunt extends StatefulWidget {
  final int gameId;
  const PrejoiningStartHunt({super.key, required this.gameId});

  @override
  _PrejoiningStartHuntState createState() => _PrejoiningStartHuntState();
}

class _PrejoiningStartHuntState extends State<PrejoiningStartHunt>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool _isLoading = false;
  Timer? _timer;
  Timer? _timer1;
  int _start = 0;
  socket_io.Socket? socket;
  final Logger logger = Logger();
  int userid = 0;
  String username = "";
  late TabController _tabController;
  final ValueNotifier<int> _unreadChat = ValueNotifier<int>(0);

  // Lifecycle management variables
  bool _isAppInForeground = true;
  bool _isWidgetActive = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);

    // Add listener to the TabController to unfocus when the tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Dismiss the keyboard when the tab is changed
        FocusManager.instance.primaryFocus?.unfocus();
        // Clear unread when landing on Chats tab (index 2)
        log('_tabController.index >>> ${_tabController.index}');
        if (_tabController.index == 2) {
          _unreadChat.value = 0;
        }
      }
    });

    getUserId();

    // Call initial data load after widget is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        startTimer();
      }
    });
  }

  Future<void> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('saved_userId')) {
      userid = (prefs.getInt('saved_userId') ?? 0);
      username = (prefs.getString('saved_userName') ?? "");
      setState(() {}); // show UI if needed

      // 🔗 Connect global chat socket once user id is known
      final chat = ChatSocketService();
      chat.connect(
        userId: userid,
        roomId: widget.gameId,
        baseUrl: ApiConstants.socketUrl,
        path: ApiConstants.socketPath,
      );

      //  Listen for new messages to bump badge when not on chat tab
      chat.onNewMessage.listen((msg) {
        // Only bump if not on chat tab and message is not from me
        final myIdStr = userid.toString();
        if (_tabController.index != 2 && msg.userId != myIdStr) {
          _unreadChat.value = _unreadChat.value + 1;
        }
      });
    }
  }

  @override
  void dispose() {
    log(" PrejoiningStartHunt disposing - cleaning up resources");
    WidgetsBinding.instance.removeObserver(this);
    _stopPeriodicRefresh();
    _timer?.cancel();
    _timer1?.cancel();
    _tabController.dispose();
    _unreadChat.dispose();
    ChatSocketService().disconnect();
    super.dispose();
  }

  @override
  void deactivate() {
    log("⏸ PrejoiningStartHunt deactivated - stopping API calls");
    _isWidgetActive = false;
    _stopPeriodicRefresh();
    super.deactivate();
  }

  @override
  void activate() {
    log("▶ PrejoiningStartHunt activated - resuming API calls");
    _isWidgetActive = true;
    super.activate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _shouldRunTimer()) {
        log("🔄 activate - starting timer");
        startTimer();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        log(" App resumed - starting periodic refresh");
        _isAppInForeground = true;
        if (_shouldRunTimer()) {
          startTimer();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        log(" App went to background - stopping periodic refresh");
        _isAppInForeground = false;
        _stopPeriodicRefresh();
        break;
      case AppLifecycleState.detached:
        log(" App detached - stopping periodic refresh");
        _isAppInForeground = false;
        _stopPeriodicRefresh();
        break;
    }
  }

  bool _shouldRunTimer() {
    return _isAppInForeground && _isWidgetActive && mounted;
  }

  void _stopPeriodicRefresh() {
    if (_timer1 != null) {
      log("⏹ Stopping periodic refresh timer");
      _timer1?.cancel();
      _timer1 = null;
    }
  }

  void startTimer() async {
    _stopPeriodicRefresh();

    if (!_shouldRunTimer()) {
      log(" Not starting timer - conditions not met (isAppInForeground: $_isAppInForeground, isWidgetActive: $_isWidgetActive, mounted: $mounted)");
      return;
    }

    log(" Starting periodic refresh timer (2 seconds interval)");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _timer1 = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (mounted && _shouldRunTimer()) {
        log(" Periodic refresh triggered");
        _teamItemList11(prefs, widget.gameId);
      } else {
        log(" Stopping timer - conditions no longer met");
        _stopPeriodicRefresh();
      }
    });
  }

  Future<void> _teamItemList11(SharedPreferences prefs, int gameId) async {
    // Don't make API call if widget is not active or app is in background
    if (!_shouldRunTimer()) {
      log(" Skipping API call - widget not active or app in background");
      return;
    }

    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final value = await ApiService.getGameTeam({
        "game_id": widget.gameId,
      });

      if (!mounted) {
        _isRefreshing = false;
        return;
      }

      if (value.success) {
        final gameList = List<ResultGameteamItem>.from(
            value.response.map((x) => ResultGameteamItem.fromJson(x)));
        await prefs.remove('playerList');

        var playerList = gameList;
        var pC = 0;
        var itC = 0;
        for (var team in playerList) {
          pC += 1;
          for (var item1 in team.playItems) {
            if (item1.itemImgUrl != null) {
              itC++;
            }
          }
        }
        prefs.setInt('pC', pC);
        prefs.setInt('itC', itC);
        prefs.setString('playerList', jsonEncode(value.response));
        log("Team items updated - $pC teams, $itC items");
      }
    } catch (e) {
      log(" Error fetching team items: $e");
    } finally {
      _isRefreshing = false;
    }
  }

  void _showContinueDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            "Are you sure you want to quit the hunt?",
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                try {
                  _timer?.cancel();
                  _timer1?.cancel();
                } catch (e) {
                  // print(e);
                }
                // Navigator.of(context).pop();
                // leaveRoom();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(userName: ""),
                  ),
                  (Route<dynamic> route) =>
                      false, // This removes all previous routes
                );
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // _createGameClick(); // Close the dialog
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
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
          if (_tabController.index != 0) {
            _tabController.animateTo(0);
          } else {
            _showContinueDialog(context);
          }
          // leaveRoom();
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const HomeScreen(userName: ""),
          //   ),
          //   (Route<dynamic> route) => false,
          // );
        },
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_tabController.index != 0) {
                    _tabController.animateTo(0);
                  } else {
                    _showContinueDialog(context);
                  }
                },
              ),
              title: const Text(
                "Active  Hunt",
                style: TextStyle(fontFamily: 'Jost', fontSize: 24),
              ),
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
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.white,
                labelColor: const Color.fromARGB(255, 210, 223, 229),
                tabs: [
                  const Tab(text: 'Game Details'),
                  const Tab(text: 'Item Review'),
                  ValueListenableBuilder<int>(
                    valueListenable: _unreadChat,
                    builder: (_, count, __) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Tab(text: 'Chats'),
                          if (count > 0)
                            Positioned(
                              right: -12,
                              top: -8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(minWidth: 18),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            body: Container(
              width: screenSize.width,
              height: screenSize.height,
              child: TabBarView(
                controller: _tabController,
                physics:
                    const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
                children: [
                  GameDetailsTab(gameId: widget.gameId),
                  // const Text('data'),
                  ItemDetailsTabPage(gameId: widget.gameId),
                  ChatScreen(
                    gameId: widget.gameId,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class GameDetailsTab extends StatefulWidget {
  final int gameId;
  const GameDetailsTab({super.key, required this.gameId});

  @override
  _GameDetailsTabState createState() => _GameDetailsTabState();
}

class _GameDetailsTabState extends State<GameDetailsTab> {
  //final _PrejoiningStartHuntState prejoinstart = new _PrejoiningStartHuntState();
  bool _isLoading = false;
  String gameTitle = "";
  String gamedesc = "";
  String startTimeString = "";
  int _start = 0;
  int pC = 0;
  int itC = 0;
  Timer? _timer;
  String startDateAndTime = "";
  String endDateAndTime = "";
  String isEndtime = "";

  String gameImg = "";

  // DateTime _startTime = DateTime.now();
  // Duration _elapsedTime = Duration.zero;
  bool isStartEqualToCurrent = false;

  Widget gamePicWidget = getPicture(50, 50);
  final Logger logger = Logger();
  int userid = 0;
  String username = "";
  final huntItemAllList = [];
  List<ResultGameteamItem> playerList = [];
  List<dynamic> restructuredPlayerList = [];

  @override
  void initState() {
    super.initState();
    getUserId();
    _timer?.cancel();
    _getgameDetails();
    log("This is the list of the hunt items >>>>>>>>>${huntItemAllList.toList()}");
  }

  Future<void> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('saved_userId')) {
      setState(() {
        userid = (prefs.getInt('saved_userId') ?? 0);
        username = (prefs.getString('saved_userName') ?? "");
      });
    }
  }

  void startTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    //   setState(() {
    //     _start = prefs.getInt('timer') ?? 0;
    //     pC = prefs.getInt('pC') ?? 0;
    //     itC = prefs.getInt('itC') ?? 0;
    //   });
    // });

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _start = _start + 1;
      pC = prefs.getInt('pC') ?? 0;
      itC = prefs.getInt('itC') ?? 0;
      if (mounted) {
        setState(() {});
      }
      // prefs.setInt('timer', _start);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<void> _teamItemList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final value = await ApiService.getGameTeam({
        "game_id": widget.gameId,
      });

      if (value.success) {
        final gameList = List<ResultGameteamItem>.from(
          value.response.map((x) => ResultGameteamItem.fromJson(x)),
        );

        playerList = gameList;
        log("✅ Total Teams Fetched: ${playerList.map((e) => e.toJson()).toList()}");

        int totalNotApprovedItems = 0;
        int totalNotSubmittedTeams = 0;
        int totalUnUploadItem = 0;
        // 🔹 Loop through all teams (players)
        for (var team in playerList) {
          bool hasUnapprovedItem = false;

          if (team.issubmitted == 0) {
            totalNotSubmittedTeams++;
            log("❌ Team '${team.teamname}' has issubmitted = 0");
          }

          // 🔹 Check playItems only if issubmitted == 1
          if ((team.issubmitted == 1 || team.issubmitted == 0) &&
              team.playItems.isNotEmpty) {
            for (var item in team.playItems) {
              // Ignore items that have no snapshot
              if (team.issubmitted == 0) {
                if ((item.snapshot == null ||
                        item.snapshot.toString().trim().isEmpty) &&
                    (item.itemImgUrl == null ||
                        item.snapshot.toString().trim().isEmpty)) {
                  totalUnUploadItem++;
                }
              }
              if ((item.snapshot == null ||
                      item.snapshot.toString().trim().isEmpty) &&
                  (item.itemImgUrl == null ||
                      item.snapshot.toString().trim().isEmpty)) {
                continue;
              }

              // If snapshot exists, check approval status
              if (item.status.toString() != '1') {
                totalNotApprovedItems++;
                hasUnapprovedItem = true;
                log("⚠️ Team '${team.teamname}' → Item '${item.name}' not approved (status: ${item.status})");
              }
            }

            if (hasUnapprovedItem) {
              log("⚠️ Team '${team.teamname}' has unapproved items despite issubmitted = 1");
            }
          }
        }

        // 🔹 Decision making based on results
        if (totalNotSubmittedTeams == 0 && totalNotApprovedItems == 0) {
          // ✅ Everything is approved and submitted
          log("🎯 All teams submitted and all valid items approved. Ending hunt...");
          _endHunt();
        } else {
          // ⚠️ Show summary dialog for issues
          _showStatusDialog(
              notApprovedItemCount: totalNotApprovedItems,
              totalPlayers: playerList.length,
              notSubmittedPlayers: totalNotSubmittedTeams,
              totalUnUploadItem: totalUnUploadItem);
        }
      } else {
        log("❌ API Error: ${value.message}");
      }
    } catch (e, st) {
      log("⚠️ Exception: $e\n$st");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showStatusDialog(
      {required int notApprovedItemCount,
      required int totalPlayers,
      required int notSubmittedPlayers,
      required int totalUnUploadItem}) {
    showDialog(
      context: context,
      barrierDismissible: false, // user can't close by tapping outside
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              "Team Status Summary",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            totalPlayers == 0
                ? SizedBox()
                : _buildStatusRow(
                    "Total Players:", totalPlayers.toString(), Colors.blue),
            notSubmittedPlayers == 0
                ? SizedBox()
                : _buildStatusRow("Players not submitted:",
                    notSubmittedPlayers.toString(), Colors.orange),
            // const SizedBox(height: 8),
            notApprovedItemCount == 0
                ? SizedBox()
                : _buildStatusRow("Unapproved Items:",
                    notApprovedItemCount.toString(), Colors.redAccent),
            // const SizedBox(height: 8),
            totalUnUploadItem == 0
                ? SizedBox()
                : _buildStatusRow("Items Not Submited:",
                    totalUnUploadItem.toString(), Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              notApprovedItemCount == 0 && notSubmittedPlayers == 0
                  ? "✅ All items are approved and all players have submitted their results."
                  : "⚠️ Please review unapproved items or pending players before proceeding.",
              style: TextStyle(
                fontSize: 14,
                color: notApprovedItemCount == 0 && notSubmittedPlayers == 0
                    ? Colors.green
                    : Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _endHunt();
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text("Proceed"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getgameDetails() async {
    setState(() {
      _isLoading = true;
    });
    ApiService.gameDetails(widget.gameId).then((value) {
      try {
        if (value.success) {
          var homeResponse = Result.fromJson(value.response);
          gameTitle = homeResponse.title;
          gamedesc = homeResponse.description;
          if (homeResponse.inTime != null) {
            homeResponse.inTime = homeResponse.inTime!.replaceAll('Z', '');
          }

          // log("This is the item of the hunt >>>>>>>>>${homeResponse.items[0].toJson()}");
          DateTime dateTime1 = DateTime.parse(homeResponse.inTime!);
          DateTime dateTime = (dateTime1);
          startDateAndTime =
              DateFormat("MMM d, y 'at' h:mm a").format(dateTime);
          DateTime now = DateTime.now();
          Duration difference = now.difference(dateTime1);
          _start = difference.inSeconds;
          if (_start < 0) {
            _start = 0;
          }
          if (homeResponse.outTime != null && homeResponse.outTime != "") {
            DateTime dateTime2 = DateTime.parse(homeResponse.outTime!);
            endDateAndTime =
                DateFormat("MMM d, y 'at' h:mm a").format(dateTime2);
          }

          String formattedTime = DateFormat('h:mma').format(dateTime1);
          startTimeString = formattedTime.toLowerCase();
          gameImg = homeResponse.gameImg ?? '';
          startTimer();
        } else {}
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _endHunt() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _timer?.cancel();
    } catch (e) {}
    ApiService.endGame({"id": widget.gameId}).then((value) {
      if (value.success) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LeaderboardPage(gameId: widget.gameId)));
      } else {}
    });

    setState(() {
      _isLoading = false;
    });
  }

  String getTimeString(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showEndGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to end the game?"),
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
                _endHunt();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 57, 41, 206),
              ),
              child: const Text(
                "Yes",
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

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: ListTile(
                leading: gameImg.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                            50), // Adjust the radius value
                        child: Image.network(
                          gameImg,
                          fit: BoxFit
                              .cover, // Optional: adjust how the image fits in the container
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(
                            50), // Adjust the radius value
                        child: Image.asset(
                          'assets/images/defaultImg.jpg',
                          fit: BoxFit
                              .cover, // Optional: adjust how the image fits in the container
                        ),
                      ),
                title: Text(
                  gameTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B00AB),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('1h 32min'),
                    // Text('12:00pm'),
                    const SizedBox(height: 8),
                    Text(gamedesc),
                    const SizedBox(height: 8),
                    // Row(
                    //   children: [
                    //     Icon(Icons.monetization_on, color: Colors.amber),
                    //     Text('600'),
                    //     SizedBox(width: 16),
                    //     Icon(Icons.token, color: Colors.amber),
                    //     Text('1000'),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/game-default.jpg'),
                ),
                title: Text(
                  '$itC Picture Uploaded By $pC Teams',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: screenSize.width, // 80% of the screen width
              height: 351,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Hunt_timing_blue_ico.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              //child: const SingleChildScrollView(
              padding: const EdgeInsets.only(left: 28, right: 28, bottom: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 0),
                  Text(
                    getTimeString(_start),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                      height: 0.01,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Start time: ${startDateAndTime}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w500,
                      height: 0.05,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  endDateAndTime.isNotEmpty
                      ? Text(
                          'End time: ${endDateAndTime}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w500,
                            height: 0.05,
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 30),
                ],
              ),
              // ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(userName: ""),
                  ),
                  (Route<dynamic> route) =>
                      false, // This removes all previous routes
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF153792),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ), //_login,
              child: const Text('Back to DashBoard'),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _teamItemList();
                      // _showEndGameDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF153792),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ), //_login,
                    child: const Text('End'),
                  ),
                ),
        ],
      ),
    );
  }
}

class ItemDetailsTabPage extends StatefulWidget {
  final int gameId;
  const ItemDetailsTabPage({super.key, required this.gameId});

  @override
  _ItemDetailsTabPageState createState() => _ItemDetailsTabPageState();
}

class _ItemDetailsTabPageState extends State<ItemDetailsTabPage>
    with WidgetsBindingObserver {
  bool _isLoading = false;
  bool isItemApprove = false;

  List<ResultGameteamItem> playerList = [];
  List<dynamic> restructuredPlayerList = [];
  List<dynamic> waitingForApprovalList = [];
  List<ResultGameteamItem> filteredList = [];
  Timer? _timer;

  // Lifecycle management variables
  bool _isAppInForeground = true;
  bool _isWidgetActive = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Call initial data load after widget is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _teamItemList();
        _getgameDetails();
        _startTimer();
      }
    });
  }

  Future<void> _onRefresh() async {
    _stopPeriodicRefresh();
    await _teamItemList();
    await _getgameDetails();
    if (_shouldRunTimer()) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    log(" ItemDetailsTabPage disposing - cleaning up resources");
    WidgetsBinding.instance.removeObserver(this);
    _stopPeriodicRefresh();
    super.dispose();
  }

  @override
  void deactivate() {
    log("⏸ ItemDetailsTabPage deactivated - stopping API calls");
    _isWidgetActive = false;
    _stopPeriodicRefresh();
    super.deactivate();
  }

  @override
  void activate() {
    log("▶ ItemDetailsTabPage activated - resuming API calls");
    _isWidgetActive = true;
    super.activate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _shouldRunTimer()) {
        log("🔄 activate - starting timer");
        _startTimer();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        log(" App resumed - starting periodic refresh");
        _isAppInForeground = true;
        if (_shouldRunTimer()) {
          _startTimer();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        log(" App went to background - stopping periodic refresh");
        _isAppInForeground = false;
        _stopPeriodicRefresh();
        break;
      case AppLifecycleState.detached:
        log(" App detached - stopping periodic refresh");
        _isAppInForeground = false;
        _stopPeriodicRefresh();
        break;
    }
  }

  bool _shouldRunTimer() {
    return _isAppInForeground && _isWidgetActive && mounted;
  }

  void _stopPeriodicRefresh() {
    if (_timer != null) {
      log("⏹️ Stopping periodic refresh timer");
      _timer?.cancel();
      _timer = null;
    }
  }

  _startTimer() async {
    _stopPeriodicRefresh();

    if (!_shouldRunTimer()) {
      log(" Not starting timer - conditions not met (isAppInForeground: $_isAppInForeground, isWidgetActive: $_isWidgetActive, mounted: $mounted)");
      return;
    }

    log(" Starting periodic refresh timer (2 seconds interval)");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted && _shouldRunTimer()) {
        log(" Periodic refresh triggered");
        try {
          var jsonResponse1 = jsonDecode(prefs.getString('playerList') ?? '');
          playerList = List<ResultGameteamItem>.from(
              jsonResponse1.map((x) => ResultGameteamItem.fromJson(x)));
          // log("this is the items comes for the approveable >>>>>>>>>> before ${playerList.map((i) => i.toJson())}");

          filteredList =
              // playerList.where((item) => item.issubmitted == 1 ).toList();

              playerList
                  .where((item) =>
                      item.issubmitted == 1 && item.playItems[1].status != 0)
                  .toList();

          restructuredPlayerList = restructureTeamItemList(filteredList);
          // restructuredPlayerList = (filteredList);

          // log("this is the items comes for the approveable >>>>>>>>>> after  ${filteredList.map((i) => i.toJson())}");
          setState(() {});
        } catch (e) {
          log("❌ Error processing player list: $e");
        }
      } else {
        log("🛑 Stopping timer - conditions no longer met");
        _stopPeriodicRefresh();
      }
    });
  }

  Future<void> _teamItemList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      ApiService.getGameTeam({
        "game_id": widget.gameId,
      }).then((value) async {
        if (value.success) {
          // final jsonResponseData = GameTeamListResponse.fromJson(value.response);
          final gameList = List<ResultGameteamItem>.from(
              value.response.map((x) => ResultGameteamItem.fromJson(x)));
          playerList = gameList;
          filteredList =
              // playerList.where((item) => item.issubmitted == 1).toList();
              playerList
                  .where((item) =>
                      item.issubmitted == 1 && item.playItems[1].status != 0)
                  .toList();
          // log("this is the items comes for the approveable >>>>>>>>>> ${value.response}");
          restructuredPlayerList = restructureTeamItemList(filteredList);
          // restructuredPlayerList = (filteredList);
          // log("this is the items comes for the approveable >>>>>>>>>> after  ${filteredList.map((i) => i.toJson())}");

          // log("this is the game item >>>>>>>>>>>>${gameList[0].toJson()}");
          setState(() {});
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   content: Text('hunt failed: ${value.message}'),
          // ));
        }
      });
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  restructureTeamItemList(List<ResultGameteamItem> playerList) {
    List<dynamic> updatedList = [];
    for (var team in playerList) {
      for (var item in team.playItems) {
        if (item.status.toString() == '1' ||
            item.itemImgUrl == null ||
            item.itemImgUrl == '') {
          continue;
        }
        updatedList.add({
          "team_id": team.teamId,
          "status": team.status,
          "teamname": team.teamname,
          "teamimg": team.teamimg,
          "player": team.player.toJson(),
          "issubmitted": team.issubmitted,
          "playItem": {
            "id": item.id,
            "itemImgUrl": item.itemImgUrl,
            "status": item.status,
            "type": item.type,
            "itemid": item.itemid,
            "name": item.name,
            "snapshot": item.snapshot,
            "updatedAt": item.updatedAt ?? '',
            "baseimage": item.baseimage ?? ''
          }
        });
      }
    }
    return updatedList;
  }

  Future<void> _getgameDetails() async {
    setState(() {
      _isLoading = true;
    });
    ApiService.gameDetails(widget.gameId).then((value) {
      try {
        if (value.success) {
          var homeResponse = Result.fromJson(value.response);
          isItemApprove = homeResponse.isItemApproved;
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   content: Text('Login failed: ${value.message}'),
          // ));
        }
      } catch (e) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('An error occurred: $e')),
        // );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _acceptItem(itemid) async {
    setState(() {
      _isLoading = true;
    });

    ApiService.acceptPlayerItem({"id": itemid}).then((value) {
      try {
        if (value.success) {
          // final jsonResponseData = UploadItemResponse.fromJson(jsonResponse);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Item Accepted!'),
          ));
          _teamItemList();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('hunt failed with status: ${value.message}'),
          ));
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _rejectItem(itemid) async {
    setState(() {
      _isLoading = true;
    });

    ApiService.rejectPlayerItem({"id": itemid}).then((value) {
      try {
        if (value.success) {
          // final jsonResponseData = UploadItemResponse.fromJson(jsonResponse);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Item Rejected!'),
          ));
          _teamItemList();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('hunt failed with status: ${value.message}'),
          ));
        }
      } catch (e) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('An error occurred: $e')),
        // );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _showImagePopup(
    BuildContext context,
    String imageUrl, // Updated image or video URL
    String baseImage, // Original image or video URL
    String teamName,
    String itemName,
    dynamic itemId,
    bool isVideo,
    bool isApproved, // Approval flag
  ) {
    bool showOriginal = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              teamName,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.close, color: Colors.black54),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 🏷️ Item name
                      Text(
                        itemName,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // 🔁 Toggle Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() => showOriginal = !showOriginal);
                            },
                            icon: Icon(
                              showOriginal ? Icons.hide_image : Icons.image,
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF153792),
                            ),
                            label: Text(
                              showOriginal ? "Hide " : "Show ",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      if (showOriginal) ...[
                        Text(
                          "Original ",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              baseImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],

                      // 🖼️ Uploaded Image (always visible)
                      Text(
                        "Uploaded ",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: isVideo
                            ? VideoWidget(
                                url: imageUrl,
                                play: true,
                                isborder: false,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image,
                                          size: 50, color: Colors.grey),
                                ),
                              ),
                      ),

                      const SizedBox(height: 20),

                      const SizedBox(height: 15),

                      // ✅❌ Action Buttons (only if not approved)
                      if (!isApproved)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _acceptItem(itemId); // your function
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              child:
                                  const Icon(Icons.check, color: Colors.white),
                            ),
                            const SizedBox(width: 15),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _rejectItem(itemId); // your function
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              child:
                                  const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Helper widget to display image or video
  Widget _buildImageWidget(String url, String title, {bool isVideo = false}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        if (isVideo)
          Center(
            child: SizedBox(
              height: 140,
              width: 140,
              child: VideoWidget(
                url: url,
                play: true,
                isborder: false,
              ),
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }

  Widget getStatusString(String status) {
    if (status == '0') {
      return const Text(
        'Pending',
        style: TextStyle(
            color: Colors.amber, fontSize: 16, fontWeight: FontWeight.w500),
      );
    } else if (status == '1') {
      return const Text(
        'Accepted',
        style: TextStyle(
            color: Colors.green, fontSize: 16, fontWeight: FontWeight.w500),
      );
    } else if (status == '2') {
      return const Text(
        'Rejected',
        style: TextStyle(
            color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
      );
    } else {
      return const Text(
        'Resubmitted',
        style: TextStyle(
            color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w500),
      );
    }
  }

  playVideo(BuildContext context, String url) {
    var vUrl = url;
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: SizedBox(
                  height: 400,
                  width: 500,
                  child: VideoWidget(url: vUrl, play: true)));
        });
  }

  bool _isVideoUrl(String? url) {
    if (url == null) return false;
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv');
  }

  String formatDateTime(String dateTime) {
    try {
      DateTime parsedDate = DateTime.parse(dateTime).toLocal();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);
    } catch (e) {
      return dateTime; // Return original string if parsing fails
    }
  }

  int getRowCount(int length, int crossAxisCount) {
    double result = length / crossAxisCount;
    return result.ceil(); // This will round up any decimal
  }

  int getApproveItemCount(itemList) {
    int count = 0;
    for (var item in itemList) {
      if (item.status == '1') {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final crossAxis = MediaQuery.of(context).size.width > 700 ? 4 : 4;
    int rowCount = getRowCount(restructuredPlayerList.length, crossAxis) > 12
        ? 12
        : getRowCount(restructuredPlayerList.length, crossAxis);
    rowCount = rowCount == 0 ? 1 : rowCount;
    return SingleChildScrollView(
        child: Column(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Items Submitted for approval  (${restructuredPlayerList.length})',
                  style: const TextStyle(
                      color: Color(0xFF0B00AB),
                      fontSize: 20,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600),
                ))),
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredList.length,
            itemBuilder: (context, teamIndex) {
              final team = filteredList[teamIndex];

              final entryItems = team.playItems
                  .where((i) =>
                      i.itemImgUrl != null &&
                      i.snapshot != null &&
                      i.status == '0')
                  .toList();

              final entry = filteredList[teamIndex];
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.teamname.toString() +
                        " (" +
                        entryItems.length.toString() +
                        ")",
                    style: const TextStyle(
                      color: Color(0xFF0B00AB),
                      fontSize: 16,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.only(bottom: 5),
                      margin: const EdgeInsets.all(0.0),
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 10),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: entryItems.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxis,
                              childAspectRatio:
                                  1.0, // adjust height vs width of card
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                            itemBuilder: (context, itemIndex) {
                              PlayItem playitem = entryItems[itemIndex];
                              final isVideo = _isVideoUrl(playitem.itemImgUrl);

                              // Card UI
                              return GestureDetector(
                                  onTap: () {
                                    log("this is the image of the base image >>>>>>>> ${playitem.baseimage}");
                                    if (playitem.itemImgUrl != null &&
                                        playitem.itemImgUrl!.isNotEmpty) {
                                      _showImagePopup(
                                          context,
                                          playitem.itemImgUrl!,
                                          playitem.baseimage ?? '',
                                          entry.teamname ?? "",
                                          playitem.name,
                                          playitem.id,
                                          false,
                                          false);
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      // old one
                                      // Card(
                                      //     elevation: 2,
                                      //     shape: RoundedRectangleBorder(
                                      //         borderRadius: BorderRadius.circular(10)),
                                      //     child: Container(
                                      //         decoration: BoxDecoration(
                                      //           borderRadius: BorderRadius.circular(10),
                                      //           image: DecorationImage(
                                      //             image: (playitem['snapshot'] != null &&
                                      //                     playitem['snapshot']!
                                      //                         .isNotEmpty)
                                      //                 ? NetworkImage(
                                      //                     playitem['snapshot']!)
                                      //                 : (playitem['itemImgUrl'] != null &&
                                      //                         playitem['itemImgUrl']!
                                      //                             .isNotEmpty
                                      //                     ? NetworkImage(
                                      //                         playitem['itemImgUrl']!)
                                      //                     : const AssetImage(
                                      //                             'assets/images/waiting-for-upload.png')
                                      //                         as ImageProvider),
                                      //             fit: BoxFit.cover,
                                      //           ),
                                      //         ),
                                      //         child: Center(
                                      //             child: GestureDetector(
                                      //                 onTap: () {
                                      //                   if (playitem['itemImgUrl'] !=
                                      //                           null &&
                                      //                       playitem['itemImgUrl']!
                                      //                           .isNotEmpty) {
                                      //                     _showImagePopup(
                                      //                         context,
                                      //                         playitem['itemImgUrl']!,
                                      //                         entry['teamname'],
                                      //                         playitem['name'],
                                      //                         playitem['id'],
                                      //                         isVideo,
                                      //                         false);
                                      //                   }
                                      //                 },
                                      //                 child: const Image(
                                      //                     image: AssetImage(
                                      //                         'assets/images/pending.png'),
                                      //                     width: 60,
                                      //                     height: 60))))),
                                      // // new one

                                      Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        clipBehavior: Clip
                                            .antiAlias, // This replaces nested Container decoration
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            // Background Image Layer
                                            _buildBackgroundImageFromPlayItem(
                                                playitem),

                                            // Overlay Layer with Icon
                                            Center(
                                              child:
                                                  _buildOverlayIconFromPlayItem(
                                                      context,
                                                      playitem,
                                                      entry,
                                                      isVideo),
                                            ),
                                          ],
                                        ),
                                      ),

                                      if (isVideo)
                                        const Positioned(
                                          top: 4,
                                          right: 0,
                                          child: Icon(
                                            Icons.play_circle,
                                            color: Colors.black,
                                          ),
                                        ),
                                    ],
                                  ));
                            },
                          ),
                        ),
                      )),
                ],
              );
            }),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Approve Items:',
                  style: TextStyle(
                      color: Color(0xFF0B00AB),
                      fontSize: 20,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600),
                ))),
        ...playerList.map((team) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${team.teamname} (${getApproveItemCount(team.playItems)}/${team.playItems.length})',
                  style: const TextStyle(
                    color: Color(0xFF0B00AB),
                    fontSize: 16,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // --- Left-aligned horizontal scroller ---
                Builder(
                  builder: (context) {
                    final visibleItems = team.playItems
                        .where((i) => i.status == '1' || i.status == '2')
                        .toList();

                    return SizedBox(
                      height: 90, // ensures the ListView has a fixed height
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets
                            .zero, // no extra padding (starts flush left)
                        itemCount: visibleItems.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final item = visibleItems[index];
                          final isVideo = _isVideoUrl(item.itemImgUrl);

                          final ImageProvider imageProvider = (item.snapshot !=
                                      null &&
                                  item.snapshot!.isNotEmpty)
                              ? NetworkImage(item.snapshot!)
                              : (item.itemImgUrl != null &&
                                      item.itemImgUrl!.isNotEmpty)
                                  ? NetworkImage(item.itemImgUrl!)
                                  : const AssetImage(
                                          'assets/images/waiting-for-upload.png')
                                      as ImageProvider;

                          return GestureDetector(
                            onTap: () {
                              if (item.itemImgUrl != null &&
                                  item.itemImgUrl!.isNotEmpty) {
                                _showImagePopup(
                                  context,
                                  item.itemImgUrl ?? '',
                                  item.baseimage ?? '',
                                  team.teamname ?? '',
                                  item.name,
                                  item.id,
                                  isVideo,
                                  true,
                                );
                              }
                            },
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                children: [
                                  // === Main Card ===
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: isVideo
                                          ? Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (item.itemImgUrl != null) {
                                                    _showImagePopup(
                                                      context,
                                                      item.itemImgUrl ?? '',
                                                      item.baseimage ?? '',
                                                      team.teamname ?? '',
                                                      item.name,
                                                      item.id,
                                                      true,
                                                      true,
                                                    );
                                                  }
                                                },
                                                child: const Icon(
                                                  Icons.play_circle_fill,
                                                  size: 48,
                                                  color: Color.fromRGBO(
                                                      21, 55, 146, 0.9),
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),

                                  // === Cross icon when status == '2' ===
                                  if (item.status == '2')
                                    const Positioned(
                                      top: 20,
                                      right: 13,
                                      child: const Icon(
                                        Icons.close,
                                        weight: 100,
                                        color: Color.fromARGB(255, 255, 3, 3),
                                        size: 50,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ],
    ));
  }

// Helper method to build background image from PlayItem
  Widget _buildBackgroundImageFromPlayItem(PlayItem playitem) {
    final imageUrl = _getImageUrlFromPlayItem(playitem);

    return Image(
      image: imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 40),
        );
      },
    );
  }

// Helper method to determine which image to use from PlayItem
  ImageProvider _getImageUrlFromPlayItem(PlayItem playitem) {
    // Priority: snapshot > itemImgUrl > default asset
    if (playitem.snapshot != null && playitem.snapshot!.isNotEmpty) {
      return NetworkImage(playitem.snapshot!);
    } else if (playitem.itemImgUrl != null && playitem.itemImgUrl!.isNotEmpty) {
      return NetworkImage(playitem.itemImgUrl!);
    } else {
      return const AssetImage('assets/images/waiting-for-upload.png');
    }
  }

// Helper method to build the overlay icon from PlayItem
  Widget _buildOverlayIconFromPlayItem(
    BuildContext context,
    PlayItem playitem,
    ResultGameteamItem entry,
    bool isVideo,
  ) {
    final hasImage =
        playitem.itemImgUrl != null && playitem.itemImgUrl!.isNotEmpty;

    return GestureDetector(
      onTap: hasImage
          ? () => _showImagePopup(
                context,
                playitem.itemImgUrl!,
                playitem.baseimage ?? '',
                entry.teamname ?? '',
                playitem.name,
                playitem.id,
                isVideo,
                false,
              )
          : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3), // Semi-transparent background
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Image(
          image: AssetImage('assets/images/pending.png'),
          width: 60,
          height: 60,
        ),
      ),
    );
  }

// Helper method to build background image (legacy - for Map)
  Widget _buildBackgroundImage(Map<String, dynamic> playitem) {
    final imageUrl = _getImageUrl(playitem);

    return Image(
      image: imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 40),
        );
      },
    );
  }

// Helper method to determine which image to use (legacy - for Map)
  ImageProvider _getImageUrl(Map<String, dynamic> playitem) {
    // Priority: snapshot > itemImgUrl > default asset
    if (playitem['snapshot'] != null && playitem['snapshot']!.isNotEmpty) {
      return NetworkImage(playitem['snapshot']!);
    } else if (playitem['itemImgUrl'] != null &&
        playitem['itemImgUrl']!.isNotEmpty) {
      return NetworkImage(playitem['itemImgUrl']!);
    } else {
      return const AssetImage('assets/images/waiting-for-upload.png');
    }
  }

// Helper method to build the overlay icon (legacy - for Map)
  Widget _buildOverlayIcon(
    BuildContext context,
    Map<String, dynamic> playitem,
    Map<String, dynamic> entry,
    bool isVideo,
  ) {
    final hasImage =
        playitem['itemImgUrl'] != null && playitem['itemImgUrl']!.isNotEmpty;

    return GestureDetector(
      onTap: hasImage
          ? () => _showImagePopup(
                context,
                playitem['itemImgUrl']!,
                playitem['baseimage']!,
                entry['teamname'],
                playitem['name'],
                playitem['id'],
                isVideo,
                false,
              )
          : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3), // Semi-transparent background
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Image(
          image: AssetImage('assets/images/pending.png'),
          width: 60,
          height: 60,
        ),
      ),
    );
  }
}
