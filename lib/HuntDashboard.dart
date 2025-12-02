import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/LeaderBoardPage.dart';
import 'package:scavenger_app/MyGameItemListResponse.dart';
import 'package:scavenger_app/UploadImageResponse.dart';
import 'package:http/http.dart' as http;
import 'package:scavenger_app/chatScreen.dart';
import 'package:scavenger_app/pages/utility/video_trimmer_page.dart';
import 'package:scavenger_app/services/orientation.dart';
import 'package:scavenger_app/shared/video.widget.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'constants.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/chalangeDetails.model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:scavenger_app/services/common.service.dart';
import 'package:scavenger_app/pages/custom_camera.dart';
import 'package:scavenger_app/services/chat_socket_service.dart';

class HuntDashboard extends StatefulWidget {
  final String myteam;
  final int gameId;
  final String? gameType;
  const HuntDashboard(
      {super.key,
      required this.myteam,
      required this.gameId,
      this.gameType = 'hunt'});

  @override
  _HuntDashboardState createState() => _HuntDashboardState();
}

Timer? _timer;
Timer? _timer2;

class _HuntDashboardState extends State<HuntDashboard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool _isLoading = false;
  bool _isItemLoading = false;
  int uploadItemid = 0;
  File? galleryFile;
  final picker = ImagePicker();
  String uplodedImgUrl = "";
  List<ResultGameTeam> items = [];
  String gameName = '';
  bool isItemApproved = false;
  String HuntDes = '';
  String HuntEndTime = '';
  String teamName = '';
  String gameImg = '';
  final ImagePicker _picker = ImagePicker();
  File? _videoFile;
  bool isTimerCheck = false;
  OrientationService orientationService = OrientationService();
  CameraController? _controller;
  String currentorientation = '';
  socket_io.Socket? socket;
  final Logger logger = Logger();
  int userid = 0;
  String username = "";
  int oriantation = 0;
  List<Map<dynamic, String>> oriantationList = [];
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
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to the TabController to unfocus when the tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Dismiss the keyboard when the tab is changed
        FocusManager.instance.primaryFocus?.unfocus();
      }
      if (_tabController.index == 1) {
        _unreadChat.value = 0;
      }
    });

    getUserId();
    orientationService.startListening((orientation) {
      if (mounted)
        setState(() {
          currentorientation = orientation;
        });
    });

    // Call initial data load after widget is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getgameDetails();
      }
    });
  }

  @override
  void dispose() {
    log(" HuntDashboard disposing - cleaning up resources");
    WidgetsBinding.instance.removeObserver(this);
    _stopPeriodicRefresh();
    _timer?.cancel();
    _timer2?.cancel();
    try {
      _controller?.dispose();
    } catch (e) {}
    try {
      orientationService.stopListening();
    } catch (e) {}
    try {
      _unreadChat.dispose();
    } catch (e) {}
    try {
      ChatSocketService().disconnect();
    } catch (e) {}
    super.dispose();
  }

  @override
  void deactivate() {
    log("⏸ HuntDashboard deactivated - stopping API calls");
    _isWidgetActive = false;
    _stopPeriodicRefresh();
    super.deactivate();
  }

  @override
  void activate() {
    log("▶ HuntDashboard activated - resuming API calls");
    _isWidgetActive = true;
    super.activate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _shouldRunTimer()) {
        log("🔄 activate - refreshing data and starting timer");
        _NewmyGameItemList(0);
        _startPeriodicRefresh();
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

  bool _shouldRunTimer() {
    return widget.gameType == 'hunt' &&
        _isAppInForeground &&
        _isWidgetActive &&
        mounted;
  }

  void _startPeriodicRefresh() {
    _stopPeriodicRefresh();
    if (!_shouldRunTimer()) {
      log(" Not starting timer - conditions not met (gameType: ${widget.gameType}, isAppInForeground: $_isAppInForeground, isWidgetActive: $_isWidgetActive, mounted: $mounted)");
      return;
    }

    log(" Starting periodic refresh timer (2 seconds interval)");
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && _shouldRunTimer()) {
        log(" Periodic refresh triggered");
        _NewmyGameItemList(0);
      } else {
        log(" Stopping timer - conditions no longer met");
        _stopPeriodicRefresh();
      }
    });
  }

  void _stopPeriodicRefresh() {
    if (_timer != null) {
      log("⏹️ Stopping periodic refresh timer");
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('saved_userId')) {
      userid = (prefs.getInt('saved_userId') ?? 0);
      username = (prefs.getString('saved_userName') ?? "");
      if (mounted) setState(() {});
      //  Connect global chat socket once user id is known
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
        if (_tabController.index != 1 && msg.userId != myIdStr) {
          _unreadChat.value = _unreadChat.value + 1;
        }
      });
    }
  }

  Future<void> _getgameDetails() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      if (mounted)
        setState(() {
          _isLoading = true;
        });

      final res = await ApiService.gameDetails(widget.gameId);

      if (!mounted) {
        _isRefreshing = false;
        return;
      }

      try {
        if (res.success) {
          final homeResponse = ChallangeDetailsModel.fromJson(res.response);
          gameName = homeResponse.title;
          HuntDes = homeResponse.description;
          var endTime = homeResponse.outTime ?? '';
          isItemApproved = homeResponse.isItemApproved ?? false;
          gameImg = homeResponse.gameImg ?? '';

          await _NewmyGameItemList(1);

          // Start periodic refresh only if conditions are met
          if (_shouldRunTimer()) {
            _startPeriodicRefresh();
          }

          if (endTime != '') {
            var date =
                DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(endTime);
            HuntEndTime = DateFormat("MMM d, y 'at' h:mm a").format(date);
          }
        }
      } catch (error) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: "Something went wrong! Please try again later.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: const Color.fromARGB(255, 196, 9, 9),
            textColor: Colors.white,
            fontSize: 14.0,
          );
        }
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _myGameItemList(int flag) async {
    if (flag == 1) {
      if (mounted)
        setState(() {
          _isLoading = true;
        });
    }
    ApiService.fetchGameItems({"teamId": widget.myteam}).then((res) {
      try {
        if (res.success) {
          final jsonResponseData = List<ResultGameTeam>.from(
              res.response.map((x) => ResultGameTeam.fromJson(x)));
          if (jsonResponseData.isNotEmpty) {
            if (mounted)
              setState(() {
                items = jsonResponseData;
              });
          }
        } else {
          /*  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('hunt failed: ${res.message}'),
          )); */
        }
      } catch (e) {}
    });

    if (flag == 1) {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  Future<void> _NewmyGameItemList(int flag) async {
    // Don't make API call if widget is not active or app is in background
    if (!_shouldRunTimer() && flag == 0) {
      log("⚠️ Skipping API call - widget not active or app in background");
      return;
    }

    if (flag == 1) {
      if (mounted)
        setState(() {
          _isLoading = true;
        });
    }

    try {
      final res = await ApiService.fetchNewGameItemsList(
          {"teamId": widget.myteam, "gameId": widget.gameId});

      if (!mounted) return;

      try {
        if (res.success) {
          final jsonResponseData = ResultData.fromJson(res.response);
          teamName = jsonResponseData.teamDtl.teamname;
          if (jsonResponseData.items.isNotEmpty) {
            log("✅ Game items updated - ${jsonResponseData.items.length} items");
            items = jsonResponseData.items;
            // log("this is the item for cal the api >>>>>>>>>> $items");
            if (mounted) setState(() {});
          }

          if (jsonResponseData.isEnd) {
            log("🏁 Game ended - navigating to leaderboard");
            _stopPeriodicRefresh();
            _timer2?.cancel();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LeaderboardPage(gameId: widget.gameId)));
          }
        }
      } catch (e) {
        log("❌ Error parsing game items: $e");
      }
    } catch (e) {
      log("❌ Error fetching game items: $e");
    }

    if (flag == 1 && mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadImage(int itid, String type, int oriantation) async {
    if (galleryFile == null && _videoFile == null) return;
    String uploadUrl =
        '${ApiConstants.uploadUrl}/upload'; // Replace with your server URL
    if (mounted)
      setState(() {
        for (var item in items) {
          if (item.id == itid) {
            item.isUploading = true;
          }
        }
      });
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      type == "image" ? galleryFile?.path ?? '' : _videoFile?.path ?? '',
    ));

    var response = await request.send();
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      final jsonResponseData = UploadImageResponse.fromJson(jsonResponse);

      if (jsonResponseData.success) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text('hunt successful!'),
        // ));
        String uploadedImgUrl = jsonResponseData.result.secureUrl;
        print("======1111=====$oriantation");
        _uploaditem(itid, uploadedImgUrl, oriantation);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('hunt failed: ${jsonResponseData.mesasge}'),
        ));
      }
    } else {
      print('Image upload failed with status: ${response.statusCode}');
    }
  }

  Future<void> _uploaditem(uploadid, imgurl, oriantation) async {
    String status = "0";
    for (var item in items) {
      if (item.id == uploadid) {
        status = item.status;
        break;
      }
    }
    var reqData = {
      "id": uploadid,
      "item_img_url": imgurl,
      "status": status == "1" ? "1" : "0",
      "orientation": oriantation
    };

    ApiService.uploadGameItem(reqData).then((res) {
      try {
        if (res.success) {
          // Navigator.pop(context);
          // final jsonResponseData = UploadItemResponse.fromJson(jsonResponse);
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   content: Text('hunt failed: ${res.message}'),
          // ));
        }
      } catch (e) {}
    });
    if (mounted)
      setState(() {
        for (var item in items) {
          if (item.id == uploadid) {
            item.isUploading = false;
            item.itemImgUrl = imgurl;
          }
        }
      });
  }

  void onImageCapture(int itid, bool isCamera) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 25,
        maxHeight: 800,
        maxWidth: 800);
    if (pickedFile != null) {
      // galleryFile = File(pickedFile.path);
      // _uploadImage(itid, "image");
      File orientationImg = File(pickedFile.path);
      // final result = await _fixImageRotation(orientationImg);
      print("currentorientation ===============>${currentorientation}");
      final result = await compute(processImageRotation, {
        'path': orientationImg.path,
        'orientation': currentorientation,
      });
      galleryFile = File(result['path']);
      oriantation = result['orientation'] ?? 0;
      if (galleryFile != null) {
        _uploadImage(itid, "image", oriantation);
      }
    }
  }

  Future<dynamic> openVideoCamera() async {
    final cameras = await availableCameras();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenCameraModal(
          durationSeconds: 5,
          cameras: cameras,
        ),
      ),
    );

    if (result != null && result is File) {
      print("Video saved at: ${result.path}");
      // Upload or process the video
      return result.path;
    } else {
      return null;
    }
  }

  Future<void> onVideoCapture(int itid, bool isCamera) async {
    String video = '';
    // if (isCamera) {
    //   video = await openVideoCamera();
    // } else {

    // }
    final XFile? vid = await _picker.pickVideo(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        maxDuration: const Duration(seconds: 5));
    video = vid?.path ?? '';
    if (video != '') {
      final trimmedPath = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return TrimmerView(File(video));
        }),
      );
      if (trimmedPath != null) {
        video = trimmedPath as String;
      } else {
        video = '';
      }
    }

    if (video != '' && video != null) {
      if (mounted)
        setState(() {
          _videoFile = File(video);
        });

      // Get device orientation at capture time
      String detectedOrientation = await getDeviceOrientation();

      // Initialize video player
      VideoPlayerController controller =
          VideoPlayerController.file(File(video));
      await controller.initialize();

      int width = controller.value.size.width.toInt();
      int height = controller.value.size.height.toInt();

      log("this is the width and height of the video >>>>>>>> ${width}  ------- $height");
      double aspectRatio = controller.value.aspectRatio;
      final Duration duration = controller.value.duration;

      if (duration.inSeconds > 5) {
        await controller.dispose(); // Clean up
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Video duration should be less than or equal to 5 seconds'),
        ));
      }

      // Check rotation metadata
      // int rotation = controller
      //     .value.rotationCorrection; // This should give rotation if available
      // if (rotation == 90 || rotation == 270) {
      //   int temp = width;
      //   width = height;
      //   height = temp;
      // }

      // Determine corrected orientation
      String videoOrientation = width > height ? "Landscape" : "Portrait";

      // Compare device orientation at capture with video orientation
      if (videoOrientation != detectedOrientation) {
        // print(">>>> Warning: Video might be rotated!");
      }
      if (videoOrientation == "Portrait") {
        oriantation = 1;
      } else {
        oriantation = 0;
      }
      // oriantationList.add({
      //   "itid": itid.toString(),
      //   "orientation": oriantation,
      // });

      log("this is the width and height of the video >>>>>>>> after  ${width}  ------- $height");

      _uploadImage(itid, "video", oriantation);

      controller.dispose();
    }
  }

// Function to get the device orientation using accelerometer
  Future<String> getDeviceOrientation() async {
    try {
      AccelerometerEvent event = await accelerometerEvents.first;
      double x = event.x;
      double y = event.y;

      if (x.abs() > y.abs()) {
        return "Landscape";
      } else {
        return "Portrait";
      }
    } catch (e) {
      print("Error detecting orientation: $e");
      return "Unknown";
    }
  }

  void onItemTapped(BuildContext context, int itid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose Media Type"),
          content: const Text("Do you want to select a picture or a video?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // _showSourceDialog(
                //   context,
                //   itid,
                //   isImage: true,
                // );
                onImageCapture(itid, true);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Picture"),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // _showSourceDialog(
                //   context,
                //   itid,
                //   isImage: false,
                // );
                onVideoCapture(itid, true);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Video"),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSourceDialog(BuildContext context, int itid,
      {required bool isImage}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Source'),
          content: const Text('Do you want to use Camera or Gallery?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isImage) {
                  onImageCapture(itid, true); // open camera for image
                } else {
                  onVideoCapture(itid, true); // open camera for video
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, color: Colors.green),
                  SizedBox(width: 8),
                  Text("Camera"),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isImage) {
                  onImageCapture(itid, false); // gallery for image
                } else {
                  onVideoCapture(itid, false); // gallery for video
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Gallery"),
                ],
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
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const HomeScreen(userName: '')));
                },
              ),
              title: Text(gameName),
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
                  const Tab(text: 'Hunt Items'),
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
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width - 30),
                        height: 120,
                        decoration: BoxDecoration(
                          // color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF153792),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: (MediaQuery.of(context).size.width - 40),
                              height: 110,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 65,
                                    width: 65,
                                    margin: const EdgeInsets.only(left: 14),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 65, 15, 15),
                                      borderRadius: BorderRadius.circular(50),
                                      image: gameImg == null || gameImg == ''
                                          ? const DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/defaultImg.jpg'),
                                              fit: BoxFit.fill,
                                            )
                                          : DecorationImage(
                                              image:
                                                  NetworkImage(gameImg ?? ''),
                                              fit: BoxFit.fill,
                                            ),
                                    ),
                                  ),
                                  Container(
                                    width: (MediaQuery.of(context).size.width -
                                        120),
                                    height: 200,
                                    padding: EdgeInsets.only(left: 3),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                gameName,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  color: Color(0xFF153792),
                                                  fontSize: 18,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )),
                                        if (HuntDes != '')
                                          Container(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          "Description :$HuntDes",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style:
                                                              const TextStyle(
                                                            color: Color(
                                                                0xFF153792),
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Roboto',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            height: 1,
                                                          )),
                                                      GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                // title: const Text("Full Description"),
                                                                content:
                                                                    SingleChildScrollView(
                                                                  child: Text(
                                                                    HuntDes,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          'Jost',
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: HuntDes
                                                                    .isNotEmpty &&
                                                                HuntDes.length >
                                                                    30
                                                            ? const Text(
                                                                "Show More",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          70,
                                                                          81,
                                                                          111,
                                                                          1),
                                                                  fontSize:
                                                                      12.0,
                                                                  height: 1,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline, // Optional: underline for interactivity
                                                                ),
                                                              )
                                                            : const SizedBox(),
                                                      )
                                                    ]),
                                              )),
                                        if (HuntEndTime != '')
                                          Container(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "End Time: ${HuntEndTime}",
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    color: Color(0xFF153792),
                                                    fontSize: 14,
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
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // Text("zjhfg"),dfhbsdjg
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            dynamic newitem;
                            if (items[index].sequence != 0 &&
                                items[index].sequence != null) {
                              newitem = items.firstWhere(
                                (item) => item.sequence == index + 1,
                                // orElse: () => null, // prevent error if not found
                              );
                            } else {
                              newitem = items[index];
                            }

                            return ListItem(
                                item: newitem,
                                gameType: widget.gameType ?? 'hunt',
                                isItemApproved: isItemApproved,
                                onItemTapped: onItemTapped);
                          },
                        ),
                      ),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle submit action
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context1) {
                                      return AlertDialog(
                                        title: const Text('Warning!'),
                                        content: const Text(
                                            'Are you sure you want to submit your hunt? This action cannot be undone.'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context1)
                                                  .pop(); // Close the dialog
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              ApiService.submitHunt(
                                                      {"teamId": widget.myteam})
                                                  .then((value) {
                                                if (value.success) {
                                                  if (widget.gameType ==
                                                      'hunt') {
                                                    _showAlertDialog(context);
                                                  } else {
                                                    Navigator.of(context1)
                                                        .pop();
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                HomeScreen(
                                                                    userName:
                                                                        "userName",
                                                                    gameId: widget
                                                                        .gameId)));
                                                  }
                                                } else {
                                                  // ScaffoldMessenger.of(context)
                                                  //     .showSnackBar(SnackBar(
                                                  //   content: Text(
                                                  //       'Login failed: ${value.message}'),
                                                  // ));
                                                }
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red, // Warning color
                                            ),
                                            child: const Text('Proceed',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF153792),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ),
                            ),
                    ],
                  ),
                  ChatScreen(gameId: widget.gameId, teamName: teamName),
                ],
              ),
            ),
          ),
        ));
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Align(
              //   alignment: Alignment.topRight,
              //   child: IconButton(
              //     icon: const Icon(Icons.close),
              //     onPressed: () {
              //       _timer2!.cancel();
              //       Navigator.of(context).pop();
              //     },
              //   ),
              // ),
              Image.asset('assets/images/waitingImg.png',
                  width: 197, height: 174),
              const SizedBox(height: 20),
              const Text(
                'Please Wait For Result or you can check it later.',
                style: TextStyle(
                  color: Color(0xFF153792),
                  fontSize: 14,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,

                  // height: 0.04,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen(
                                userName: '',
                              )));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF153792),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void _showImagePopup(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

_showVideoDialog(BuildContext context, String url) {
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

typedef ItemTappedCallback = void Function(
  BuildContext context,
  int name,
);

class ListItem extends StatelessWidget {
  bool _isLoading = false;
  final _HuntDashboardState huntdash = new _HuntDashboardState();
  final ResultGameTeam item;
  final String gameType;
  final bool isItemApproved;

  //ListItem({required this.item});
  //final VoidCallback onImageSelected;
  final ItemTappedCallback onItemTapped;

//    ListItem({super.key, required this.onImageSelected,required this.item});
// final VoidCallback onImageSelected;

  ListItem(
      {Key? key,
      required this.item,
      required this.gameType,
      required this.isItemApproved,
      required this.onItemTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;
    switch (item.status) {
      case "0":
        statusText = 'Pending';
        statusColor = Colors.grey;
        break;
      case "1":
        statusText = 'Accept';
        statusColor = Colors.green;
        break;
      case "2":
        statusText = 'Reject';
        statusColor = Colors.red;
        break;
      case "3":
        statusText = 'Resubmit';
        statusColor = Colors.yellow;
        break;
      default:
        statusText = 'Unknown';
        statusColor = Colors.black;
    }
    // bool isVideo = item.itemImgUrl != null && item.itemImgUrl.endsWith(".mp4");
    bool isVideo = item.itemImgUrl != null &&
        (item.itemImgUrl.endsWith(".mp4") ||
            item.itemImgUrl.endsWith(".MOV") ||
            item.itemImgUrl.endsWith(".mov"));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          item.item.imgUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(item.item.imgUrl),
                  radius: 30.0,
                )
              : const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/defaultImg.jpg'),
                ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.item.name,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(21, 55, 146, 1.0),
                  ),
                ),
                Text(
                  item.item.description,
                  style: const TextStyle(
                    color: Color.fromRGBO(70, 81, 111, 1),
                    fontSize: 14.0,
                    height: 1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          // title: const Text("Full Description"),
                          content: SingleChildScrollView(
                            child: Text(
                              item.item.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Jost',
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: item.item.description.isNotEmpty &&
                          item.item.description.length > 30
                      ? const Text(
                          "Show More",
                          style: TextStyle(
                            color: Color.fromRGBO(70, 81, 111, 1),
                            fontSize: 12.0,
                            height: 1,
                            decoration: TextDecoration
                                .underline, // Optional: underline for interactivity
                          ),
                        )
                      : const SizedBox(),
                ),
                // Container(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       // Text(
                //       //   item.item.description,
                //       //   style: const TextStyle(
                //       //     fontSize: 12,
                //       //     color: Color.fromRGBO(70, 81, 111, 1),
                //       //     fontWeight: FontWeight.w400,
                //       //     overflow: TextOverflow.ellipsis,
                //       //     height: 1,
                //       //   ),
                //       // ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 4.0),
                if (isItemApproved)
                  Text(
                    gameType == 'hunt' ? statusText : '',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          (item.isUploading ?? false)
              ? const CircularProgressIndicator()
              : item.itemImgUrl == null || item.status == "2"
                  ? IconButton(
                      // icon: const Image(
                      //   image: AssetImage('assets/images/upload_ico.png'),
                      //   height: 50,
                      //   width: 50,
                      // ),
                      icon: Icon(
                        Icons.camera_alt_sharp,
                        size: 40,
                        color: Colors.green,
                        shadows: [
                          Shadow(
                            color: const Color.fromARGB(255, 199, 199, 199)
                                .withOpacity(0.5),
                            offset: const Offset(3, 3),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      onPressed: () {
                        // Handle the upload button action
                        //huntdash.getImage(ImageSource.gallery,item.id);
                        //onImageSelected;
                        onItemTapped(context, item.id);
                      },
                    )
                  : isVideo
                      ? GestureDetector(
                          onTap: () =>
                              _showVideoDialog(context, item.itemImgUrl),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              item.snapshot != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(item
                                          .snapshot), // Placeholder for video
                                      radius: 30.0,
                                    )
                                  : const CircleAvatar(
                                      backgroundImage: AssetImage(
                                          "assets/images/logo.jpg"), // Placeholder for video
                                      radius: 30.0,
                                    ),
                              const Icon(
                                Icons.play_circle_fill,
                                color: Color.fromRGBO(21, 55, 146, 1.0),
                                size: 30.0,
                              ),
                            ],
                          ))
                      : GestureDetector(
                          onTap: () =>
                              _showImagePopup(context, item.itemImgUrl),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(item.itemImgUrl),
                            radius: 30.0,
                          ),
                        ),
          // more menu
          PopupMenuButton(
            enabled: item.itemImgUrl != null &&
                item.itemImgUrl != '' &&
                item.status != '1',
            onSelected: (menu) {
              if (menu == 'change') {
                onItemTapped(context, item.id);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(value: 'change', child: Text('Change')),
            ],
          ),
        ],
      ),
    );
  }
}

class Item {
  final String imageUrl;
  final String name;
  final String description;
  final String status;

  Item({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.status,
  });
}
