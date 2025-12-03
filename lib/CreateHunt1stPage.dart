import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:scavenger_app/CreateHunt2ndPage.dart';
import 'package:scavenger_app/GameStepStartResponse.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/pages/subcriptions/subcription_popup.dart';
import 'package:scavenger_app/services/crop.service.dart';
import 'package:scavenger_app/services/stepper.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_textfield.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/gameUpdate.model.dart';
import 'package:scavenger_app/HomeScreen.dart';

class CreateHunt1stPage extends StatefulWidget {
  final int? gameId;
  final String? gameuniqueId;
  const CreateHunt1stPage({super.key, this.gameId = 0, this.gameuniqueId = ''});

  @override
  _CreateHunt1stPageState createState() => _CreateHunt1stPageState();
}

class _CreateHunt1stPageState extends State<CreateHunt1stPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;
  bool _isImageLoading = false;
  int gameId = 0;
  String gameuniqueId = '';
  File? galleryFile;
  final picker = ImagePicker();
  String gameImg = '';
  final dashImages = [
    'assets/images/accept.png',
    'assets/images/accept.png',
    'assets/images/accept.png',
    'assets/images/accept.png',
    'assets/images/accept.png',
  ];
  int activeStep = 0;
  final int _maxLength = 35;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();

    log("create hunt page call ${widget.gameId}");
    if (widget.gameId != 0) {
      gameId = widget.gameId!;
      gameuniqueId = widget.gameuniqueId!;
      _gameDetails();
    }
    _nameController.addListener(() {
      if (mounted)
        setState(() {
          _currentLength = _nameController.text.length;
        });
    });
  }

  void _gameDetails() {
    if (mounted)
      setState(() {
        _isLoading = true;
      });
    ApiService.gameDetails(gameId).then((value) {
      try {
        if (value.success) {
          var result = GameStep1.fromJson(value.response);

          log("this is the game details fo the hunt >>>>>>>>>> ${value.response}");
          if (mounted)
            setState(() {
              _nameController.text = result.title ?? '';
              _descController.text = result.description ?? '';
              gameImg = result.gameImg ?? '';
            });
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

  void _createGameClick() {
    if (widget.gameId != 0 || gameId != 0) {
      if (gameId == 0) {
        gameId = widget.gameId!;
        gameuniqueId = widget.gameuniqueId!;
      }
      _createGame1();
    } else {
      _createGame0();
    }
  }

  Future<void> _createGame0() async {
    final String name = _nameController.text;
    final String desc = _descController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter details to create a hunt'),
      ));
      return;
    }
    if (mounted)
      setState(() {
        _isLoading = true;
      });
    ApiService.initiateGameCreate().then((value) {
      if (value.success) {
        final jsonResponseData = Result.fromJson(value.response);
        gameId = jsonResponseData.game.id;
        gameuniqueId = jsonResponseData.game.gameId;
        _createGame1();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('hunt failed: ${value.message}'),
        ));
      }
    });
  }

  Future<void> _createGame1() async {
    final String name = _nameController.text;
    final String desc = _descController.text ?? "";
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter details to create a hunt'),
      ));
      return;
    }
    if (mounted)
      setState(() {
        _isLoading = true;
      });
    var reqData = {
      "id": gameId,
      "title": name,
      "description": desc ?? "",
      "game_img": gameImg,
      "game_type": "hunt"
    };

    ApiService.updateGameTitle(reqData).then((value) {
      try {
        if (value.success) {
          // final jsonResponseData = CreateHuntResponse.fromJson(value.response);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateHunt2ndPage(
                      gameId: gameId, gameuniqueId: gameuniqueId)));
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

  Future<void> _uploadImage() async {
    if (galleryFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select an image to upload'),
      ));
      return;
    }
    if (mounted)
      setState(() {
        // _isLoading = true;
        _isImageLoading = true;
      });
    ApiService.uploadFile(galleryFile!.path).then((value) async {
      if (mounted)
        setState(() {
          // _isLoading = false;
          _isImageLoading = false;
        });
      if (value != '') {
        if (mounted)
          setState(() {
            gameImg = value;
          });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Image upload failed'),
        ));
      }
    });
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img, imageQuality: 25);
    final cropImgData =
        await CropImageService.cropImage(pickedFile, cropStyle: 'square');
    if (mounted)
      setState(
        () {
          if (cropImgData != null) {
            galleryFile = File(cropImgData!.path);
            _uploadImage();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
                const SnackBar(content: Text('Nothing is selected')));
          }
        },
      );
  }

  void _showContinueDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            "You have not selected a image for this Hunt ",
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Upload Hunt Image',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildUploadOption(
                                    icon: Icons.camera_alt,
                                    label: 'Camera',
                                    onTap: () {
                                      // Handle Camera option
                                      getImage(ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  _buildUploadOption(
                                    icon: Icons.photo,
                                    label: 'Gallery',
                                    onTap: () {
                                      getImage(ImageSource.gallery);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ));
                  },
                );
                // Close the dialog
              },
              child: const Text("Add image now"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createGameClick(); // Close the dialog
              },
              child: const Text("Continue without image"),
            ),
          ],
        );
      },
    );
  }

  void _onNextPage() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? subcriptionCheckString = prefs.getString('subscription_Check');
    // PolicyResult? tempSubcriptionCheckNo;
    // if (subcriptionCheckString != null && subcriptionCheckString.isNotEmpty) {
    //   try {
    //     Map<String, dynamic> decodedJson = jsonDecode(subcriptionCheckString);
    //     tempSubcriptionCheckNo = PolicyResult.fromJson(decodedJson);
    //   } catch (e) {
    //     tempSubcriptionCheckNo = null;
    //   }
    // } else {
    //   tempSubcriptionCheckNo = null;
    // }
    // if (tempSubcriptionCheckNo != null) {
    gameImg == '' ? _showContinueDialog(context) : _createGameClick();
    // } else {
    //   showSubscriptionModal(context);
    // }
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
                    builder: (context) => const HomeScreen(userName: ""),
                  ),
                );
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
                        'assets/images/1 1.png',
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
                          activeStep: 0, totalStep: 6, gameId: gameId),
                      const SizedBox(height: 20),
                      GestureDetector(
                          onTap: () {
                            //Navigator.of(context).pop();
                            // getImage(ImageSource.gallery);
                            showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                    height: 200,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Upload Quest Image',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildUploadOption(
                                                icon: Icons.camera_alt,
                                                label: 'Camera',
                                                onTap: () {
                                                  // Handle Camera option
                                                  getImage(ImageSource.camera);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              _buildUploadOption(
                                                icon: Icons.photo,
                                                label: 'Gallery',
                                                onTap: () {
                                                  getImage(ImageSource.gallery);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ));
                              },
                            );
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: _isImageLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        // borderRadius:
                                        //     BorderRadius.circular(100),
                                        border: Border.all(
                                            width: 2,
                                            color: const Color.fromARGB(
                                                255, 27, 56, 150))),
                                    child: ClipRRect(
                                      // borderRadius: BorderRadius.circular(radius),
                                      child: gameImg == ''
                                          ? const Icon(
                                              size: 50,
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              color: Colors.black,
                                            )
                                          : Image(
                                              image: NetworkImage(gameImg),
                                              height: 50,
                                              width: 50,
                                            ),
                                    )),
                          )),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "Cover Photo",
                          style: TextStyle(
                            color: Color(0xFF153792),
                            fontSize: 16,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Hunt Title:',
                        hintText: 'Enter your hunt title',
                        maxLines: 1,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(_maxLength),
                        ],
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '$_currentLength/$_maxLength',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _descController,
                        labelText: 'Hunt Description:',
                        hintText: 'Enter your hunt Description:',
                        maxLines: 4,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(500),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () {
                                _onNextPage();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF153792),
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
        ));
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
}
