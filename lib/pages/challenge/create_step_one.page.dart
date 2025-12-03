import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/custom_textfield.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/pages/subcriptions/subcription_popup.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/pages/challenge/challenge_item.page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scavenger_app/services/challengeStepper.service.dart';
import 'package:scavenger_app/services/crop.service.dart';
import 'package:scavenger_app/model/challenge.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateChallenge1stPage extends StatefulWidget {
  final int? gameId;
  final String? gameuniqueId;
  const CreateChallenge1stPage(
      {super.key, this.gameId = 0, this.gameuniqueId = ''});

  @override
  _CreateChallenge1stPageState createState() => _CreateChallenge1stPageState();
}

class _CreateChallenge1stPageState extends State<CreateChallenge1stPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;
  bool _isImageLoading = false;
  int gameId = 0;
  String gameuniqueId = '';
  String gameType = "challenge";
  File? galleryFile;
  final picker = ImagePicker();
  String gameImg = '';
  String assignFor = 'others';
  final List<String> assignList = <String>['Self', 'Others'];
  final int _maxLength = 35;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    if (widget.gameId != 0) {
      gameId = widget.gameId!;
      gameuniqueId = widget.gameuniqueId!;
      _gameDetails();
    }
    _nameController.addListener(() {
      setState(() {
        _currentLength = _nameController.text.length;
      });
    });
  }

  void _createGameClick() {
    if (widget.gameId != 0) {
      _updateChallenge();
    } else {
      _createChallenge();
    }
  }

  void _gameDetails() {
    ApiService.getChallengeDetails(gameId).then((value) {
      if (value.success) {
        var result = ChallengeModel.fromJson(value.response);
        setState(() {
          _nameController.text = result.name;
          _descController.text = result.description;
          gameImg = result.imageurl ?? '';
        });
      }
    });
  }

  Future<void> _createChallenge() async {
    final String name = _nameController.text;
    final String desc = _descController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter details to create a quest'),
      ));
      return;
    }
    setState(() {
      _isLoading = true;
    });
    ApiService.createChallenge({
      "name": name,
      "description": desc ?? "",
      "imageurl": gameImg,
    }).then((value) async {
      setState(() {
        _isLoading = false;
      });
      if (value.success) {
        final jsonResponseData = CreateChallengeResp.fromJson(value.response);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChallengeItemPage(
                    gameId: jsonResponseData.id, gameuniqueId: gameuniqueId)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Quest failed: ${value.message}'),
        ));
      }
    });
  }

  Future<void> _updateChallenge() async {
    final String name = _nameController.text;
    final String desc = _descController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter details to create a Quest'),
      ));
      return;
    }
    setState(() {
      _isLoading = true;
    });
    ApiService.updateChallenge({
      "challengeid": gameId,
      "name": name,
      "description": desc ?? "",
      "imageurl": gameImg,
    }).then((value) async {
      setState(() {
        _isLoading = false;
      });
      if (value.success) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChallengeItemPage(
                    gameId: gameId, gameuniqueId: gameuniqueId)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('hunt failed: ${value.message}'),
        ));
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
    setState(() {
      // _isLoading = true;
      _isImageLoading = true;
    });
    ApiService.uploadFile(galleryFile!.path).then((value) async {
      setState(() {
        _isImageLoading = false;
        // _isLoading = false;
      });
      if (value != '') {
        setState(() {
          gameImg = value;
        });
        print(gameImg);
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
            "You have not selected a image for this Quest ",
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
      gameImg == "" ? _showContinueDialog(context) : _createGameClick();
    } else {
      showSubscriptionModal(context);
    }
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
                  const HomeScreen(userName: "", selectedTab: 1),
            ),
          );
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const HomeScreen(userName: "", selectedTab: 1),
                  ),
                );
              },
            ),
            title: const Text("Create a Quest"),
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
                                  'Create a Quest                                     ',
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
                      const SizedBox(height: 0),
                      ChallengeStepperTabPage(activeStep: 0, totalStep: 5),
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
                          child: _isImageLoading
                              ? const Center(child: CircularProgressIndicator())
                              : Align(
                                  alignment: Alignment.center,
                                  child: Container(
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
                                        // borderRadius:
                                        //     BorderRadius.circular(50.0),
                                        child: gameImg == ''
                                            ? const Icon(
                                                size: 50,
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                color: Colors.black,
                                              )
                                            : Image.network(
                                                gameImg,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (BuildContext
                                                        context,
                                                    Object exception,
                                                    StackTrace? stackTrace) {
                                                  return const Icon(
                                                    Icons
                                                        .add_photo_alternate_outlined,
                                                    color: Colors.black,
                                                  );
                                                },
                                                loadingBuilder:
                                                    (BuildContext context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  } else {
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  }
                                                },
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
                        labelText: 'Quest Title:',
                        hintText: 'Enter your quest title',
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
                        labelText: 'Quest Description:',
                        hintText: 'Enter your quest Description:',
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
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
