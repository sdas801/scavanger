import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/model/relanch.result.dart';
import 'package:scavenger_app/pages/challenge/complete_relanch_destailspage.dart';
import 'package:scavenger_app/pages/subcriptions/currentPlandialog.dart';
import 'package:scavenger_app/pages/subcriptions/subcriptionList.dart';
import 'package:scavenger_app/pages/subcriptions/subcription_popup.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/model/challenge.model.dart';
import 'package:scavenger_app/services/download.service.dart';
import 'package:scavenger_app/shared/video.widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:scavenger_app/pages/challenge/create_step_one.page.dart';
import 'package:scavenger_app/pages/challenge/challenge_item_upload.page.dart';

class ChallengeDetails extends StatefulWidget {
  final int challengeId;
  const ChallengeDetails({super.key, required this.challengeId});

  @override
  _ChallengeDetailsState createState() => _ChallengeDetailsState();
}

class _ChallengeDetailsState extends State<ChallengeDetails> {
  ChallengeModel challenge = ChallengeModel(
      id: 0,
      name: '',
      description: '',
      status: 0,
      createdat: '',
      endtime: '',
      items: [],
      imageurl: '',
      otp: '',
      qrcode: '',
      videofile: '');
  bool _isLoading = false;
  List<ChallengeItem> items = [];
  int checkStatus = 0;
  String gameStartDate = "";
  String gameName = "";
  final String baseUrl = "https://d1nb9mmvrnnzth.cloudfront.net";
  String videoMainFile = "";
  ScreenshotController screenshotController = ScreenshotController();
  StreamController<ErrorAnimationType>? errorController;
  TextEditingController textEditingController = TextEditingController();
  int isclone = 0;
  String qrCode = "";
  String OTP = "";
  String currentText = "";
  int relanchId = 0;

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>.broadcast();
    getChallengeDetails();
  }

  getChallengeDetails() async {
    setState(() {
      _isLoading = true;
    });
    ApiService.getChallengeDetails(widget.challengeId).then((res) {
      if (res.success) {
        setState(() {
          isclone = res.response["is_clone"];
          challenge = ChallengeModel.fromJson(res.response);
          _isLoading = false;
          items = challenge.items ?? [];
          checkStatus = challenge.status;
          gameName = challenge.name;
          // qrCode = challenge.qrcode.replaceAll('data:image/png;base64,', '');
          // OTP = challenge.otp;
          // textEditingController.text = OTP.toString();
          videoMainFile = challenge.videofile ?? "";

          if (challenge.createdat != '') {
            challenge.createdat = DateFormat("MMM d, y 'at' h:mm a")
                .format(DateTime.parse(challenge.createdat));
          }

          // var startDate = challenge.createdat ?? "";

          // if (startDate != '') {
          //   var date =
          //       DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(startDate);
          //   gameStartDate = DateFormat("MM/dd/yyyy HH:mm aaa").format(date);
          // }
        });
      }
    });
  }

  _shareHuntCode(image, gameName, gameStartDate) async {
    // final result = await ImageGallerySaver.saveImage(image);
    // print("File Saved to Gallery");
    // convert Uint8List image to a XFile
    final imageFile =
        XFile.fromData(image, name: 'image.png', mimeType: 'image/png');
    final result = await Share.shareXFiles([imageFile],
        text:
            'You are invited to join the Scavengertime Hunt called $gameName that will begin on $gameStartDate. Click this link to join or enter the code into your Scavengertime App. If you do not have Scavengertime downlod here and click this link once you have Scavengertime.');
    if (result.status == ShareResultStatus.success) {
      print('Thank you for sharing the picture!');
    }
  }

  void deleteGame() async {
    final res =
        await ApiService.deleteChallenge({"challengeid": widget.challengeId});
    if (res.success) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                  userName: "", selectedTab: 1, gameId: widget.challengeId)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete : ${res.message ?? "Unknown error"}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    // } catch (error) {}
  }

  Future<void> _onDownloadVideo(String url, String fileName) async {
    await downloadVideo(url, fileName);
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Delete',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 89, 54, 244),
            ),
          ),
          content: const Text(
            'Are you sure you want to delete Quest.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            // Confirm Button
            TextButton(
                onPressed: () {
                  deleteGame();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 16),
                )),
          ],
        );
      },
    );
  }

  void onDelete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    PolicyResult? tempSubcriptionCheckNo;
    if (subcriptionCheckString != null && subcriptionCheckString.isNotEmpty) {
      try {
        Map<String, dynamic> decodedJson = jsonDecode(subcriptionCheckString);
        tempSubcriptionCheckNo = PolicyResult.fromJson(decodedJson);
      } catch (e) {
        tempSubcriptionCheckNo = null;
      }
    } else {
      tempSubcriptionCheckNo = null;
    }
    if (tempSubcriptionCheckNo != null) {
      showDeleteDialog(context);
    } else {
      showSubscriptionModal(context);
    }
  }

  void enterChallenge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    PolicyResult? tempSubcriptionCheckNo;
    if (subcriptionCheckString != null && subcriptionCheckString.isNotEmpty) {
      try {
        Map<String, dynamic> decodedJson = jsonDecode(subcriptionCheckString);
        tempSubcriptionCheckNo = PolicyResult.fromJson(decodedJson);
      } catch (e) {
        tempSubcriptionCheckNo = null;
      }
    } else {
      tempSubcriptionCheckNo = null;
    }
    if (tempSubcriptionCheckNo != null) {
      if (items.isEmpty) {
        Fluttertoast.showToast(
          msg: "Add items to the quest to continue",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => ChallengeItemUploadPage(
        //               gameId: challenge.id,
        //             )));
        int? maxHuntItems = tempSubcriptionCheckNo!.maxChallengeItems;
        if (maxHuntItems != null && items.length > maxHuntItems) {
          showCurrentPlanAlertDialog(context, tempSubcriptionCheckNo,
              " You have reached the limit of {$maxHuntItems} items per quest under your current subscription plan.");
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChallengeItemUploadPage(
                        gameId: challenge.id,
                      )));
        }
      }
    } else {
      showSubscriptionModal(context);
    }
  }

  void onrelaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    PolicyResult? tempSubcriptionCheckNo;
    if (subcriptionCheckString != null && subcriptionCheckString.isNotEmpty) {
      try {
        Map<String, dynamic> decodedJson = jsonDecode(subcriptionCheckString);
        tempSubcriptionCheckNo = PolicyResult.fromJson(decodedJson);
      } catch (e) {
        tempSubcriptionCheckNo = null;
      }
    } else {
      tempSubcriptionCheckNo = null;
    }
    if (tempSubcriptionCheckNo != null) {
      if (tempSubcriptionCheckNo.isRelaunch == 0) {
        showCurrentPlanAlertDialog(context, tempSubcriptionCheckNo,
            "As per your current subscription plan you can not relaunch the quest.");
      } else {
        showRelanchDialog(context);
      }
    } else {
      showSubscriptionModal(context);
    }
  }

  void _onRelanch() async {
    ApiService.relaunChChallenge({"challengeid": widget.challengeId})
        .then((res) {
      if (res.success) {
        var relanchData = RelanchModel.fromJson(res.response);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CompletedRelanchDetails(challengeId: relanchData.id)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${res.message ?? "Unknown error"}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void showQrcode() async {
    ApiService.getUniqueChallengeId({"challenge_id": widget.challengeId})
        .then((res) {
      if (res.success) {
        OTP = res.response['otp'] ?? "";
        textEditingController.text = OTP.toString();
        final String qrImg = res.response['qr_img'];
        qrCode = qrImg.replaceAll('data:image/png;base64,', '');
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
            return Container(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Close Button
                        Container(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 30,
                              semanticLabel: 'Close',
                            ),
                          ),
                        ),

                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(45),
                              topRight: Radius.circular(45),
                            ),
                          ),
                          child: Screenshot(
                            controller: screenshotController,
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              color: Colors.white,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: 50,
                                    height: 50,
                                    padding: const EdgeInsets.only(
                                        top: 20.0, left: 20.0, right: 20.0),
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/images/logo.jpg"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    gameName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 22,
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  qrCode != ''
                                      ? Image.memory(
                                          base64Decode(qrCode),
                                          height: 180,
                                          fit: BoxFit.fill,
                                        )
                                      : Image.asset(
                                          'assets/images/qrcode.png', // Update the image asset accordingly
                                          height: 180,
                                          fit: BoxFit.fill,
                                        ),
                                  const Text(
                                    "Scan the QR Code to Join The quest",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 14,
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  const Text(
                                    "Or",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 20,
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  const Text(
                                    "Use this code to enter quest on your app",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 14,
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  IgnorePointer(
                                    ignoring: true,
                                    child: PinCodeTextField(
                                      appContext: context,
                                      length: 6,
                                      obscureText: false,
                                      animationType: AnimationType.fade,
                                      autoDisposeControllers: false,
                                      pinTheme: PinTheme(
                                        shape: PinCodeFieldShape.circle,
                                        borderRadius: BorderRadius.circular(2),
                                        fieldHeight: 40,
                                        fieldWidth: 40,
                                        activeFillColor: Colors.white,
                                        activeColor: Colors.blue,
                                        selectedColor: Colors.blue,
                                        inactiveColor: const Color.fromARGB(
                                            255, 251, 246, 246),
                                        inactiveFillColor: Colors.white,
                                        selectedFillColor: const Color.fromARGB(
                                            255, 250, 251, 252),
                                      ),
                                      animationDuration:
                                          const Duration(milliseconds: 300),
                                      backgroundColor: Colors.transparent,
                                      enableActiveFill: true,
                                      errorAnimationController: errorController,
                                      controller: textEditingController,
                                      onCompleted: (v) {},
                                      onChanged: (value) {
                                        setState(() {
                                          currentText = value;
                                        });
                                      },
                                      beforeTextPaste: (text) {
                                        return true;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            screenshotController
                                .capture(delay: const Duration(milliseconds: 1))
                                .then((capturedImage) async {
                              print(capturedImage);
                              _shareHuntCode(
                                  capturedImage, gameName, gameStartDate);
                            }).catchError((onError) {
                              print(onError);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 214, 208, 208),
                            foregroundColor: const Color(0xFF0B00AB),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Share'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${res.message ?? "Unknown error"}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void showRelanchDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Relaunch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 89, 54, 244),
            ),
          ),
          content: const Text(
            'Are you sure you want to relaunch the quest ?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            // Confirm Button
            TextButton(
                onPressed: () {
                  _onRelanch();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFD4E8E1),
                  foregroundColor: const Color(0xFF45AA6E),
                ),
                child: const Text(
                  'Relaunch',
                  style: TextStyle(fontSize: 16),
                )),
          ],
        );
      },
    );
  }

  void showUpdateRelanchDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Upgrade your subcription plan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 89, 54, 244),
            ),
          ),
          content: const Text(
            "As per your current subscription plan, you can't relaunch the quest.Do you want to upgrade your subcription plan ? ",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            // Confirm Button
            TextButton(
                onPressed: () {
                  print({">>>>>>>>>>>>>>>>>>>>"});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Subcription()),
                  );
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => Subcription()));
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFD4E8E1),
                  foregroundColor: const Color(0xFF45AA6E),
                ),
                child: const Text(
                  'Upgrade',
                  style: TextStyle(fontSize: 16),
                )),
          ],
        );
      },
    );
  }

  void onItemTappedlist(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Description"),
          content: Text(description),
        );
      },
    );
  }

  void onItemlist(
      BuildContext context, String description, String titel, String gameImg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              gameImg.isNotEmpty
                  ? CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(gameImg),
                    )
                  : const CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          AssetImage('assets/images/defaultImg.jpg'),
                    ),
              const SizedBox(width: 10), // Adds spacing between image and title
              Expanded(
                child: Text(
                  titel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(description),
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const HomeScreen(userName: '', selectedTab: 1)),
          );
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
                          const HomeScreen(userName: '', selectedTab: 1)),
                );
              },
            ),
            title: const Text('Quest Details ',
                style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 22,
                    color: Color.fromRGBO(255, 255, 255, 1))),
            backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
            foregroundColor: Colors.white,
          ),
          body: Skeletonizer(
              enabled: _isLoading,
              enableSwitchAnimation: true,
              child: Center(
                child: Container(
                    padding: const EdgeInsets.only(top: 15),
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
                      padding: const EdgeInsets.all(16.0),
                      child: challenge.videofile != ''
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
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
                                    child: challenge.imageurl != ''
                                        ? ClipOval(
                                            child: Image.network(
                                              challenge.imageurl ?? '',
                                              fit: BoxFit.cover,
                                              width: 150,
                                              height: 150,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child; // Show the image when fully loaded
                                                }
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(), // Show a loader while the image is loading
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                    'assets/images/logo.jpg'); // Fallback for broken image
                                              },
                                            ),
                                          )
                                        : const CircleAvatar(
                                            radius: 75,
                                            backgroundImage: AssetImage(
                                                'assets/images/logo.jpg'),
                                          ),
                                  ),
                                  Text(
                                    challenge.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 22,
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    challenge.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF153792),
                                      fontSize: 14,
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  items.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Items :",
                                              style: TextStyle(
                                                color: Color(0xFF153792),
                                                fontSize: 18,
                                                fontFamily: 'Raleway',
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(
                                                height:
                                                    10), // Add some spacing after "Rules:"
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                              child: ListView.builder(
                                                // shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                // physics:
                                                //     const NeverScrollableScrollPhysics(), // Prevents ListView from scrolling independently
                                                itemCount: items.length,
                                                itemBuilder: (context, index) {
                                                  log("this is the item of the quest =>>>>>>>>>>>> ${items.map((i) => i.toJson())}");
                                                  dynamic newitem;

                                                  if (items[index].sequence !=
                                                          0 &&
                                                      items[index].sequence !=
                                                          null) {
                                                    newitem = items.firstWhere(
                                                      (item) =>
                                                          item.sequence ==
                                                          index + 1,
                                                      // orElse: () => null, // prevent error if not found
                                                    );
                                                  } else {
                                                    newitem = items[index];
                                                  }

                                                  return ListItem(
                                                      item: newitem,
                                                      // onItemTapped: onItemTapped,
                                                      onItemTappedlist:
                                                          onItemTappedlist

                                                      // title:
                                                      //     items[index].itemname ??
                                                      //         "",
                                                      // subtitle: items[index]
                                                      //         .description ??
                                                      //     "",
                                                      // imagePath:
                                                      //     items[index].imageurl ??
                                                      //         "",
                                                      // id: items[index].id,
                                                      // index: index,
                                                      // onItemTappedlist: onItemlist,
                                                      );
                                                },
                                              ),
                                            )
                                          ],
                                        )
                                      : const Center(
                                          child: Text(
                                            'No items found',
                                            style: TextStyle(
                                              color: Color(0xFF153792),
                                              fontSize: 18,
                                              fontFamily: 'Raleway',
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (checkStatus == 0)
                                    ElevatedButton(
                                        onPressed: () {
                                          enterChallenge();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 85, 126, 238),
                                          foregroundColor:
                                              const Color(0xFFFFFFFF),
                                          minimumSize:
                                              const Size(double.infinity, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text('Enter Quest')),
                                  if (isclone == 0)
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  if (checkStatus == 0 && isclone == 0)
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CreateChallenge1stPage(
                                                        gameId: challenge.id,
                                                        gameuniqueId: '',
                                                      )));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 85, 126, 238),
                                          foregroundColor:
                                              const Color(0xFFFFFFFF),
                                          minimumSize:
                                              const Size(double.infinity, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text('Edit Quest')),
                                  // Continue button for the challenge
                                  if (isclone == 0)
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  if (isclone == 0)
                                    ElevatedButton(
                                      onPressed: () {
                                        showQrcode();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 214, 208, 208),
                                        foregroundColor:
                                            const Color(0xFF0B00AB),
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text('Share'),
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (checkStatus == 1)
                                    videoMainFile.isNotEmpty
                                        ? videoMainFile == "removed"
                                            ? const Text(
                                                "Memory was deleted ",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      21, 55, 146, 1),
                                                ),
                                              )
                                            : ElevatedButton(
                                                onPressed: () {
                                                  String fullUrl =
                                                      "$baseUrl/${videoMainFile}";
                                                  _onDownloadVideo(
                                                      fullUrl, videoMainFile);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 85, 126, 238),
                                                  foregroundColor:
                                                      const Color(0xFFFFFFFF),
                                                  minimumSize: const Size(
                                                      double.infinity, 50),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                                child: const Text(
                                                    'Download Video'))
                                        : const Text(
                                            "Memory is being prepared and will be available in approximately 10 minutes.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(
                                                  21, 55, 146, 1),
                                            ),
                                          ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    children: [
                                      if (checkStatus == 1) ...[
                                        ElevatedButton(
                                          onPressed: () {
                                            onrelaunch();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFD4E8E1),
                                            foregroundColor:
                                                const Color(0xFF45AA6E),
                                            minimumSize:
                                                const Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: const Text('Relaunch'),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ],
                                  ),

                                  // if (checkStatus == 0)
                                  ElevatedButton(
                                      onPressed: () {
                                        onDelete();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 252, 251, 249),
                                        foregroundColor:
                                            const Color(0xFFFFFFFF),
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red))),
                                ])
                          : const Text(
                              "Memory is being prepared and will be available in approximately 10 minutes.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 55, 146, 1),
                              ),
                            ),
                    )),
              )),
        ));
  }
}

void _showImagePopup(BuildContext context, String imageUrl) {
  print({">>>>>item.uploadedimg", imageUrl});
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
                height: 300,
                width: 450,
                child: VideoWidget(url: vUrl, play: true)));
      });
}

typedef ItemTappedCallback = void Function(BuildContext context, int name);
typedef ItemTappedlistCallback = void Function(
    BuildContext context, String name);

class ListItem extends StatelessWidget {
  final ChallengeItem item;
  // final ItemTappedCallback onItemTapped;
  final ItemTappedlistCallback onItemTappedlist;

  const ListItem(
      {super.key,
      required this.item,
      // required this.onItemTapped,
      required this.onItemTappedlist});

  @override
  Widget build(BuildContext context) {
    bool isVideo = item.uploadedimg != null &&
        ((item.uploadedimg?.endsWith(".mp4") ?? false) ||
            (item.uploadedimg?.endsWith(".MOV") ?? false) ||
            (item.uploadedimg?.endsWith(".mov") ?? false));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              item.imageurl ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child; // Show the image when fully loaded
                }
                return const Center(
                  child:
                      CircularProgressIndicator(), // Show a loader while the image is loading
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/defaultImg.jpg',
                  width: 50,
                  height: 50,
                ); // Fallback for broken image
              },
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemname ?? '',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(21, 55, 146, 1.0),
                  ),
                ),
                Text(
                  item.description ?? '',
                  style: const TextStyle(
                    color: Color.fromRGBO(70, 81, 111, 1),
                    fontSize: 14.0,
                    height: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.description?.isNotEmpty ?? true)
                  GestureDetector(
                    onTap: () {
                      onItemTappedlist(context, item.description ?? '');
                    },
                    child: const Text(
                      "Show More",
                      style: TextStyle(
                        color: Color.fromRGBO(70, 81, 111, 1),
                        fontSize: 14.0,
                        height: 1,
                        decoration: TextDecoration
                            .underline, // Optional: underline for interactivity
                      ),
                    ),
                  ),
                const SizedBox(height: 4.0),
              ],
            ),
          ),
          // item.isUploading
          //     ? const CircularProgressIndicator()
          //     :
          item.uploadedimg == ''
              ? SizedBox()
              // IconButton(
              //     icon: const Image(
              //       image: AssetImage('assets/images/upload_ico.png'),
              //       height: 50,
              //       width: 50,
              //     ),
              //     onPressed: () {
              //       // Handle the upload button action
              //       //huntdash.getImage(ImageSource.gallery,item.id);
              //       //onImageSelected;
              //       // onItemTapped(context, item.id);
              //     },
              //   )
              : isVideo
                  ? GestureDetector(
                      onTap: () =>
                          _showVideoDialog(context, item.uploadedimg ?? ""),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          item.snapshot != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      item.snapshot), // Placeholder for video
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
                  : item.snapshot == null
                      ? SizedBox()
                      : GestureDetector(
                          onTap: () =>
                              _showImagePopup(context, item.uploadedimg ?? ""),
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(item.uploadedimg ?? ''),
                            radius: 30.0,
                          ),
                        ),
        ],
      ),
    );
  }
}
