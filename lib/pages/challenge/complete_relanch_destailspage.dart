import 'dart:async';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:scavenger_app/model/relanch.result.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/model/challenge.model.dart';
import 'package:scavenger_app/services/download.service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:scavenger_app/pages/challenge/create_step_one.page.dart';
import 'package:scavenger_app/pages/challenge/challenge_item_upload.page.dart';

class CompletedRelanchDetails extends StatefulWidget {
  final int challengeId;
  const CompletedRelanchDetails({super.key, required this.challengeId});

  @override
  _CompletedRelanchDetailsState createState() =>
      _CompletedRelanchDetailsState();
}

class _CompletedRelanchDetailsState extends State<CompletedRelanchDetails> {
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
          challenge = ChallengeModel.fromJson(res.response);
          _isLoading = false;
          items = challenge.items ?? [];
          log(items.map((i) => i.toJson()).toList().toString());
          checkStatus = challenge.status;
          gameName = challenge.name;
          qrCode = challenge.qrcode.replaceAll('data:image/png;base64,', '');
          OTP = challenge.otp;
          textEditingController.text = OTP.toString();
          videoMainFile = challenge.videofile ?? "";
          if (challenge.createdat != '') {
            challenge.createdat = DateFormat("MMM d, y 'at' h:mm a")
                .format(DateTime.parse(challenge.createdat));
          }
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
    try {
      final res =
          await ApiService.deleteChallenge({"challengeid": widget.challengeId});
      if (res.success) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                    userName: "userName",
                    gameId: widget.challengeId,
                    selectedTab: 1)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to delete : ${res.message ?? "Unknown error"}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {}
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
            'Are you sure you want to delete ths quest.',
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
                builder: (context) => const HomeScreen(
                      userName: '',
                      selectedTab: 1,
                    )),
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
                      builder: (context) => const HomeScreen(
                            userName: '',
                            selectedTab: 1,
                          )),
                );
              },
            ),
            title: const Text('Quest Details',
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
                        child: Column(
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
                                          "Items: ",
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
                                        ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          physics:
                                              const NeverScrollableScrollPhysics(), // Prevents ListView from scrolling independently
                                          itemCount: items.length,
                                          itemBuilder: (context, index) {
                                            dynamic newitem;
                                            if (items[index].sequence != null &&
                                                items[index].sequence != null) {
                                              newitem = items.firstWhere(
                                                (item) =>
                                                    item.sequence == index + 1,
                                                // orElse: () => null, // prevent error if not found
                                              );
                                            } else {
                                              newitem == items;
                                            }

                                            return ListItem(
                                              title:
                                                  newitem[index].itemname ?? "",
                                              subtitle:
                                                  newitem[index].description ??
                                                      "",
                                              imagePath:
                                                  items[index].imageurl ?? "",
                                              id: newitem[index].id,
                                              index: index,
                                            );
                                          },
                                        ),
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
                                      if (items.isEmpty) {
                                        Fluttertoast.showToast(
                                          msg:
                                              "Add items to the quest to continue",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChallengeItemUploadPage(
                                                      gameId: challenge.id,
                                                    )));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 85, 126, 238),
                                      foregroundColor: const Color(0xFFFFFFFF),
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text('Start Quest')),
                              const SizedBox(
                                height: 10,
                              ),
                              if (checkStatus == 0)
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
                                      foregroundColor: const Color(0xFFFFFFFF),
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text('Edit Quest')),
                              // Continue button for the challenge
                              const SizedBox(
                                height: 10,
                              ),
                              if (checkStatus == 0)
                                ElevatedButton(
                                    onPressed: () {
                                      showDeleteDialog(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 252, 251, 249),
                                      foregroundColor: const Color(0xFFFFFFFF),
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red))),
                            ]))),
              )),
        ));
  }
}

class ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final int id;
  final int index;

  const ListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.id,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16), // Adjust the radius as needed
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
        color: Colors.white,
        child: ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: ClipOval(
              child: Image.network(
                imagePath,
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
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(21, 55, 146, 1),
              overflow: TextOverflow.ellipsis,
              height: 1,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromRGBO(19, 49, 131, 1),
              fontWeight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
