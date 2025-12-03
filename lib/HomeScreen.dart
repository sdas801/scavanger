import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scavenger_app/CompletedDetailsPage.dart';
import 'package:scavenger_app/CreateHunt1stPage.dart';
import 'package:scavenger_app/HomeScreenResponse.dart';
import 'package:scavenger_app/HuntChallengesListPage.dart';
import 'package:scavenger_app/OTPScreen.dart';
import 'package:scavenger_app/ProfileScreen.dart';
import 'package:scavenger_app/ScanQRCodeScreen.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/model/challenge.model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scavenger_app/pages/challenge/challenge_list.page.dart';
import 'package:scavenger_app/pages/store/purchase.page.dart';
import 'package:scavenger_app/pages/subcriptions/freePlan.dart';
import 'package:scavenger_app/pages/subcriptions/subcriptionList.dart';
import 'package:scavenger_app/pages/subcriptions/subcription_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scavenger_app/HuntCreationCompleteScreen.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/pages/challenge/create_step_one.page.dart';
import 'package:scavenger_app/HuntDashboard.dart';
import 'package:scavenger_app/pages/challenge/player_dashboard.page.dart';
import 'package:scavenger_app/pages/store/index.page.dart';
import 'package:scavenger_app/services/notification.service.dart';
import 'package:scavenger_app/pages/challenge/challenge_home.page.dart';
import 'package:shimmer/shimmer.dart';

const double cardHeight = 110;
const Color questsColor = Color.fromRGBO(18, 220, 230, 0.4); // #12DCE6

class HomeScreen extends StatefulWidget {
  final int selectedTab;
  @override
  _HomeScreenState createState() => _HomeScreenState();
  final String userName;
  final int gameId = 0;
  final int gameuniqueId = 0;
  final String OTP = '';

  const HomeScreen(
      {super.key,
      required this.userName,
      dynamic gameId,
      dynamic OTP,
      dynamic gameuniqueId,
      this.selectedTab = 0});
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String title = "";
  bool subcriptionCheckShowHide = false;
  static bool _isSubscriptionDataLoaded = false;
  String premiumCheck = "";
  int maxHUnt = 0;
  int maxHQuest = 0;
  @override
  void initState() {
    super.initState();
    title = widget.userName;
    if (title == '') {
      getUserName();
    }
    isAndroidPermissionGranted();
    requestPermissions();
    _onItemTapped;
    _getSubcriptionData();
  }

  void _getSubcriptionData() async {
    log("get subscription data fetch ");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = (prefs.getInt('saved_userId') ?? 0);

    ApiService.getUserSubscriptions({"user_id": userid}).then((res) {
      try {
        if (res.success) {
          var subcriptionCheck =
              res.response != null ? PolicyResult.fromJson(res.response) : null;

          maxHUnt = subcriptionCheck?.maxHunts ?? 0;
          maxHQuest = subcriptionCheck?.maxChallenges ?? 0;

          if (subcriptionCheck != null) {
            String jsonString = jsonEncode(subcriptionCheck.toJson());
            prefs.setString('subscription_Check', jsonString);
            if (mounted) {
              setState(() {
                premiumCheck = subcriptionCheck.name;
              });
            }
          } else {
            prefs.setString('subscription_Check', 'null');
          }
          bool isSubscriptionDataLoaded =
              prefs.getBool('isSubscriptionDataLoaded') ?? false;
          if (isSubscriptionDataLoaded) return;
          if (!isSubscriptionDataLoaded) {
            showModalSec(subcriptionCheck, res.response);
            isSubscriptionDataLoaded = true;
            prefs.setBool('isSubscriptionDataLoaded', true);
          }
        }
      } catch (error) {
        // print(error);
      }
    });
  }

  void showModalSec(subcriptionCheck, response) {
    if (subcriptionCheck == null) {
      if (mounted)
        setState(() {
          subcriptionCheckShowHide = true;
        });
      showSubscriptionModal(context);
    } else if (subcriptionCheck.name == "Free") {
      freePlan(context, response);
    }
  }

  void _onItemTapped(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('saved_userName')) {
      if (mounted)
        setState(() {
          title = (prefs.getString('saved_userName') ?? "");
        });
    }
    if (mounted)
      setState(() {
        _selectedIndex = index;
        if (index == 0) {
          title = title;
        } else if (index == 1) {
          title = 'Library';
        } else if (index == 2) {
          title = 'Store';
        } else if (index == 3) {
          title = 'Profile';
        }
      });
  }

  getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('saved_userName')) {
      if (mounted)
        setState(() {
          title = (prefs.getString('saved_userName') ?? "");
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // Do something
        if (didPop) {
          return;
        }
        final shouldPop = await _showBackDialog() ?? false;
        if (context.mounted && shouldPop == true) {
          exit(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Jost',
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          automaticallyImplyLeading: false, // Remove the back button
          backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
          foregroundColor: Colors.white,
          actions: [
            // IconButton(
            //   icon: const Image(
            //     image: AssetImage('assets/images/notification.png'),
            //     height: 34,
            //     width: 34,
            //   ),
            //   onPressed: () {},
            // ),
            premiumCheck == "Free"
                ? const SizedBox()
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Subcription()));
                    },
                    child: const Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0), // Adjust the top margin
                            child: Icon(
                              Icons.workspace_premium_sharp,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Upgrade',
                            style: TextStyle(
                              fontFamily: 'Jost',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
        backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
        body: <Widget>[
          HomeScreenBody(
              selectedTab: widget.selectedTab,
              checkSub: subcriptionCheckShowHide,
              isActiveTab: _selectedIndex == 0,
              createdHunt: maxHUnt,
              createdQuest: maxHQuest),
          // const Text('Hunts'),
          // const Leaderboard(),
          const PurchaseItemPage(isBottom: true),
          const StorePage(),
          const ProfileScreen()
        ][_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 13,
          unselectedFontSize: 13,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(
                Icons.library_add,
              ),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Future<bool?> _showBackDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Do you want to leave?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Keep Going'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: Text(
                'Leave',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }
}

class HomeScreenBody extends StatefulWidget {
  final int selectedTab;
  bool checkSub;
  final bool isActiveTab;
  int createdHunt;
  int createdQuest;
  // Public RouteObserver for MaterialApp
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  @override
  _HomeScreenBodyState createState() => _HomeScreenBodyState();
  HomeScreenBody(
      {super.key,
      required this.selectedTab,
      required this.checkSub,
      required this.isActiveTab,
      required this.createdHunt,
      required this.createdQuest});
}

class _HomeScreenBodyState extends State<HomeScreenBody>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  TabController? _tabController; // Make it nullable
  int _initialIndex = 0;
  List<Result> upcomingitems = [];
  List<Result> activeHuntitems = [];
  List<Result> completedHuntitems = [];
  List<ChallengeModel> ActivechallengeList = [];
  List<ChallengeModel> completedchallengeList = [];
  int isHuntScroll = 0;
  int isChallengeScroll = 0;
  Timer? _refreshTimer; // Timer for periodic API calls
  bool _isAppInForeground = true; // Track app lifecycle state
  bool _isWidgetActive = true; // Track if widget is active and visible
  bool _isRouteCovered = false; // Track if route is covered by another route


  void _onTabControllerChange() {
    if (!mounted || _tabController == null) return; // Check mounted FIRST
    
    setState(() {
      _initialIndex = _tabController?.index ?? 0;
    });
    
    if (_tabController!.indexIsChanging) {
      PageStorage.of(context)?.writeState(context, _tabController!.index);
    }
    _handleTabChange();
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialIndex = widget.selectedTab;

    // Initialize TabController immediately
    _tabController = TabController(
      vsync: this,
      length: 2,
      initialIndex: widget.selectedTab,
    );

    _tabController!.addListener(_onTabControllerChange);

    // Call initial data load and start timer after controller is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshTabSpecificData();
        _startPeriodicRefresh();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    HomeScreenBody.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void deactivate() {
    log("⏸ HomeScreenBody deactivated - stopping API calls");
    _isWidgetActive = false;
    _stopPeriodicRefresh();
    super.deactivate();
  }

  @override
  void activate() {
    log("▶ HomeScreenBody activated - resuming API calls");
    _isWidgetActive = true;
    super.activate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _tabController != null) {
        // Ensure tab controller is synced with _initialIndex
        if (_tabController!.index != _initialIndex) {
          log("🔄 activate - syncing tab controller from ${_tabController!.index} to $_initialIndex");
          _tabController!.index = _initialIndex;
        }

        // Immediately refresh the correct tab's data
        int currentTab = _tabController!.index;
        log("🔄 activate - immediately refreshing tab $currentTab");
        _refreshTabSpecificData();

        // Start periodic timer after the first refresh
        if (_shouldRunTimer()) {
          _startPeriodicRefresh();
        }
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
        if (widget.isActiveTab) {
          _startPeriodicRefresh();
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

  void _handleTabChange() {
    int currentTab = _tabController?.index ?? 0;
    log("🔄 Tab changed to index: $currentTab");
    // Update _initialIndex to keep it in sync
    if (mounted) {
      setState(() {
        _initialIndex = currentTab;
      });
    }
    // Refresh data for the newly selected tab
    _refreshTabSpecificData();
    if (_shouldRunTimer()) {
      _startPeriodicRefresh();
    } else {
      _stopPeriodicRefresh();
    }
  }

  bool _shouldRunTimer() {
    return widget.isActiveTab &&
        _isAppInForeground &&
        _isWidgetActive &&
        !_isRouteCovered &&
        mounted &&
        (_tabController?.index == 0 || _tabController?.index == 1);
  }

  // RouteAware methods
  @override
  void didPush() {
    // Route was pushed onto navigator and is now topmost route
    log("📍 Route pushed - starting timer");
    _isRouteCovered = false;
    if (_shouldRunTimer()) {
      _startPeriodicRefresh();
    }
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator, this route is now topmost
    log("📍 Route uncovered (returned from another screen) - resuming timer");
    _isRouteCovered = false;
    if (mounted) {
      _refreshTabSpecificData();
      if (_shouldRunTimer()) {
        _startPeriodicRefresh();
      }
    }
  }

  @override
  void didPushNext() {
    // A new route was pushed onto navigator, covering this route
    log("📍 Route covered (navigated to another screen) - stopping timer");
    _isRouteCovered = true;
    _stopPeriodicRefresh();
  }

  @override
  void didPop() {
    // This route was popped off the navigator
    log("📍 Route popped - stopping timer");
    _isRouteCovered = true;
    _stopPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    _stopPeriodicRefresh();
    if (!_shouldRunTimer()) {
      log("⚠️ Not starting timer - conditions not met (isActiveTab: ${widget.isActiveTab}, isAppInForeground: $_isAppInForeground, isWidgetActive: $_isWidgetActive, mounted: $mounted)");
      return;
    }

    int currentTab = _tabController?.index ?? 0;
    String tabName = currentTab == 0 ? "Hunts" : "Quests";
    log("🕒 Starting periodic refresh timer for $tabName tab");

    // ✅ Timer only triggers *next* refreshes, not first one
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _shouldRunTimer()) {
        log("⏰ Periodic refresh triggered for ${_tabController?.index == 0 ? 'Hunts' : 'Quests'} tab");
        _refreshTabSpecificData();
      } else {
        log("🛑 Stopping timer - conditions no longer met");
        _stopPeriodicRefresh();
      }
    });
  }

  void _stopPeriodicRefresh() {
    if (_refreshTimer != null) {
      log(" Stopping periodic refresh timer");
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }

  bool _isRefreshing = false;

  Future<void> _refreshTabSpecificData() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      int currentTab = _tabController?.index ?? 0;
      log("📡 Refreshing data for tab $currentTab");

      if (currentTab == 0) {
        final upcoming = await _getUpcommingHunt();
        final active = await _getActivehunt();
        final completed = await _getCompletedHunt();
        final carousel = await _getCarouselScrollInfo();

        // ✅ Always update state if mounted, regardless of _isWidgetActive
        // This ensures UI reflects changes even when widget was briefly inactive
        if (mounted) {
          setState(() {
            if (upcoming != null) upcomingitems = upcoming;
            if (active != null) activeHuntitems = active;
            if (completed != null) completedHuntitems = completed;
            if (carousel != null) {
              isHuntScroll = carousel["isHunt"] ?? isHuntScroll;
              isChallengeScroll = carousel["isQuest"] ?? isChallengeScroll;
            }
          });
          log("✅ Hunts tab data updated - Upcoming: ${upcomingitems.length}, Active: ${activeHuntitems.length}, Completed: ${completedHuntitems.length}");
        }
      } else if (currentTab == 1) {
        final activeChallenge = await _getActivechallengeList();
        final completedChallenge = await _getCompletedchallengeList();
        final carousel = await _getCarouselScrollInfo();

        // ✅ Always update state if mounted, regardless of _isWidgetActive
        // This ensures UI reflects changes even when widget was briefly inactive
        if (mounted) {
          setState(() {
            if (activeChallenge != null) {
              ActivechallengeList = activeChallenge;
            }
            if (completedChallenge != null) {
              completedchallengeList = completedChallenge;
            }
            if (carousel != null) {
              isHuntScroll = carousel["isHunt"] ?? isHuntScroll;
              isChallengeScroll = carousel["isQuest"] ?? isChallengeScroll;
            }
          });
          log("✅ Quests tab data updated - Active: ${ActivechallengeList.length}, Completed: ${completedchallengeList.length}");
        }
      }
    } finally {
      _isRefreshing = false;
    }
  }

// ---- API Functions ----

  Future<List<Result>?> _getCompletedHunt() async {
    log(" [HUNTS TAB] API: _getCompletedHunt()");
    try {
      final res =
          await ApiService.getGameList({"status": "end", "gameType": "hunt"});
      if (res.success) {
        var list =
            List<Result>.from(res.response.map((x) => Result.fromJson(x)));
        log(" [HUNTS TAB] Completed hunts loaded: ${list.length}");
        return list;
      }
    } catch (e) {
      log(" [HUNTS TAB] _getCompletedHunt() Error: $e");
    }
    return null;
  }

  Future<List<Result>?> _getActivehunt() async {
    log(" [HUNTS TAB] API: _getActivehunt()");
    try {
      final res = await ApiService.getGameList(
          {"status": "active", "gameType": "hunt"});
      if (res.success) {
        var list =
            List<Result>.from(res.response.map((x) => Result.fromJson(x)));
        log(" [HUNTS TAB] Active hunts loaded: ${list.length}");
        return list;
      }
    } catch (e) {
      log(" [HUNTS TAB] _getActivehunt() Error: $e");
    }
    return null;
  }

  Future<List<Result>?> _getUpcommingHunt() async {
    log(" [HUNTS TAB] API: _getUpcommingHunt()");
    try {
      final res = await ApiService.getGameList(
          {"status": "upcomming", "gameType": "hunt"});
      if (res.success) {
        var list =
            List<Result>.from(res.response.map((x) => Result.fromJson(x)));
        log(" [HUNTS TAB] Upcoming hunts loaded: ${list.length}");
        return list;
      }
    } catch (e) {
      log(" [HUNTS TAB] _getUpcommingHunt() Error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getCarouselScrollInfo() async {
    int currentTab = _tabController?.index ?? 0;
    String tabName = currentTab == 0 ? "HUNTS TAB" : "QUESTS TAB";
    log(" [$tabName] API: _getCarouselScrollInfo()");
    try {
      final res = await ApiService.getCarouselScrollInfo();
      if (res.success && res.response.isNotEmpty) {
        log(" [$tabName] Carousel info loaded");
        return {
          "isHunt": res.response[0]['isHunt'],
          "isQuest": res.response[0]['isQuest'],
        };
      }
    } catch (e) {
      log(" [$tabName] _getCarouselScrollInfo() Error: $e");
    }
    return null;
  }

  Future<List<ChallengeModel>?> _getActivechallengeList() async {
    log(" [QUESTS TAB] API: _getActivechallengeList()");
    try {
      final res = await ApiService.getChallengeList(
          {"status": 0, "limit": 10, "offset": 0});
      if (res.success) {
        var list = List<ChallengeModel>.from(
            res.response.map((x) => ChallengeModel.fromJson(x)));
        list.sort((a, b) => a.id.compareTo(b.id));
        log(" [QUESTS TAB] Active challenges loaded: ${list.length}");
        return list;
      }
    } catch (e) {
      log(" [QUESTS TAB] _getActivechallengeList() Error: $e");
    }
    return null;
  }

  Future<List<ChallengeModel>?> _getCompletedchallengeList() async {
    log(" [QUESTS TAB] API: _getCompletedchallengeList()");
    try {
      final res = await ApiService.getChallengeList(
          {"status": 1, "limit": 10, "offset": 0});
      if (res.success) {
        var list = List<ChallengeModel>.from(
            res.response.map((x) => ChallengeModel.fromJson(x)));
        list.sort((a, b) => a.id.compareTo(b.id));
        log(" [QUESTS TAB] Completed challenges loaded: ${list.length}");
        return list;
      }
    } catch (e) {
      log(" [QUESTS TAB] _getCompletedchallengeList() Error: $e");
    }
    return null;
  }

  @override
  void didUpdateWidget(HomeScreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle selectedTab changes
    if (oldWidget.selectedTab != widget.selectedTab) {
      log("🔄 selectedTab changed from ${oldWidget.selectedTab} to ${widget.selectedTab}");
      _initialIndex = widget.selectedTab;
      if (_tabController != null &&
          _tabController!.index != widget.selectedTab) {
        _tabController!.index = widget.selectedTab;
      }
    }

    // Handle isActiveTab changes
    if (oldWidget.isActiveTab != widget.isActiveTab) {
      log("🔄 Parent tab changed - isActiveTab: ${widget.isActiveTab}");
      if (widget.isActiveTab && _shouldRunTimer()) {
        log("🔄 Tab active - refreshing data and restarting timer");
        _refreshTabSpecificData();
        _startPeriodicRefresh();
      } else {
        log("⏸️ Tab inactive - stopping timer");
        _stopPeriodicRefresh();
      }
    }
  }

  @override
  void dispose() {
    log(" Disposing HomeScreenBody - stopping periodic refresh");
    HomeScreenBody.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _stopPeriodicRefresh();

    _tabController?.removeListener(_onTabControllerChange);
    _tabController?.dispose();
    
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    var screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Center(
        child: Container(
          width: screenSize.width, // 80% of the screen width
          height: screenSize.height,
          decoration: ShapeDecoration(
            color: _initialIndex == 0 ? const Color(0xFFF2F2F2) : questsColor,
            shape: const RoundedRectangleBorder(
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(45),
                //   topRight: Radius.circular(45),
                // ),
                ),
          ),
          child: Column(
            children: [
              // give the tab bar a height [can change hheight to preferred height]
              Container(
                height: 45,
                margin: const EdgeInsets.only(top: 10),
                width: screenSize.width - 60,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  // give the indicator a decoration (color and border radius)
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ),
                    color: const Color.fromRGBO(11, 0, 171, 1),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: [
                    // first tab [you can add an icon using the icon property]
                    Tab(
                      child: SizedBox(
                        width: (screenSize.width - 60) / 2 - 30,
                        child: const Center(
                          child: Text(
                            'Hunts',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // second tab [you can add an icon using the icon property]
                    Tab(
                      child: SizedBox(
                        width: (screenSize.width - 60) / 2 - 30,
                        child: const Center(
                          child: Text(
                            'Quests',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // tab bar view here
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // first tab bar view widget
                    HuntListPage(
                        upcomingitems: upcomingitems,
                        activeHuntitems: activeHuntitems,
                        completedHuntitems: completedHuntitems,
                        isHuntScroll: isHuntScroll,
                        maxhunt: widget.createdHunt),

                    // second tab bar view widget
                    ChallengeListPage(
                        ActivechallengeList: ActivechallengeList,
                        completedchallengeList: completedchallengeList,
                        isChallengeScroll: isChallengeScroll,
                        maxQuest: widget.createdQuest)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HuntListPage extends StatelessWidget {
  final List<Result> upcomingitems;
  final List<Result> activeHuntitems;
  final List<Result> completedHuntitems;
  final int isHuntScroll;
  int maxhunt;
  HuntListPage({
    super.key,
    required this.upcomingitems,
    required this.activeHuntitems,
    required this.completedHuntitems,
    required this.isHuntScroll,
    required this.maxhunt,
  });

  @override
  Widget build(BuildContext context) {
    print('activeHuntitems ${activeHuntitems.length}');
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: upcomingitems.isNotEmpty ||
                activeHuntitems.isNotEmpty ||
                completedHuntitems.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BannerWidget(
                      imageName: 'bannerImg1.jpeg',
                      type: 0,
                      autoScroll: isHuntScroll),
                  const SizedBox(height: 16),
                  ActionButtons(type: 'Hunt', max: maxhunt),
                  // SizedBox(height: 16),
                  // SectionTitle(title: 'Top packages'),
                  // IconWidget(),
                  const SizedBox(height: 16),
                  activeHuntitems.isNotEmpty
                      ? const SectionTitle(
                          title: 'Active Hunts',
                          type: 'hunt',
                          checkType: "active")
                      : const SizedBox(),
                  activeHuntitems.isNotEmpty
                      ? const HuntsListJoined(type: 'hunt')
                      : const SizedBox(),
                  const SizedBox(height: 16),
                  upcomingitems.isNotEmpty
                      ? const SectionTitle(
                          title: 'Upcoming Hunts',
                          type: 'hunt',
                          checkType: "upcoming")
                      : const SizedBox(),
                  upcomingitems.isNotEmpty
                      ? const HuntsList(type: 'hunt')
                      : const SizedBox(),
                  const SizedBox(height: 16),

                  completedHuntitems.isNotEmpty
                      ? const SectionTitle(
                          title: 'Completed Hunts',
                          type: 'hunt',
                          checkType: "completed")
                      : const SizedBox(),
                  completedHuntitems.isNotEmpty
                      ? const MyHuntsList(type: 'hunt')
                      : const SizedBox(),
                  const SizedBox(height: 16),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BannerWidget(
                      imageName: 'bannerImg1.jpeg',
                      type: 0,
                      autoScroll: isHuntScroll),
                  const SizedBox(height: 16),
                  ActionButtons(type: 'Hunt', max: maxhunt),
                  // SizedBox(height: 16),
                  // SectionTitle(title: 'Top packages'),
                  // IconWidget(),
                  const SizedBox(height: 16),
                  const Center(
                      child: Column(
                    children: [
                      SizedBox(
                        height: 30, // Corrected syntax
                      ),
                      Image(
                        image: AssetImage('assets/images/empty.png'),
                      ),
                      Text(
                        "You Have not create or jonied in any hunt yet!",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color.fromRGBO(11, 0, 171, 1)),
                      )
                    ],
                  ))
                ],
              ),
      ),
    );
  }
}

class ChallengeListPage extends StatelessWidget {
  final List<ChallengeModel> ActivechallengeList;
  final List<ChallengeModel> completedchallengeList;
  final int isChallengeScroll;
  int maxQuest;
  ChallengeListPage({
    super.key,
    required this.ActivechallengeList,
    required this.completedchallengeList,
    required this.isChallengeScroll,
    required this.maxQuest,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            ActivechallengeList.isNotEmpty || completedchallengeList.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BannerWidget(
                          imageName: 'challenge-word-colored.webp',
                          type: 1,
                          autoScroll: isChallengeScroll),

                      const SizedBox(height: 16),
                      ActionButtons(type: 'Challenge', max: maxQuest),
                      // SizedBox(height: 16),
                      // SectionTitle(title: 'Top packages'),
                      // IconWidget(),
                      const SizedBox(height: 16),
                      ActivechallengeList.isNotEmpty
                          ? const SectionTitle(
                              title: 'Active Quests',
                              type: 'challenge',
                              checkType: "0")
                          : const SizedBox(),
                      ActivechallengeList.isNotEmpty
                          ? const ChalengeList(type: 0)
                          : const SizedBox(),
                      const SizedBox(height: 16),
                      completedchallengeList.isNotEmpty
                          ? const SectionTitle(
                              title: 'Completed Quests',
                              type: 'challenge',
                              checkType: "1")
                          : const SizedBox(),
                      completedchallengeList.isNotEmpty
                          ? const ChalengeList(type: 1)
                          : SizedBox(),
                      const SizedBox(height: 16),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BannerWidget(
                          imageName: 'challenge-word-colored.webp',
                          type: 1,
                          autoScroll: isChallengeScroll),
                      /* SectionTitle(title: 'Upcoming Challenges'),
            HuntsList(type: 'challenge'),
            SizedBox(height: 16), */
                      const SizedBox(height: 16),
                      ActionButtons(type: 'Challenge', max: maxQuest),
                      // SizedBox(height: 16),
                      // SectionTitle(title: 'Top packages'),
                      // IconWidget(),
                      const SizedBox(height: 16),
                      const Center(
                          child: Column(
                        children: [
                          SizedBox(
                            height: 30, // Corrected syntax
                          ),
                          Image(
                            image: AssetImage('assets/images/empty.png'),
                          ),
                          Text(
                            "You have not create or jonied in any Quests yet!",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: const Color.fromRGBO(11, 0, 171, 1)),
                          )
                        ],
                      ))
                    ],
                  ),
      ),
    );
  }
}

class BannerWidget extends StatefulWidget {
  final String imageName;
  final int type;
  final int autoScroll;
  @override
  _BannerBodyState createState() => _BannerBodyState();
  const BannerWidget(
      {super.key,
      required this.imageName,
      required this.type,
      required this.autoScroll});
}

class _BannerBodyState extends State<BannerWidget>
    with SingleTickerProviderStateMixin {
  int _initialIndex = 0;
  List<CarouselModel> CarouselList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getBannerList();
  }

  Future<void> _getBannerList() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    ApiService.getCarouselData({"type": widget.type}).then((res) {
      try {
        if (res.success) {
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
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  void _launchURL(String redirectUrl) async {
    if (redirectUrl == '') {
      return;
    }
    final url = Uri.parse(redirectUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          width: double.infinity,
          child: AnotherCarousel(
            autoplay: widget.autoScroll == 0 ? false : true,
            images: CarouselList.map((d) => NetworkImage(d.imgUrl)).toList(),
            dotSize: 6,
            indicatorBgPadding: 5.0,
            onImageTap: (p0) {
              _launchURL(CarouselList[p0].link_url ?? '');
            },
          ),
        )
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String type;
  final String checkType;

  const SectionTitle(
      {super.key,
      required this.title,
      required this.type,
      required this.checkType});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Raleway',
              color: Color.fromRGBO(21, 55, 146, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          height: 20,
          width: 100,
          right: 0,
          child: ElevatedButton(
            onPressed: () {
              if (type == "hunt") {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HuntChallengesListPage(
                            type: type, checkType: checkType)));
              } else {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChallengesListPage(
                            type: type, checkType: checkType)));
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.only(left: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: type == "hunt"
                      ? const Color.fromRGBO(242, 242, 242, 1)
                      : const Color.fromARGB(0, 18, 219, 230),
                ),
              ),
              backgroundColor: type == "hunt"
                  ? const Color.fromRGBO(242, 242, 242, 1)
                  : const Color.fromARGB(0, 18, 219, 230),
              foregroundColor: const Color.fromRGBO(11, 0, 171, 1),
              elevation: 0,
            ),
            child: const Text('See more'),
          ),
        ),
      ],
    );
  }
}

class HuntsList extends StatefulWidget {
  final String type;
  const HuntsList({super.key, required this.type});

  @override
  State<HuntsList> createState() => _HuntsListState();
}

class _HuntsListState extends State<HuntsList> {
  bool _isLoading = false;
  List<Result> upcomingitems = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'hunt') {
      _getUpcommingData(1);
    } else {
      _getHomeData(1);
    }
    _timer = Timer.periodic(const Duration(seconds: 55), (_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    if (widget.type == 'hunt') {
      _getUpcommingData(0);
    } else {
      _getHomeData(0);
    }
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  Future<void> _getHomeData(int flag) async {
    if (flag == 1) {
      if (mounted)
        setState(() {
          _isLoading = true;
        });
    }
    ApiService.upcommingGames(widget.type).then((res) {
      try {
        if (res.success) {
          var huntList =
              List<Result>.from(res.response.map((x) => Result.fromJson(x)));
          if (mounted) {
            setState(() {
              upcomingitems = huntList;
            });
          }
        }
      } catch (error) {
        // print(error);
      }
    });
    if (flag == 1) {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  Future<void> _getUpcommingData(int flag) async {
    if (flag == 1 && mounted) {
      if (mounted)
        setState(() {
          _isLoading = true;
        });
    }
    ApiService.getGameList({"status": "upcomming", "gameType": widget.type})
        .then((res) {
      try {
        if (res.success) {
          var huntList =
              List<Result>.from(res.response.map((x) => Result.fromJson(x)));
          String jsonString = jsonEncode(huntList);
          if (mounted) {
            setState(() {
              upcomingitems = huntList;
            });
          }
        }
      } catch (error) {
        // print(error);
      } finally {
        if (flag == 1 && mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  void deleteGame(int id, int isHost) async {
    if (isHost == 0) {
      try {
        final res = await ApiService.deletegameJoiner({"gameId": id});
        if (res.success) {
          if (mounted) {
            setState(() {
              upcomingitems.removeWhere((element) => element.id == id);
            });
          }
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
          if (mounted) {
            setState(() {
              upcomingitems.removeWhere((element) => element.id == id);
            });
          }
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: upcomingitems.isEmpty && !_isLoading
          ? Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: const Image(image: AssetImage('assets/images/empty.png')),
            )
          : ListView.builder(
              key: ValueKey(upcomingitems),
              scrollDirection: Axis.horizontal,
              itemCount:
                  _isLoading ? upcomingitems.length + 6 : upcomingitems.length,
              itemBuilder: (context, index) {
                if (index < upcomingitems.length) {
                  final item = upcomingitems[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HuntCard(
                      key: ValueKey(item.id),
                      imageUrl:
                          "assets/images/scavenger_hunt.png", //items[index].items.first.imgUrl,NetworkImage('https://example.com/path/to/profile_picture.jpg'),
                      title: upcomingitems[index].title,
                      subtitle: upcomingitems[index].description,
                      gameId: upcomingitems[index].id,
                      gameuniqueId: upcomingitems[index].gameId,
                      otp: upcomingitems[index].otp,
                      inTime: upcomingitems[index].inTime,
                      outTime: upcomingitems[index].outTime,
                      isTimed: upcomingitems[index].isTimed,
                      isPrized: upcomingitems[index].isPrized,
                      isItemApproved: upcomingitems[index].isItemApproved,
                      isAllowToMsgOthers:
                          upcomingitems[index].isAllowToMsgOthers,
                      itemCount: upcomingitems[index].items?.length,
                      prizeCount: upcomingitems[index].prizes?.length,
                      gameRules: upcomingitems[index].gameRules,
                      gameType: upcomingitems[index].gameType,
                      gameImg: upcomingitems[index].gameImg,
                      teamId: upcomingitems[index].teamId,

                      isHost: upcomingitems[index].isHost ?? 1,
                      cardType:
                          upcomingitems[index].isHost == 0 ? 'joined' : 'host',
                      gamePlayId: upcomingitems[index].gamePlayId,
                      gamePlayStatus: upcomingitems[index].gamePlayStatus,
                      isprocessed: upcomingitems[index].isprocessed,
                      totalItems: upcomingitems[index].totalItems,
                      uploadedItems: upcomingitems[index].uploadedItems,
                      ondelete: (val) {
                        deleteGame(val['id'], upcomingitems[index].isHost ?? 1);
                      },
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
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
  final DeleteCallback ondelete;
  final bool? isActionMenu;
  final int isHost;
  final int? gamePlayId;
  final String? gamePlayStatus;
  final int? isprocessed;
  final int? totalItems;
  final int? uploadedItems;

  const HuntCard({
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
    required this.ondelete,
    this.isActionMenu = true,
    this.isHost = 1,
    this.gamePlayId = 0,
    this.gamePlayStatus = '',
    this.isprocessed = 0,
    this.totalItems = 0,
    this.uploadedItems = 0,
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
  String gameuniqueId = '';
  String? otp;
  String? status;
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
  int? isprocessed = 0;

  @override
  void initState() {
    super.initState();
    imageUrl = widget.imageUrl;
    title = widget.title;
    subtitle = widget.subtitle;
    gameId = widget.gameId;
    gameuniqueId = widget.gameuniqueId;
    otp = widget.otp;
    status = widget.status;
    inTime = widget.inTime;
    outTime = widget.outTime;
    isTimed = widget.isTimed;
    isPrized = widget.isPrized;
    isItemApproved = widget.isItemApproved;
    isAllowToMsgOthers = widget.isAllowToMsgOthers;
    itemCount = widget.itemCount;
    prizeCount = widget.prizeCount;
    gameRules = widget.gameRules;
    gameType = widget.gameType;
    cardType = widget.cardType;
    teamId = widget.teamId;
    gameImg = widget.gameImg;
    isHost = widget.isHost;
    gamePlayId = widget.gamePlayId;
    gamePlayStatus = widget.gamePlayStatus;
    isprocessed = widget.isprocessed;
    _loadData();
  }

  Future<void> _loadData() async {
    if (inTime != null && inTime != "") {
      var gameStartDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(inTime ?? '');
      fetchTime = DateFormat("MMM d, y 'at' h:mm a").format(gameStartDate);
    }

    if (outTime != null && outTime != "") {
      var gameEndDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(outTime ?? '');
      fetchOutTime = DateFormat("MMM d, y 'at' h:mm a").format(gameEndDate);
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
    return GestureDetector(
        onTap: () {
          if (status == '2') {
            Navigator.pushReplacement(
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
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HuntCreationCompleteScreen(
                          gameId: gameId,
                          gameuniqueId: gameuniqueId,
                          gameType: gameType ?? 'hunt',
                          cardType: 'host',
                          myteam: teamId ?? '')));
            } else if (cardType == 'joined') {
              if (status == '1' || status == '0') {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => HuntDashboard(
                //             myteam: teamId ?? '',
                //             gameId: gameId,
                //             gameType: gameType ?? 'hunt')));
                Navigator.pushReplacement(
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
              Navigator.pushReplacement(
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
                // isHost == 1
                //     ?
                // Positioned(
                //     height: 30,
                //     width: 30,
                //     // top: 3,
                //     right: 0,
                //     child: ElevatedButton(
                //       onPressed: () {
                //         showActionButtons(context, status);
                //       },
                //       style: ElevatedButton.styleFrom(
                //         padding: const EdgeInsets.all(3),
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
                //   )
                // : const SizedBox(),
                Positioned(
                  top: 40,
                  left: -40,
                  // right: 28,
                  child: Transform.rotate(
                      angle: 4.7124,
                      child: Container(
                        width: cardHeight - 15,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isHost == 0
                              ? const Color.fromARGB(255, 3, 139, 121)
                              : const Color.fromARGB(255, 223, 90, 28),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12), // Top-right corner
                            topRight:
                                Radius.circular(12), // Bottom-right corner
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
                ),
              if (isprocessed == 1)
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
                    right: isprocessed == 1 ? 40 : 10,
                    // right: 28,
                    child: Text(
                      '${widget.uploadedItems}/${widget.totalItems}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    )),
              if (status == '1')
                const Positioned(
                    bottom: 0,
                    right: 0,
                    child: Image(
                        width: 30,
                        height: 30,
                        image: AssetImage('assets/images/live.png'))),
            ],
          ),
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
                    if (status == "1" || status == "2" || isHost == 0) {
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
                  if (status == "1" || isHost == 0) {
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

class ActionButtons extends StatefulWidget {
  final String type;
  int? max;
  ActionButtons({super.key, required this.type, this.max});

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool isCheckSubcription = false;
  @override
  void initState() {
    super.initState();

    getNumberOfCretedHunt();
  }

  int numberOfCreatedHunt = 0;
  int numberOfCreatedQuest = 0;
  void _onUniqueCode() async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => OTPScreen(
                  OTP: '',
                  type: widget.type,
                )));
  }

  void _onScanPage() async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ScanQRCodeScreen(
                  type: widget.type,
                )));
  }
  //implement

  Future<void> getNumberOfCretedHunt() async {
    ApiService.getNumberOfCretedHunt().then((res) {
      try {
        if (res.success) {
          if (mounted) {
            // setState(() {
            numberOfCreatedHunt = res.response['huntCount'];
            numberOfCreatedQuest = res.response['challengeCount'];
            // });
          }
        }
      } catch (error) {
        log("Number of hunt >>>>>>>>>>>>> error");
      }
    });
  }

  void showSubscriptionDialog(BuildContext context, int type) {
    log("this is the test message dialog ");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actionsPadding: const EdgeInsets.only(bottom: 15, right: 15, top: 5),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFF153792)),
              SizedBox(width: 8),
              Text(
                "Subscription Required",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF153792),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            "The ${type == 1 ? 'hunt' : 'Quest'} creation limit has been exceeded.\n\n"
            "To extend your limit, please upgrade the subscription.",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Subcription()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF153792),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                "Upgrade",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
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
    return Container(
      height: 50,
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // const SizedBox(width: 5),
          // widget.type == "Hunt"
          // ?
          ElevatedButton(
            onPressed: () {
              // log("this is the create hunt click ");
              // Handle register action
              showModalBottomSheet<void>(
                context: context,
                // set backgroundColor to transparent
                backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 340,
                    child: Center(
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 40),
                          Text(
                            "Join a ${widget.type.toLowerCase() == 'challenge' ? 'Quest' : 'Hunt'}",
                            style: const TextStyle(
                              color: Color(0xFF153792),
                              fontSize: 24,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                          Text(
                            'Select how to join the ${widget.type.toLowerCase() == 'challenge' ? 'Quest' : 'Hunt'}',
                            style: const TextStyle(
                              color: Color(0xFF4F4444),
                              fontSize: 15,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Image.asset('assets/images/otpim.png'),
                                onPressed: () {
                                  _onUniqueCode();
                                },
                              ),
                              const SizedBox(width: 40),
                              IconButton(
                                icon: Image.asset('assets/images/QRimg.png'),
                                onPressed: () {
                                  _onScanPage();
                                },
                              ),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                'Enter Unique Code',
                                style: TextStyle(
                                  color: Color(0xFF002D3F),
                                  fontSize: 15,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                              SizedBox(width: 60),
                              Text(
                                textAlign: TextAlign.center,
                                'Scan QR Code',
                                style: TextStyle(
                                  color: Color(0xFF002D3F),
                                  fontSize: 15,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              // backgroundColor: const Color(0xFF0B00AB),
              foregroundColor: const Color(0xFF0B00AB),
              minimumSize:
                  Size((MediaQuery.of(context).size.width - 50) / 2, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF0B00AB))),
            ),
            child: Text(
                'Join a ${widget.type.toLowerCase() == 'challenge' ? 'Quest' : 'Hunt'}'),
          ),
          // : const SizedBox(),
          // const SizedBox(width: 5),
          ElevatedButton(
            onPressed: () {
              // Handle register action
              if (widget.type == 'Challenge') {
                if ((widget.max ?? 0) <= numberOfCreatedQuest) {
                  log("this is the test message ${widget.max ?? 0} ------${numberOfCreatedQuest} ");
                  showSubscriptionDialog(context, 0);
                } else {
                  log("this is the test message ${widget.max ?? 0} ------${numberOfCreatedQuest} ");

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const CreateChallenge1stPage()));
                }
              } else {
                // implement
                if ((widget.max ?? 0) <= numberOfCreatedHunt) {
                  log("this is the test message ${widget.max ?? 0} ------${numberOfCreatedHunt} ");
                  showSubscriptionDialog(context, 1);
                } else {
                  log("this is the test message ${widget.max ?? 0} ------${numberOfCreatedHunt} ");

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateHunt1stPage()));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              // backgroundColor: const Color(0xFF0B00AB),
              foregroundColor: const Color(0xFF0B00AB),
              minimumSize:
                  //  widget.type == "Hunt"
                  //     ?
                  Size((MediaQuery.of(context).size.width - 50) / 2, 40),
              // : Size((MediaQuery.of(context).size.width - 50), 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF0B00AB))),
            ),
            child: Text(
                'Create a ${widget.type.toLowerCase() == 'challenge' ? 'Quest' : 'Hunt'}'),
          ),
        ],
      ),
    );
  }
}
//joined- hunts

class HuntsListJoined extends StatefulWidget {
  final String type;
  const HuntsListJoined({super.key, required this.type});

  @override
  State<HuntsListJoined> createState() => _HuntsListJoinedState();
}

class _HuntsListJoinedState extends State<HuntsListJoined> {
  bool _isLoading = false;
  List<Result> upcomingitems = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // if (widget.type == 'hunt') {
    //   _getActiveData();
    // } else {
    //   _getjoinedData();
    // }
    _getActiveData(1);
    _timer = Timer.periodic(const Duration(seconds: 50), (_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    _getActiveData(0);
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  Future<void> _getActiveData(int flag) async {
    if (flag == 1 && mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    ApiService.getGameList({"status": "active", "gameType": widget.type})
        .then((res) {
      try {
        if (res.success) {
          var huntList =
              List<Result>.from(res.response.map((x) => Result.fromJson(x)));
          // Navigate to the next screen or perform other actions
          if (mounted) {
            setState(() {
              upcomingitems = huntList;
            });
          }
        }
      } catch (error) {
        // print(error);
      } finally {
        if (flag == 1 && mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: upcomingitems.isEmpty && !_isLoading
          ? Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: const Image(image: AssetImage('assets/images/empty.png')),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  _isLoading ? upcomingitems.length + 6 : upcomingitems.length,
              itemBuilder: (context, index) {
                if (index < upcomingitems.length) {
                  final item = upcomingitems[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HuntCard(
                      imageUrl:
                          "assets/images/scavenger_hunt.png", //items[index].items.first.imgUrl,NetworkImage('https://example.com/path/to/profile_picture.jpg'),
                      title: upcomingitems[index].title,
                      subtitle: upcomingitems[index].description,
                      gameId: upcomingitems[index].id,
                      gameuniqueId: upcomingitems[index].gameId,
                      otp: '',
                      inTime: upcomingitems[index].inTime,
                      outTime: upcomingitems[index].outTime,
                      status: upcomingitems[index].status,
                      gameType: upcomingitems[index].gameType,
                      teamId: upcomingitems[index].teamId,
                      cardType:
                          upcomingitems[index].isHost == 0 ? 'joined' : 'host',
                      gameImg: upcomingitems[index].gameImg,
                      ondelete: (val) => {},
                      isActionMenu: true,
                      isHost: upcomingitems[index].isHost ?? 1,
                      gamePlayId: upcomingitems[index].gamePlayId,
                      gamePlayStatus: upcomingitems[index].gamePlayStatus,
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
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

// my hunts----

class MyHuntsList extends StatefulWidget {
  final String type;
  const MyHuntsList({super.key, required this.type});

  @override
  State<MyHuntsList> createState() => _MyHuntsListState();
}

class _MyHuntsListState extends State<MyHuntsList> {
  bool _isLoading = false;
  List<Result> upcomingitems = [];
  Timer? _timer;

  void initState() {
    super.initState();
    _getCompletedData(1);
    _timer = Timer.periodic(const Duration(seconds: 50), (_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    _getCompletedData(0);
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  Future<void> _getCompletedData(int flag) async {
    if (flag == 1) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    }
    ApiService.getGameList({"status": "end", "gameType": widget.type})
        .then((res) {
      try {
        if (res.success) {
          var huntList =
              List<Result>.from(res.response.map((x) => Result.fromJson(x)));
          // Navigate to the next screen or perform other actions
          if (mounted) {
            setState(() {
              upcomingitems = huntList;
              print(upcomingitems);
            });
          }
        }
      } catch (error) {
        // print(error);
      } finally {
        if (flag == 1 && mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  void deleteGame(int id, int isHost) async {
    if (isHost == 0) {
      try {
        final res = await ApiService.deletegameJoiner({"gameId": id});
        if (res.success) {
          if (mounted) {
            setState(() {
              upcomingitems.removeWhere((element) => element.id == id);
            });
          }
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
          if (mounted) {
            setState(() {
              upcomingitems.removeWhere((element) => element.id == id);
            });
          }
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: upcomingitems.isEmpty && !_isLoading
          ? Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: const Image(image: AssetImage('assets/images/empty.png')),
            )
          : ListView.builder(
              key: ValueKey(upcomingitems),
              scrollDirection: Axis.horizontal,
              itemCount:
                  _isLoading ? upcomingitems.length + 6 : upcomingitems.length,
              itemBuilder: (context, index) {
                if (index < upcomingitems.length) {
                  final item = upcomingitems[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HuntCard(
                      key: ValueKey(item.id),
                      imageUrl:
                          "assets/images/scavenger_hunt.png", //items[index].items.first.imgUrl,NetworkImage('https://example.com/path/to/profile_picture.jpg'),
                      title: upcomingitems[index].title,
                      subtitle: upcomingitems[index].description,
                      gameId: upcomingitems[index].id,
                      gameuniqueId: upcomingitems[index].gameId,
                      otp: upcomingitems[index].otp,
                      inTime: upcomingitems[index].inTime,
                      outTime: upcomingitems[index].outTime,
                      gameType: upcomingitems[index].gameType,
                      cardType:
                          upcomingitems[index].isHost == 0 ? 'joined' : 'host',
                      status: upcomingitems[index].status,
                      teamId: upcomingitems[index].teamId,
                      gameImg: upcomingitems[index].gameImg,
                      isHost: upcomingitems[index].isHost ?? 1,
                      gamePlayId: upcomingitems[index].gamePlayId,
                      gamePlayStatus: upcomingitems[index].gamePlayStatus,
                      isprocessed: upcomingitems[index].isprocessed == 1 &&
                              upcomingitems[index].isHost != 1
                          ? 1
                          : 0,
                      ondelete: (val) => {
                        deleteGame(val['id'], upcomingitems[index].isHost ?? 1)
                      },
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
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

class IconWidget extends StatelessWidget {
  // final String imageName;
  const IconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.pink,
                        backgroundImage: NetworkImage(
                            'https://thumbs.dreamstime.com/b/special-discount-blue-special-discount-blue-background-347384621.jpg'),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              255, 223, 90, 28), // Comma added here
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Packages',
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                );
              },
            )),
      ],
    );
  }
}
