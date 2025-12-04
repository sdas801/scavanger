import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:scavenger_app/AddNewTeam.dart';
import 'package:scavenger_app/CreatedGameDetailsResponse.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/MyTeamResponse.dart';
import 'package:scavenger_app/WaitingScreen.dart';
import 'package:scavenger_app/custom_textfield.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/services/crop.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:random_avatar/random_avatar.dart';

class CreateNewTeam extends StatefulWidget {
  final String myteam;
  final int statusChangeid;
  final int gameid;
  const CreateNewTeam(
      {super.key,
      required this.myteam,
      required this.statusChangeid,
      required this.gameid});

  @override
  State<CreateNewTeam> createState() => _CreateNewTeamState();
}

class _CreateNewTeamState extends State<CreateNewTeam> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mainNameController = TextEditingController();

  bool isTimedHunt = false;
  bool willOfferPrizes = false;
  bool willApproveItems = false;
  bool allowMessaging = false;
  bool _isLoading = false;
  String? selectedTeam;
  File? galleryFile;
  String gameImg = '';
  final picker = ImagePicker();
  String gameTitle = "";
  String gamedesc = "";
  String huntImg = "";
  bool _isImgLoading = false;
  String gameStartDate = "";
  String statusCheck = "";
  String teamId = "";
  int checkTeam = 0;
  int gamePlayId = 0;
  String teamName1 = "";
  String teamImg = "";
  bool imgLoader = false;
  int maxTeam = 0;
  PolicyResult? isCheckSubcription;

  List<ResultMyteam> teamMembers = [];
  void initState() {
    _getgameDetails();
    getSubcriptionCheck();
  }

  Future<void> _getgameDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('saved_userName')) {
      _nameController.text = (prefs.getString('saved_userName') ?? "");
    }
    setState(() {
      _isLoading = true;
    });
    ApiService.gameDetails(widget.gameid, "1").then((value) {
      if (value.success) {
        final homeResponse = Result.fromJson(value.response);
        gameTitle = homeResponse.title;
        gamedesc = homeResponse.description;
        huntImg = homeResponse.gameImg ?? '';
        statusCheck = homeResponse.status;
        maxTeam = homeResponse.maxTeam ?? 0;
        var startDate = homeResponse.inTime ?? "";
        if (startDate != '') {
          var date =
              DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(startDate);
          gameStartDate = DateFormat("MMM d, y 'at' h:mm a").format(date);
          // fetchDate = DateFormat('MM/dd/yy').format(date);
          // fetchTime = DateFormat('hh:mm a').format(date);
        }
        teamId = homeResponse.teamId ?? '';
        gamePlayId = homeResponse.gamePlayId ?? 0;
        teamName1 = homeResponse.teamname ?? '';
        if (teamId.isNotEmpty) {
          checkTeam = 1;
        }
        _mainNameController.text = teamName1.isNotEmpty
            ? "${teamName1}"
            : "${_nameController.text}'s team";
        teamImg = homeResponse.teamimg ?? "";

        _myteam();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${value.message}'),
        ));
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  /* void getSubcriptionCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    if (subcriptionCheckString != null) {
      Map<String, dynamic> jsonData = jsonDecode(subcriptionCheckString);
      setState(() {
        isCheckSubcription = PolicyResult.fromJson(jsonData);
      });
    }
  } */

  void getSubcriptionCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');

    if (subcriptionCheckString != null && subcriptionCheckString.isNotEmpty) {
      final decoded = jsonDecode(subcriptionCheckString);
      if (decoded is Map<String, dynamic>) {
        setState(() {
          isCheckSubcription = PolicyResult.fromJson(decoded);
        });
      } else {
        debugPrint("Decoded subscription data is not a map");
      }
    } else {
      debugPrint("No subscription_Check data found in SharedPreferences");
    }
  }

  Future<void> _createTeam() async {
    final String teamname = _teamNameController.text.trim();
    // final String teamEmail = _emailController.text.trim();
    // final String teamPhoneNo = _phoneNoController.text.trim();
    // final String emailPattern =
    //     r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    // final RegExp emailRegex = RegExp(emailPattern);

    if (teamname.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter team name !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    var reqData = {
      "teamId": checkTeam == 1 ? teamId : widget.myteam,
      "name": teamname,
      "email": "",
      "phone": "",
      "user_img": gameImg
    };
    ApiService.createTeam(reqData).then((value) {
      if (value.success) {
        //  final jsonResponseData = CreateTeamResponse.fromJson(value.response);
        _teamNameController.text = '';
        Navigator.of(context).pop();
        _myteam();
        _clearData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed: ${value.message}'),
        ));
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _clearData() async {
    setState(() {
      _teamNameController.clear();
      // _emailController.clear();
      // _phoneNoController.clear();
      gameImg = "";
    });
  }

  Future<void> _myteam() async {
    setState(() {
      _isLoading = true;
    });
    ApiService.getMyTeamList(
        {"teamId": checkTeam == 1 ? teamId : widget.myteam}).then((value) {
      try {
        if (value.success) {
          var jsonResponseData = List<ResultMyteam>.from(
              value.response.map((x) => ResultMyteam.fromJson(x)));
          teamMembers = jsonResponseData;
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
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _updateTeamName() async {
    final String mainTeamName = _mainNameController.text;
    if (mainTeamName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter team name !'),
      ));
      return;
    }
    setState(() {
      _isLoading = true;
    });
    var reqData = {
      "teamId": checkTeam == 1 ? teamId : widget.myteam,
      "teamName": mainTeamName,
      "teamimg": teamImg
    };
    ApiService.updateTeamName(reqData).then((res) {
      try {
        setState(() {
          _isLoading = false;
        });
        if (res.success) {
          _changeStatus();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('hunt failed: ${res.message}'),
          ));
        }
      } catch (error) {
        // print(error);
      } finally {}
    });
  }

  Future<void> _changeStatus() async {
    setState(() {
      _isLoading = true;
    });
    ApiService.changeGameStatus(
            {"id": checkTeam == 1 ? gamePlayId : widget.statusChangeid})
        .then((res) {
      try {
        setState(() {
          _isLoading = false;
        });
        if (res.success) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => WaitingScreen(
                      gameId: widget.gameid,
                      myteam: checkTeam == 1 ? teamId : widget.myteam)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('hunt failed: ${res.message}'),
          ));
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

  Future<void> _uploadImage() async {
    if (galleryFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select an image to upload'),
      ));
      return;
    }
    ApiService.uploadFile(galleryFile!.path).then((value) async {
      if (value != '') {
        var mainImg = value;
        setState(() {
          teamImg = mainImg;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Image upload failed'),
        ));
      }
      if (mounted) {
        setState(() {
          imgLoader = false;
        });
      }
    });
  }

  Future getImage(
    ImageSource img,
  ) async {
    setState(() {
      imgLoader = true;
    });
    final pickedFile = await picker.pickImage(source: img, imageQuality: 25);
    final cropImgData =
        await CropImageService.cropImage(pickedFile, cropStyle: 'circle');
    setState(
      () {
        if (cropImgData != null) {
          galleryFile = File(cropImgData!.path);
          _uploadImage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
        imgLoader = false;
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
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomeScreen(userName: '')));
              },
            ),
            title: const Text("Create New Team"),
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
          backgroundColor: const Color(0xFF0B00AB),
          body: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Center(
              child: Container(
                width: screenSize.width,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 28.0, left: 28.0, right: 28.0, bottom: 10),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFF153792),
                                  width: 3,
                                ),
                              ),
                              child: huntImg.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        huntImg,
                                        fit: BoxFit.cover,
                                        width: 150,
                                        height: 150,
                                      ),
                                    )
                                  : const CircleAvatar(
                                      radius: 75,
                                      backgroundImage: AssetImage(
                                          'assets/images/defaultImg.jpg'),
                                    ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                gameTitle,
                                style: const TextStyle(
                                  color: Color(0xFF153792),
                                  fontSize: 22,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gamedesc,
                                    style: const TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 16,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      overflow: TextOverflow
                                          .ellipsis, // Shows ellipsis if text is long
                                      height: 1,
                                    ),
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
                                                gamedesc,
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
                                    child: gamedesc.isNotEmpty &&
                                            gamedesc.length > 30
                                        ? const Text(
                                            "Show More",
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  70, 81, 111, 1),
                                              fontSize: 12.0,
                                              height: 1,
                                              decoration: TextDecoration
                                                  .underline, // Optional: underline for interactivity
                                            ),
                                          )
                                        : const SizedBox(),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Description Label
                                const Text(
                                  "Start at : ",
                                  style: TextStyle(
                                    color: Color(0xFF153792),
                                    fontSize: 15,
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    gameStartDate,
                                    style: const TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 13,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Team Image",
                                    style: const TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 16,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: InkWell(
                                  onTap: () {
                                    if (statusCheck == "2") {
                                      Fluttertoast.showToast(
                                        msg:
                                            "The hunt has already ended. You can’t add any teams.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        backgroundColor:
                                            const Color(0xFF0B00AB),
                                        textColor: Colors.white,
                                        fontSize: 12.0,
                                      );
                                    } else {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SizedBox(
                                            height: 200,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    'Upload Quest Image',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      _buildUploadOption(
                                                        icon: Icons.camera_alt,
                                                        label: 'Camera',
                                                        onTap: () async {
                                                          // Capture image from camera
                                                          final newImage =
                                                              await getImage(
                                                                  ImageSource
                                                                      .camera);
                                                          if (newImage !=
                                                              null) {
                                                            setState(() {
                                                              teamImg =
                                                                  newImage; // Update the image URL
                                                            });
                                                          }
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                      _buildUploadOption(
                                                        icon: Icons.photo,
                                                        label: 'Gallery',
                                                        onTap: () async {
                                                          // Select image from gallery
                                                          final newImage =
                                                              await getImage(
                                                                  ImageSource
                                                                      .gallery);
                                                          if (newImage !=
                                                              null) {
                                                            setState(() {
                                                              teamImg =
                                                                  newImage; // Update the image URL
                                                            });
                                                          }
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        width: 2,
                                        color: const Color.fromARGB(
                                            255, 27, 56, 150),
                                      ),
                                    ),
                                    child: imgLoader
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50.0),
                                            child: teamImg.isNotEmpty
                                                ? Image.network(
                                                    teamImg,
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.cover,
                                                  )
                                                : const Icon(
                                                    size: 50,
                                                    Icons
                                                        .add_photo_alternate_outlined,
                                                    color: Colors.black,
                                                  ),
                                          ),
                                  ),
                                )),
                            const SizedBox(height: 15),
                            CustomTextField(
                                controller: _mainNameController,
                                labelText: 'Team Name',
                                hintText: 'Enter your Team Name',
                                maxLines: 1,
                                enabled: statusCheck == "2" ? false : true),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Team Member Text
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Team Member',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(21, 55, 146, 1),
                                    ),
                                  ),
                                ),
                                // Add Button
                                TextButton.icon(
                                  icon:
                                      Image.asset('assets/images/teamadd.png'),
                                  label: const Text(""),
                                  onPressed: () {
                                    setState(() {
                                      _isLoading = false;
                                    });

                                    if (statusCheck == "2") {
                                      Fluttertoast.showToast(
                                        msg:
                                            "The hunt has already ended. You can’t add any teams.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        backgroundColor:
                                            const Color(0xFF0B00AB),
                                        textColor: Colors.white,
                                        fontSize: 12.0,
                                      );
                                    } else {
                                      if (maxTeam == teamMembers.length) {
                                        Fluttertoast.showToast(
                                          msg:
                                              "This hunt support $maxTeam team members",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          backgroundColor:
                                              const Color(0xFF0B00AB),
                                          textColor: Colors.white,
                                          fontSize: 12.0,
                                        );
                                      } else {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(45),
                                              topRight: Radius.circular(45),
                                            ),
                                          ),
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return AddTeam(
                                                myteam: widget.myteam,
                                                huntImg: huntImg,
                                                gamedesc: gamedesc,
                                                gameTitle: gameTitle,
                                                checkTeam: checkTeam,
                                                itemId: teamId,
                                                teamid: 0,
                                                userImg: "",
                                                teamName: "");
                                          },
                                        ).whenComplete(() {
                                          print('completed');
                                          _myteam();
                                          ;
                                        });
                                      }
                                    }
                                  }, // Update the image asset accordingly
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      teamMembers.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 30),
                                  Icon(
                                    Icons.inbox,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 30),
                                  Text(
                                    "No new team member added yet",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: teamMembers.length,
                              itemBuilder: (context, index) {
                                return TeamMemberWidget(
                                    imageUrl: teamMembers[index].userImg ?? '',
                                    name: teamMembers[index].name,
                                    description: "",
                                    id: teamMembers[index].id,
                                    index: index,
                                    statusCheck: statusCheck,
                                    onClick:
                                        (val, type, index, id, imageUrl, name) {
                                      if (type == 'edit') {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(45),
                                              topRight: Radius.circular(45),
                                            ),
                                          ),
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return AddTeam(
                                                myteam: widget.myteam,
                                                huntImg: huntImg,
                                                gamedesc: gamedesc,
                                                gameTitle: gameTitle,
                                                checkTeam: checkTeam,
                                                itemId: teamId,
                                                teamid: id,
                                                userImg: imageUrl,
                                                teamName: name);
                                          },
                                        ).whenComplete(() {
                                          print('completed');
                                          _myteam();
                                          ;
                                        });
                                      } else if (type == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  "Delete Confirmation"),
                                              content: const Text(
                                                  "Are you sure you want to delete the  team member?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    "No",
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    ApiService
                                                        .deleteTeamMemberList({
                                                      "teamId": checkTeam == 1
                                                          ? teamId.toString()
                                                          : widget.myteam
                                                              .toString(),
                                                      "participantId":
                                                          teamMembers[index].id
                                                    }).then((res) {
                                                      if (res.success) {
                                                        Fluttertoast.showToast(
                                                          msg:
                                                              "Team member deleted successfully",
                                                          toastLength: Toast
                                                              .LENGTH_SHORT,
                                                          gravity: ToastGravity
                                                              .BOTTOM,
                                                          backgroundColor:
                                                              Colors.green,
                                                          textColor:
                                                              Colors.white,
                                                          fontSize: 16.0,
                                                        );
                                                        _myteam();
                                                      } else {
                                                        Fluttertoast.showToast(
                                                          msg:
                                                              "Failed to delete the team member list",
                                                          toastLength: Toast
                                                              .LENGTH_SHORT,
                                                          gravity: ToastGravity
                                                              .BOTTOM,
                                                          backgroundColor:
                                                              Colors.red,
                                                          textColor:
                                                              Colors.white,
                                                          fontSize: 16.0,
                                                        );
                                                      }
                                                    });
                                                  },
                                                  child: Text("Yes"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    });
                              },
                            ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  _updateTeamName();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(11, 0, 171, 1),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Ready to Start',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

typedef void ItemClickCallback(
    int val, String type, int index, int itemid, String imageUrl, String name);

class TeamMemberWidget extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final int id;
  final int index;
  final String statusCheck;
  final ItemClickCallback onClick;

  const TeamMemberWidget({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.id,
    required this.index,
    required this.description,
    required this.statusCheck,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 28),
      margin: const EdgeInsets.only(bottom: 3.0),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                imageUrl.isEmpty
                    ? const CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            AssetImage('assets/images/defaultImg.jpg'),
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                        radius: 30.0,
                      ),
                const SizedBox(width: 16.0),
                Expanded(
                  // Ensures the text doesn't overflow and wraps properly
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow:
                        TextOverflow.ellipsis, // Adds "..." if text is too long
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          if (statusCheck == "0")
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Color.fromRGBO(21, 55, 146, 1),
                    ),
                    onPressed: () {
                      onClick(id, 'edit', index, id, imageUrl, name);
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      size: 20,
                      color: Color.fromRGBO(221, 4, 4, 1),
                    ),
                    onPressed: () {
                      onClick(id, 'delete', index, id, imageUrl, name);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildUploadOption({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF153792),
            size: 40,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ),
  );
}
